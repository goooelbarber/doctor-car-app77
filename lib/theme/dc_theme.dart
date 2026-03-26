import 'package:flutter/material.dart';

class DcTheme {
  // نفس الأخضر اللي عندك
  static const Color brand = Color.fromARGB(255, 26, 217, 105);

  // خلفيات داكنة (اختياري)
  static const Color bg1 = Color(0xFF0B1220);
  static const Color bg2 = Color(0xFF081837);
  static const Color bg3 = Color(0xFF06101C);

  /// ✅ نفس التدرّج (أخضر -> أبيض)
  static LinearGradient greenWhite = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      brand.withOpacity(.92),
      Color.lerp(brand, Colors.white, .62)!,
      Colors.white,
    ],
    stops: const [0.0, 0.56, 1.0],
  );

  static Color brand3 = Color.lerp(brand, Colors.white, 0.18)!;
}
