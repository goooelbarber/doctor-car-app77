// ================================================================
// FILE: lib/screens/account/account_settings_screen.dart
// ULTRA PRODUCTION VERSION
// ================================================================

import 'dart:io';
import 'package:doctor_car_app/screens/account/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:doctor_car_app/pages/home/home_page.dart';
import 'package:doctor_car_app/widgets/account/account_quick_actions.dart';
import 'package:doctor_car_app/screens/vehicles/vehicle_screen.dart';
import 'package:doctor_car_app/screens/account/security_center_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;
  String _language = 'ar';
  String _userName = 'مستخدم التطبيق';
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _language = prefs.getString('lang') ?? 'ar';
      _userName = prefs.getString('name') ?? 'مستخدم التطبيق';
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setString('lang', _language);
    await prefs.setString('name', _userName);
  }

  Future<void> _changeLang(String lang) async {
    setState(() => _language = lang);
    await context.setLocale(Locale(lang));
    _save();
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _profileImage = File(img.path));
  }

  Future<void> _editName() async {
    final c = TextEditingController(text: _userName);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تعديل الاسم"),
        content: TextField(controller: c),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              setState(() => _userName = c.text);
              _save();
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  Future<void> _contact(String t) async {
    final map = {
      'whatsapp': Uri.parse("https://wa.me/201275649151"),
      'email': Uri.parse("mailto:support@doctorcar.com"),
      'call': Uri.parse("tel:+201275649151"),
    };
    if (await canLaunchUrl(map[t]!)) {
      await launchUrl(map[t]!, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDarkMode ? const Color(0xff0D0F22) : const Color(0xffF6F7FB);
    final txt = _isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("حسابي",
            style: TextStyle(color: txt, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _profile(txt),
          const SizedBox(height: 20),
          const AccountQuickActions(),
          const SizedBox(height: 30),
          _title("لوحة التحكم", txt),
          _dashboard(),
          const SizedBox(height: 30),
          _title("الإعدادات", txt),
          _setting(Icons.language, Colors.blue, "اللغة",
              subtitle: _language == 'ar' ? "العربية" : "English",
              trailing: _langDropdown()),
          _switch(Icons.notifications, Colors.orange, "الإشعارات",
              _notificationsEnabled, (v) {
            setState(() => _notificationsEnabled = v);
            _save();
          }),
          _switch(Icons.dark_mode, Colors.purple, "الوضع الليلي", _isDarkMode,
              (v) {
            setState(() => _isDarkMode = v);
            _save();
          }),
          _setting(Icons.security, Colors.red, "الأمان",
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SecurityCenterScreen()))),
          _setting(Icons.notifications_active, Colors.amber, "مركز الإشعارات",
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()))),
          const SizedBox(height: 30),
          _title("الدعم الفني", txt),
          _support(),
          const SizedBox(height: 35),
          _logout(),
        ],
      ),
    );
  }

  // ================= UI =================

  Widget _profile(Color txt) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withOpacity(.1),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue,
                    child:
                        Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(_userName, style: TextStyle(color: txt, fontSize: 22)),
            TextButton(onPressed: _editName, child: const Text("تعديل الاسم")),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: .75),
            const Text("اكتمال الحساب 75%"),
          ],
        ),
      );

  Widget _dashboard() => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.2,
        children: [
          _dash(
              FontAwesomeIcons.store,
              "المتجر",
              Colors.teal,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HomePage()))),
          _dash(Icons.wallet, "المحفظة", Colors.orange, () {}),
          _dash(Icons.history, "الطلبات", Colors.blue, () {}),
          _dash(
              Icons.car_rental,
              "مركباتي",
              Colors.green,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const VehiclesScreen()))),
        ],
      );

  Widget _dash(IconData i, String t, Color c, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient:
                LinearGradient(colors: [c.withOpacity(.8), c.withOpacity(.5)]),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(i, color: Colors.white, size: 36),
            const SizedBox(height: 10),
            Text(t, style: const TextStyle(color: Colors.white)),
          ]),
        ),
      );

  Widget _title(String t, Color c) => Text(t,
      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: c));

  Widget _support() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _supportBtn(FontAwesomeIcons.whatsapp, "WhatsApp", Colors.green,
              () => _contact('whatsapp')),
          _supportBtn(
              Icons.email, "Email", Colors.blue, () => _contact('email')),
          _supportBtn(
              Icons.phone, "Call", Colors.orange, () => _contact('call')),
        ],
      );

  Widget _supportBtn(IconData i, String t, Color c, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Column(children: [
          CircleAvatar(
              backgroundColor: c.withOpacity(.15), child: Icon(i, color: c)),
          const SizedBox(height: 6),
          Text(t, style: TextStyle(color: c)),
        ]),
      );

  Widget _logout() => ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text("تسجيل الخروج"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        },
      );

  Widget _setting(IconData i, Color c, String t,
          {String? subtitle, Widget? trailing, VoidCallback? onTap}) =>
      Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
              backgroundColor: c.withOpacity(.15), child: Icon(i, color: c)),
          title: Text(t),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      );

  Widget _switch(
          IconData i, Color c, String t, bool v, Function(bool) onChanged) =>
      Card(
        child: SwitchListTile(
          value: v,
          onChanged: onChanged,
          title: Text(t),
          secondary: CircleAvatar(
              backgroundColor: c.withOpacity(.15), child: Icon(i, color: c)),
        ),
      );

  Widget _langDropdown() => DropdownButton<String>(
        value: _language,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'ar', child: Text("العربية")),
          DropdownMenuItem(value: 'en', child: Text("English")),
        ],
        onChanged: (v) => _changeLang(v!),
      );
}
