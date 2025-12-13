import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("About Doctor Car"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("Who We Are"),
            const SizedBox(height: 12),
            _text(
              "Doctor Car provides an integrated smart platform designed to assist drivers during emergency road situations.",
            ),
            const SizedBox(height: 20),
            _title("Our Mission"),
            const SizedBox(height: 12),
            _text(
              "Providing an integrated smart platform to assist drivers with immediate help in emergency road conditions, by enabling requests for maintenance and rapid support services, activating the follow-up feature, and implementing high-quality technical support in a timely manner..",
            ),
            const SizedBox(height: 30),
            _highlightCard(),
          ],
        ),
      ),
    );
  }

  Widget _title(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.amber,
        ),
      );

  Widget _text(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white70,
          height: 1.6,
        ),
      );

  Widget _highlightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xffE8C87A), Color(0xffB68A32)],
        ),
      ),
      child: const Text(
        "Smart • Fast • Reliable Road Assistance",
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
