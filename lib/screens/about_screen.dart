import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _brand = Color(0xFFA8F12A);
  static const Color _bg1 = Color(0xFF0B1220);
  static const Color _bg2 = Color(0xFF081837);
  static const Color _bg3 = Color(0xFF0A2038);

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
                    padding: const EdgeInsets.all(22),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_bg1, _bg2, _bg3],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, "/home");
              }
            },
          ),
          const SizedBox(width: 6),
          Text(
            "About DoctorCar",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
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
        Center(
          child: Image.asset(
            "assets/images/logo_doctorcar.png",
            width: 110,
          ),
        ),
        const SizedBox(height: 20),

        /// Main Glass Card
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Doctor Car",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Smart road assistance powered by AI.\n"
                "Request professional technicians, towing, fuel delivery, battery support and tire services instantly.",
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        /// Mission Section
        Text(
          "Our Mission",
          style: GoogleFonts.cairo(
            color: _brand,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "To deliver fast, safe and reliable assistance on the road using AI & Real-Time Tracking technology.",
          style: GoogleFonts.cairo(
            color: Colors.white70,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 22),

        /// Features
        _featureTile(Icons.psychology, "AI Smart Matching"),
        _featureTile(Icons.map, "Live Tracking & Navigation"),
        _featureTile(Icons.security, "Secure & Reliable Service"),
        _featureTile(Icons.support_agent, "24/7 Support"),

        const SizedBox(height: 25),

        /// Contact Section
        Text(
          "Contact Us",
          style: GoogleFonts.cairo(
            color: _brand,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            _socialButton(Icons.email, "Email", "mailto:support@doctorcar.app"),
            const SizedBox(width: 10),
            _socialButton(Icons.language, "Website", "https://doctorcar.app"),
          ],
        ),

        const SizedBox(height: 30),
        const Divider(color: Colors.white24),
        const SizedBox(height: 10),

        Center(
          child: Column(
            children: [
              Text(
                "Version 1.0.0",
                style: GoogleFonts.cairo(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Powered by AI & Maps Technology",
                style: GoogleFonts.cairo(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _featureTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _brand.withOpacity(.15),
            ),
            child: Icon(icon, color: _brand, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(IconData icon, String label, String url) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _brand, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
