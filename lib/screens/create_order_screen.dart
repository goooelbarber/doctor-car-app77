// PATH: lib/screens/create_order_screen.dart
// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import '../config/api_config.dart';
import 'searching_technician_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  static const Color _bg = Color(0xFF0B1220);
  static const Color _yellow = Colors.amber;

  bool loading = false;
  String selectedService = "battery";

  /// ✅ شغّل/اقفل الفيك من هنا بسرعة
  bool useFakeFlow = true;

  final Map<String, String> services = const {
    "battery": "خدمة البطارية",
    "tow": "خدمة السحب",
    "fuel": "توصيل وقود",
    "tire": "تبديل الإطارات",
  };

  void _snack(String msg, {bool danger = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: danger ? Colors.red : null,
        content: Text(msg, style: GoogleFonts.cairo()),
      ),
    );
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("userId");
    if (id == null || id.isEmpty) {
      throw Exception("المستخدم غير مسجل");
    }
    return id;
  }

  Future<Position> _getMyLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("فعّل GPS أولًا");

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw Exception("تم رفض صلاحية الموقع");
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> createOrder() async {
    if (loading) return;

    debugPrint("CreateOrderScreen -> useFakeFlow=$useFakeFlow");
    setState(() => loading = true);

    try {
      final userId = await _getUserId();
      final pos = await _getMyLocation();

      final address =
          "${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}";

      // ✅ Fake Mode: ادخل شاشة البحث مباشرة (بدون API)
      if (useFakeFlow) {
        _snack("🟡 وضع تجريبي: جاري البحث عن فنيين (فيك)...");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SearchingTechnicianScreen(
              userId: userId,
              serviceType: selectedService,
              lat: pos.latitude,
              lng: pos.longitude,
              address: address,
              selectedServices: [selectedService],

              // أي قيمة.. مش هتتستخدم في الفيك
              orderId: "FAKE_ORDER",

              // ✅ Fake settings (الموجودة في شاشة البحث الحالية عندك)
              fakeMode: true,
              fakeAfterSeconds: 2,
              fakeTechCount: 8,

              // لو شاشة البحث عندك فيها دول سيبهم.. لو مش موجودين شيلهم
              autoMatchBestTech: true,
              autoAssignAfterSeconds: 2,
              hideTechList: true,
            ),
          ),
        );
        return;
      }

      // ✅ Real Mode: createOrder من السيرفر
      final body = {
        "userId": userId,
        "serviceName": services[selectedService],
        "serviceType": selectedService,
        "location": {"lat": pos.latitude, "lng": pos.longitude},
      };

      final res = await http
          .post(
            Uri.parse(ApiConfig.createOrder),
            headers: ApiConfig.jsonHeaders(),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      final decoded =
          res.body.isNotEmpty ? jsonDecode(res.body) : <String, dynamic>{};

      if (res.statusCode != 201 && res.statusCode != 200) {
        final msg = (decoded is Map ? decoded["message"] : null)?.toString();
        throw Exception(msg ?? "فشل إنشاء الطلب");
      }

      final data = decoded as Map<String, dynamic>;
      final order = (data["order"] ?? data) as Map<String, dynamic>;
      final orderId = (order["_id"] ?? order["orderId"])?.toString();

      if (orderId == null || orderId.isEmpty) {
        throw Exception("orderId غير موجود في response");
      }

      _snack("✅ تم إرسال الطلب، جاري البحث عن فني قريب...");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SearchingTechnicianScreen(
            userId: userId,
            serviceType: selectedService,
            lat: pos.latitude,
            lng: pos.longitude,
            orderId: orderId,
            selectedServices: [selectedService],
            address: address,
            fakeMode: false,
          ),
        ),
      );
    } catch (e) {
      _snack(
        e.toString().replaceAll("Exception:", "").trim(),
        danger: true,
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Text("طلب خدمة", style: GoogleFonts.cairo(color: Colors.white)),
        actions: [
          Row(
            children: [
              Text("Fake",
                  style:
                      GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
              Switch(
                value: useFakeFlow,
                onChanged:
                    loading ? null : (v) => setState(() => useFakeFlow = v),
                activeColor: _yellow,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _serviceSelector(),
            const Spacer(),
            _submitButton(),
          ],
        ),
      ),
    );
  }

  Widget _serviceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "اختر نوع الخدمة",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...services.entries.map(
          (e) => RadioListTile<String>(
            value: e.key,
            groupValue: selectedService,
            onChanged:
                loading ? null : (v) => setState(() => selectedService = v!),
            title: Text(e.value, style: GoogleFonts.cairo(color: Colors.white)),
            activeColor: _yellow,
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : createOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: _yellow,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                useFakeFlow ? "طلب الفني الآن (Fake)" : "طلب الفني الآن",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}
