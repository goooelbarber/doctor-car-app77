import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'find_technician_screen.dart';

// شاشة التتبع الصحيحة
import 'tracking/tracking_screen.dart';

class TechnicianUnavailableScreen extends StatefulWidget {
  final String userId;
  final String serviceType;
  final double lat;
  final double lng;

  const TechnicianUnavailableScreen({
    super.key,
    required this.userId,
    required this.serviceType,
    required this.lat,
    required this.lng,
  });

  @override
  State<TechnicianUnavailableScreen> createState() =>
      _TechnicianUnavailableScreenState();
}

class _TechnicianUnavailableScreenState
    extends State<TechnicianUnavailableScreen> {
  Map<String, dynamic>? nextTech;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadNextTechnician();
  }

  Future<void> _loadNextTechnician() async {
    setState(() => loading = true);

    final url = Uri.parse("${ApiConfig.technicians}/next-available");
    final body = {
      "lat": widget.lat,
      "lng": widget.lng,
      "serviceType": widget.serviceType,
    };

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        setState(() {
          nextTech = data["technician"];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================================================================
  // اختيار الفني البديل
  // ================================================================
  void _chooseNextTech() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TrackingScreen(
          orderId: "REPLACED_BY_SERVER_ORDER_ID", // غيّرها عند الدمج
          userId: widget.userId,
          baseUrl: ApiConfig.baseUrl,
        ),
      ),
    );
  }

  // ================================================================
  // إعادة البحث عن فني
  // ================================================================
  void _retryFindTech() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FindTechnicianScreen(
          userId: widget.userId,
          serviceType: widget.serviceType,
          lat: widget.lat,
          lng: widget.lng,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        title: const Text("⚠️ الفني غير متاح"),
        backgroundColor: Colors.redAccent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 60),
                  const SizedBox(height: 15),
                  const Text(
                    "عذراً، لا يوجد فني متاح في الوقت الحالي.",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  if (nextTech != null) _buildNextTechCard(),

                  const Spacer(),

                  // إعادة المحاولة
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _retryFindTech,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("إعادة المحاولة",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // رجوع
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("رجوع",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNextTechCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "الفني البديل المقترح:",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.person, size: 28, color: Colors.blue),
              ),
              title: Text(
                nextTech!["name"],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("المسافة: ${nextTech!["distance"]} كم"),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _chooseNextTech,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("اختيار هذا الفني",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
