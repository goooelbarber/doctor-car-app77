import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, "/home");
            }
          },
        ),
        title: Text(
          "About Us",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                "assets/images/logo_doctorcar.png",
                width: 120,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Doctor Car",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "We provide smart road assistance powered by AI.\n"
              "Our platform helps users request professional technicians, towing, fuel, battery and tire services instantly.",
              style: GoogleFonts.cairo(
                color: Colors.white70,
                height: 1.6,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Our Mission",
              style: GoogleFonts.cairo(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "To deliver fast, safe and reliable assistance on the road using AI & Real-Time Tracking.",
              style: GoogleFonts.cairo(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            const Divider(color: Colors.white24),
            Center(
              child: Text(
                "Powered by AI & Maps Technology",
                style: GoogleFonts.cairo(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
