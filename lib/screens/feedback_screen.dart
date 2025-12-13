// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  final String orderId;
  final String userId;

  const FeedbackScreen({
    super.key,
    required this.orderId,
    required this.userId,
    String? technicianName,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  int rating = 0;
  final TextEditingController commentController = TextEditingController();

  late AnimationController confettiCtrl;

  @override
  void initState() {
    super.initState();
    confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    confettiCtrl.dispose();
    super.dispose();
  }

  // ⭐ Star Widget
  Widget _star(int index) {
    return GestureDetector(
      onTap: () {
        setState(() => rating = index);
      },
      child: AnimatedScale(
        scale: (rating >= index) ? 1.25 : 1,
        duration: const Duration(milliseconds: 150),
        child: Icon(
          Icons.star_rounded,
          size: 55,
          color: (rating >= index) ? Colors.amber : Colors.grey.shade700,
        ),
      ),
    );
  }

  // 🔥 Confetti Particles
  Widget _confetti() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: confettiCtrl,
        builder: (_, __) {
          final t = confettiCtrl.value;
          return CustomPaint(
            painter: ConfettiPainter(t),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }

  // إرسال التقييم
  void _submitFeedback() async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("اختر التقييم أولاً 🌟")),
      );
      return;
    }

    confettiCtrl.forward(from: 0);

    await Future.delayed(const Duration(seconds: 2));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إرسال التقييم بنجاح ❤️")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _confetti(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  "تقييم الخدمة",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),
                const Text(
                  "نقدّر رأيك لتحسين خدماتنا دائمًا 💛",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                // ⭐⭐⭐⭐⭐ النجوم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => _star(i + 1)),
                ),

                const SizedBox(height: 30),

                // نص التقييم
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: TextField(
                      controller: commentController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "اكتب ملاحظاتك هنا…",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // زر الإرسال
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "إرسال التقييم",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// 🎉 Confetti Painter
class ConfettiPainter extends CustomPainter {
  final double progress;
  final Random rnd = Random();

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < 35; i++) {
      paint.color = Colors.primaries[i % Colors.primaries.length]
          .withOpacity(1 - progress);

      double dx = rnd.nextDouble() * size.width;
      double dy = (progress * size.height) + rnd.nextDouble() * 50;

      canvas.drawCircle(Offset(dx, dy), 5 + rnd.nextDouble() * 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
