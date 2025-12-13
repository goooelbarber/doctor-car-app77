import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    // نحدد النوع dynamic ثم نعمل cast داخل الـ itemBuilder
    final List<Map<String, dynamic>> items = [
      {"title": "الملف الشخصي", "icon": Icons.person},
      {"title": "المفضلة", "icon": Icons.favorite},
      {"title": "العناوين", "icon": Icons.location_on},
      {"title": "الدعم الفني", "icon": Icons.support_agent},
      {"title": "الإعدادات", "icon": Icons.settings},
      {"title": "تسجيل الخروج", "icon": Icons.logout},
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF3F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "المزيد",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final String title = items[i]["title"] as String;
          final IconData icon = items[i]["icon"] as IconData;

          return Material(
            color: Colors.white,
            elevation: 2,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: Icon(icon, size: 28, color: Colors.blue),
              title: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                // TODO: هنا تضيف التنقل لكل عنصر لو حابب
              },
            ),
          );
        },
      ),
    );
  }
}
