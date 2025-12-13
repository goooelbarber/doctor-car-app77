import 'package:flutter/material.dart';

class VehicleHealthScreen extends StatelessWidget {
  const VehicleHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("حالة المركبة"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _VehicleCard(
            name: "Toyota Corolla 2020",
            health: 0.85,
            status: "ممتازة",
            lastCheck: "منذ 3 أيام",
          ),
          _VehicleCard(
            name: "Hyundai Elantra 2018",
            health: 0.55,
            status: "تحتاج صيانة",
            lastCheck: "منذ شهر",
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final String name;
  final double health;
  final String status;
  final String lastCheck;

  const _VehicleCard({
    required this.name,
    required this.health,
    required this.status,
    required this.lastCheck,
  });

  @override
  Widget build(BuildContext context) {
    final color = health > 0.7
        ? Colors.green
        : health > 0.4
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: health,
              color: color,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("الحالة: $status", style: TextStyle(color: color)),
                Text("آخر فحص: $lastCheck",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
