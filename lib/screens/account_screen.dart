import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:doctor_car_app/screens/vehicles/vehicle_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _notificationsEnabled = true;
  String _language = 'ar';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _language = prefs.getString('language') ?? 'ar';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('language', _language);
  }

  // 🔄 تغيير اللغة (مع حراسة mounted قبل أي استخدام لـ context بعد await)
  Future<void> _changeLanguage(String lang) async {
    setState(() => _language = lang);
    await _saveSettings();
    if (!mounted) return;
    await context.setLocale(Locale(lang));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang == 'ar'
              ? 'تم تغيير اللغة إلى العربية 🇪🇬'
              : 'Language changed to English 🇬🇧',
        ),
      ),
    );
  }

  // 🔗 روابط التواصل
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح التطبيق المطلوب')),
      );
    }
  }

  // ❌ حذف الحساب (يحترم mounted)
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse("https://yourapi.com/api/delete_account");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'reason': 'user_request'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await prefs.clear();
        if (!mounted) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حذف الحساب بنجاح ✅")),
        );
      } else {
        throw Exception('فشل الحذف');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء حذف الحساب ❌")),
      );
    }
  }

  // 🔘 نافذة اختيار اللغة
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تغيير اللغة"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: _language,
              onChanged: (v) {
                Navigator.pop(context);
                _changeLanguage('ar');
              },
            ),
            RadioListTile(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              onChanged: (v) {
                Navigator.pop(context);
                _changeLanguage('en');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text('حسابي', style: GoogleFonts.cairo()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👤 بيانات المستخدم
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("يوسف البربير",
                        style: GoogleFonts.cairo(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("+201275649151",
                        style: GoogleFonts.cairo(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("إعدادات الحساب"),

          // 🚗 إدارة المركبات
          _buildOption(
            FontAwesomeIcons.car,
            "إدارة المركبات (سياراتي)",
            "إضافة وتعديل بيانات السيارات",
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VehiclesScreen()),
            ),
          ),

          // 💳 طرق الدفع
          _buildOption(
            FontAwesomeIcons.creditCard,
            "طرق الدفع",
            "إدارة البطاقات والمحافظ",
            Colors.orange,
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("ميزة الدفع قادمة قريبًا 💳")),
            ),
          ),

          // 🌐 تغيير اللغة
          _buildOption(
            Icons.language,
            "تغيير اللغة",
            _language == 'ar' ? "العربية" : "English",
            Colors.green,
            _showLanguageDialog,
          ),

          // 🔔 الإشعارات
          _buildOption(
            Icons.notifications_active,
            "تشغيل الإشعارات",
            _notificationsEnabled ? "مفعلة" : "متوقفة",
            Colors.purple,
            () {
              setState(() => _notificationsEnabled = !_notificationsEnabled);
              _saveSettings();
            },
          ),

          const SizedBox(height: 20),
          _buildSectionTitle("التواصل مع الدعم الفني"),

          // 🔹 تواصل مع الدعم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _supportButton(FontAwesomeIcons.whatsapp, 'واتساب', Colors.green,
                  () => _openUrl('https://wa.me/201275649151')),
              _supportButton(FontAwesomeIcons.envelope, 'بريد إلكتروني',
                  Colors.blue, () => _openUrl('mailto:support@doctorcar.com')),
              _supportButton(FontAwesomeIcons.phone, 'اتصال', Colors.orange,
                  () => _openUrl('tel:+201275649151')),
            ],
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("إجراءات الحساب"),

          // 🚪 تسجيل الخروج
          ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم تسجيل الخروج بنجاح ✅")),
              );
            },
            icon: const Icon(FontAwesomeIcons.signOutAlt, color: Colors.white),
            label: const Text('تسجيل الخروج'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 10),

          // ❌ حذف الحساب (مع تأكيد سريع)
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("تأكيد حذف الحساب"),
                  content: const Text("هل أنت متأكد؟ لا يمكن التراجع."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("إلغاء"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteAccount(context);
                      },
                      child: const Text("حذف"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(FontAwesomeIcons.trashAlt, color: Colors.red),
            label: const Text('حذف الحساب',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
              color: const Color(0xFF1565C0),
              fontSize: 17,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildOption(IconData icon, String title, String subtitle, Color color,
      VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style:
                GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle,
            style:
                GoogleFonts.cairo(color: Colors.grey.shade600, fontSize: 13)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      ),
    );
  }

  Widget _supportButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 95,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(label,
                style: GoogleFonts.cairo(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
