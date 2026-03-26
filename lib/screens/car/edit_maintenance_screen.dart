import 'package:flutter/material.dart';
// ignore: unused_import
import '../../services/api_service.dart';

class EditMaintenanceScreen extends StatefulWidget {
  final Map maintenance;

  const EditMaintenanceScreen({super.key, required this.maintenance});

  @override
  State<EditMaintenanceScreen> createState() => _EditMaintenanceScreenState();
}

class _EditMaintenanceScreenState extends State<EditMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController kmCtrl;
  late TextEditingController costCtrl;
  late TextEditingController notesCtrl;
  late String selectedType;
  DateTime? selectedDate;

  final types = [
    "تغيير زيت",
    "تغيير إطارات",
    "تغيير بطارية",
    "تنظيف بخاخات",
    "فلاتر",
    "تيل فرامل",
    "تشخيص أعطال",
    "صيانة عامة",
  ];

  @override
  void initState() {
    super.initState();

    final m = widget.maintenance;

    selectedType = m["type"];
    kmCtrl = TextEditingController(text: m["km"].toString());
    costCtrl = TextEditingController(text: m["cost"]?.toString() ?? "");
    notesCtrl = TextEditingController(text: m["notes"] ?? "");
    selectedDate = DateTime.tryParse(m["date"]);
  }

  Future pickDate() async {
    final now = DateTime.now();
    final pick = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (pick != null) setState(() => selectedDate = pick);
  }

  Future update() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = {
      "type": selectedType,
      "km": kmCtrl.text,
      "cost": costCtrl.text,
      "notes": notesCtrl.text,
      "date": selectedDate.toString(),
    };

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("تعديل الصيانة"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                value: selectedType,
                dropdownColor: Colors.black,
                items: types
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: const TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v!),
                decoration: _box("نوع الصيانة"),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _dec(),
                  child: Text(
                    selectedDate == null
                        ? "اختر التاريخ"
                        : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: kmCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _box("المسافة (كم)"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: costCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _box("التكلفة"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: notesCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _box("ملاحظات"),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: update,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 55)),
                child: const Text("حفظ"),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _box(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1C1F27),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  BoxDecoration _dec() => BoxDecoration(
        color: const Color(0xFF1C1F27),
        borderRadius: BorderRadius.circular(12),
      );
}
