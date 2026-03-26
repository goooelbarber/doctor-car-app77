// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'select_location_screen.dart';
import 'obd/obd_scan_screen.dart';

class RoadServicesSelectionScreen extends StatefulWidget {
  final String initial;

  const RoadServicesSelectionScreen({
    super.key,
    required this.initial,
  });

  @override
  State<RoadServicesSelectionScreen> createState() =>
      _RoadServicesSelectionScreenState();
}

class _RoadServicesSelectionScreenState
    extends State<RoadServicesSelectionScreen> with TickerProviderStateMixin {
  static const Color _bg = Color(0xFF0B1220);
  static const Color _bg2 = Color(0xFF081837);
  static const Color _bg3 = Color(0xFF0A2038);
  // ignore: unused_field
  static const Color _card = Color(0xFF121B2E);
  static const Color _brand = Color(0xFFA8F12A);

  static const Color _danger = Color.fromARGB(255, 230, 0, 19);
  static const Color _danger2 = Color.fromARGB(255, 252, 1, 1);
  // ignore: unused_field
  static const Color _dangerSoft = Color(0xFFFFD1DB);

  final Set<String> _selected = {};

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final AnimationController _bgCtrl;

  final List<Map<String, dynamic>> services = const [
    {"key": "tow", "title": "خدمة ونش", "image": "assets/images/tow_truck.png"},
    {
      "key": "battery",
      "title": "خدمة بطارية",
      "image": "assets/images/battery.png"
    },
    {"key": "fuel", "title": "خدمة بنزين", "image": "assets/images/fuel.png"},
    {"key": "tire", "title": "خدمة كاوتش", "image": "assets/images/tire.png"},
    {"key": "ride", "title": "سيارة ركاب", "image": "assets/images/car.png"},
  ];

  @override
  void initState() {
    super.initState();

    final initKey = widget.initial.trim();
    if (initKey.isNotEmpty) _selected.add(initKey);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(.92),
      ),
    );
  }

  void _confirmOrder() {
    if (_selected.isEmpty) {
      HapticFeedback.heavyImpact();
      _snack("يرجى اختيار خدمة أولاً");
      return;
    }

    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectLocationScreen(
          serviceType: _selected.join(", "),
          userId: "68fe4505493ae17aa81d605b",
          selectedServices: _selected.toList(),
        ),
      ),
    );
  }

  void _openSmartDiagnosis() {
    HapticFeedback.mediumImpact();

    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ObdScanScreen(
          isArabic: isArabic,
          isDarkMode: isDarkMode,
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
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_bg, _bg2, _bg3],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Align(
              alignment: Alignment(dx, -0.92),
              child: _glowBlob(size: 260, opacity: 0.18),
            ),
            Align(
              alignment: Alignment(-0.85, dy),
              child: _glowBlob(size: 320, opacity: 0.14),
            ),
            Align(
              alignment: Alignment(0.95, 0.25 - dy),
              child: _glowBlob(size: 240, opacity: 0.12),
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
            _brand.withOpacity(opacity),
            _brand.withOpacity(opacity * 0.35),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = mq.textScaler.scale(1.0);
    final clamped = scale.clamp(1.0, 1.15);
    final fixedMq = mq.copyWith(textScaler: TextScaler.linear(clamped));

    return MediaQuery(
      data: fixedMq,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            _proBackground(),
            _content(),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    return SafeArea(
      child: Column(
        children: [
          _glassAppBar(),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _smartDiagnosisCard(),
                      const SizedBox(height: 18),
                      Text(
                        "ما نوع المساعدة التي تحتاجها؟",
                        style: GoogleFonts.cairo(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 3,
                        width: 120,
                        decoration: BoxDecoration(
                          color: _brand,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _selectedChips(),
                      const SizedBox(height: 14),
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: services.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.92,
                          ),
                          itemBuilder: (context, i) {
                            final s = services[i];
                            final isSel = _selected.contains(s["key"]);
                            return _serviceCard(s, isSel);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ctaButton(),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _brand.withOpacity(.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _brand.withOpacity(.24)),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: _brand,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "خدمات الطريق",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smartDiagnosisCard() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _danger.withOpacity(.22),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openSmartDiagnosis,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.white.withOpacity(.08),
                        Colors.white.withOpacity(.04),
                        Colors.white.withOpacity(.03),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(.10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _brand.withOpacity(.12),
                          border: Border.all(
                            color: _brand.withOpacity(.35),
                          ),
                        ),
                        child: const Icon(
                          Icons.psychology_alt_rounded,
                          color: _brand,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "اطلب خدمتك في ثواني",
                              style: GoogleFonts.cairo(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "اختار الخدمة ← حدد موقعك ← نوصلك بأقرب فني",
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _openSmartDiagnosis,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      _danger,
                                      _danger2,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _danger.withOpacity(.28),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "تائه في مشكلة سيارتك؟ اطلب التشخيص الذكي الآن",
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(.12),
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

  Widget _selectedChips() {
    if (_selected.isEmpty) {
      return Text(
        "اختار خدمة واحدة أو أكتر",
        style: GoogleFonts.cairo(
          color: Colors.white70,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      );
    }

    final selectedList = services
        .where((e) => _selected.contains(e["key"]))
        .map((e) => e["title"] as String)
        .toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: selectedList.map((t) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.22),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _brand.withOpacity(.24)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: _brand, size: 16),
              const SizedBox(width: 8),
              Text(
                t,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _serviceCard(Map<String, dynamic> s, bool selected) {
    final String title = (s["title"] ?? "").toString();
    final String key = (s["key"] ?? "").toString();
    final String image = (s["image"] ?? "").toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? _brand.withOpacity(.95) : Colors.white12,
          width: selected ? 2.4 : 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white.withOpacity(.08),
            Colors.white.withOpacity(.04),
            Colors.white.withOpacity(.02),
          ],
        ),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: _brand.withOpacity(.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (selected) {
              _selected.remove(key);
            } else {
              _selected.add(key);
            }
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 108,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white10),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported,
                        color: Colors.white.withOpacity(.70),
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? _brand : Colors.white38,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ctaButton() {
    final disabled = _selected.isEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!disabled)
              BoxShadow(
                color: _brand.withOpacity(0.28),
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
                        : LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color.lerp(_brand, Colors.white, 0.25)!,
                              _brand,
                              Color.lerp(
                                _brand,
                                const Color(0xFF0B1220),
                                0.18,
                              )!,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: disabled ? null : _confirmOrder,
                  child: Center(
                    child: Text(
                      disabled ? "اختر خدمة أولاً" : "اطلب الخدمة الآن",
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
