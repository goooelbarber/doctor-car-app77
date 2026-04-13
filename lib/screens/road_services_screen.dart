// PATH: lib/screens/road_services_screen.dart
// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'vehicles/vehicle_screen.dart';
import 'ai_diagnosis/ai_diagnosis_screen.dart';
import 'confirm_request_screen.dart';
import 'searching_technician_screen.dart';
import 'select_location_screen.dart';
import 'smart_accident_screen.dart';

class RoadServicesScreen extends StatefulWidget {
  final String? initialServiceKey;

  const RoadServicesScreen({
    super.key,
    this.initialServiceKey,
  });

  @override
  State<RoadServicesScreen> createState() => _RoadServicesScreenState();
}

class _RoadServicesScreenState extends State<RoadServicesScreen>
    with SingleTickerProviderStateMixin {
  String? selected;
  dynamic selectedVehicle;
  bool _opening = false;

  static const Color _bgStart = Color(0xFF081A36);
  static const Color _bgMid = Color(0xFF0B2348);
  static const Color _bgEnd = Color(0xFF040D1D);

  static const Color _panel = Color(0xFF143F7C);
  // ignore: unused_field
  static const Color _panelTop = Color(0xFF17345F);

  static const Color _accent = Color(0xFF1B4F9C);
  static const Color _accentDark = Color(0xFF10386B);
  static const Color _accentSoft = Color(0xFFE7EEF9);
  static const Color _accentGlow = Color(0xFF7CC4F5);

  // ignore: unused_field
  static const Color _text = Color(0xFFF2F6FB);
  static const Color _muted = Color(0xFFC9D6EA);
  // ignore: unused_field
  static const Color _hint = Color(0xFF93A9C9);
  // ignore: unused_field
  static const Color _line = Color(0xFF29496F);
  // ignore: unused_field
  static const Color _lime = Color(0xFFE8F09E);

  static const Color _danger = Color.fromARGB(255, 223, 5, 5);
  static const Color _danger2 = Color.fromARGB(255, 249, 0, 0);
  static const Color _danger3 = Color.fromARGB(255, 243, 5, 5);
  static const Color _dangerSoft = Color(0xFFFFD1DB);

  String get _userId => "68fe4505493ae17aa81d605b";

  final List<Map<String, dynamic>> services = const [
    {
      "key": "tow",
      "name": "خدمة ونش",
      "img": "assets/images/s.png",
      "icon": Icons.local_shipping_rounded,
    },
    {
      "key": "battery",
      "name": "خدمة بطارية",
      "img": "assets/images/ss.png",
      "icon": Icons.battery_charging_full_rounded,
    },
    {
      "key": "fuel",
      "name": "خدمة بنزين",
      "img": "assets/images/ssss.png",
      "icon": Icons.local_gas_station_rounded,
    },
    {
      "key": "tire",
      "name": "خدمة الكاوتش",
      "img": "assets/images/sss.png",
      "icon": Icons.trip_origin_rounded,
    },
    {
      "key": "ride",
      "name": "سيارة ركاب",
      "img": "assets/images/sssss.png",
      "icon": Icons.directions_car_filled_rounded,
    },
    {
      "key": "accident",
      "name": "تبليغ عن حادث",
      "img": "assets/images/ssssss.png",
      "icon": Icons.warning_amber_rounded,
      "openDirect": true,
    },
  ];

  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);

    selected = widget.initialServiceKey;
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF122946),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _openSmartDiagnosis() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AiDiagnosisScreen(),
      ),
    );
  }

  List<Map<String, dynamic>> get _items => services;

  LinearGradient get _bgGradient => const LinearGradient(
        colors: [_bgStart, _bgMid, _bgEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  LinearGradient get _ctaGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1B4F99),
          Color(0xFF245AA6),
          Color(0xFF153F78),
        ],
        stops: [0.0, 0.50, 1.0],
      );

  LinearGradient get _glassGradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white.withOpacity(.10),
          Colors.white.withOpacity(.06),
          Colors.white.withOpacity(.03),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  LinearGradient get _selectedGradient => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF245AA6),
          Color(0xFF173E75),
          Color(0xFF102C54),
        ],
      );

  List<BoxShadow> get _softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.22),
          blurRadius: 22,
          offset: const Offset(0, 12),
        ),
      ];

  List<BoxShadow> get _brandGlow => [
        BoxShadow(
          color: _accent.withOpacity(.28),
          blurRadius: 34,
          offset: const Offset(0, 18),
        ),
        BoxShadow(
          color: _accentGlow.withOpacity(.16),
          blurRadius: 22,
          offset: const Offset(0, 12),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final mq = MediaQuery.of(context);
    final scale = mq.textScaler.scale(1.0);
    final clamped = scale.clamp(1.0, 1.12);
    final fixedMq = mq.copyWith(textScaler: TextScaler.linear(clamped));

    final items = _items;

    return MediaQuery(
      data: fixedMq,
      child: Scaffold(
        backgroundColor: _bgStart,
        body: Stack(
          children: [
            _proBackground(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _sliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 118 + bottomPad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _compactTopStrip(),
                        const SizedBox(height: 12),
                        _smartDiagnosisCard(),
                        const SizedBox(height: 14),
                        _selectionSummaryStrip(),
                        const SizedBox(height: 14),
                        _servicesHeader(),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, c) {
                            final w = c.maxWidth;
                            final crossAxisCount = w >= 700 ? 3 : 2;
                            final aspect = w >= 700 ? 0.88 : 0.78;

                            return GridView.builder(
                              itemCount: items.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: aspect,
                              ),
                              itemBuilder: (_, index) {
                                final item = items[index];
                                final String key = item["key"] as String;
                                final String name = item["name"] as String;
                                final String img = item["img"] as String;
                                final IconData icon = item["icon"] as IconData;
                                final bool openDirect =
                                    (item["openDirect"] == true);

                                final isSel = selected == key;

                                return Semantics(
                                  button: true,
                                  selected: isSel,
                                  label: name,
                                  child: _serviceCard(
                                    keyId: key,
                                    name: name,
                                    img: img,
                                    icon: icon,
                                    openDirect: openDirect,
                                    selected: isSel,
                                    onTap: _opening
                                        ? null
                                        : () async {
                                            _tap(() => setState(() {
                                                  selected = key;
                                                }));
                                            await _openSelected(key);
                                          },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: SafeArea(
                top: false,
                child: _bottomCta(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _proBackground() {
    return AnimatedBuilder(
      animation: _bgCtrl,
      builder: (_, __) {
        final t = _bgCtrl.value;
        final dx = lerpDouble(-0.18, 0.18, t)!;
        final dy = lerpDouble(0.06, -0.04, t)!;

        return Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: _bgGradient)),
            Align(
              alignment: Alignment(dx, -0.92),
              child: _glowBlob(size: 240, opacity: 0.16),
            ),
            Align(
              alignment: Alignment(-0.85, dy),
              child: _glowBlob(size: 300, opacity: 0.12),
            ),
            Align(
              alignment: Alignment(0.95, 0.25 - dy),
              child: _glowBlob(size: 220, opacity: 0.10),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _RoadBackdropPainter(
                  lineColor: Colors.white.withOpacity(.018),
                  accentColor: _accentGlow.withOpacity(.035),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.28),
                    Colors.transparent,
                    Colors.black.withOpacity(0.18),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _glowBlob({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _accent.withOpacity(opacity),
            _accent.withOpacity(opacity * 0.32),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }

  SliverAppBar _sliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 68,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: _ctaGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(.16)),
            ),
            child: const Icon(
              Icons.alt_route_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "خدمات الطريق",
            style: GoogleFonts.cairo(
              fontSize: 17.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.62),
              _accentDark.withOpacity(0.22),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _compactTopStrip() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: _ctaGradient,
                  boxShadow: _brandGlow.take(1).toList(),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "اختار الخدمة المناسبة وابدأ طلبك بسرعة",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.4,
                    height: 1.25,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(.08)),
                ),
                child: Text(
                  "Road",
                  style: GoogleFonts.cairo(
                    color: _accentSoft,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectionSummaryStrip() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected != null
              ? _accentGlow.withOpacity(.24)
              : Colors.white.withOpacity(.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: selected != null ? _ctaGradient : _glassGradient,
              border: Border.all(color: Colors.white.withOpacity(.10)),
            ),
            child: Icon(
              selected != null ? Icons.check_rounded : Icons.grid_view_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selected == null
                  ? "اختر نوع الخدمة من البطاقات بالأسفل"
                  : "تم اختيار: ${_selectedName()}",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _servicesHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "الخدمات المتاحة",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: Text(
            "${services.length} خدمات",
            style: GoogleFonts.cairo(
              color: _accentSoft,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _smartDiagnosisCard() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _danger.withOpacity(.30),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openSmartDiagnosis,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        _danger,
                        _danger2,
                        _danger3,
                      ],
                    ),
                    border: Border.all(
                      color: _dangerSoft.withOpacity(.28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.14),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.psychology_alt_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "التشخيص الذكي",
                              style: GoogleFonts.cairo(
                                fontSize: 18.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "حل أسرع لو مش عارف نوع العطل",
                              style: GoogleFonts.cairo(
                                fontSize: 13.2,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withOpacity(.92),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(.16),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceCard({
    required String keyId,
    required String name,
    required String img,
    required IconData icon,
    required bool openDirect,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: selected ? _accentGlow.withOpacity(.95) : Colors.white10,
            width: selected ? 2.2 : 1.1,
          ),
          gradient: selected ? _selectedGradient : _glassGradient,
          boxShadow: selected ? _brandGlow : _softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _serviceIconBadge(icon, selected: selected),
                      const Spacer(),
                      if (openDirect)
                        _fastChip()
                      else
                        _selectStateChip(selected),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _serviceImageLarge(img, selected: selected),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceIconBadge(IconData icon, {required bool selected}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: selected ? _ctaGradient : _glassGradient,
        border: Border.all(
          color: selected
              ? Colors.white.withOpacity(.16)
              : Colors.white.withOpacity(.10),
        ),
        boxShadow: selected ? _brandGlow.take(1).toList() : null,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  Widget _fastChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.red.withOpacity(.18)),
      ),
      child: Text(
        "مباشر",
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 10.8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _selectStateChip(bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Text(
        selected ? "تم الاختيار" : "اختيار",
        style: GoogleFonts.cairo(
          color: Colors.white.withOpacity(.92),
          fontSize: 10.8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _serviceImageLarge(String img, {required bool selected}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.12),
        border: Border.all(
          color: selected
              ? Colors.white.withOpacity(.16)
              : Colors.white.withOpacity(.08),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Image.asset(
        img,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.image_not_supported,
          color: Colors.white.withOpacity(0.70),
          size: 56,
        ),
      ),
    );
  }

  Widget _bottomCta() {
    final disabled = (selected == null || _opening);
    final btnText = _buttonLabel();
    final sub =
        (selected == null) ? "اختار خدمة عشان تكمل" : "هنبدأ طلب الخدمة فورًا";

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _panel.withOpacity(.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected != null)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.20),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _accent.withOpacity(.24)),
                      ),
                      child: Text(
                        "الخدمة: ${_selectedName()}",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.verified_rounded,
                      color: _accentSoft,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "DoctorCar",
                      style: GoogleFonts.cairo(
                        color: _muted,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              if (selected != null) const SizedBox(height: 10),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!disabled)
                        BoxShadow(
                          color: _accent.withOpacity(0.30),
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedOpacity(
                          opacity: disabled ? 0.45 : 1,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: disabled
                                  ? LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(.14),
                                        Colors.white.withOpacity(.10),
                                      ],
                                    )
                                  : _ctaGradient,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: disabled
                                ? null
                                : () async {
                                    HapticFeedback.mediumImpact();
                                    await _openSelected(selected!);
                                  },
                            child: Center(
                              child: _opening
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.flash_on_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          btnText,
                                          style: GoogleFonts.cairo(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16.6,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _selectedName() {
    final k = selected;
    if (k == null) return "";
    final m = services.where((e) => e["key"] == k).toList();
    return m.isEmpty ? k : (m.first["name"] as String);
  }

  String _buttonLabel() {
    if (selected == null) return "اختر خدمة أولاً";
    if (selected == "accident") return "فتح نظام الحوادث الذكي";
    return "طلب الخدمة الآن";
  }

  Future<void> _openSelected(String key) async {
    if (_opening) return;
    setState(() => _opening = true);

    try {
      if (key == "accident") {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SmartAccidentScreen()),
        );
        return;
      }

      final vehicle = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const VehiclesScreen(selectMode: true),
        ),
      );

      if (vehicle == null) return;
      selectedVehicle = vehicle;

      final PickedLocation? picked = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectLocationScreen(
            serviceType: key,
            userId: _userId,
            selectedServices: [key],
          ),
        ),
      );

      if (picked == null) return;

      final ConfirmRequestResult? confirm = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmRequestScreen(
            args: ConfirmRequestArgs(
              serviceType: key,
              userId: _userId,
              selectedServices: [key],
              lat: picked.lat,
              lng: picked.lng,
              address: picked.address,
              vehicle: selectedVehicle,
            ),
          ),
        ),
      );

      if (confirm == null) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchingTechnicianScreen(
            serviceType: key,
            userId: _userId,
            selectedServices: [key],
            lat: picked.lat,
            lng: picked.lng,
            address: picked.address,
            orderId: '',
          ),
        ),
      );
    } catch (e) {
      _snack("حصل خطأ: $e");
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }
}

class _RoadBackdropPainter extends CustomPainter {
  const _RoadBackdropPainter({
    required this.lineColor,
    required this.accentColor,
  });

  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (double x = -size.height; x < size.width + size.height; x += 30) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * .88, -10),
      Offset(size.width * .62, size.height * .26),
      accentPaint,
    );

    canvas.drawLine(
      Offset(-10, size.height * .64),
      Offset(size.width * .24, size.height * .96),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoadBackdropPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.accentColor != accentColor;
  }
}
