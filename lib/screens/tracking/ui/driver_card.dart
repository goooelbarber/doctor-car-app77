import 'package:flutter/material.dart';

class DriverCard extends StatelessWidget {
  final String name;
  final String carModel;
  final String plate;
  final double rating;
  final String? imagePath;

  const DriverCard({
    super.key,
    required this.name,
    required this.carModel,
    required this.plate,
    required this.rating,
    this.imagePath, // صورة اختيارية
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // صورة الفني
        CircleAvatar(
          radius: 32,
          backgroundImage: imagePath != null
              ? AssetImage(imagePath!)
              : const AssetImage("assets/images/driver.png"),
        ),

        const SizedBox(width: 14),

        // بيانات
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              carModel,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 15,
              ),
            ),
            Text(
              plate,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),

            // تقييم
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade400, size: 18),
                Text(
                  " ${rating.toStringAsFixed(1)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                )
              ],
            )
          ],
        ),
      ],
    );
  }
}
