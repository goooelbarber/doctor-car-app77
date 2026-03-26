// PATH: lib/screens/splash_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/app_routes.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _minSplash = Duration(milliseconds: 4000);
  static const String _logoAsset = 'assets/images/xx.png';

  late final AnimationController _introController;
  late final AnimationController _roadController;
  late final AnimationController _glowController;
  late final AnimationController _cursorController;
  late final AnimationController _logoPulseController;
  late final AnimationController _progressShimmerController;
  late final AnimationController _carFloatController;
  late final AnimationController _curveController;

  late final Animation<double> _overlayFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _brandFade;
  late final Animation<double> _tagFade;
  late final Animation<double> _bottomFade;
  late final Animation<double> _roadReveal;
  late final Animation<double> _curveReveal;

  Timer? _textTimer;
  Timer? _progressTimer;

  final String _brand = 'DoctorCar';
  String _displayBrand = '';

  double _progress = 0.06;
  double _targetProgress = 0.34;
  bool _workDone = false;
  bool _navigated = false;
  bool _typingFinished = false;
  String _version = 'v';

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    _logoPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _progressShimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _carFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _curveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _overlayFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.00, 0.28, curve: Curves.easeOut),
    );

    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.08, 0.32, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.58, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.06, 0.36, curve: Curves.easeOutBack),
      ),
    );

    _brandFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.22, 0.56, curve: Curves.easeOut),
    );

    _tagFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.42, 0.78, curve: Curves.easeOut),
    );

    _bottomFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.50, 0.94, curve: Curves.easeOut),
    );

    _roadReveal = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.18, 0.62, curve: Curves.easeOutCubic),
    );

    _curveReveal = CurvedAnimation(
      parent: _curveController,
      curve: Curves.easeOutCubic,
    );

    _startTypewriter();
    _startFakeProgress();
    _bootstrap();
  }

  void _startTypewriter() {
    int index = 0;
    _textTimer?.cancel();

    _textTimer = Timer.periodic(const Duration(milliseconds: 105), (timer) {
      if (!mounted) return;

      if (index >= _brand.length) {
        timer.cancel();
        if (!_typingFinished) {
          _typingFinished = true;
          _curveController.forward();
        }
        return;
      }

      setState(() {
        index++;
        _displayBrand = _brand.substring(0, index);
      });
    });
  }

  void _startFakeProgress() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 70), (_) {
      if (!mounted) return;

      final double cap = _workDone ? 1.0 : 0.93;
      final double target = math.min(_targetProgress, cap);

      setState(() {
        final double diff = target - _progress;
        if (diff <= 0) return;
        _progress += math.max(0.0035, diff * 0.082);
        _progress = _progress.clamp(0.0, cap);
      });
    });
  }

  Future<void> _bootstrap() async {
    final Future<void> minDelay = Future.delayed(_minSplash);
    final Future<void> work = _initWork();

    await Future.wait([minDelay, work]);

    if (!mounted || _navigated) return;

    _workDone = true;
    _progressTimer?.cancel();

    for (int i = 0; i < 16; i++) {
      if (!mounted) break;
      await Future.delayed(const Duration(milliseconds: 28));
      setState(() {
        _progress = math.min(1.0, _progress + 0.032);
      });
    }

    if (!mounted) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      AppRoutes.fadeScale(const RoleSelectionScreen()),
    );
  }

  Future<void> _initWork() async {
    _setStage(0.24);
    await _loadVersion();

    _setStage(0.52);
    await Future.delayed(const Duration(milliseconds: 360));

    _setStage(0.78);
    await Future.delayed(const Duration(milliseconds: 440));

    _setStage(0.93);
  }

  void _setStage(double value) {
    if (!mounted) return;
    setState(() {
      _targetProgress = value;
    });
  }

  Future<void> _loadVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _version = 'v${info.version}+${info.buildNumber}';
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _progressTimer?.cancel();
    _introController.dispose();
    _roadController.dispose();
    _glowController.dispose();
    _cursorController.dispose();
    _logoPulseController.dispose();
    _progressShimmerController.dispose();
    _carFloatController.dispose();
    _curveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isWide = size.width > 520;
    final double brandFont = isWide ? 54 : 44;
    final double roadWidth = math.min(size.width * 0.70, 340.0);
    final double roadHeight = isWide ? 270 : 240;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _introController,
            _roadController,
            _glowController,
            _cursorController,
            _logoPulseController,
            _progressShimmerController,
            _carFloatController,
            _curveController,
          ]),
          builder: (context, child) {
            return Stack(
              children: [
                const _PremiumBackground(),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CinematicGlowPainter(
                        pulse: _glowController.value,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: _HeroLogo(
                              asset: _logoAsset,
                              size: isWide ? 150 : 128,
                              pulse: _logoPulseController.value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _brandFade,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _BrandTitle(
                                text: _displayBrand,
                                fontSize: brandFont,
                                cursorOpacity: _cursorController.value,
                                showCursor:
                                    _displayBrand.length < _brand.length,
                              ),
                              const SizedBox(height: 10),
                              Opacity(
                                opacity: _curveReveal.value,
                                child: SizedBox(
                                  width: isWide ? 250 : 210,
                                  height: 22,
                                  child: CustomPaint(
                                    painter: _CurvedUnderlinePainter(
                                      progress: _curveReveal.value,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: _tagFade,
                          child: _CenterTagLine(isWide: isWide),
                        ),
                        const SizedBox(height: 38),
                        Opacity(
                          opacity: _roadReveal.value,
                          child: SizedBox(
                            width: roadWidth,
                            height: roadHeight,
                            child: CustomPaint(
                              painter: _CenteredRoadPainter(
                                move: _roadController.value,
                                overlay: _overlayFade.value,
                              ),
                              child: Center(
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    -6 +
                                        math.sin(
                                              _carFloatController.value *
                                                  math.pi *
                                                  2,
                                            ) *
                                            2.0,
                                  ),
                                  child: const _FrontFacingCar(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 28,
                  child: SafeArea(
                    top: false,
                    child: FadeTransition(
                      opacity: _bottomFade,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _MinimalLoadingSection(
                          progress: _progress,
                          shimmer: _progressShimmerController.value,
                          width:
                              isWide ? 270 : math.min(size.width * 0.58, 240),
                          version: _version,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF071019),
                  Color(0xFF04080F),
                  Color(0xFF03060C),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -50,
          child: _BlurCircle(
            size: 220,
            color: const Color(0xFF68C6FF).withOpacity(0.10),
          ),
        ),
        Positioned(
          top: 180,
          right: -70,
          child: _BlurCircle(
            size: 260,
            color: const Color(0xFF68C6FF).withOpacity(0.08),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 20,
          child: _BlurCircle(
            size: 170,
            color: Colors.white.withOpacity(0.025),
          ),
        ),
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 38, sigmaY: 38),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _CinematicGlowPainter extends CustomPainter {
  const _CinematicGlowPainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    final double alpha1 = 0.03 + (pulse * 0.02);
    final double alpha2 = 0.018 + ((1 - pulse) * 0.015);

    paint.color = const Color(0xFF68C6FF).withOpacity(alpha1);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.44),
      150,
      paint,
    );

    paint.color = Colors.white.withOpacity(alpha2);
    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.26),
      120,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CinematicGlowPainter oldDelegate) {
    return oldDelegate.pulse != pulse;
  }
}

class _HeroLogo extends StatelessWidget {
  const _HeroLogo({
    required this.asset,
    required this.size,
    required this.pulse,
  });

  final String asset;
  final double size;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final double scale = 0.992 + (pulse * 0.016);

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: size + 40,
        height: size + 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size + 40,
              height: size + 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF68C6FF).withOpacity(0.18),
                    const Color(0xFF68C6FF).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              width: size + 18,
              height: size + 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.035),
                border: Border.all(
                  color: const Color(0xFF90D9FF).withOpacity(0.18),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF68C6FF).withOpacity(0.12),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Image.asset(
                asset,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.car_repair_rounded,
                  color: Colors.white,
                  size: size * 0.52,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({
    required this.text,
    required this.fontSize,
    required this.cursorOpacity,
    required this.showCursor,
  });

  final String text;
  final double fontSize;
  final double cursorOpacity;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: [
        ShaderMask(
          shaderCallback: (Rect rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF3FBFF),
                Color(0xFFD9F0FF),
                Color(0xFF93D8FF),
              ],
            ).createShader(rect);
          },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              height: 1,
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: showCursor ? cursorOpacity : 0,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Container(
              width: 3,
              height: fontSize * 0.72,
              decoration: BoxDecoration(
                color: const Color(0xFF7CCBFF),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CurvedUnderlinePainter extends CustomPainter {
  const _CurvedUnderlinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    final double revealX = size.width * progress;

    path.moveTo(0, size.height * 0.72);
    path.quadraticBezierTo(
      size.width * 0.22,
      size.height * 0.15,
      size.width * 0.50,
      size.height * 0.60,
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height * 1.02,
      size.width,
      size.height * 0.28,
    );

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, revealX, size.height));

    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF7CCBFF).withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [
          Color(0x007CCBFF),
          Color(0xFF7CCBFF),
          Color(0xFFEAF7FF),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CurvedUnderlinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _CenterTagLine extends StatelessWidget {
  const _CenterTagLine({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: isWide ? 390 : 330),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.045),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        'مساعدة على الطريق • صيانة • فحص • تشخيص',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.78),
          fontSize: isWide ? 14 : 12.4,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
    );
  }
}

class _CenteredRoadPainter extends CustomPainter {
  const _CenteredRoadPainter({
    required this.move,
    required this.overlay,
  });

  final double move;
  final double overlay;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double bottomY = size.height;
    final double horizonY = size.height * 0.14;
    final double bottomHalf = size.width * 0.40;
    final double topHalf = size.width * 0.12;

    final Path road = Path()
      ..moveTo(centerX - bottomHalf, bottomY)
      ..lineTo(centerX - topHalf, horizonY)
      ..lineTo(centerX + topHalf, horizonY)
      ..lineTo(centerX + bottomHalf, bottomY)
      ..close();

    final Rect roadRect = Rect.fromLTWH(0, horizonY, size.width, size.height);
    final Paint roadPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0E1620).withOpacity(0.86),
          const Color(0xFF172435).withOpacity(0.96),
          const Color(0xFF0D151F),
        ],
      ).createShader(roadRect);

    canvas.drawPath(road, roadPaint);

    final Paint edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFF7CCBFF).withOpacity(0.12 * overlay);

    canvas.drawLine(
      Offset(centerX - bottomHalf, bottomY),
      Offset(centerX - topHalf, horizonY),
      edgePaint,
    );
    canvas.drawLine(
      Offset(centerX + bottomHalf, bottomY),
      Offset(centerX + topHalf, horizonY),
      edgePaint,
    );

    final Paint dashPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final double phase = ((i / 8) + move) % 1.0;
      final double yTop = lerpDouble(horizonY + 18, bottomY - 84, phase)!;
      final double yBottom = yTop + lerpDouble(8, 24, phase)!;
      final double halfTop = lerpDouble(1.8, 9.0, phase)!;
      final double halfBottom = lerpDouble(4.0, 18.0, phase)!;

      final Path dash = Path()
        ..moveTo(centerX - halfTop, yTop)
        ..lineTo(centerX + halfTop, yTop)
        ..lineTo(centerX + halfBottom, yBottom)
        ..lineTo(centerX - halfBottom, yBottom)
        ..close();

      dashPaint.color = Colors.white.withOpacity(0.28 + (phase * 0.55));
      canvas.drawPath(dash, dashPaint);
    }

    final Paint centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7CCBFF).withOpacity(0.11),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(centerX, size.height * 0.68),
          radius: 72,
        ),
      );

    canvas.drawCircle(Offset(centerX, size.height * 0.68), 72, centerGlow);
  }

  @override
  bool shouldRepaint(covariant _CenteredRoadPainter oldDelegate) {
    return oldDelegate.move != move || oldDelegate.overlay != overlay;
  }
}

class _FrontFacingCar extends StatelessWidget {
  const _FrontFacingCar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 2,
            child: Container(
              width: 44,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: RadialGradient(
                  colors: [
                    Colors.black.withOpacity(0.34),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          CustomPaint(
            size: const Size(82, 82),
            painter: _FrontCarPainter(),
          ),
        ],
      ),
    );
  }
}

class _FrontCarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2 + 2);

    final Paint body = Paint()..color = const Color(0xFFEFF9FF);
    final Paint dark = Paint()..color = const Color(0xFF12202C);
    final Paint accent = Paint()..color = const Color(0xFF7CCBFF);
    final Paint soft = Paint()..color = const Color(0xFFD7EEFF);

    final Rect lowerBody = Rect.fromCenter(
      center: Offset(c.dx, c.dy + 6),
      width: 34,
      height: 26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(lowerBody, const Radius.circular(10)),
      body,
    );

    final Path roof = Path()
      ..moveTo(c.dx - 12, c.dy - 4)
      ..quadraticBezierTo(c.dx - 10, c.dy - 18, c.dx, c.dy - 20)
      ..quadraticBezierTo(c.dx + 10, c.dy - 18, c.dx + 12, c.dy - 4)
      ..lineTo(c.dx + 9, c.dy + 1)
      ..lineTo(c.dx - 9, c.dy + 1)
      ..close();
    canvas.drawPath(roof, soft);

    final Rect glass = Rect.fromCenter(
      center: Offset(c.dx, c.dy - 6),
      width: 16,
      height: 10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(glass, const Radius.circular(4)),
      dark,
    );

    canvas.drawLine(
      Offset(c.dx, c.dy - 2),
      Offset(c.dx, c.dy + 16),
      Paint()
        ..color = const Color(0xFFCAE9FF).withOpacity(0.5)
        ..strokeWidth = 1.2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + 13),
          width: 12,
          height: 4,
        ),
        const Radius.circular(3),
      ),
      dark,
    );

    canvas.drawCircle(Offset(c.dx - 13.5, c.dy + 17), 3.5, dark);
    canvas.drawCircle(Offset(c.dx + 13.5, c.dy + 17), 3.5, dark);

    canvas.drawCircle(Offset(c.dx - 11.5, c.dy + 2), 2.3, accent);
    canvas.drawCircle(Offset(c.dx + 11.5, c.dy + 2), 2.3, accent);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx - 14, c.dy + 8),
          width: 3,
          height: 6,
        ),
        const Radius.circular(2),
      ),
      accent,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx + 14, c.dy + 8),
          width: 3,
          height: 6,
        ),
        const Radius.circular(2),
      ),
      accent,
    );

    final Paint glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..color = const Color(0xFF7CCBFF).withOpacity(0.18);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy + 10),
        width: 44,
        height: 14,
      ),
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MinimalLoadingSection extends StatelessWidget {
  const _MinimalLoadingSection({
    required this.progress,
    required this.shimmer,
    required this.width,
    required this.version,
  });

  final double progress;
  final double shimmer;
  final double width;
  final String version;

  @override
  Widget build(BuildContext context) {
    final double value = progress.clamp(0.0, 1.0);
    final int percent = (value * 100).toInt();

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PremiumProgressBar(
            width: width,
            value: value,
            shimmer: shimmer,
          ),
          const SizedBox(height: 10),
          Text(
            'جارِ تجهيز التطبيق $percent%',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.76),
              fontSize: 11.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            version,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.18),
              fontSize: 9.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumProgressBar extends StatelessWidget {
  const _PremiumProgressBar({
    required this.width,
    required this.value,
    required this.shimmer,
  });

  final double width;
  final double value;
  final double shimmer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: math.max(14, width * value),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFF7FCFF),
                      Color(0xFFDDF3FF),
                      Color(0xFF9EDBFF),
                      Color(0xFF78CBFF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7CCBFF).withOpacity(0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: (width * shimmer) - 30,
              top: -2,
              bottom: -2,
              child: Container(
                width: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.24),
                      Colors.white.withOpacity(0.0),
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
