// PATH: lib/screens/ai_diagnosis/ai_diagnosis_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ai_camera_diagnosis_screen.dart';
import '../obd/obd_scan_screen.dart';

class AiDiagnosisScreen extends StatefulWidget {
  const AiDiagnosisScreen({super.key});

  @override
  State<AiDiagnosisScreen> createState() => _AiDiagnosisScreenState();
}

class _AiDiagnosisScreenState extends State<AiDiagnosisScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  static const Color _bg0 = Color(0xFF0A1A33);
  static const Color _bg1 = Color(0xFF163A6E);
  static const Color _bg2 = Color(0xFF294F86);

  static const Color _panel = Color(0xFF7092BA);
  static const Color _panel2 = Color(0xFF7C9CC0);
  static const Color _panel3 = Color(0xFF88A6C7);

  static const Color _blueBtn1 = Color(0xFF1492FF);
  static const Color _blueBtn2 = Color(0xFF0B76DC);
  static const Color _blueBtn3 = Color(0xFF095EB6);

  static const Color _text = Colors.white;
  static const Color _muted = Color(0xFFDDE8F7);
  static const Color _muted2 = Color(0xFFEDF4FF);
  static const Color _deepIcon = Color(0xFF20339B);
  static const Color _success = Color(0xFF5BE08B);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _blurBlob({required double size, required Color color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size),
          ),
        ),
      ),
    );
  }

  Widget _background() {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bg1, _bg0, _bg2],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: -70,
          left: -50,
          child: _blurBlob(
            size: 200,
            color: Colors.white.withOpacity(.06),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -40,
          child: _blurBlob(
            size: 220,
            color: const Color(0xFF2D8BFF).withOpacity(.10),
          ),
        ),
      ],
    );
  }

  void _openObd() {
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

  void _openCameraDiagnosis() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AiCameraDiagnosisScreen(),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
        ),
        const Spacer(),
        const Text(
          "التشخيص الذكي",
          style: TextStyle(
            color: _text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _titleBlock() {
    return const Column(
      children: [
        SizedBox(height: 8),
        Text(
          "اختر طريقة الفحص",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _text,
            fontSize: 29,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "قم بالحصول على التشخيص المناسب لمشكلتك بدقة",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _muted,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _outerCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: child,
    );
  }

  Widget _scanCard({
    required bool recommended,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return _outerCard(
      child: Container(
        decoration: BoxDecoration(
          color: _panel.withOpacity(.88),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Column(
          children: [
            if (recommended)
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _success.withOpacity(.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      "موصى به • مجاني",
                      style: TextStyle(
                        color: _success,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: recommended
                          ? _panel2.withOpacity(.70)
                          : _panel3.withOpacity(.55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(.08),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 62,
                        color: _deepIcon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted2,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [_blueBtn1, _blueBtn2, _blueBtn3],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _blueBtn1.withOpacity(.28),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: onTap,
                        icon: Icon(
                          recommended
                              ? Icons.arrow_forward_rounded
                              : Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noticeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _muted2,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "تأكد من إيقاف السيارة في وضع آمن قبل البدء بالفحص عبر منفذ OBD.",
              style: TextStyle(
                color: _muted2,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            _background(),
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: AnimatedBuilder(
                  animation: _slide,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slide.value),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      children: [
                        _topBar(),
                        const SizedBox(height: 16),
                        _titleBlock(),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _scanCard(
                                recommended: true,
                                icon: Icons.tune_rounded,
                                title: "الفحص عبر OBD",
                                subtitle: "منفذ كمبيوتر السيارة",
                                description:
                                    "قم بتوصيل جهازك بمنفذ الفحص للحصول على أكواد الأعطال وقراءة بيانات السيارة بدقة.",
                                buttonText: "ابدأ الفحص الشامل",
                                onTap: _openObd,
                              ),
                              const SizedBox(height: 14),
                              _scanCard(
                                recommended: false,
                                icon: Icons.camera_alt_outlined,
                                title: "الفحص البصري بالذكاء الاصطناعي",
                                subtitle: "تقنية الذكاء الاصطناعي",
                                description:
                                    "تحليل بصري ذكي لتقدير المشكلة المحتملة من خلال الكاميرا والصور بشكل سريع.",
                                buttonText: "فتح الكاميرا",
                                onTap: _openCameraDiagnosis,
                              ),
                              const SizedBox(height: 14),
                              _noticeCard(),
                            ],
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

// ignore: unused_element
class _DiagnosisBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(.022)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 42) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFF3A6FB5).withOpacity(.18);

    final center = Offset(size.width / 2, size.height * .34);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * .62),
      3.14,
      3.14,
      false,
      glowPaint,
    );

    final dotPaint = Paint()..color = const Color(0xFF9AB5D8).withOpacity(.12);

    for (int i = 0; i < 16; i++) {
      final dx = (size.width / 15) * i;
      final dy = 120 + (i % 6) * 92.0;
      canvas.drawCircle(Offset(dx, dy), 1.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
