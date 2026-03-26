import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

enum PaymentMethod { cash, card, wallet }

class ConfirmRequestArgs {
  final String serviceType;
  final String userId;
  final List<String> selectedServices;

  final double lat;
  final double lng;
  final String? address;

  /// ✅ المركبة المختارة (Dynamic عشان ما نكسرش أي موديل)
  final dynamic vehicle;

  const ConfirmRequestArgs({
    required this.serviceType,
    required this.userId,
    required this.selectedServices,
    required this.lat,
    required this.lng,
    this.address,
    this.vehicle,
  });
}

class ConfirmRequestResult {
  final PaymentMethod paymentMethod;
  final String notes;

  /// ✅ رجّع المركبة المختارة كمان
  final dynamic vehicle;

  const ConfirmRequestResult({
    required this.paymentMethod,
    required this.notes,
    this.vehicle,
  });
}

class ConfirmRequestScreen extends StatefulWidget {
  final ConfirmRequestArgs args;

  const ConfirmRequestScreen({super.key, required this.args});

  @override
  State<ConfirmRequestScreen> createState() => _ConfirmRequestScreenState();
}

class _ConfirmRequestScreenState extends State<ConfirmRequestScreen> {
  // ===== Brand Tokens (DoctorCar Dark Blue) =====
  static const Color _bg1 = Color(0xFF081A36);
  // ignore: unused_field
  static const Color _bg2 = Color(0xFF0B2348);
  static const Color _bg3 = Color(0xFF040D1D);

  static const Color _brand = Color(0xFF1B4F9C);

  Color get _brand2 => Color.lerp(_brand, const Color(0xFF040D1D), 0.22)!;
  Color get _brand3 => Color.lerp(_brand, Colors.white, 0.12)!;

  Color get _stroke => Colors.white.withOpacity(.12);
  Color get _textMain => Colors.white;
  Color get _textSub => Colors.white.withOpacity(.78);

  LinearGradient get _screenBg => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_bg1, Color.lerp(_bg1, _brand2, .07)!, _bg3],
      );

  /// ✅ Dark blue primary gradient
  LinearGradient get _bluePrimary => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF1B4F99),
          Color(0xFF245AA6),
          Color(0xFF153F78),
        ],
        stops: [0.0, 0.56, 1.0],
      );

  LinearGradient get _glass => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(.09),
          Colors.white.withOpacity(.06),
          Colors.white.withOpacity(.04),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  List<BoxShadow> get _shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(.22),
          blurRadius: 16,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get _blueGlow => [
        BoxShadow(
          color: _brand.withOpacity(.22),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(.20),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  // ===== State =====
  PaymentMethod _payment = PaymentMethod.cash;
  final TextEditingController _notes = TextEditingController();
  final FocusNode _notesFocus = FocusNode();
  bool _sending = false;

  static const int _notesMax = 160;

  // ✅ vehicle state
  dynamic _vehicle;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.args.vehicle;

    _notesFocus.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _notes.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
  }

  String _paymentLabel(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash:
        return "كاش";
      case PaymentMethod.card:
        return "بطاقة";
      case PaymentMethod.wallet:
        return "محفظة";
    }
  }

  IconData _paymentIcon(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash:
        return Icons.payments_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تعذر فتح خرائط جوجل",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(),
          ),
        ),
      );
    }
  }

  // ✅ استخراج بيانات العربية بشكل آمن
  String _v(dynamic v, String key) {
    if (v == null) return "-";
    if (v is Map) return (v[key] ?? "-").toString();
    return "-";
  }

  String get _vehicleTitle {
    final brand = _v(_vehicle, "brand");
    final model = _v(_vehicle, "model");
    final year = _v(_vehicle, "year");
    if (brand == "-" && model == "-") return "لم يتم اختيار مركبة";
    final y = (year != "-" && year.trim().isNotEmpty) ? " • $year" : "";
    return "$brand $model$y";
  }

  Future<void> _confirm() async {
    if (_sending) return;
    HapticFeedback.mediumImpact();
    setState(() => _sending = true);

    final result = ConfirmRequestResult(
      paymentMethod: _payment,
      notes: _notes.text.trim(),
      vehicle: _vehicle,
    );

    if (mounted) Navigator.pop(context, result);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.args;
    final coords = "${a.lat.toStringAsFixed(5)} , ${a.lng.toStringAsFixed(5)}";

    final mq = MediaQuery.of(context);
    final scale = mq.textScaler.scale(1.0);
    final clamped = scale.clamp(1.0, 1.12);
    final fixedMq = mq.copyWith(textScaler: TextScaler.linear(clamped));

    final addressText = (a.address != null && a.address!.trim().isNotEmpty)
        ? a.address!.trim()
        : coords;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return MediaQuery(
      data: fixedMq,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _bg1,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              Container(decoration: BoxDecoration(gradient: _screenBg)),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _glassCard(
                              child: Row(
                                children: [
                                  _iconBadge(Icons.directions_car_rounded),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "المركبة المختارة",
                                          style: GoogleFonts.cairo(
                                            color: _textMain,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15.5,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _vehicleTitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cairo(
                                            color: _textSub,
                                            fontSize: 13.2,
                                            fontWeight: FontWeight.w700,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            _miniTag(
                                                "اللوحة: ${_v(_vehicle, "plateNumber")}"),
                                            const SizedBox(width: 8),
                                            _miniTag(
                                                "اللون: ${_v(_vehicle, "color")}"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      "تعديل",
                                      style: GoogleFonts.cairo(
                                        color: _brand3,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _glassCard(
                              child: Row(
                                children: [
                                  _iconBadge(Icons.location_on_rounded),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "الموقع المختار",
                                          style: GoogleFonts.cairo(
                                            color: _textMain,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15.5,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          addressText,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cairo(
                                            color: _textSub,
                                            fontSize: 13.2,
                                            fontWeight: FontWeight.w700,
                                            height: 1.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      "تعديل",
                                      style: GoogleFonts.cairo(
                                        color: _brand3,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _miniMapPreview(
                              lat: a.lat,
                              lng: a.lng,
                              title: (a.address != null &&
                                      a.address!.trim().isNotEmpty)
                                  ? "فتح على الخريطة"
                                  : "عرض على الخريطة",
                              onTap: () => _openMaps(a.lat, a.lng),
                            ),
                            const SizedBox(height: 12),
                            _glassCard(
                              child: Row(
                                children: [
                                  _iconBadge(Icons.build_circle_rounded),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "الخدمة: ${a.serviceType}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.cairo(
                                        color: _textMain,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _glassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "طريقة الدفع",
                                    style: GoogleFonts.cairo(
                                      color: _textMain,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: PaymentMethod.values.map((m) {
                                      final selected = _payment == m;
                                      return _paymentChip(
                                        label: _paymentLabel(m),
                                        icon: _paymentIcon(m),
                                        selected: selected,
                                        onTap: () => _tap(
                                          () => setState(() => _payment = m),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _glassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "ملاحظات إضافية (اختياري)",
                                          style: GoogleFonts.cairo(
                                            color: _textMain,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15.2,
                                          ),
                                        ),
                                      ),
                                      ValueListenableBuilder<TextEditingValue>(
                                        valueListenable: _notes,
                                        builder: (_, v, __) {
                                          final len = v.text.length;
                                          final warn = len > (_notesMax - 20);
                                          return Text(
                                            "$len/$_notesMax",
                                            style: GoogleFonts.cairo(
                                              color: warn
                                                  ? Colors.orangeAccent
                                                  : _textSub,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12.5,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _notesFocus.hasFocus
                                            ? _brand.withOpacity(.75)
                                            : Colors.white.withOpacity(.10),
                                        width: _notesFocus.hasFocus ? 1.4 : 1.0,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: TextField(
                                        controller: _notes,
                                        focusNode: _notesFocus,
                                        maxLines: 3,
                                        maxLength: _notesMax,
                                        buildCounter: (_,
                                                {required currentLength,
                                                required isFocused,
                                                maxLength}) =>
                                            const SizedBox.shrink(),
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        cursorColor: _brand,
                                        decoration: InputDecoration(
                                          hintText: "مثال: أنا واقف أمام محطة…",
                                          hintStyle: GoogleFonts.cairo(
                                            color:
                                                Colors.white.withOpacity(.55),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          filled: true,
                                          fillColor:
                                              Colors.white.withOpacity(.07),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  12, 12, 12, 12),
                                          prefixIcon: const Icon(
                                            Icons.edit_note_rounded,
                                            color: Colors.white54,
                                          ),
                                          suffixIcon: _notes.text.trim().isEmpty
                                              ? null
                                              : IconButton(
                                                  onPressed: () => setState(
                                                      () => _notes.clear()),
                                                  icon: const Icon(
                                                    Icons.close_rounded,
                                                    color: Colors.white54,
                                                  ),
                                                ),
                                        ),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
                      child: _ctaButton(
                        label: "تأكيد وبدء البحث",
                        enabled: !_sending,
                        loading: _sending,
                        onTap: _confirm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI Parts =================

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: _bluePrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(.10)),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "تأكيد طلب الخدمة",
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 17.5,
            ),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _bg3,
              Color.lerp(_bg3, _brand2, 0.10)!,
              Colors.transparent,
            ],
            stops: const [0.0, 0.80, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: _glass,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _stroke),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _iconBadge(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Icon(icon, color: _brand3, size: 22),
    );
  }

  Widget _miniTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: Colors.white70,
          fontWeight: FontWeight.w900,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _miniMapPreview({
    required double lat,
    required double lng,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _tap(onTap),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: _shadowSm,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(.08),
                      _brand.withOpacity(.10),
                      Colors.white.withOpacity(.05),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                painter: _GridPainter(color: Colors.white.withOpacity(.06)),
                size: Size.infinite,
              ),
              Positioned(
                left: 14,
                top: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(.10)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}",
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: _bluePrimary,
                    shape: BoxShape.circle,
                    boxShadow: _blueGlow,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(.10)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined, color: _brand3, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _tap(onTap),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? _bluePrimary : null,
          color: selected ? null : Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Colors.white.withOpacity(.10)
                : Colors.white.withOpacity(.10),
            width: selected ? 1.2 : 1.0,
          ),
          boxShadow: selected ? _blueGlow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctaButton({
    required String label,
    required bool enabled,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled ? _blueGlow : _shadowSm,
        ),
        child: ElevatedButton(
          onPressed: (!enabled || loading) ? null : () => _tap(onTap),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.white.withOpacity(.10),
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: enabled ? _bluePrimary : null,
              color: enabled ? null : Colors.white.withOpacity(.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: enabled ? Colors.white.withOpacity(.10) : _stroke,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.5,
                        color: enabled ? Colors.white : Colors.white70,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Painter for subtle grid =====
class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;

    const step = 22.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
