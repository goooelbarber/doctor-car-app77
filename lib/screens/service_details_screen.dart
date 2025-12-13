// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'map_picker_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          s["name"],
          style: GoogleFonts.cairo(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => isFavorite = !isFavorite);
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      // ================= BODY ================
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ----- صورة الخدمة -----
            Container(
              height: 170,
              margin: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Icon(
                  s["icon"],
                  size: 95,
                  color: Colors.redAccent,
                ),
              ),
            ),

            // ----- اسم الخدمة -----
            Text(
              s["name"],
              style: GoogleFonts.cairo(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // ----- تقييم + وقت -----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 22),
                const SizedBox(width: 4),
                Text(
                  "${s['rating']}",
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 18),
                const Icon(Icons.timer, size: 22, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  s["time"],
                  style: GoogleFonts.cairo(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ----- الوصف -----
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.06),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Text(
                s["desc"],
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ----- السعر -----
            Text(
              "السعر",
              style: GoogleFonts.cairo(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${s['price']} جنيه",
              style: GoogleFonts.cairo(
                fontSize: 23,
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // ================== زر طلب الخدمة ==================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
            )
          ],
        ),
        child: SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.location_on, size: 26, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapPickerScreen(
                    selectedService: s["type"] ?? s["name"],
                  ),
                ),
              );
            },
            label: Text(
              "تحديد الموقع وبدء الطلب",
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
