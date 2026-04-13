import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const String phone = "01275649151";
  static const String whatsapp = "01275649151";
  static const String email = "support@doctorcar.com";

  static const Color _bg1 = Color(0xFF050B14);
  static const Color _bg2 = Color(0xFF081321);
  static const Color _bg3 = Color(0xFF0A1B31);

  static const Color _surface = Color(0xFF0C1524);
  static const Color _textMain = Color(0xFFF8FBFF);
  static const Color _textSoft = Color(0xFFD8E6FA);
  static const Color _textMuted = Color(0xFFAFC4DF);

  static const Color _blue = Color(0xFF4A8FFF);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _green = Color(0xFF10B981);
  static const Color _amber = Color(0xFFF59E0B);

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
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    child: Column(
                      children: [
                        _heroCard(),
                        const SizedBox(height: 20),
                        _contactCard(
                          icon: Icons.phone_rounded,
                          title: "Phone Call",
                          subtitle: phone,
                          description:
                              "Talk directly with our support team for urgent roadside assistance.",
                          palette: const _ContactPalette(
                            base: _amber,
                            strong: Color(0xFFD97706),
                            soft: Color(0xFFFCD34D),
                          ),
                          onTap: () => _launchUri(
                            context,
                            Uri(
                              scheme: "tel",
                              path: phone,
                            ),
                          ),
                        ),
                        _contactCard(
                          icon: FontAwesomeIcons.whatsapp,
                          title: "WhatsApp",
                          subtitle: whatsapp,
                          description:
                              "Send us a message anytime for quick updates and service support.",
                          palette: const _ContactPalette(
                            base: _green,
                            strong: Color(0xFF059669),
                            soft: Color(0xFF86EFAC),
                          ),
                          onTap: () => _launchUri(
                            context,
                            Uri.parse("https://wa.me/2$whatsapp"),
                            external: true,
                          ),
                        ),
                        _contactCard(
                          icon: Icons.email_rounded,
                          title: "Email",
                          subtitle: email,
                          description:
                              "Reach out for general inquiries, technical help, and business communication.",
                          palette: const _ContactPalette(
                            base: _cyan,
                            strong: Color(0xFF0284C7),
                            soft: Color(0xFF67E8F9),
                          ),
                          onTap: () => _launchUri(
                            context,
                            Uri.parse("mailto:$email"),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _bottomNote(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUri(
    BuildContext context,
    Uri uri, {
    bool external = false,
  }) async {
    try {
      final ok = await launchUrl(
        uri,
        mode: external
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );

      if (!ok && context.mounted) {
        _showSnack(context, "Could not open link");
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, "Could not open link");
      }
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF11243E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
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
          child: _glowOrb(220, _blue.withOpacity(.10)),
        ),
        Positioned(
          top: 260,
          left: -50,
          child: _glowOrb(170, _cyan.withOpacity(.07)),
        ),
        Positioned(
          bottom: -40,
          right: -20,
          child: _glowOrb(180, _amber.withOpacity(.06)),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _ContactBackgroundPainter(),
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
              "Contact Us",
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
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.16),
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
            top: -22,
            right: -12,
            child: _glowOrb(90, Colors.white.withOpacity(.06)),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: _glowOrb(80, Colors.white.withOpacity(.04)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.10),
                    border: Border.all(color: Colors.white.withOpacity(.14)),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "We’re Here to Help",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose the best way to reach DoctorCar support. Call, message us on WhatsApp, or send an email anytime.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(.84),
                    fontSize: 14.3,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required _ContactPalette palette,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: _glassCard(
            child: Row(
              children: [
                _iconShell(
                  icon: icon,
                  palette: palette,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          color: _textMain,
                          fontSize: 16.4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          color: palette.soft,
                          fontSize: 13.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: GoogleFonts.cairo(
                          color: _textMuted,
                          fontSize: 12.6,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: palette.base.withOpacity(.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: palette.base.withOpacity(.18),
                        ),
                      ),
                      child: Text(
                        "Open",
                        style: GoogleFonts.cairo(
                          color: _textMain,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: palette.soft,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
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

  Widget _iconShell({
    required IconData icon,
    required _ContactPalette palette,
  }) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: palette.base.withOpacity(.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.14),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    palette.soft.withOpacity(.26),
                    palette.base,
                    palette.strong,
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(.16)),
              ),
            ),
          ),
          Positioned(
            top: 7,
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
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNote() {
    return _glassCard(
      child: Center(
        child: Text(
          "DoctorCar Support is available to help you with technical issues, roadside requests, and service inquiries.",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _textSoft,
            fontSize: 13.2,
            fontWeight: FontWeight.w700,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class _ContactPalette {
  const _ContactPalette({
    required this.base,
    required this.strong,
    required this.soft,
  });

  final Color base;
  final Color strong;
  final Color soft;
}

class _ContactBackgroundPainter extends CustomPainter {
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
