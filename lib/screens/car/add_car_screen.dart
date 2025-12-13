// 📁 lib/screens/car/add_car_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  String? selectedBrand;
  String? selectedModel;
  String? selectedYear;

  List brands = [];
  List models = [];
  List years = [];

  bool loadingBrands = false;
  bool loadingModels = false;
  bool loadingYears = false;
  bool sendingCar = false;

  final baseUrl =
      "http://192.168.1.14:5001/api/car-types"; // 🔥 غيّر IP حسب سيرفرك

  @override
  void initState() {
    super.initState();
    fetchBrands();
  }

  // ============================================================
  // 🔵 1) جلب ماركات السيارات
  // ============================================================
  Future<void> fetchBrands() async {
    setState(() => loadingBrands = true);

    try {
      final res = await http.get(Uri.parse("$baseUrl/brands"));
      brands = jsonDecode(res.body);
    } catch (e) {
      debugPrint("❌ Error loading brands: $e");
    }

    setState(() => loadingBrands = false);
  }

  // ============================================================
  // 🔵 2) جلب الموديلات حسب الماركة
  // ============================================================
  Future<void> fetchModels(String brand) async {
    setState(() {
      loadingModels = true;
      selectedModel = null;
      selectedYear = null;
      models = [];
      years = [];
    });

    try {
      final res = await http.get(Uri.parse("$baseUrl/models/$brand"));
      models = jsonDecode(res.body);
    } catch (e) {
      debugPrint("❌ Error loading models: $e");
    }

    setState(() => loadingModels = false);
  }

  // ============================================================
  // 🔵 3) جلب السنوات حسب الموديل
  // ============================================================
  Future<void> fetchYears(String brand, String model) async {
    setState(() {
      loadingYears = true;
      selectedYear = null;
      years = [];
    });

    try {
      final res = await http.get(Uri.parse("$baseUrl/years/$brand/$model"));
      years = jsonDecode(res.body);
    } catch (e) {
      debugPrint("❌ Error loading years: $e");
    }

    setState(() => loadingYears = false);
  }

  // ============================================================
  // 🔵 4) إرسال السيارة للباكند
  // ============================================================
  Future<void> submitCar() async {
    if (selectedBrand == null ||
        selectedModel == null ||
        selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ برجاء اختيار جميع البيانات")),
      );
      return;
    }

    setState(() => sendingCar = true);

    try {
      final res = await http.post(
        Uri.parse("http://192.168.1.14:5001/api/vehicles/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "brand": selectedBrand,
          "model": selectedModel,
          "year": selectedYear,
          "userId": "YOUR_USER_ID"
        }),
      );

      if (res.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🚗 تم إضافة السيارة بنجاح")),
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        debugPrint("❌ Error: ${res.body}");
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
    }

    setState(() => sendingCar = false);
  }

  // ============================================================
  // 🔵 UI
  // ============================================================
  Widget dropdown({
    required String label,
    required String? value,
    required List items,
    required bool loading,
    required Function(String?) onChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
              : DropdownButton(
                  isExpanded: true,
                  underline: const SizedBox(),
                  value: value,
                  hint: Text("اختر $label"),
                  items: items.map<DropdownMenuItem<String>>((item) {
                    return DropdownMenuItem(
                      value:
                          item is String ? item : item["name"] ?? item["model"],
                      child: Text(item is String
                          ? item
                          : item["name"] ?? item["model"]),
                    );
                  }).toList(),
                  onChanged: onChange,
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة سيارة", style: GoogleFonts.cairo()),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            dropdown(
              label: "الماركة",
              value: selectedBrand,
              items: brands,
              loading: loadingBrands,
              onChange: (v) {
                setState(() => selectedBrand = v);
                fetchModels(v!);
              },
            ),
            const SizedBox(height: 20),
            dropdown(
              label: "الموديل",
              value: selectedModel,
              items: models,
              loading: loadingModels,
              onChange: (v) {
                setState(() => selectedModel = v);
                fetchYears(selectedBrand!, v!);
              },
            ),
            const SizedBox(height: 20),
            dropdown(
              label: "سنة الصنع",
              value: selectedYear,
              items: years,
              loading: loadingYears,
              onChange: (v) => setState(() => selectedYear = v),
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: sendingCar ? null : submitCar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: sendingCar
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("إضافة السيارة",
                      style: GoogleFonts.cairo(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
