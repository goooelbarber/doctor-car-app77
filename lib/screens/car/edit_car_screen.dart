// 📁 lib/screens/car/edit_vehicle_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:doctor_car_app/services/api_service.dart';

class EditVehicleScreen extends StatefulWidget {
  final Map vehicle;

  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  // ✅ brands هنا لازم تكون List<String> لأن ApiService.getCarBrands بيرجع Strings
  List<String> brands = [];
  List<String> models = [];
  List<String> years = [];

  bool loadingBrands = false;
  bool loadingModels = false;
  bool loadingYears = false;
  bool saving = false;

  String? selectedBrand;
  String? selectedModel;
  String? selectedYear;
  String? selectedFuel;
  String? selectedCondition;
  String? selectedColor;

  final plateCtrl = TextEditingController();
  final chassisCtrl = TextEditingController();

  final fuelTypes = const ["بنزين", "ديزل", "هايبرد", "كهرباء"];
  final conditions = const ["ممتازة", "جيدة جدًا", "جيدة", "تحتاج صيانة"];
  final colors = const ["أبيض", "أسود", "فضي", "رمادي", "أزرق", "أحمر", "ذهبي"];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // ============================================================
  // 🟦 تحميل البيانات الأساسية
  // ============================================================
  Future<void> _loadInitialData() async {
    setState(() => loadingBrands = true);

    try {
      brands = await ApiService.getCarBrands();

      selectedBrand = widget.vehicle["brand"]?.toString();
      selectedModel = widget.vehicle["model"]?.toString();
      selectedYear = widget.vehicle["year"]?.toString();
      selectedFuel = widget.vehicle["fuel"]?.toString();
      selectedCondition = widget.vehicle["condition"]?.toString();
      selectedColor = widget.vehicle["color"]?.toString();

      plateCtrl.text = widget.vehicle["plateNumber"]?.toString() ?? "";
      chassisCtrl.text = widget.vehicle["chassisNumber"]?.toString() ?? "";

      await _loadModels();
      await _loadYears();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تعذر تحميل بيانات المركبة")),
      );
    } finally {
      if (!mounted) return;
      setState(() => loadingBrands = false);
    }
  }

  // ============================================================
  // 🟩 جلب الموديلات
  // ============================================================
  Future<void> _loadModels() async {
    if (selectedBrand == null || selectedBrand!.isEmpty) return;

    setState(() => loadingModels = true);

    try {
      final data = await ApiService.getModelsByBrand(selectedBrand!);
      models = List<String>.from(data);

      // ✅ لو الموديل الحالي مش موجود في القائمة
      if (selectedModel != null && !models.contains(selectedModel)) {
        selectedModel = null;
      }
    } catch (_) {
      models = [];
    } finally {
      if (!mounted) return;
      setState(() => loadingModels = false);
    }
  }

  // ============================================================
  // 🟧 جلب السنوات
  // ============================================================
  Future<void> _loadYears() async {
    if (selectedBrand == null ||
        selectedBrand!.isEmpty ||
        selectedModel == null ||
        selectedModel!.isEmpty) return;

    setState(() => loadingYears = true);

    try {
      final data = await ApiService.getYears(selectedBrand!, selectedModel!);
      years = List<String>.from(data.map((e) => e.toString()));

      if (selectedYear != null && !years.contains(selectedYear)) {
        selectedYear = null;
      }
    } catch (_) {
      years = [];
    } finally {
      if (!mounted) return;
      setState(() => loadingYears = false);
    }
  }

  // ============================================================
  // 💾 حفظ التعديلات
  // ============================================================
  Future<void> _saveEdit() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicleId = widget.vehicle["_id"]?.toString();
    if (vehicleId == null || vehicleId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ معرف المركبة غير صحيح"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      // ✅ ApiService.updateVehicle في النسخة الجديدة بدون token
      final res = await ApiService.updateVehicle(
        vehicleId: vehicleId,
        brand: selectedBrand,
        model: selectedModel,
        year: selectedYear,
        fuel: selectedFuel,
        condition: selectedCondition,
        plateNumber: plateCtrl.text.trim(),
        color: selectedColor,
        chassisNumber: chassisCtrl.text.trim(),
      );

      if (!mounted) return;

      if (res["error"] == true || res["success"] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"]?.toString() ?? "فشل التحديث"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚗 تم تحديث بيانات السيارة بنجاح"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تعذر الاتصال بالسيرفر"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => saving = false);
    }
  }

  // ============================================================
  // 🟦 Dropdown Widget
  // ============================================================
  Widget buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required bool isLoading,
    required void Function(String?) onChanged,
    bool requiredField = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: (value != null && items.contains(value)) ? value : null,
          style: const TextStyle(color: Colors.white),
          dropdownColor: Colors.black87,
          decoration: _inputStyle(label, icon),
          items: isLoading
              ? const []
              : items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
          onChanged: isLoading ? null : onChanged,
          validator: requiredField ? (v) => v == null ? "مطلوب" : null : null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ============================================================
  // 🎨 Input style
  // ============================================================
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.amber),
      filled: true,
      // ignore: deprecated_member_use
      fillColor: Colors.white.withOpacity(.12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        borderSide: BorderSide(color: Colors.white.withOpacity(.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        borderSide: BorderSide(color: Colors.white.withOpacity(.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.amber, width: 1.4),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================
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
        title: const Text(
          "تعديل بيانات المركبة",
          style: TextStyle(color: Colors.white),
        ),
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
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(.15)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildDropdown(
                          label: "الماركة",
                          icon: FontAwesomeIcons.car,
                          value: selectedBrand,
                          items: brands,
                          isLoading: loadingBrands,
                          onChanged: (v) async {
                            selectedBrand = v;
                            selectedModel = null;
                            selectedYear = null;
                            await _loadModels();
                            await _loadYears();
                            if (mounted) setState(() {});
                          },
                        ),
                        buildDropdown(
                          label: "الموديل",
                          icon: FontAwesomeIcons.gear,
                          value: selectedModel,
                          items: models,
                          isLoading: loadingModels,
                          onChanged: (v) async {
                            selectedModel = v;
                            selectedYear = null;
                            await _loadYears();
                            if (mounted) setState(() {});
                          },
                        ),
                        buildDropdown(
                          label: "سنة الصنع",
                          icon: FontAwesomeIcons.calendar,
                          value: selectedYear,
                          items: years,
                          isLoading: loadingYears,
                          onChanged: (v) => setState(() => selectedYear = v),
                        ),
                        buildDropdown(
                          label: "نوع الوقود",
                          icon: FontAwesomeIcons.gasPump,
                          value: selectedFuel,
                          items: fuelTypes,
                          isLoading: false,
                          onChanged: (v) => setState(() => selectedFuel = v),
                        ),
                        buildDropdown(
                          label: "حالة المركبة",
                          icon: FontAwesomeIcons.screwdriverWrench,
                          value: selectedCondition,
                          items: conditions,
                          isLoading: false,
                          onChanged: (v) =>
                              setState(() => selectedCondition = v),
                        ),
                        buildDropdown(
                          label: "اللون",
                          icon: FontAwesomeIcons.palette,
                          value: selectedColor,
                          items: colors,
                          isLoading: false,
                          onChanged: (v) => setState(() => selectedColor = v),
                        ),
                        _buildTextField(
                            "رقم اللوحة", FontAwesomeIcons.idCard, plateCtrl),
                        _buildTextField("رقم الهيكل (الشاصي)",
                            FontAwesomeIcons.hashtag, chassisCtrl),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: saving ? null : _saveEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              saving ? "جاري التحديث..." : "حفظ التعديلات",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: _inputStyle(label, icon),
          validator: (v) => (v == null || v.trim().isEmpty) ? "مطلوب" : null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  void dispose() {
    plateCtrl.dispose();
    chassisCtrl.dispose();
    super.dispose();
  }
}
