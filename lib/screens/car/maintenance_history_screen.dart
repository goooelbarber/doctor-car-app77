import 'package:flutter/material.dart';
import 'package:doctor_car_app/services/api_service.dart';
import 'package:doctor_car_app/screens/car/edit_maintenance_screen.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  final String vehicleId;

  const MaintenanceHistoryScreen({
    super.key,
    required this.vehicleId,
    required Map vehicle,
  });

  @override
  State<MaintenanceHistoryScreen> createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  List history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ----------------- تحميل السجل -----------------
  Future<void> loadHistory() async {
    final data = await ApiService.getMaintenanceHistory(widget.vehicleId);
    setState(() {
      history = data;
      loading = false;
    });
  }

  // ----------------- حذف الصيانة -----------------
  Future<void> deleteMaintenance(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل تريد حذف عملية الصيانة؟"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("إلغاء")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("حذف", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await ApiService.deleteMaintenance(id);

    if (result["error"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"]), backgroundColor: Colors.red),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("تم حذف العملية"),
      backgroundColor: Colors.green,
    ));

    loadHistory();
  }

  // ----------------- عنصر واحد -----------------
  Widget maintenanceCard(m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F27),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                m["type"],
                style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),

              // 🔧 أزرار التعديل والحذف
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditMaintenanceScreen(maintenance: m),
                        ),
                      );

                      if (updated == true) loadHistory();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteMaintenance(m["_id"]),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Text("التاريخ: ${m["date"].toString().substring(0, 10)}",
              style: const TextStyle(color: Colors.white)),
          Text("المسافة: ${m["km"]} KM",
              style: const TextStyle(color: Colors.white)),
          if (m["cost"] != null && m["cost"].toString().isNotEmpty)
            Text("التكلفة: ${m["cost"]} ج.م",
                style: const TextStyle(color: Colors.white)),
          if (m["notes"] != null && m["notes"].toString().isNotEmpty)
            Text("ملاحظات: ${m["notes"]}",
                style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("سجل الصيانة", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : history.isEmpty
              ? const Center(
                  child: Text("لا يوجد عمليات صيانة",
                      style: TextStyle(color: Colors.white54, fontSize: 18)),
                )
              : RefreshIndicator(
                  onRefresh: loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: history.length,
                    itemBuilder: (_, i) => maintenanceCard(history[i]),
                  ),
                ),
    );
  }
}
