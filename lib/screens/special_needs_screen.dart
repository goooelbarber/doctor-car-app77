import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpecialNeedsScreen extends StatelessWidget {
  const SpecialNeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // خلفية داكنة
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          "دعم ذوي الهمم",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "اختر الخدمة التي تحتاجها",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            // الشبكة
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildAnimatedButton(
                    context,
                    "مساعدة فورية",
                    "يتم إرسال موقعك مباشرة لأقرب فريق دعم.",
                    Icons.sos,
                    const [Color(0xFFFF6B6B), Color(0xFFE63946)],
                  ),
                  _buildAnimatedButton(
                    context,
                    "نقل مجهز",
                    "طلب سيارة مجهزة للكرسي المتحرك.",
                    Icons.directions_car_filled_rounded,
                    const [Color(0xFF60A5FA), Color(0xFF2563EB)],
                  ),
                  _buildAnimatedButton(
                    context,
                    "صيانة خاصة",
                    "فنيين مدرّبين لصيانة سيارات ذوي الهمم.",
                    Icons.build_circle_rounded,
                    const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  _buildAnimatedButton(
                    context,
                    "تواصل فوري",
                    "تحدث مباشرة أو بلّغ بأمان.",
                    Icons.chat_bubble_rounded,
                    const [Color(0xFF34D399), Color(0xFF10B981)],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 1),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: GestureDetector(
          onTapDown: (_) {
            // تقليص الزر عند الضغط
            (context as Element).markNeedsBuild();
          },
          onTapCancel: () {
            // عودة الحجم الطبيعي
            (context as Element).markNeedsBuild();
          },
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("تم اختيار: $title"),
                behavior: SnackBarBehavior.floating,
                backgroundColor: gradientColors.last,
              ),
            );
          },
          child: _buildServiceCard(title, description, icon, gradientColors),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    String description,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
