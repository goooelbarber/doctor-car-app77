import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _brand = Color(0xFF7AB3FF);
  static const Color _brand2 = Color(0xFF4A8FFF);
  // ignore: unused_field
  static const Color _brandSoft = Color(0xFFB9D8FF);

  static const Color _bg1 = Color(0xFF050B14);
  static const Color _bg2 = Color(0xFF081321);
  static const Color _bg3 = Color(0xFF0A1B31);
  static const Color _surface = Color(0xFF0C1524);
  // ignore: unused_field
  static const Color _surface2 = Color(0xFF101B2C);

  static const Color _textMain = Color(0xFFF8FBFF);
  static const Color _textSoft = Color(0xFFD8E6FA);
  static const Color _textMuted = Color(0xFFAFC4DF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg1,
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Column(
              children: [
                _appBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
                    child: _content(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _background() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bg1, _bg2, _bg3],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -40,
          child: _glowOrb(220, _brand.withOpacity(.10)),
        ),
        Positioned(
          top: 240,
          left: -60,
          child: _glowOrb(160, const Color(0xFF5AA6FF).withOpacity(.07)),
        ),
        Positioned(
          bottom: -40,
          right: -20,
          child: _glowOrb(180, const Color(0xFF89BDFF).withOpacity(.05)),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _AboutBackgroundPainter(),
          ),
        ),
      ],
    );
  }

  Widget _glowOrb(double size, Color color) {
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
              blurRadius: 90,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 6),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(.08)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, "/home");
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "About DoctorCar",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heroCard(),
        const SizedBox(height: 20),
        _sectionTitle("Our Mission"),
        const SizedBox(height: 10),
        _missionCard(),
        const SizedBox(height: 20),
        _sectionTitle("What We Offer"),
        const SizedBox(height: 12),
        _featureTile(
          Icons.psychology_alt_rounded,
          "AI Smart Matching",
          "Instantly connects users with the most suitable service provider.",
        ),
        _featureTile(
          Icons.route_rounded,
          "Live Tracking & Navigation",
          "Real-time route visibility with faster response and arrival updates.",
        ),
        _featureTile(
          Icons.verified_user_rounded,
          "Secure & Reliable Service",
          "Trusted service workflow built for safety, quality and confidence.",
        ),
        _featureTile(
          Icons.support_agent_rounded,
          "24/7 Support",
          "Always-on assistance whenever drivers need urgent roadside help.",
        ),
        const SizedBox(height: 22),
        _sectionTitle("Contact Us"),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _socialButton(
                icon: Icons.email_rounded,
                label: "Email",
                subtitle: "support@doctorcar.app",
                url: "mailto:support@doctorcar.app",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _socialButton(
                icon: Icons.language_rounded,
                label: "Website",
                subtitle: "doctorcar.app",
                url: "https://doctorcar.app",
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _bottomInfoCard(),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF163A74),
            Color(0xFF102B58),
            Color(0xFF0A1A36),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _brand.withOpacity(.16),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -10,
            child: _glowOrb(100, Colors.white.withOpacity(.07)),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: _glowOrb(90, Colors.white.withOpacity(.04)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(.14),
                      ),
                    ),
                    child: Image.asset(
                      "assets/images/logo_doctorcar.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withOpacity(.10),
                      ),
                    ),
                    child: Text(
                      "Smart Road Assistance",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Doctor Car",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Smart roadside assistance powered by AI. Request professional technicians, towing, fuel delivery, battery support and tire services instantly with a premium digital experience.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(.84),
                    height: 1.65,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        value: "24/7",
                        label: "Support",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        value: "AI",
                        label: "Powered",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        value: "Live",
                        label: "Tracking",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.white.withOpacity(.80),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionCard() {
    return _glassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconShell(Icons.rocket_launch_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "To deliver fast, safe and reliable assistance on the road using AI, smart dispatching and real-time tracking technology.",
              style: GoogleFonts.cairo(
                color: _textSoft,
                height: 1.65,
                fontSize: 14.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
            gradient: const LinearGradient(
              colors: [_brand, _brand2],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              color: _textMain,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface.withOpacity(.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(.07)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(.035),
                Colors.white.withOpacity(.010),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.24),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _iconShell(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _brand2.withOpacity(.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7AB3FF),
                    Color(0xFF4A8FFF),
                    Color(0xFF2A65D9),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(.16)),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 8,
            right: 8,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(.35),
                    Colors.white.withOpacity(.03),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _glassCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconShell(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: _textMain,
                      fontWeight: FontWeight.w900,
                      fontSize: 15.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      color: _textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.8,
                      height: 1.5,
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

  Widget _socialButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required String url,
  }) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: _glassCard(
        child: Column(
          children: [
            _iconShell(icon),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: _textMain,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: _textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomInfoCard() {
    return _glassCard(
      child: Center(
        child: Column(
          children: [
            Text(
              "Version 1.0.0",
              style: GoogleFonts.cairo(
                color: _textSoft,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Powered by AI & Maps Technology",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: _textMuted,
                fontSize: 12.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint softLine = Paint()
      ..color = Colors.white.withOpacity(.018)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    final Paint brightLine = Paint()
      ..color = const Color(0xFF8FBFFF).withOpacity(.045)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    for (double x = -size.width; x < size.width * 2; x += 96) {
      canvas.drawLine(
        Offset(x, -40),
        Offset(x + size.height * .54, size.height + 50),
        softLine,
      );
    }

    for (double x = -size.width + 30; x < size.width * 2; x += 180) {
      canvas.drawLine(
        Offset(x, -40),
        Offset(x + size.height * .48, size.height + 60),
        brightLine,
      );
    }

    final Paint wave = Paint()
      ..color = const Color(0xFF9BC8FF).withOpacity(.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final Path topWave = Path()
      ..moveTo(0, size.height * .16)
      ..quadraticBezierTo(
        size.width * .25,
        size.height * .08,
        size.width * .54,
        size.height * .16,
      )
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .22,
        size.width,
        size.height * .13,
      );

    final Path bottomWave = Path()
      ..moveTo(0, size.height * .82)
      ..quadraticBezierTo(
        size.width * .20,
        size.height * .78,
        size.width * .42,
        size.height * .86,
      )
      ..quadraticBezierTo(
        size.width * .74,
        size.height * .96,
        size.width,
        size.height * .89,
      );

    canvas.drawPath(topWave, wave);
    canvas.drawPath(bottomWave, wave);

    final Paint ringPaint = Paint()
      ..color = const Color(0xFF9BC8FF).withOpacity(.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(
      Offset(size.width * .86, size.height * .18),
      34,
      ringPaint,
    );
    canvas.drawCircle(
      Offset(size.width * .16, size.height * .58),
      26,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
