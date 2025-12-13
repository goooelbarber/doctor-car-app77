// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

import '../services/order_service.dart';
import 'searching_technician_screen.dart'; // الشاشة التالية

class AllowLocationScreen extends StatefulWidget {
  final String serviceName;
  final String serviceType;
  final int price;

  const AllowLocationScreen({
    super.key,
    required this.serviceName,
    required this.serviceType,
    required this.price,
  });

  @override
  State<AllowLocationScreen> createState() => _AllowLocationScreenState();
}

class _AllowLocationScreenState extends State<AllowLocationScreen> {
  bool loading = false;

  Future<void> requestLocation() async {
    setState(() => loading = true);

    try {
      // 1️⃣ التأكد من تفعيل GPS
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        await Geolocator.openLocationSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("من فضلك فعّل خدمة GPS ثم حاول مرة أخرى"),
          ),
        );
        setState(() => loading = false);
        return;
      }

      // 2️⃣ طلب إذن الوصول للموقع
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }

      if (p == LocationPermission.denied ||
          p == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("لا يمكن المتابعة بدون إذن الموقع")),
        );
        setState(() => loading = false);
        return;
      }

      // 3️⃣ الحصول على الإحداثيات
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4️⃣ إنشاء الطلب على السيرفر
      final result = await OrderService.createOrder(
        userId: "68fe4505493ae17aa81d605b",
        serviceType: widget.serviceType,
        lat: pos.latitude,
        lng: pos.longitude,
      );

      dynamic order = result["order"] ?? result;
      final String orderId =
          (order["_id"] ?? order["id"] ?? result["orderId"] ?? "").toString();

      if (orderId.isEmpty) {
        throw Exception("لم أستطع تحديد رقم الطلب (orderId)!");
      }

      // 5️⃣ فتح شاشة البحث عن الفني
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SearchingTechnicianScreen(
            userId: "68fe4505493ae17aa81d605b",
            serviceType: widget.serviceType,
            lat: pos.latitude,
            lng: pos.longitude,
            orderId: orderId, // ← مهم جداً
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ أثناء إرسال الطلب: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("السماح بالموقع", style: GoogleFonts.cairo()),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.location_on_rounded,
                size: 95, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(
              "نحتاج موقعك لتحديد أقرب فني لخدمة:\n${widget.serviceName}",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : requestLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "السماح بالموقع",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
