// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';
import 'package:doctor_car_app/screens/tracking/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class TechnicianSelectionScreen extends StatefulWidget {
  final String orderId;
  final String userId;
  final String serviceType;
  final double lat;
  final double lng;
  final List<Map<String, dynamic>> technicians;

  const TechnicianSelectionScreen({
    super.key,
    required this.orderId,
    required this.userId,
    required this.serviceType,
    required this.lat,
    required this.lng,
    required this.technicians,
  });

  @override
  State<TechnicianSelectionScreen> createState() =>
      _TechnicianSelectionScreenState();
}

class _TechnicianSelectionScreenState extends State<TechnicianSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController fadeCtrl;

  @override
  void initState() {
    super.initState();
    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  // --------------------------------------------------------------
  // ✔ اختيار الفني → حفظه في السيرفر → فتح صفحة التتبع
  // --------------------------------------------------------------
  Future<void> _selectTechnician(Map tech) async {
    try {
      final url = Uri.parse("${ApiConfig.orders}/${widget.orderId}/assign");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"technicianId": tech["_id"]}),
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TrackingScreen(
              orderId: widget.orderId,
              userId: widget.userId,
              baseUrl: ApiConfig.baseUrl,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ فشل تعيين الفني")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ خطأ: $e")),
      );
    }
  }

  // --------------------------------------------------------------
  // UI
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final technicians = widget.technicians;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "اختر الفني المناسب",
          style: GoogleFonts.cairo(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: technicians.isEmpty
          ? _noTechnicians()
          : FadeTransition(
              opacity: fadeCtrl,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: technicians.length,
                itemBuilder: (_, i) =>
                    _techCard(technicians[i], i == 0 /* الأول أفضل */),
              ),
            ),
    );
  }

  Widget _noTechnicians() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "لا يوجد فنيين بالقرب منك الآن",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _techCard(Map tech, bool priority) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: priority
            ? Border.all(color: Colors.orange, width: 2)
            : Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundImage: AssetImage("assets/images/driver.png"),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tech["name"],
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("السيارة: ${tech["carModel"]}",
                        style: TextStyle(color: Colors.grey.shade700)),
                    Text("لوحة: ${tech["plate"]}",
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 22),
                  const SizedBox(width: 4),
                  Text(
                    tech["rating"].toString(),
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.route, size: 22, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              Text("المسافة: ${tech["distance"]} كم",
                  style: GoogleFonts.cairo(fontSize: 15)),
              const Spacer(),
              Icon(Icons.timer, size: 22, color: Colors.green.shade700),
              const SizedBox(width: 6),
              Text("الوقت: ${tech["eta"]} دقيقة",
                  style: GoogleFonts.cairo(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _selectTechnician(tech),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "اختيار هذا الفني",
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 17),
              ),
            ),
          )
        ],
      ),
    );
  }
}
