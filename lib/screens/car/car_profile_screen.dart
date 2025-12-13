// 📁 lib/screens/car/car_profile_screen.dart

import 'dart:ui';
import 'package:doctor_car_app/screens/car/edit_car_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CarProfileScreen extends StatelessWidget {
  final Map vehicle;

  const CarProfileScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            const Text("تفاصيل المركبة", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // خلفية
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF232526), Color(0xFF414345)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // المحتوى
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(.18)),
                  ),
                  child: Column(
                    children: [
                      // صورة رمزية
                      const Icon(FontAwesomeIcons.car,
                          color: Colors.amber, size: 80),
                      const SizedBox(height: 20),

                      infoItem("الماركة", vehicle["brand"]),
                      infoItem("الموديل", vehicle["model"]),
                      infoItem("سنة الصنع", vehicle["year"]),
                      infoItem("اللون", vehicle["color"]),
                      infoItem("نوع الوقود", vehicle["fuel"]),
                      infoItem("الحالة", vehicle["condition"]),
                      infoItem("رقم اللوحة", vehicle["plateNumber"]),
                      infoItem("رقم الهيكل (الشاصي)", vehicle["chassisNumber"]),

                      const SizedBox(height: 25),

                      // زر تعديل
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text("تعديل المركبة"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditVehicleScreen(vehicle: vehicle),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoItem(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(.10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(.8),
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
