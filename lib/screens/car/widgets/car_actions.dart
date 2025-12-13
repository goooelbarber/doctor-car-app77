// 📁 lib/screens/car/widgets/car_actions.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/car_model.dart';

class CarActions extends StatelessWidget {
  final CarModel car;
  final bool darkMode;

  const CarActions({
    super.key,
    required this.car,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color btnColor =
        darkMode ? const Color(0xFFFFC107) : const Color(0xFF0A2A5A);

    final Color textColor = darkMode ? Colors.black : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        actionButton(Icons.edit, "Edit", btnColor, textColor, () {}),
        actionButton(Icons.delete, "Delete", Colors.red, Colors.white, () {}),
      ],
    );
  }

  Widget actionButton(IconData icon, String text, Color bg, Color txtColor,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: bg,
        ),
        child: Row(
          children: [
            Icon(icon, color: txtColor, size: 18),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.cairo(color: txtColor, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
