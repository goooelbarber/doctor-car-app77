import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  final List<Map<String, dynamic>> offers = const [
    {
      "title": "خصم 20% على تغيير الزيت",
      "desc": "لفترة محدودة فقط – خصم خاص!",
      "image": "assets/images/oil_offer.png"
    },
    {
      "title": "فحص كمبيوتر مجاني",
      "desc": "مع أي طلب خدمات فوق 300 جنيه",
      "image": "assets/images/scan_offer.png"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("العروض", style: GoogleFonts.cairo()),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, i) {
          final o = offers[i];

          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              children: [
                Image.asset(o["image"], height: 120),
                const SizedBox(height: 10),
                Text(
                  o["title"],
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(o["desc"], style: GoogleFonts.cairo()),
              ],
            ),
          );
        },
      ),
    );
  }
}
