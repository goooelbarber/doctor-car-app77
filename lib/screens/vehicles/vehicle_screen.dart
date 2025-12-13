import 'package:doctor_car_app/screens/car/edit_car_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctor_car_app/services/api_service.dart';
import 'package:doctor_car_app/screens/car/add_vehicle_screen.dart';
import 'package:doctor_car_app/screens/vehicles/car_dashboard_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<dynamic> vehicles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  // ============================================================
  // 🔵 جلب المركبات من السيرفر
  // ============================================================
  Future<void> _fetchVehicles() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final res = await ApiService.getVehicles(token);

    if (!mounted) return;

    setState(() {
      vehicles = res;
      loading = false;
    });
  }

  // ============================================================
  // 🗑 حذف المركبة
  // ============================================================
  Future<void> _deleteVehicle(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل تريد حذف هذه السيارة؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final res = await ApiService.deleteVehicle(token, id);

    if (!mounted) return;

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚗 تم حذف المركبة")),
      );
      _fetchVehicles();
    }
  }

  // ============================================================
  // ➕ إضافة مركبة
  // ============================================================
  Future<void> _goToAddCar() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
    );

    if (added == true) _fetchVehicles();
  }

  // ============================================================
  // 🎛 واجهة Dashboard في حالة عدم وجود سيارات
  // ============================================================
  Widget emptyView() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0F14), Color(0xFF1C1F27)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.blueGrey.shade800, width: 10),
                    gradient: const RadialGradient(
                      colors: [Color(0xFF13181E), Color(0xFF1E232A)],
                    ),
                  ),
                ),
                Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 18,
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.speed, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      "0 KM/H",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "لا توجد مركبات",
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "قم بإضافة مركبتك الآن",
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 40),

          // ✅ نفس الزر – Click مضمون
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: _goToAddCar,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3D3D), Color(0xFFFF6A00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  "➕ إضافة مركبة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🚗 بطاقة عرض كل مركبة
  // ============================================================
  Widget vehicleCard(car) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarDashboardScreen(vehicle: car),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1C1F27), Color(0xFF13161C)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.3),
              blurRadius: 10,
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
                  car["brand"] ?? "",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const Icon(FontAwesomeIcons.car, color: Colors.redAccent),
              ],
            ),
            const SizedBox(height: 10),
            info("الموديل", car["model"]),
            info("اللون", car["color"]),
            info("اللوحة", car["plateNumber"]),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  car["condition"] ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditVehicleScreen(vehicle: car),
                          ),
                        ).then((v) {
                          if (v == true) _fetchVehicles();
                        });
                      },
                      icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    ),
                    IconButton(
                      onPressed: () => _deleteVehicle(car["_id"]),
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget info(String label, value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value?.toString() ?? "-",
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white54)),
      ],
    );
  }

  // ============================================================
  // 🧩 الواجهة الرئيسية
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1F27),

        // ✅ حل سهم الرجوع
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,

        title: const Text(
          "لوحة المركبات",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : vehicles.isEmpty
              ? emptyView()
              : RefreshIndicator(
                  onRefresh: _fetchVehicles,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vehicles.length,
                    itemBuilder: (_, i) => vehicleCard(vehicles[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _goToAddCar,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
