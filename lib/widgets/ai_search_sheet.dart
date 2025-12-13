import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiSearchSheet extends StatefulWidget {
  const AiSearchSheet({super.key});

  @override
  State<AiSearchSheet> createState() => _AiSearchSheetState();
}

class _AiSearchSheetState extends State<AiSearchSheet> {
  final TextEditingController controller = TextEditingController();
  String aiResponse = "";

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.95,
      initialChildSize: 0.75,
      minChildSize: 0.50,
      builder: (_, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: Colors.white.withOpacity(.2)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 55,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "كيف يمكنني مساعدتك؟",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _searchField(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        aiResponse,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "اكتب سؤالك…",
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(.6), fontSize: 16),
          border: InputBorder.none,
        ),
        onSubmitted: (txt) => _askAi(txt),
      ),
    );
  }

  void _askAi(String q) async {
    setState(() => aiResponse = "🤖 جاري التفكير…");

    await Future.delayed(const Duration(milliseconds: 700));

    setState(() => aiResponse = _smartAi(q));
  }

  String _smartAi(String q) {
    q = q.toLowerCase();

    if (q.contains("سحب") || q.contains("ونش")) {
      return "🚚 يبدو أنك تحتاج خدمة **سحب سيارة**.\nاضغط للانتقال الآن.";
    }

    if (q.contains("بنزين") || q.contains("نفد")) {
      return "⛽ خدمة تزويد الوقود الأقرب إليك متاحة الآن.";
    }

    if (q.contains("بطارية") || q.contains("ما بتدورش")) {
      return "🔋 ربما تحتاج **شحن أو تغيير بطارية**.";
    }

    return "🤖 لم أفهم تمامًا… جرب:\n• سحب\n• بنزين\n• بطارية\n• صيانة";
  }
}
