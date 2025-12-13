// 📁 lib/screens/car/widgets/car_header.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/car_model.dart';

class CarHeader extends StatelessWidget {
  final CarModel car;
  final bool darkMode;

  const CarHeader({
    super.key,
    required this.car,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = darkMode ? Colors.white : const Color(0xFF0A1F44);

    return Column(
      children: [
        // 🔙 زر رجوع
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textColor, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // 🚗 صورة السيارة
        Center(
          child: Container(
            height: 160,
            width: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: car.imageUrl != null
                    ? NetworkImage(car.imageUrl!)
                    : const AssetImage("assets/images/car_placeholder.png")
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.25),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        // 🏷️ اسم السيارة
        Text(
          "${car.brandId} ${car.model}",
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),

        Text(
          "Model ${car.years}",
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: textColor.withOpacity(.7),
          ),
        ),
      ],
    );
  }
}
