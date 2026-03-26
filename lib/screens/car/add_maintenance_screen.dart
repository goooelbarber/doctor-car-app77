import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddMaintenanceScreen extends StatefulWidget {
  final Map vehicle;

  const AddMaintenanceScreen({super.key, required this.vehicle});

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Fields
  String? selectedType;
  DateTime? selectedDate;
  final kmCtrl = TextEditingController();
  final costCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  bool saving = false;

  final maintenanceTypes = [
    "تغيير زيت",
    "تغيير إطارات",
    "تغيير بطارية",
    "تنظيف بخاخات",
    "فلاتر",
    "تيل فرامل",
    "تشخيص أعطال",
    "صيانة عامة",
  ];

  // اختيار تاريخ
  Future<void> pickDate() async {
    DateTime now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // إرسال البيانات إلى السيرفر
  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    final result = await ApiService.addMaintenance(
      vehicleId: widget.vehicle["_id"],
      type: selectedType!,
      km: kmCtrl.text.trim(),
      cost: costCtrl.text.trim(),
      notes: notesCtrl.text.trim(),
      date: selectedDate?.toIso8601String() ?? DateTime.now().toString(),
    );

    setState(() => saving = false);

    if (result["error"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🔧 تم حفظ عملية الصيانة بنجاح"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("إضافة عملية صيانة",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.25),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // نوع الصيانة
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: Colors.black,
                      items: maintenanceTypes
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedType = v),
                      decoration: inputStyle("نوع الصيانة"),
                      validator: (v) => v == null ? "هذا الحقل مطلوب" : null,
                    ),

                    const SizedBox(height: 20),

                    // التاريخ
                    GestureDetector(
                      onTap: pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: inputBox(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate == null
                                  ? "اختر التاريخ"
                                  : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            const Icon(Icons.calendar_month,
                                color: Colors.white70),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // الكيلومترات
                    TextFormField(
                      controller: kmCtrl,
                      decoration: inputStyle("الكيلومترات الحالية"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "مطلوب" : null,
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    // التكلفة
                    TextFormField(
                      controller: costCtrl,
                      decoration: inputStyle("التكلفة (اختياري)"),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    // ملاحظات
                    TextFormField(
                      controller: notesCtrl,
                      decoration: inputStyle("ملاحظات"),
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: saving ? null : save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 55),
                      ),
                      child: Text(
                        saving ? "جارٍ الحفظ..." : "حفظ العملية",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1C1F27),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  BoxDecoration inputBox() {
    return BoxDecoration(
      color: const Color(0xFF1C1F27),
      borderRadius: BorderRadius.circular(12),
    );
  }
}
