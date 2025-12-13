// 📁 lib/screens/car/widgets/car_maintenance_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/car_model.dart';

class CarMaintenanceCard extends StatelessWidget {
  final CarModel car;
  final bool darkMode;

  const CarMaintenanceCard({
    super.key,
    required this.car,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = darkMode
        ? Colors.blueGrey.shade900.withOpacity(.3)
        : Colors.white.withOpacity(.9);

    final Color textColor = darkMode ? Colors.white : const Color(0xFF0A1F44);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 25,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Maintenance",
              style: GoogleFonts.cairo(
                  fontSize: 20, color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          maintenanceRow("Last Oil Change",
              car.lastOilChange?.toString() ?? "Unknown", textColor),
          const SizedBox(height: 12),
          maintenanceRow("Next Oil Change",
              car.nextOilChange?.toString() ?? "Unknown", textColor),
          const SizedBox(height: 12),
          maintenanceRow("Last Service",
              car.lastService?.toString() ?? "Unknown", textColor),
        ],
      ),
    );
  }

  Widget maintenanceRow(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                color: textColor.withOpacity(.7), fontSize: 16)),
        Text(value,
            style: GoogleFonts.cairo(
                color: textColor, fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
