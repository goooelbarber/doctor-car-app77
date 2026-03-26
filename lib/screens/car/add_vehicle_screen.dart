// 📁 lib/screens/car/add_vehicle_screen.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final plateCtrl = TextEditingController();
  final chassisCtrl = TextEditingController();

  List<dynamic> brands = [];
  List<String> models = [];
  List<String> years = [];

  String? selectedBrand;
  String? selectedModel;
  String? selectedYear;
  String? selectedFuel;
  String? selectedCondition;
  String? selectedColor;

  bool loadingBrands = false;
  bool loadingModels = false;
  bool loadingYears = false;
  bool saving = false;

  final fuelTypes = const ["بنزين", "ديزل", "هايبرد", "كهرباء"];
  final conditions = const ["ممتازة", "جيدة جدًا", "جيدة", "تحتاج صيانة"];
  final colors = const [
    "أبيض",
    "أسود",
    "فضي",
    "رمادي",
    "أزرق",
    "أحمر",
    "ذهبي",
  ];

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  Color get _bg => AppTheme.bgEnd;
  Color get _surface => const Color(0xFF10233E);
  Color get _surface2 => const Color(0xFF17345F);
  Color get _surface3 => const Color(0xFF0D2140);

  Color get _textMain => AppTheme.textLight;
  Color get _textSub => AppTheme.muted;

  Color get _border => Colors.white.withOpacity(.10);
  Color get _primary => AppTheme.accent;
  Color get _danger => AppTheme.danger;

  LinearGradient get _pageGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF081A36),
          Color(0xFF122B50),
          Color(0xFF040D1D),
        ],
      );

  LinearGradient get _headerGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1D4F99),
          Color(0xFF163F7E),
          Color(0xFF0E2D60),
        ],
      );

  LinearGradient get _primaryGradient => AppTheme.ctaAquaGradient;

  List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.24),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get _strongGlow => [
        BoxShadow(
          color: _primary.withOpacity(.18),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(.20),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _loadBrands();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: .985, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    plateCtrl.dispose();
    chassisCtrl.dispose();
    super.dispose();
  }

  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
  }

  void _showMessage(String msg, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? _danger : _surface2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _loadBrands() async {
    if (!mounted) return;
    setState(() => loadingBrands = true);

    try {
      final list = await ApiService.getCarBrands();

      // ignore: unnecessary_type_check
      if (list is List) {
        if (list.isNotEmpty && list.first is Map) {
          brands = list;
        } else {
          brands = list.map((e) => {"name": e.toString()}).toList();
        }
      } else {
        brands = [];
      }
    } catch (_) {
      brands = [];
      if (!mounted) return;
      _showMessage("تعذر تحميل الماركات", error: true);
    } finally {
      if (!mounted) return;
      setState(() => loadingBrands = false);
    }
  }

  Future<void> _loadModels() async {
    if (selectedBrand == null || selectedBrand!.isEmpty) return;

    if (!mounted) return;
    setState(() {
      loadingModels = true;
      models = [];
      years = [];
      selectedModel = null;
      selectedYear = null;
    });

    try {
      final list = await ApiService.getModelsByBrand(selectedBrand!);
      models = List<String>.from(list.map((e) => e.toString()));
    } catch (_) {
      models = [];
    } finally {
      if (!mounted) return;
      setState(() => loadingModels = false);
    }
  }

  Future<void> _loadYears() async {
    if (selectedBrand == null ||
        selectedBrand!.isEmpty ||
        selectedModel == null ||
        selectedModel!.isEmpty) {
      return;
    }

    if (!mounted) return;
    setState(() {
      loadingYears = true;
      years = [];
      selectedYear = null;
    });

    try {
      final list = await ApiService.getYears(selectedBrand!, selectedModel!);
      years = List<String>.from(list.map((e) => e.toString()));
    } catch (_) {
      years = [];
    } finally {
      if (!mounted) return;
      setState(() => loadingYears = false);
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedBrand == null ||
        selectedModel == null ||
        selectedYear == null ||
        selectedFuel == null ||
        selectedCondition == null ||
        selectedColor == null) {
      _showMessage("⚠️ برجاء استكمال كل البيانات", error: true);
      return;
    }

    if (!mounted) return;
    setState(() => saving = true);

    try {
      final res = await ApiService.addVehicle(
        brand: selectedBrand!,
        model: selectedModel!,
        fuel: selectedFuel!,
        condition: selectedCondition!,
        plateNumber: plateCtrl.text.trim(),
        year: selectedYear!,
        color: selectedColor!,
        chassisNumber: chassisCtrl.text.trim(),
      );

      if (!mounted) return;

      if (res["error"] == true || res["success"] == false) {
        _showMessage(
          res["message"]?.toString() ?? "فشل إضافة المركبة",
          error: true,
        );
        return;
      }

      _showMessage("🚗 تم إضافة المركبة بنجاح");
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      _showMessage("تعذر الاتصال بالسيرفر", error: true);
    } finally {
      if (!mounted) return;
      setState(() => saving = false);
    }
  }

  double _completionProgress() {
    int filled = 0;

    if (selectedBrand != null) filled++;
    if (selectedModel != null) filled++;
    if (selectedYear != null) filled++;
    if (selectedFuel != null) filled++;
    if (selectedCondition != null) filled++;
    if (selectedColor != null) filled++;
    if (plateCtrl.text.trim().isNotEmpty) filled++;
    if (chassisCtrl.text.trim().isNotEmpty) filled++;

    return filled / 8;
  }

  Widget _bgOrb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(22)),
    bool withGlow = false,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: borderRadius,
        border: Border.all(color: _border),
        boxShadow: withGlow ? _strongGlow : _cardShadow,
      ),
      child: child,
    );
  }

  Widget _iconBadge(
    IconData icon, {
    double size = 54,
    double iconSize = 24,
    bool light = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: light
            ? LinearGradient(
                colors: [
                  Colors.white.withOpacity(.22),
                  Colors.white.withOpacity(.14),
                ],
              )
            : _primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (light ? Colors.white : _primary).withOpacity(.20),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            gradient: _primaryGradient,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _textMain,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputStyle(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: _textSub.withOpacity(.70),
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: _primary),
      filled: true,
      fillColor: _surface3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _danger.withOpacity(.7)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _danger, width: 1.4),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required bool isLoading,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _textMain,
            fontSize: 14.8,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: (value != null && items.contains(value)) ? value : null,
          dropdownColor: _surface2,
          decoration: _inputStyle(label, icon),
          style: TextStyle(
            color: _textMain,
            fontWeight: FontWeight.w800,
          ),
          iconEnabledColor: _primary,
          items: isLoading
              ? const []
              : items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(color: _textMain),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: isLoading ? null : onChanged,
          validator: (v) => v == null ? "مطلوب" : null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _textField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _textMain,
            fontSize: 14.8,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: _textMain,
            fontWeight: FontWeight.w800,
          ),
          decoration: _inputStyle(label, icon),
          validator: (v) => (v == null || v.trim().isEmpty) ? "مطلوب" : null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _progressCard() {
    final progress = _completionProgress();
    final percent = (progress * 100).round();

    return _card(
      withGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: _primaryGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "اكتمال البيانات",
                style: TextStyle(
                  color: _textMain,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 10),
              _iconBadge(Icons.fact_check_rounded, size: 46, iconSize: 21),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(_primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "استكمل جميع الحقول لإضافة المركبة بنجاح.",
            style: TextStyle(
              color: _textSub,
              fontWeight: FontWeight.w700,
              fontSize: 12.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintCard() {
    return _card(
      child: Row(
        children: [
          _iconBadge(Icons.tips_and_updates_rounded, size: 46, iconSize: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "اختر الماركة أولًا ثم الموديل ثم سنة الصنع، وبعدها أكمل بقية بيانات المركبة.",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _textSub,
                fontWeight: FontWeight.w700,
                fontSize: 12.8,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctaButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: saving ? null : _primaryGradient,
          color: saving ? _surface2 : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: saving ? _cardShadow : _strongGlow,
        ),
        child: ElevatedButton.icon(
          onPressed: saving ? null : () => _tap(_saveVehicle),
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                ),
          label: Text(
            saving ? "جاري الحفظ..." : "إضافة المركبة",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brandNames = brands
        .map((e) => (e is Map ? e["name"] : e).toString())
        .where((x) => x.trim().isNotEmpty)
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: _pageGradient)),
            Positioned(
              top: -50,
              right: -40,
              child: _bgOrb(170, _primary.withOpacity(.13)),
            ),
            Positioned(
              bottom: -70,
              left: -50,
              child: _bgOrb(160, Colors.white.withOpacity(.04)),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                          decoration: BoxDecoration(
                            gradient: _headerGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: _strongGlow,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          "إضافة مركبة",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 21,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "أضف مركبتك وابدأ إدارة بياناتها بسهولة",
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(.82),
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _iconBadge(
                                    Icons.directions_car_filled_rounded,
                                    size: 46,
                                    iconSize: 20,
                                    light: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _progressCard(),
                        const SizedBox(height: 14),
                        _hintCard(),
                        const SizedBox(height: 18),
                        _card(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _sectionTitle("بيانات المركبة"),
                                const SizedBox(height: 14),
                                _dropdown(
                                  label: "الماركة",
                                  icon: FontAwesomeIcons.car,
                                  value: selectedBrand,
                                  items: brandNames,
                                  isLoading: loadingBrands,
                                  onChanged: (v) async {
                                    selectedBrand = v;
                                    selectedModel = null;
                                    selectedYear = null;
                                    await _loadModels();
                                    if (mounted) setState(() {});
                                  },
                                ),
                                if (selectedBrand != null)
                                  _dropdown(
                                    label: "الموديل",
                                    icon: FontAwesomeIcons.gear,
                                    value: selectedModel,
                                    items: models,
                                    isLoading: loadingModels,
                                    onChanged: (v) async {
                                      selectedModel = v;
                                      selectedYear = null;
                                      await _loadYears();
                                      if (mounted) setState(() {});
                                    },
                                  ),
                                if (selectedModel != null)
                                  _dropdown(
                                    label: "سنة الصنع",
                                    icon: FontAwesomeIcons.calendar,
                                    value: selectedYear,
                                    items: years,
                                    isLoading: loadingYears,
                                    onChanged: (v) =>
                                        setState(() => selectedYear = v),
                                  ),
                                _dropdown(
                                  label: "نوع الوقود",
                                  icon: FontAwesomeIcons.gasPump,
                                  value: selectedFuel,
                                  items: fuelTypes,
                                  isLoading: false,
                                  onChanged: (v) =>
                                      setState(() => selectedFuel = v),
                                ),
                                _dropdown(
                                  label: "الحالة",
                                  icon: FontAwesomeIcons.screwdriverWrench,
                                  value: selectedCondition,
                                  items: conditions,
                                  isLoading: false,
                                  onChanged: (v) =>
                                      setState(() => selectedCondition = v),
                                ),
                                _dropdown(
                                  label: "اللون",
                                  icon: FontAwesomeIcons.palette,
                                  value: selectedColor,
                                  items: colors,
                                  isLoading: false,
                                  onChanged: (v) =>
                                      setState(() => selectedColor = v),
                                ),
                                _sectionTitle("بيانات إضافية"),
                                const SizedBox(height: 14),
                                _textField(
                                  label: "رقم اللوحة",
                                  icon: FontAwesomeIcons.idCard,
                                  controller: plateCtrl,
                                ),
                                _textField(
                                  label: "رقم الهيكل (الشاصي)",
                                  icon: FontAwesomeIcons.carBurst,
                                  controller: chassisCtrl,
                                ),
                                const SizedBox(height: 8),
                                _ctaButton(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
