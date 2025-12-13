// ignore: unused_import
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:doctor_car_app/services/api_service.dart';
import 'package:doctor_car_app/screens/car/add_maintenance_screen.dart';
import 'package:doctor_car_app/screens/car/maintenance_history_screen.dart';

class CarDashboardScreen extends StatefulWidget {
  final Map vehicle;

  const CarDashboardScreen({super.key, required this.vehicle});

  @override
  State<CarDashboardScreen> createState() => _CarDashboardScreenState();
}

class _CarDashboardScreenState extends State<CarDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController speedCtrl;
  late AnimationController rpmCtrl;

  double speed = 0;
  double rpm = 0;

  List maintenanceHistory = [];
  Map? lastMaintenance;

  @override
  void initState() {
    super.initState();
    loadMaintenance();
    initAnimations();
  }

  void initAnimations() {
    speedCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    rpmCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    speedCtrl.addListener(() => setState(() => speed = speedCtrl.value * 180));
    rpmCtrl.addListener(() => setState(() => rpm = rpmCtrl.value * 8000));

    speedCtrl.forward();
    rpmCtrl.forward();
  }

  Future<void> loadMaintenance() async {
    final list = await ApiService.getMaintenanceHistory(widget.vehicle["_id"]);
    setState(() {
      maintenanceHistory = list;
      lastMaintenance = list.isNotEmpty ? list.first : null;
    });
  }

  @override
  void dispose() {
    speedCtrl.dispose();
    rpmCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------
  // INFO CARD
  // ------------------------------------------
  Widget infoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1C1F27), Color(0xFF13161C)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(.3),
              blurRadius: 10,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                Text(
                  value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ------------------------------------------
  // MAIN UI
  // ------------------------------------------
  @override
  Widget build(BuildContext context) {
    final car = widget.vehicle;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "${car["brand"]} ${car["model"]}",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.orangeAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MaintenanceHistoryScreen(
                    vehicleId: car["_id"],
                    vehicle: const {},
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // SPEED + RPM
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                gauge(speed, 180, Colors.orange, "km/h"),
                gauge(rpm, 8000, Colors.redAccent, "RPM"),
              ],
            ),

            const SizedBox(height: 30),

            // LAST MAINTENANCE
            infoCard(
              "آخر عملية صيانة",
              lastMaintenance == null
                  ? "لا يوجد"
                  : "${lastMaintenance!["type"]} - ${lastMaintenance!["km"]} km",
              Icons.build,
              Colors.orangeAccent,
            ),

            const SizedBox(height: 14),

            // NEXT SERVICE
            infoCard(
              "الصيانة القادمة",
              car["nextServiceKm"]?.toString() ?? "غير محدد",
              Icons.car_repair,
              Colors.greenAccent,
            ),

            const SizedBox(height: 25),

            // ADD MAINTENANCE BUTTON
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddMaintenanceScreen(vehicle: widget.vehicle),
                  ),
                );

                if (result != null) {
                  await ApiService.addMaintenance(
                    vehicleId: car["_id"],
                    type: result["type"],
                    km: result["km"],
                    cost: result["cost"],
                    notes: result["notes"],
                    date: result["date"],
                  );

                  loadMaintenance();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("إضافة عملية صيانة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 55),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------
  // GAUGE UI
  // ---------------------------------------------
  Widget gauge(double value, double maxValue, Color color, String label) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value / maxValue,
            strokeWidth: 12,
            backgroundColor: Colors.white12,
            color: color,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toInt().toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Text(label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
