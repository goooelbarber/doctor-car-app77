import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import 'vehicles/vehicle_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _notificationsEnabled = true;
  String _language = 'ar';

  // ====== Doctor Car Dark Blue Theme ======
  static const Color _brand = Color(0xFF1B4F9C);
  static const Color _bg1 = Color(0xFF081A36);
  // ignore: unused_field
  static const Color _bg2 = Color(0xFF0B2348);
  static const Color _bg3 = Color(0xFF040D1D);

  Color get _brand2 => Color.lerp(_brand, const Color(0xFF040D1D), 0.22)!;
  // ignore: unused_element
  Color get _brand3 => Color.lerp(_brand, Colors.white, 0.12)!;

  LinearGradient get _screenBgGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _bg1,
          Color.lerp(_bg1, _brand2, .08)!,
          _bg3,
        ],
      );

  LinearGradient get _bluePrimaryGradient => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF1B4F99),
          Color(0xFF245AA6),
          Color(0xFF153F78),
        ],
        stops: [0.0, 0.56, 1.0],
      );

  LinearGradient get _blueGlassGradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          _brand.withOpacity(.24),
          Colors.white.withOpacity(.08),
          Colors.white.withOpacity(.05),
        ],
        stops: const [0.0, 0.60, 1.0],
      );

  List<BoxShadow> get _glow => [
        BoxShadow(
          color: _brand.withOpacity(.22),
          blurRadius: 26,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(.22),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.22),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
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

  Future<void> _changeLanguage(String lang) async {
    setState(() => _language = lang);
    await _saveSettings();
    if (!mounted) return;
    await context.setLocale(Locale(lang));
    if (!mounted) return;

    _snack(
      lang == 'ar'
          ? 'تم تغيير اللغة إلى العربية 🇪🇬'
          : 'Language changed to English 🇬🇧',
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(.88),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _snack('تعذر فتح التطبيق المطلوب');
      }
    } catch (_) {
      _snack('تعذر فتح التطبيق المطلوب');
    }
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _snack('تم النسخ ✅');
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse("https://yourapi.com/api/delete_account");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': 'user_request'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await prefs.clear();
        if (!mounted) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
        _snack("تم حذف الحساب بنجاح ✅");
      } else {
        throw Exception('فشل الحذف');
      }
    } catch (_) {
      if (!mounted) return;
      _snack("حدث خطأ أثناء حذف الحساب ❌");
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF10233E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "تغيير اللغة",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.white70,
              ),
              child: RadioListTile(
                activeColor: _brand,
                title: Text(
                  'العربية',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                value: 'ar',
                groupValue: _language,
                onChanged: (_) {
                  Navigator.pop(context);
                  _changeLanguage('ar');
                },
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.white70,
              ),
              child: RadioListTile(
                activeColor: _brand,
                title: Text(
                  'English',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                value: 'en',
                groupValue: _language,
                onChanged: (_) {
                  Navigator.pop(context);
                  _changeLanguage('en');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = mq.textScaler.scale(1.0);
    final clamped = scale.clamp(1.0, 1.15);
    final fixedMq = mq.copyWith(textScaler: TextScaler.linear(clamped));

    return MediaQuery(
      data: fixedMq,
      child: Scaffold(
        backgroundColor: _bg1,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: _screenBgGradient)),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                children: [
                  _profileCard(),
                  const SizedBox(height: 18),
                  _sectionTitle("إعدادات الحساب"),
                  _optionCard(
                    icon: FontAwesomeIcons.car,
                    title: "إدارة المركبات (سياراتي)",
                    subtitle: "إضافة وتعديل بيانات السيارات",
                    chipText: "PRO",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                    ),
                  ),
                  _optionCard(
                    icon: FontAwesomeIcons.creditCard,
                    title: "طرق الدفع",
                    subtitle: "إدارة البطاقات والمحافظ",
                    chipText: "قريبًا",
                    onTap: () => _snack("ميزة الدفع قادمة قريبًا 💳"),
                  ),
                  _optionCard(
                    icon: Icons.language,
                    title: "تغيير اللغة",
                    subtitle: _language == 'ar' ? "العربية" : "English",
                    onTap: _showLanguageDialog,
                  ),
                  _optionCard(
                    icon: Icons.notifications_active,
                    title: "تشغيل الإشعارات",
                    subtitle: _notificationsEnabled ? "مفعلة" : "متوقفة",
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeColor: _brand,
                      onChanged: (v) {
                        _tap(() => setState(() => _notificationsEnabled = v));
                        _saveSettings();
                      },
                    ),
                    onTap: () {
                      _tap(() => setState(() =>
                          _notificationsEnabled = !_notificationsEnabled));
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle("التواصل مع الدعم الفني"),
                  _supportRow(),
                  const SizedBox(height: 18),
                  _sectionTitle("إجراءات الحساب"),
                  _dangerActions(context),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        'حسابي',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w900,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _bg3,
              Color.lerp(_bg3, _brand2, .10)!,
              Colors.transparent,
            ],
            stops: const [0.0, 0.72, 1.0],
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: "نسخ الرقم",
          onPressed: () => _copyText("+201275649151"),
          icon: Icon(Icons.copy_rounded, color: Colors.white.withOpacity(.90)),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _profileCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: _glow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _blueGlassGradient,
              border: Border.all(color: _brand.withOpacity(.22)),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: _bluePrimaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _brand.withOpacity(.24),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "يوسف البربير",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(.75),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "+201275649151",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                color: Colors.white.withOpacity(.78),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _copyText("+201275649151"),
                            splashRadius: 18,
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: Colors.white.withOpacity(.75),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(.10),
                          ),
                        ),
                        child: Text(
                          "حساب نشط",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 22,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    String? chipText,
  }) {
    return GestureDetector(
      onTap: () => _tap(onTap),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: _cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                gradient: _blueGlassGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(.10)),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: _bluePrimaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _brand.withOpacity(.18)),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(.72),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.8,
                      height: 1.20,
                    ),
                  ),
                ),
                trailing: trailing ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (chipText != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _brand.withOpacity(.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _brand.withOpacity(.22),
                              ),
                            ),
                            child: Text(
                              chipText,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withOpacity(.70),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _supportRow() {
    return Row(
      children: [
        Expanded(
          child: _supportButton(
            icon: FontAwesomeIcons.whatsapp,
            label: 'واتساب',
            onTap: () => _openUrl('https://wa.me/201275649151'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _supportButton(
            icon: FontAwesomeIcons.envelope,
            label: 'إيميل',
            onTap: () => _openUrl('mailto:support@doctorcar.com'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _supportButton(
            icon: FontAwesomeIcons.phone,
            label: 'اتصال',
            onTap: () => _openUrl('tel:+201275649151'),
          ),
        ),
      ],
    );
  }

  Widget _supportButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: _blueGlassGradient,
          border: Border.all(color: Colors.white.withOpacity(.10)),
          boxShadow: _cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: _bluePrimaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dangerActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
              _snack("تم تسجيل الخروج بنجاح ✅");
            },
            icon: const Icon(FontAwesomeIcons.signOutAlt, color: Colors.white),
            label: Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 15.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: _brand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 54,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF10233E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  title: Text(
                    "تأكيد حذف الحساب",
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  content: Text(
                    "هل أنت متأكد؟ لا يمكن التراجع.",
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "إلغاء",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteAccount(context);
                      },
                      child: Text(
                        "حذف",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(FontAwesomeIcons.trashAlt, color: Colors.red),
            label: Text(
              'حذف الحساب',
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.withOpacity(.75), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white.withOpacity(.02),
            ),
          ),
        ),
      ],
    );
  }
}
