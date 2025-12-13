import 'package:flutter/material.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الأجهزة المتصلة"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _deviceCard(
            icon: Icons.phone_android,
            title: "Android • Galaxy S23",
            subtitle: "القاهرة • نشط الآن",
            active: true,
          ),
          _deviceCard(
            icon: Icons.laptop_mac,
            title: "MacBook Pro",
            subtitle: "دبي • آخر نشاط أمس",
          ),
          _deviceCard(
            icon: Icons.phone_iphone,
            title: "iPhone 14",
            subtitle: "الرياض • منذ 3 أيام",
          ),
        ],
      ),
    );
  }

  Widget _deviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool active = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Icon(icon, size: 34),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: active
            ? const Chip(
                label: Text("هذا الجهاز"),
                backgroundColor: Colors.greenAccent,
              )
            : TextButton(
                onPressed: () {},
                child: const Text(
                  "تسجيل خروج",
                  style: TextStyle(color: Colors.red),
                ),
              ),
      ),
    );
  }
}
