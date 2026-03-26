import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../car/add_vehicle_screen.dart';
import '../car/edit_car_screen.dart';
import 'car_dashboard_screen.dart';

class VehiclesScreen extends StatefulWidget {
  final bool selectMode;

  const VehiclesScreen({super.key, this.selectMode = false});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> vehicles = [];
  bool loading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

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
    _fetchVehicles();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: .985, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _searchController.addListener(() {
      setState(
          () => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _surface2,
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

  Future<void> _fetchVehicles() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final res = await ApiService.getVehicles();
      if (!mounted) return;

      setState(() {
        vehicles = res;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
      _showMessage("تعذر تحميل المركبات");
    }
  }

  Future<void> _goToAddCar() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
    );

    if (added == true) {
      await _fetchVehicles();
    }
  }

  Future<void> _goToEditCar(Map<String, dynamic> car) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditVehicleScreen(vehicle: car),
      ),
    );

    if (updated == true) {
      await _fetchVehicles();
    }
  }

  Future<void> _deleteVehicle(String id) async {
    if (id.trim().isEmpty) {
      _showMessage("معرّف المركبة غير صحيح");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            "تأكيد الحذف",
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            "هل تريد حذف هذه المركبة؟",
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _textSub,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "إلغاء",
                style: TextStyle(
                  color: _textSub,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "حذف",
                style: TextStyle(
                  color: _danger,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    try {
      final res = await ApiService.deleteVehicle(id);
      if (!mounted) return;

      if (res["success"] == true) {
        _showMessage("🚗 تم حذف المركبة");
        await _fetchVehicles();
      } else {
        _showMessage(res["message"]?.toString() ?? "فشل حذف المركبة");
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage("تعذر الاتصال بالسيرفر");
    }
  }

  List<Map<String, dynamic>> get _filteredVehicles {
    final list = vehicles
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return list.where((car) {
      final brand = (car["brand"] ?? "").toString().toLowerCase();
      final model = (car["model"] ?? "").toString().toLowerCase();
      final plate = (car["plateNumber"] ?? "").toString().toLowerCase();
      final condition = (car["condition"] ?? "").toString().toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          brand.contains(_searchQuery) ||
          model.contains(_searchQuery) ||
          plate.contains(_searchQuery);

      final matchesFilter =
          _selectedFilter == 'all' || condition.contains(_selectedFilter);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Color _statusColor(String value) {
    final v = value.trim().toLowerCase();

    if (v.contains("ممتاز") || v.contains("excellent")) {
      return const Color(0xFF3FAE72);
    }
    if (v.contains("جيد") || v.contains("good")) {
      return Colors.orangeAccent;
    }
    if (v.contains("ضعيف") || v.contains("poor")) {
      return Colors.redAccent;
    }
    return _primary;
  }

  Widget _statusBadge(String value) {
    final color = _statusColor(value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.28)),
      ),
      child: Text(
        value.isEmpty ? "غير محدد" : value,
        style: TextStyle(
          color: color,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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

  Widget _header() {
    return Container(
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
              if (Navigator.canPop(context))
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: Colors.white,
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.selectMode ? "اختيار مركبة" : "مركباتي",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.selectMode
                          ? "اختر المركبة المناسبة للخدمة"
                          : "إدارة المركبات الخاصة بك بسهولة",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.82),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _fetchVehicles,
                icon: const Icon(Icons.refresh_rounded),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  icon: Icons.directions_car_filled_rounded,
                  value: '${vehicles.length}',
                  label: 'إجمالي المركبات',
                  darkCard: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  icon: Icons.verified_rounded,
                  value: '${_filteredVehicles.length}',
                  label: 'نتيجة حالية',
                  darkCard: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String value,
    required String label,
    bool darkCard = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: darkCard ? Colors.white.withOpacity(.10) : _surface2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: darkCard ? Colors.white.withOpacity(.12) : _border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: darkCard
                  ? Colors.white.withOpacity(.12)
                  : _primary.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.80),
                    fontSize: 11.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchAndFilters() {
    return Column(
      children: [
        _card(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: _primary),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو الموديل أو اللوحة',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: _textSub.withOpacity(.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextStyle(
                    color: _textMain,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  onPressed: () => _searchController.clear(),
                  icon: Icon(Icons.close_rounded, color: _textSub),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _filterChip('all', 'الكل'),
              _filterChip('ممتاز', 'ممتاز'),
              _filterChip('جيد', 'جيد'),
              _filterChip('ضعيف', 'ضعيف'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        onSelected: (_) => setState(() => _selectedFilter = value),
        selectedColor: _primary,
        backgroundColor: _surface2,
        side: BorderSide(color: selected ? _primary : _border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  Widget _hintBar() {
    return _card(
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.selectMode
                  ? "اختر المركبة المناسبة وسيتم إرجاعها للشاشة السابقة مباشرة."
                  : "يمكنك إضافة أو تعديل أو حذف المركبات، واضغط على أي بطاقة لعرض التفاصيل.",
              style: TextStyle(
                color: _textSub,
                fontSize: 13.2,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: icon == null
              ? const SizedBox.shrink()
              : Icon(icon, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dataRow({
    required String label,
    required dynamic value,
    IconData? icon,
  }) {
    final txt =
        value?.toString().trim().isNotEmpty == true ? value.toString() : "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: _surface3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: _primary),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              txt,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _textMain,
                fontSize: 14.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: _textSub,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: _card(
          withGlow: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconBadge(Icons.directions_car_rounded, size: 84, iconSize: 38),
              const SizedBox(height: 16),
              Text(
                "لا توجد مركبات حالياً",
                style: TextStyle(
                  color: _textMain,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.selectMode
                    ? "أضف مركبة جديدة أولاً حتى تتمكن من اختيارها."
                    : "ابدأ الآن بإضافة أول مركبة لك وإدارة بياناتها بسهولة.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSub,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              _actionButton(
                label: widget.selectMode
                    ? "إضافة مركبة ثم اختيارها"
                    : "إضافة مركبة",
                icon: Icons.add_rounded,
                onTap: _goToAddCar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget vehicleCard(Map<String, dynamic> car) {
    final brand = (car["brand"] ?? "بدون اسم").toString();
    final model = car["model"];
    final color = car["color"];
    final plate = car["plateNumber"];
    final condition = (car["condition"] ?? "غير محدد").toString();
    final id = (car["_id"] ?? "").toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          if (widget.selectMode) {
            Navigator.pop(context, car);
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CarDashboardScreen(vehicle: car),
            ),
          );
        },
        child: _card(
          borderRadius: BorderRadius.circular(26),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  if (widget.selectMode)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: _primaryGradient,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        "اختيار",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      brand,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _textMain,
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _iconBadge(FontAwesomeIcons.carSide, size: 48, iconSize: 20),
                ],
              ),
              const SizedBox(height: 14),
              _dataRow(
                label: "الموديل",
                value: model,
                icon: Icons.directions_car_filled_rounded,
              ),
              _dataRow(
                label: "اللون",
                value: color,
                icon: Icons.palette_outlined,
              ),
              _dataRow(
                label: "اللوحة",
                value: plate,
                icon: Icons.pin_outlined,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _statusBadge(condition),
                  const Spacer(),
                  Text(
                    "الحالة",
                    style: TextStyle(
                      color: _textSub,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (!widget.selectMode) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _goToEditCar(car),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text("تعديل"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: _border),
                          backgroundColor: _surface2,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteVehicle(id),
                        icon:
                            const Icon(Icons.delete_forever_rounded, size: 18),
                        label: const Text("حذف"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _danger,
                          side: BorderSide(color: _danger.withOpacity(.34)),
                          backgroundColor: _danger.withOpacity(.06),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    if (vehicles.isEmpty) {
      return _emptyView();
    }

    if (_filteredVehicles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, color: _primary, size: 54),
                const SizedBox(height: 12),
                Text(
                  "لا توجد نتائج مطابقة",
                  style: TextStyle(
                    color: _textMain,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "جرّب تغيير البحث أو الفلترة",
                  style: TextStyle(
                    color: _textSub,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _primary,
      backgroundColor: _surface,
      onRefresh: _fetchVehicles,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        itemCount: _filteredVehicles.length,
        itemBuilder: (_, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: vehicleCard(_filteredVehicles[i]),
          );
        },
      ),
    );
  }

  Widget _bottomAddBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: _card(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.all(12),
        child: _actionButton(
          onTap: _goToAddCar,
          label: widget.selectMode ? "إضافة مركبة جديدة" : "إضافة مركبة",
          icon: Icons.add_rounded,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Column(
                          children: [
                            _header(),
                            const SizedBox(height: 12),
                            _hintBar(),
                            const SizedBox(height: 12),
                            _searchAndFilters(),
                          ],
                        ),
                      ),
                      Expanded(child: _body()),
                      _bottomAddBar(),
                    ],
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
