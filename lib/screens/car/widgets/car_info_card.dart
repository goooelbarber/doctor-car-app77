import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/car_model.dart';

class CarInfoCard extends StatelessWidget {
  final CarModel car;
  final bool darkMode;

  const CarInfoCard({
    super.key,
    required this.car,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = darkMode
        ? Colors.white.withOpacity(.05)
        : Colors.white.withOpacity(.85);

    final Color textColor = darkMode ? Colors.white : const Color(0xFF0A1F44);

    return Container(
      padding: const EdgeInsets.all(18),
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
        children: [
          infoRow("Plate Number", car.plateNumber ?? "N/A", textColor),
          const SizedBox(height: 12),
          infoRow("VIN", car.vin ?? "N/A", textColor),
          const SizedBox(height: 12),
          infoRow("Mileage", "${car.mileage ?? 0} KM", textColor),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: textColor.withOpacity(.7),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
