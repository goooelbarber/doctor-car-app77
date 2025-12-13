// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AIVoicePopup extends StatefulWidget {
  final Function(String) onCommand;

  const AIVoicePopup({super.key, required this.onCommand});

  @override
  State<AIVoicePopup> createState() => _AIVoicePopupState();
}

class _AIVoicePopupState extends State<AIVoicePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController micAnim;

  @override
  void initState() {
    super.initState();

    micAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.85,
      upperBound: 1.15,
    )..repeat(reverse: true);

    /// Simulated voice detection (replace with real STT)
    Future.delayed(const Duration(seconds: 3), () {
      widget.onCommand("مشكلتي إن العربية بتقطع وأنا ماشي");
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    micAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // ignore: deprecated_member_use
      backgroundColor: Colors.black.withOpacity(.85),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: micAnim,
              child: Lottie.asset(
                "assets/lottie/voice_wave.json",
                width: 200,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "أتحدث… استمع إليك الآن",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "اخبرني مشكلتك أو ماذا تريد أن تفعل",
              style: GoogleFonts.cairo(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            )
          ],
        ),
      ),
    );
  }
}
