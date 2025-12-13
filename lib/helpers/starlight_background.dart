import 'dart:math';
import 'package:flutter/material.dart';

class StarlightBackground extends StatefulWidget {
  const StarlightBackground({super.key});

  @override
  State<StarlightBackground> createState() => _StarlightBackgroundState();
}

class _StarlightBackgroundState extends State<StarlightBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final Random random = Random();

  List<Offset> stars = [];
  List<double> sizes = [];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    // إنشاء 150 نجمة
    for (int i = 0; i < 150; i++) {
      stars.add(Offset(random.nextDouble(), random.nextDouble()));
      sizes.add(random.nextDouble() * 1.8 + 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _StarsPainter(stars, sizes, controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _StarsPainter extends CustomPainter {
  final List<Offset> stars;
  final List<double> sizes;
  final double t;

  _StarsPainter(this.stars, this.sizes, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(.85);

    for (int i = 0; i < stars.length; i++) {
      final dx = stars[i].dx * size.width;
      final dy = stars[i].dy * size.height;

      double glow = (sin((t * 6.28) + i) + 1) / 2;

      paint.color = Colors.white.withOpacity(.3 + glow * .7);

      canvas.drawCircle(Offset(dx, dy), sizes[i] * (0.6 + glow * 0.8), paint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
