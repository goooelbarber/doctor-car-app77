import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool darkMode = true;
  bool notifications = true;
  bool gps = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0B1120),

      /// ---------------- APPBAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: GoogleFonts.cairo(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      /// ---------------- BODY ----------------
      body: Container(
        padding: const EdgeInsets.only(top: 120, left: 20, right: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0B1120),
              const Color(0xFF0F172A),
              Colors.black.withOpacity(.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            buildSettingCard(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              value: darkMode,
              onChange: (v) => setState(() => darkMode = v),
            ),

            buildSettingCard(
              icon: Icons.notifications_active_rounded,
              title: "Notifications",
              value: notifications,
              onChange: (v) => setState(() => notifications = v),
            ),

            buildSettingCard(
              icon: Icons.location_on_rounded,
              title: "GPS Services",
              value: gps,
              onChange: (v) => setState(() => gps = v),
            ),

            const SizedBox(height: 12),

            /// 🔥 إعدادات إضافية
            sectionTitle("More Settings"),

            buildStaticSetting(
              icon: Icons.language_rounded,
              title: "Language",
              subtitle: "Arabic / English",
              onTap: () {},
            ),

            buildStaticSetting(
              icon: Icons.lock_outline_rounded,
              title: "Change Password",
              subtitle: "Update your password",
              onTap: () {},
            ),

            buildStaticSetting(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              subtitle: "Read our privacy terms",
              onTap: () {},
            ),

            buildStaticSetting(
              icon: Icons.info_outline_rounded,
              title: "About App",
              subtitle: "Doctor Car App v1.0",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  /// ------------------------------------------
  ///  إعداد يتحول ON/OFF (Card Premium)
  /// ------------------------------------------
  Widget buildSettingCard({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChange,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2436).withOpacity(.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.amber),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.black,
            activeTrackColor: Colors.amber,
            inactiveThumbColor: Colors.white,
            onChanged: onChange,
          ),
        ],
      ),
    );
  }

  /// ------------------------------------------
  ///  إعداد ثابت يفتح صفحة أخرى
  /// ------------------------------------------
  Widget buildStaticSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 10),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: Colors.amber,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
