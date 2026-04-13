// lib/screens/splash_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/app_routes.dart';
import 'role_selection_screen.dart';

const Color kBgStart = Color(0xFF090B12);
const Color kBgMid = Color(0xFF07111A);
const Color kBgMid2 = Color(0xFF0A1826);
const Color kBgEnd = Color(0xFF05070D);

const Color kPanel = Color(0xFF18232B);
const Color kPanelTop = Color(0xFF8EA1A9);

const Color kAccent = Color.fromARGB(255, 8, 89, 143);
const Color kAccentDark = Color.fromARGB(255, 33, 129, 194);
const Color kAccentSoft = Color.fromARGB(255, 94, 176, 217);
const Color kAccentGlow = Color(0xFF8FD3FF);

const Color kText = Color(0xFFF4F6F8);
const Color kMuted = Color(0xFFB7C1C7);
const Color kHint = Color(0xFF93A1A8);
const Color kLine = Color(0xFFDCE4E8);
const Color kSuccess = Color(0xFF7DD3AE);
const Color kLime = Color.fromARGB(255, 25, 180, 232);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _minSplash = Duration(milliseconds: 3200);
  static const String _logoAsset = 'assets/images/xx.png';

  late final AnimationController _introController;
  late final AnimationController _floatController;
  late final AnimationController _glowController;
  late final AnimationController _orbitController;
  late final AnimationController _shimmerController;
  late final AnimationController _stripeController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _panelFade;

  Timer? _progressTimer;

  double _progress = 0.08;
  double _targetProgress = 0.22;
  bool _workDone = false;
  bool _navigated = false;
  String _version = 'v';

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: kBgEnd,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14000),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _stripeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat();

    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.36, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.42, curve: Curves.easeOutBack),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.18, 0.68, curve: Curves.easeOut),
    );

    _subtitleFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.34, 0.84, curve: Curves.easeOut),
    );

    _panelFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.46, 1.0, curve: Curves.easeOut),
    );

    _startFakeProgress();
    _bootstrap();
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
        _progress += math.max(0.003, diff * 0.09);
        _progress = _progress.clamp(0.0, cap);
      });
    });
  }

  Future<void> _bootstrap() async {
    final minDelay = Future.delayed(_minSplash);
    final work = _initWork();

    await Future.wait([minDelay, work]);

    if (!mounted || _navigated) return;

    _workDone = true;
    _progressTimer?.cancel();

    for (int i = 0; i < 14; i++) {
      if (!mounted) break;
      await Future.delayed(const Duration(milliseconds: 24));
      setState(() {
        _progress = math.min(1.0, _progress + 0.04);
      });
    }

    if (!mounted) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      AppRoutes.fadeScale(const RoleSelectionScreen()),
    );
  }

  Future<void> _initWork() async {
    _setStage(0.28);
    await _loadVersion();

    _setStage(0.54);
    await Future.delayed(const Duration(milliseconds: 260));

    _setStage(0.78);
    await Future.delayed(const Duration(milliseconds: 340));

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
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _version = 'v${info.version}+${info.buildNumber}';
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _introController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _orbitController.dispose();
    _shimmerController.dispose();
    _stripeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width > 520;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBgEnd,
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _introController,
            _floatController,
            _glowController,
            _orbitController,
            _shimmerController,
            _stripeController,
          ]),
          builder: (_, __) {
            return Stack(
              children: [
                _LuxurySplashBackground(
                  glowValue: _glowController.value,
                  orbitValue: _orbitController.value,
                  stripeValue: _stripeController.value,
                ),
                SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeTransition(
                              opacity: _logoFade,
                              child: ScaleTransition(
                                scale: _logoScale,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    math.sin(_floatController.value * math.pi) *
                                        -10,
                                  ),
                                  child: _LuxuryLogoBlock(
                                    asset: _logoAsset,
                                    size: isWide ? 220 : 185,
                                    glowPulse: _glowController.value,
                                    orbitValue: _orbitController.value,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            FadeTransition(
                              opacity: _titleFade,
                              child: _BrandTitles(isWide: isWide),
                            ),
                            const SizedBox(height: 16),
                            FadeTransition(
                              opacity: _subtitleFade,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isWide ? 430 : 330,
                                ),
                                child: Text(
                                  'خدمة ذكية وسريعة للعناية بالسيارة، بتجربة راقية تبدأ من أول لحظة.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: kMuted.withOpacity(.90),
                                    fontSize: isWide ? 15 : 13.8,
                                    fontWeight: FontWeight.w500,
                                    height: 1.7,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 34),
                            FadeTransition(
                              opacity: _panelFade,
                              child: _LuxuryLoadingCard(
                                width: isWide
                                    ? 410
                                    : math.min(size.width - 48, 370),
                                progress: _progress,
                                shimmer: _shimmerController.value,
                                version: _version,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: SafeArea(
                    top: false,
                    child: FadeTransition(
                      opacity: _panelFade,
                      child: Text(
                        'Doctor Car • Premium Automotive Experience',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.24),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .35,
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

class _LuxurySplashBackground extends StatelessWidget {
  const _LuxurySplashBackground({
    required this.glowValue,
    required this.orbitValue,
    required this.stripeValue,
  });

  final double glowValue;
  final double orbitValue;
  final double stripeValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kBgStart, kBgMid, kBgMid2, kBgEnd],
                stops: [0.0, 0.28, 0.68, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -140,
          right: -90,
          child: _BlurGlow(
            size: 320,
            color: kAccentGlow.withOpacity(.14),
          ),
        ),
        Positioned(
          top: 170,
          left: -70,
          child: _BlurGlow(
            size: 240,
            color: kAccentSoft.withOpacity(.08),
          ),
        ),
        Positioned(
          bottom: -120,
          right: -50,
          child: _BlurGlow(
            size: 260,
            color: kAccent.withOpacity(.14),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _LuxuryBackgroundPainter(
              glow: glowValue,
              orbit: orbitValue,
              stripe: stripeValue,
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(.04),
                    Colors.transparent,
                    Colors.black.withOpacity(.14),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlurGlow extends StatelessWidget {
  const _BlurGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 56, sigmaY: 56),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _LuxuryBackgroundPainter extends CustomPainter {
  const _LuxuryBackgroundPainter({
    required this.glow,
    required this.orbit,
    required this.stripe,
  });

  final double glow;
  final double orbit;
  final double stripe;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stripePaint = Paint()
      ..color = kAccentGlow.withOpacity(.07)
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke;

    final Paint stripePaintSoft = Paint()
      ..color = Colors.white.withOpacity(.03)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;

    final double offset = stripe * 140;

    for (double x = -size.width; x < size.width * 1.8; x += 86) {
      canvas.drawLine(
        Offset(x - offset, -40),
        Offset(x + size.height * 0.52 - offset, size.height + 60),
        stripePaintSoft,
      );
    }

    for (double x = -size.width + 30; x < size.width * 1.8; x += 170) {
      canvas.drawLine(
        Offset(x - offset * .65, -60),
        Offset(x + size.height * 0.52 - offset * .65, size.height + 80),
        stripePaint,
      );
    }

    final Paint softLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(.05);

    final Paint accentLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = kAccentGlow.withOpacity(.14 + glow * .04);

    final Path pathTop = Path()
      ..moveTo(0, size.height * .15)
      ..quadraticBezierTo(
        size.width * .24,
        size.height * (.08 + math.sin(orbit * math.pi * 2) * .01),
        size.width * .54,
        size.height * .15,
      )
      ..quadraticBezierTo(
        size.width * .80,
        size.height * .24,
        size.width,
        size.height * .14,
      );

    final Path pathBottom = Path()
      ..moveTo(0, size.height * .84)
      ..quadraticBezierTo(
        size.width * .20,
        size.height * .79,
        size.width * .42,
        size.height * .87,
      )
      ..quadraticBezierTo(
        size.width * .72,
        size.height * .98,
        size.width,
        size.height * .89,
      );

    canvas.drawPath(pathTop, accentLine);
    canvas.drawPath(pathBottom, softLine);

    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withOpacity(.08);

    canvas.drawCircle(
      Offset(size.width * .84, size.height * .18),
      36,
      ringPaint,
    );
    canvas.drawCircle(
      Offset(size.width * .16, size.height * .60),
      24,
      ringPaint,
    );

    final Paint dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = kAccentGlow.withOpacity(.14);

    for (double x = 16; x < size.width; x += 58) {
      canvas.drawCircle(Offset(x, size.height * .24), 1.2, dotPaint);
    }

    for (double x = 8; x < size.width; x += 62) {
      canvas.drawCircle(Offset(x, size.height * .75), 1.1, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LuxuryBackgroundPainter oldDelegate) {
    return oldDelegate.glow != glow ||
        oldDelegate.orbit != orbit ||
        oldDelegate.stripe != stripe;
  }
}

class _LuxuryLogoBlock extends StatelessWidget {
  const _LuxuryLogoBlock({
    required this.asset,
    required this.size,
    required this.glowPulse,
    required this.orbitValue,
  });

  final String asset;
  final double size;
  final double glowPulse;
  final double orbitValue;

  @override
  Widget build(BuildContext context) {
    final double shellWidth = size + 150;
    final double shellHeight = size * .62 + 68;

    return SizedBox(
      width: shellWidth + 70,
      height: shellHeight + 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: shellWidth + 70,
            height: shellHeight + 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: RadialGradient(
                colors: [
                  kAccentGlow.withOpacity(.22 + glowPulse * .10),
                  kAccentGlow.withOpacity(.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Transform.rotate(
            angle: orbitValue * math.pi * 2,
            child: SizedBox(
              width: shellWidth + 26,
              height: shellHeight + 26,
              child: CustomPaint(
                painter: _OrbitFramePainter(
                  color: kAccentGlow.withOpacity(.45),
                ),
              ),
            ),
          ),
          Container(
            width: shellWidth,
            height: shellHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(.16),
                  Colors.white.withOpacity(.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(.14),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.38),
                  blurRadius: 34,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: kAccentGlow.withOpacity(.12),
                  blurRadius: 22,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF02101B),
                      Color(0xFF041827),
                      Color(0xFF031220),
                    ],
                  ),
                  border: Border.all(
                    color: kAccentGlow.withOpacity(.22),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(.05),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Image.asset(
                          asset,
                          width: size * 1.4,
                          height: size * 1.1,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.car_repair_rounded,
                            color: Colors.white,
                            size: size * .42,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitFramePainter extends CustomPainter {
  const _OrbitFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      const Radius.circular(28),
    );

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = color;

    final Path path = Path()..addRRect(rect);
    final metric = path.computeMetrics().first;
    final double length = metric.length;

    void drawSegment(double start, double sweep) {
      final Path extract =
          metric.extractPath(start * length, (start + sweep) * length);
      canvas.drawPath(extract, paint);
    }

    drawSegment(0.04, 0.10);
    drawSegment(0.28, 0.08);
    drawSegment(0.56, 0.10);
    drawSegment(0.82, 0.07);

    final Paint dotPaint = Paint()..color = color;
    canvas.drawCircle(
        Offset(size.width * .84, size.height * .32), 2.2, dotPaint);
    canvas.drawCircle(
      Offset(size.width * .22, size.height * .72),
      1.8,
      dotPaint..color = color.withOpacity(.7),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitFramePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _BrandTitles extends StatelessWidget {
  const _BrandTitles({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final double titleSize = isWide ? 42 : 35;

    return Column(
      children: [
        Text(
          'SMART AUTOMOTIVE ASSISTANCE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kAccentGlow.withOpacity(.78),
            fontSize: isWide ? 11 : 10,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFEAF7FF),
                Color(0xFF9EDFFF),
              ],
            ).createShader(rect);
          },
          child: Text(
            'DOCTOR CAR',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleSize,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'دكتور كار',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(.92),
            fontSize: isWide ? 18 : 16,
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: isWide ? 220 : 180,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                kAccentGlow.withOpacity(.98),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: kAccentGlow.withOpacity(.28),
                blurRadius: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LuxuryLoadingCard extends StatelessWidget {
  const _LuxuryLoadingCard({
    required this.width,
    required this.progress,
    required this.shimmer,
    required this.version,
  });

  final double width;
  final double progress;
  final double shimmer;
  final String version;

  @override
  Widget build(BuildContext context) {
    final double value = progress.clamp(0.0, 1.0);
    final int percent = (value * 100).toInt();

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(.12),
                Colors.white.withOpacity(.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.28),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kAccentGlow,
                      boxShadow: [
                        BoxShadow(
                          color: kAccentGlow.withOpacity(.55),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'جاري تجهيز التطبيق',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.97),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: kAccentGlow.withOpacity(.10),
                      border: Border.all(
                        color: kAccentGlow.withOpacity(.18),
                      ),
                    ),
                    child: Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Color(0xFF9ADFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _UltraPremiumProgressTrack(
                width: width - 40,
                value: value,
                shimmer: shimmer,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'تحميل المكونات الأساسية وتجهيز تجربة استخدام سريعة واحترافية',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.60),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    version,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.32),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UltraPremiumProgressTrack extends StatelessWidget {
  const _UltraPremiumProgressTrack({
    required this.width,
    required this.value,
    required this.shimmer,
  });

  final double width;
  final double value;
  final double shimmer;

  @override
  Widget build(BuildContext context) {
    final List<double> nodePositions = [0.0, 0.33, 0.66, 1.0];

    return SizedBox(
      width: width,
      height: 34,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: Colors.white.withOpacity(.08),
                border: Border.all(
                  color: Colors.white.withOpacity(.05),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            child: Container(
              width: math.max(24, width * value),
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFD9F2FF),
                    Color(0xFF97DEFF),
                    Color(0xFF55C9FF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF67CEFF).withOpacity(.38),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: (width * shimmer) - 38,
            child: Container(
              width: 38,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.white.withOpacity(.32),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          ...nodePositions.map((p) {
            final bool active = value >= p;
            return Positioned(
              left: (width * p) - 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: active ? 16 : 14,
                height: active ? 16 : 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? const Color(0xFF8AD8FF)
                      : Colors.white.withOpacity(.16),
                  border: Border.all(
                    color: active
                        ? Colors.white.withOpacity(.80)
                        : Colors.white.withOpacity(.12),
                    width: 1.2,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: const Color(0xFF67CEFF).withOpacity(.42),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
          Positioned(
            left: (width * value).clamp(0.0, width - 22),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFBDEBFF),
                    Color(0xFF72D3FF),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(.85),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF67CEFF).withOpacity(.40),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_car_rounded,
                  size: 12,
                  color: Color(0xFF062033),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
