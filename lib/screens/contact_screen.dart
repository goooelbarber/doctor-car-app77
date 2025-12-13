import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  final String phone = "01275649151";
  final String whatsapp = "01275649151";
  final String email = "support@doctorcar.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        /// 🔥 زر رجوع ذكي يعمل دائماً
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // يرجع للصفحة السابقة
            } else {
              Navigator.pushReplacementNamed(context, "/home");
            }
          },
        ),

        title: Text(
          "Contact Us",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            /// 📞 Call
            contactCard(
              icon: Icons.phone,
              title: "Phone Call",
              subtitle: phone,
              onTap: () => launchUrl(Uri(scheme: "tel", path: phone)),
            ),

            /// 💬 WhatsApp
            contactCard(
              icon: FontAwesomeIcons.whatsapp,
              title: "WhatsApp",
              subtitle: whatsapp,
              onTap: () => launchUrl(
                Uri.parse("https://wa.me/2$whatsapp"),
                mode: LaunchMode.externalApplication,
              ),
            ),

            /// ✉ Email
            contactCard(
              icon: Icons.email,
              title: "Email",
              subtitle: email,
              onTap: () => launchUrl(Uri.parse("mailto:$email")),
            ),
          ],
        ),
      ),
    );
  }

  Widget contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber, size: 32),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
