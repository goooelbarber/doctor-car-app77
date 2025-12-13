// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'technician_selection_screen.dart'; // صفحة اختيار الفني

class FindTechnicianScreen extends StatefulWidget {
  final String serviceType;
  final double lat;
  final double lng;
  final String userId;

  const FindTechnicianScreen({
    super.key,
    required this.serviceType,
    required this.lat,
    required this.lng,
    required this.userId,
  });

  @override
  State<FindTechnicianScreen> createState() => _FindTechnicianScreenState();
}

class _FindTechnicianScreenState extends State<FindTechnicianScreen> {
  bool searching = true;
  String message = "جاري البحث عن أقرب فني...";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), _createOrder);
  }

  /// إنشاء الطلب + إحضار قائمة الفنيين
  Future<void> _createOrder() async {
    try {
      /// 1️⃣ إنشاء الطلب
      final orderRes = await http.post(
        Uri.parse(ApiConfig.orders),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": widget.userId,
          "serviceType": widget.serviceType,
          "location": {"lat": widget.lat, "lng": widget.lng},
        }),
      );

      final orderData = jsonDecode(orderRes.body);

      if (orderRes.statusCode != 201 || orderData["success"] != true) {
        throw Exception("فشل إنشاء الطلب");
      }

      final String orderId = orderData["order"]["_id"];

      /// 2️⃣ البحث عن الفنيين المتاحين
      final techRes = await http.post(
        Uri.parse("${ApiConfig.technicians}/nearby"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "lat": widget.lat,
          "lng": widget.lng,
          "serviceType": widget.serviceType,
        }),
      );

      final techData = jsonDecode(techRes.body);

      if (techData["success"] != true) {
        throw Exception("لا يوجد فنيون متاحون");
      }

      final technicians =
          List<Map<String, dynamic>>.from(techData["technicians"]);

      setState(() {
        searching = false;
        message = "تم العثور على فنيين متاحين";
      });

      await Future.delayed(const Duration(milliseconds: 600));

      /// 3️⃣ الانتقال لصفحة اختيار الفني — بدون أي خطأ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TechnicianSelectionScreen(
            orderId: orderId,
            userId: widget.userId,
            serviceType: widget.serviceType,
            lat: widget.lat,
            lng: widget.lng,
            technicians: technicians,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        searching = false;
        message = "❌ فشل في تحميل الفنيين: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            searching
                ? const CircularProgressIndicator(color: Colors.blueAccent)
                : const Icon(Icons.error, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
