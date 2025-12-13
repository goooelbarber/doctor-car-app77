// 📁 lib/screens/car/add_vehicle_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:doctor_car_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final plateCtrl = TextEditingController();
  final chassisCtrl = TextEditingController();

  // ✅ تصحيح النوع فقط
  List<dynamic> brands = [];
  List<String> models = [];
  List<String> years = [];

  String? selectedBrand;
  String? selectedModel;
  String? selectedYear;
  String? selectedFuel;
  String? selectedCondition;
  String? selectedColor;

  bool loading = false;

  final fuelTypes = ["بنزين", "ديزل", "هايبرد", "كهرباء"];
  final conditions = ["ممتازة", "جيدة جدًا", "جيدة", "تحتاج صيانة"];
  final colors = ["أبيض", "أسود", "فضي", "رمادي", "أزرق", "أحمر", "ذهبي"];

  @override
  void initState() {
    super.initState();
    loadBrands();
  }

  // ============================
  // 🔵 Load Brands
  // ============================
  Future<void> loadBrands() async {
    final list = await ApiService.getCarBrands();
    if (mounted) {
      setState(() => brands = list);
    }
  }

  // ============================
  // 🟩 Load Models
  // ============================
  Future<void> loadModels(String brand) async {
    setState(() {
      models = [];
      years = [];
      selectedModel = null;
      selectedYear = null;
    });

    final list = await ApiService.getModelsByBrand(brand);
    if (mounted) {
      setState(() => models = List<String>.from(list));
    }
  }

  // ============================
  // 🟧 Load Years
  // ============================
  Future<void> loadYears(String brand, String model) async {
    setState(() {
      years = [];
      selectedYear = null;
    });

    final list = await ApiService.getYears(brand, model);
    if (mounted) {
      setState(() => years = List<String>.from(list.map((e) => e.toString())));
    }
  }

  // ============================
  // 💾 Save
  // ============================
  Future<void> saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("⚠️ يجب تسجيل الدخول")));
      return;
    }

    setState(() => loading = true);

    final res = await ApiService.addVehicle(
      token,
      brand: selectedBrand!,
      model: selectedModel!,
      fuel: selectedFuel!,
      condition: selectedCondition!,
      plateNumber: plateCtrl.text.trim(),
      year: selectedYear!,
      color: selectedColor!,
      chassisNumber: chassisCtrl.text.trim(),
    );

    setState(() => loading = false);

    if (res["error"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"]), backgroundColor: Colors.red),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("🚗 تم إضافة السيارة"), backgroundColor: Colors.green),
    );

    Navigator.pop(context, true);
  }

  // ============================
  // UI Components
  // ============================
  Widget dropdown({
    required String label,
    required List items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: Colors.black87,
          decoration: inputStyle(label),
          style: const TextStyle(color: Colors.white),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e is Map ? e["name"].toString() : e.toString(),
                    child: Text(
                      e is Map ? e["name"].toString() : e.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? "مطلوب" : null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget textField(String label, controller, icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white),
          decoration: inputStyle(label)
              .copyWith(prefixIcon: Icon(icon, color: Colors.amber)),
          validator: (v) => v!.isEmpty ? "مطلوب" : null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(.3)),
      ),
    );
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("إضافة مركبة", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.1),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        dropdown(
                          label: "الماركة",
                          items: brands,
                          value: selectedBrand,
                          onChanged: (v) {
                            setState(() => selectedBrand = v);
                            loadModels(v!);
                          },
                        ),
                        if (selectedBrand != null)
                          dropdown(
                            label: "الموديل",
                            items: models,
                            value: selectedModel,
                            onChanged: (v) {
                              setState(() => selectedModel = v);
                              loadYears(selectedBrand!, v!);
                            },
                          ),
                        if (selectedModel != null)
                          dropdown(
                            label: "سنة الصنع",
                            items: years,
                            value: selectedYear,
                            onChanged: (v) => setState(() => selectedYear = v),
                          ),
                        dropdown(
                          label: "نوع الوقود",
                          items: fuelTypes,
                          value: selectedFuel,
                          onChanged: (v) => setState(() => selectedFuel = v),
                        ),
                        dropdown(
                          label: "الحالة",
                          items: conditions,
                          value: selectedCondition,
                          onChanged: (v) =>
                              setState(() => selectedCondition = v),
                        ),
                        dropdown(
                          label: "اللون",
                          items: colors,
                          value: selectedColor,
                          onChanged: (v) => setState(() => selectedColor = v),
                        ),
                        textField(
                            "رقم اللوحة", plateCtrl, FontAwesomeIcons.idCard),
                        textField("رقم الهيكل (الشاصي)", chassisCtrl,
                            FontAwesomeIcons.carBurst),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: loading ? null : saveVehicle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            minimumSize: const Size(double.infinity, 55),
                          ),
                          child: Text(
                            loading ? "جاري الحفظ..." : "إضافة المركبة",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
