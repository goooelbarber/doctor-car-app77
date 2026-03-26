// ================================================================
// FILE: lib/screens/account/account_settings_screen.dart
// DOCTOR CAR - PREMIUM PRO VERSION
// ================================================================

import 'dart:io';

import 'package:doctor_car_app/core/theme/app_theme.dart';
import 'package:doctor_car_app/pages/home/home_page.dart';
import 'package:doctor_car_app/screens/account/notifications_screen.dart';
import 'package:doctor_car_app/screens/account/security_center_screen.dart';
import 'package:doctor_car_app/screens/orders/orders_screen.dart';
import 'package:doctor_car_app/screens/vehicles/vehicle_screen.dart';
import 'package:doctor_car_app/widgets/account/account_quick_actions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = 'ar';
  String _userName = 'مستخدم التطبيق';

  File? _profileImage;
  String? _profileImagePath;

  static const String _kNoti = 'notifications';
  static const String _kLang = 'lang';
  static const String _kName = 'name';
  static const String _kProfilePath = 'profileImagePath';

  bool get _isArabic => _language == 'ar';
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _primary => AppTheme.accent;
  Color get _primaryDark => AppTheme.accentDark;
  Color get _danger => AppTheme.danger;

  Color get _bg => _isDark ? AppTheme.bgEnd : AppTheme.ink;
  Color get _surface => _isDark ? const Color(0xFF10233E) : Colors.white;
  Color get _surface2 =>
      _isDark ? const Color(0xFF17345F) : const Color(0xFFF7FAFF);
  Color get _textMain => _isDark ? AppTheme.textLight : const Color(0xFF10233E);
  Color get _textSub => _isDark ? AppTheme.muted : const Color(0xFF62738E);

  Color get _border =>
      _isDark ? Colors.white.withOpacity(.09) : AppTheme.line.withOpacity(.12);

  LinearGradient get _pageGradient => _isDark
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF081A36),
            Color(0xFF122B50),
            Color(0xFF040D1D),
          ],
        )
      : LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFF4F7FC),
            Color(0xFFEAF1FB),
          ],
        );

  LinearGradient get _headerGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1D4F99),
          Color(0xFF163F7E),
          Color(0xFF0E2D60),
        ],
      );

  LinearGradient get _primaryGradient => AppTheme.ctaAquaGradient;

  List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: _isDark
              ? Colors.black.withOpacity(.22)
              : AppTheme.accent.withOpacity(.08),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get _strongGlow => [
        BoxShadow(
          color: _primary.withOpacity(.18),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(_isDark ? .18 : .04),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isDark ? const Color(0xFF10233E) : AppTheme.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final p = prefs.getString(_kProfilePath);
    setState(() {
      _notificationsEnabled = prefs.getBool(_kNoti) ?? true;
      _language = prefs.getString(_kLang) ?? 'ar';
      _userName = prefs.getString(_kName) ?? 'مستخدم التطبيق';
      _profileImagePath = p;

      if (p != null && p.isNotEmpty) {
        final f = File(p);
        if (f.existsSync()) _profileImage = f;
      }
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNoti, _notificationsEnabled);
    await prefs.setString(_kLang, _language);
    await prefs.setString(_kName, _userName);
    if (_profileImagePath != null) {
      await prefs.setString(_kProfilePath, _profileImagePath!);
    }
  }

  Future<void> _changeLang(String lang) async {
    setState(() => _language = lang);
    await context.setLocale(Locale(lang));
    await _save();
    _snack(lang == 'ar'
        ? 'تم تغيير اللغة بنجاح ✅'
        : 'Language changed successfully ✅');
  }

  Future<void> _pickImage() async {
    try {
      final img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img == null) return;

      final file = File(img.path);
      setState(() {
        _profileImage = file;
        _profileImagePath = img.path;
      });

      await _save();
      _snack(
          _isArabic ? 'تم تحديث الصورة الشخصية ✅' : 'Profile image updated ✅');
    } catch (_) {
      _snack(_isArabic ? 'تعذر اختيار الصورة' : 'Could not pick image');
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _userName);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          _isArabic ? 'تعديل الاسم' : 'Edit name',
          style: GoogleFonts.cairo(
            color: _textMain,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.cairo(
            color: _textMain,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: _isArabic ? 'اكتب اسمك' : 'Enter your name',
            hintStyle: GoogleFonts.cairo(color: _textSub),
            filled: true,
            fillColor: _surface2,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _primary, width: 1.4),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _isArabic ? 'إلغاء' : 'Cancel',
              style: GoogleFonts.cairo(
                color: _textSub,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              final value = controller.text.trim();
              setState(() {
                _userName = value.isEmpty ? _userName : value;
              });
              _save();
              Navigator.pop(context);
              _snack(_isArabic ? 'تم حفظ الاسم ✅' : 'Name saved ✅');
            },
            child: Text(
              _isArabic ? 'حفظ' : 'Save',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _contact(String type) async {
    final map = {
      'whatsapp': Uri.parse('https://wa.me/201275649151'),
      'email': Uri.parse('mailto:support@doctorcar.com'),
      'call': Uri.parse('tel:+201275649151'),
    };

    final uri = map[type];
    if (uri == null) return;

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _snack(_isArabic ? 'تعذر فتح الرابط' : 'Could not open link');
      }
    } catch (_) {
      _snack(_isArabic ? 'تعذر فتح الرابط' : 'Could not open link');
    }
  }

  double _profileCompletion() {
    double value = 0.45;
    if (_userName.trim().isNotEmpty && _userName != 'مستخدم التطبيق') {
      value += 0.20;
    }
    if (_profileImage != null) value += 0.20;
    if (_language.isNotEmpty) value += 0.10;
    if (_notificationsEnabled) value += 0.05;
    return value.clamp(0.0, 1.0);
  }

  String _completionText(double value) {
    final p = (value * 100).round();
    if (p >= 90)
      return _isArabic ? 'الحساب مكتمل تقريبًا' : 'Profile almost complete';
    if (p >= 70)
      return _isArabic ? 'الحساب في حالة ممتازة' : 'Profile looks great';
    if (p >= 50)
      return _isArabic
          ? 'يمكن تحسين بعض البيانات'
          : 'Some details can be improved';
    return _isArabic
        ? 'استكمل بياناتك للحصول على أفضل تجربة'
        : 'Complete your profile for a better experience';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = mq.textScaler.scale(1.0);
    final clamped = scale.clamp(1.0, 1.10);
    final fixedMq = mq.copyWith(textScaler: TextScaler.linear(clamped));

    return MediaQuery(
      data: fixedMq,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: _pageGradient)),
            Positioned(
              top: -50,
              right: -40,
              child: _bgOrb(170, _primary.withOpacity(.13)),
            ),
            Positioned(
              top: 180,
              left: -40,
              child: _bgOrb(120, Colors.white.withOpacity(_isDark ? .05 : .25)),
            ),
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
                    child: Column(
                      children: [
                        _profileHeader(),
                        const SizedBox(height: 16),
                        _statsRow(),
                        const SizedBox(height: 18),
                        const AccountQuickActions(),
                        const SizedBox(height: 22),
                        _sectionTitle(_isArabic ? 'لوحة التحكم' : 'Dashboard'),
                        const SizedBox(height: 12),
                        _dashboard(),
                        const SizedBox(height: 22),
                        _sectionTitle(_isArabic ? 'الإعدادات' : 'Settings'),
                        const SizedBox(height: 12),
                        _settingsBlock(),
                        const SizedBox(height: 22),
                        _sectionTitle(_isArabic ? 'الدعم الفني' : 'Support'),
                        const SizedBox(height: 12),
                        _support(),
                        const SizedBox(height: 26),
                        _logout(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding:
            const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isArabic ? 'حسابي' : 'My Account',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            Text(
              _isArabic
                  ? 'إدارة الحساب والإعدادات'
                  : 'Manage account and settings',
              style: GoogleFonts.cairo(
                color: Colors.white.withOpacity(.80),
                fontWeight: FontWeight.w700,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(gradient: _headerGradient),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bgOrb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            gradient: _primaryGradient,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _textMain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _solidCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(22)),
    bool withGlow = false,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: borderRadius,
        border: Border.all(color: _border),
        boxShadow: withGlow ? _strongGlow : _cardShadow,
      ),
      child: child,
    );
  }

  Widget _iconBadge(
    IconData icon, {
    double size = 56,
    double iconSize = 24,
    bool light = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: light
            ? LinearGradient(
                colors: [
                  Colors.white.withOpacity(.22),
                  Colors.white.withOpacity(.14),
                ],
              )
            : _primaryGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              light ? Colors.white.withOpacity(.18) : _primary.withOpacity(.18),
        ),
        boxShadow: [
          BoxShadow(
            color: (light ? Colors.white : _primary).withOpacity(.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  Widget _profileHeader() {
    final progress = _profileCompletion();
    final percent = (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: _headerGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _strongGlow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: _bgOrb(110, Colors.white.withOpacity(.08)),
          ),
          Positioned(
            bottom: -40,
            left: -10,
            child: _bgOrb(90, Colors.white.withOpacity(.05)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 94,
                          height: 94,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.14),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(.20)),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(.12),
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 44,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(.20)),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                              color: _primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isArabic
                                ? 'الحساب نشط وموثق'
                                : 'Account active and verified',
                            style: GoogleFonts.cairo(
                              color: Colors.white.withOpacity(.82),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: _editName,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withOpacity(.14),
                                ),
                              ),
                              child: Text(
                                _isArabic ? 'تعديل الاسم' : 'Edit name',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(.12)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _isArabic
                                  ? 'اكتمال الحساب'
                                  : 'Profile completion',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13.6,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$percent%',
                              style: GoogleFonts.cairo(
                                color: _primaryDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(.18),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _completionText(progress),
                          style: GoogleFonts.cairo(
                            color: Colors.white.withOpacity(.84),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _miniStat(
            icon: Icons.directions_car_filled_rounded,
            value: '3',
            label: _isArabic ? 'مركبات' : 'Vehicles',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniStat(
            icon: Icons.receipt_long_rounded,
            value: '12',
            label: _isArabic ? 'طلبات' : 'Orders',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniStat(
            icon: Icons.verified_user_rounded,
            value: '100%',
            label: _isArabic ? 'موثّق' : 'Verified',
          ),
        ),
      ],
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return _solidCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          _iconBadge(icon, size: 48, iconSize: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: _textMain,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: _textSub,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboard() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.95,
      children: [
        _dashboardCard(
          icon: FontAwesomeIcons.store,
          title: _isArabic ? 'المتجر' : 'Store',
          subtitle: _isArabic
              ? 'تصفح المنتجات والعروض'
              : 'Browse products and offers',
          tag: _isArabic ? 'مميز' : 'Featured',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          ),
        ),
        _dashboardCard(
          icon: Icons.account_balance_wallet_rounded,
          title: _isArabic ? 'المحفظة' : 'Wallet',
          subtitle: _isArabic ? 'رصيدك وعمليات الدفع' : 'Balance and payments',
          tag: _isArabic ? 'قريبًا' : 'Soon',
          onTap: () => _snack(
            _isArabic
                ? 'ميزة المحفظة قريبًا 💳'
                : 'Wallet feature coming soon 💳',
          ),
        ),
        _dashboardCard(
          icon: Icons.history_rounded,
          title: _isArabic ? 'الطلبات' : 'Orders',
          subtitle:
              _isArabic ? 'طلباتك السابقة والحالية' : 'Past and current orders',
          tag: _isArabic ? 'نشط' : 'Active',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrdersScreen()),
          ),
        ),
        _dashboardCard(
          icon: Icons.directions_car_filled_rounded,
          title: _isArabic ? 'مركباتي' : 'My Vehicles',
          subtitle:
              _isArabic ? 'إدارة سياراتك بسهولة' : 'Manage your cars easily',
          tag: _isArabic ? '3 مركبات' : '3 vehicles',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VehiclesScreen()),
          ),
        ),
        _dashboardCard(
          icon: Icons.shield_rounded,
          title: _isArabic ? 'الأمان' : 'Security',
          subtitle:
              _isArabic ? 'الحماية وكلمات المرور' : 'Protection and passwords',
          tag: _isArabic ? 'آمن' : 'Safe',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SecurityCenterScreen()),
          ),
        ),
        _dashboardCard(
          icon: Icons.notifications_active_rounded,
          title: _isArabic ? 'الإشعارات' : 'Alerts',
          subtitle: _isArabic
              ? 'تنبيهاتك وآخر التحديثات'
              : 'Alerts and latest updates',
          tag: _isArabic ? 'جديد' : 'New',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String tag,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _tap(onTap),
        borderRadius: BorderRadius.circular(24),
        child: _solidCard(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _iconBadge(icon, size: 58, iconSize: 25),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? Colors.white.withOpacity(.05)
                          : AppTheme.accentSoft.withOpacity(.85),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _border),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.cairo(
                        color: _isDark ? Colors.white : _primaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: _textSub,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    _isArabic ? 'فتح' : 'Open',
                    style: GoogleFonts.cairo(
                      color: _primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isArabic
                        ? Icons.arrow_back_rounded
                        : Icons.arrow_forward_rounded,
                    color: _primary,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsBlock() {
    return Column(
      children: [
        _settingTile(
          icon: Icons.language_rounded,
          title: _isArabic ? 'اللغة' : 'Language',
          subtitle: _language == 'ar' ? 'العربية' : 'English',
          trailing: _langDropdown(),
        ),
        _settingSwitchTile(
          icon: Icons.notifications_active_rounded,
          title: _isArabic ? 'الإشعارات' : 'Notifications',
          value: _notificationsEnabled,
          onChanged: (v) {
            setState(() => _notificationsEnabled = v);
            _save();
          },
        ),
        _settingTile(
          icon: Icons.security_rounded,
          title: _isArabic ? 'الأمان' : 'Security',
          subtitle: _isArabic
              ? 'إعدادات الحماية والخصوصية'
              : 'Protection and privacy settings',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SecurityCenterScreen()),
          ),
        ),
        _settingTile(
          icon: Icons.notifications_none_rounded,
          title: _isArabic ? 'مركز الإشعارات' : 'Notification Center',
          subtitle: _isArabic ? 'عرض آخر التنبيهات' : 'View latest alerts',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap == null ? null : () => _tap(onTap),
          borderRadius: BorderRadius.circular(20),
          child: _solidCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                _iconBadge(icon, size: 52, iconSize: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: _textMain,
                          fontSize: 15.3,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            color: _textSub,
                            fontSize: 12.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                trailing ??
                    Icon(
                      _isArabic
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: _textSub,
                      size: 24,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _solidCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            _iconBadge(icon, size: 52, iconSize: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontSize: 15.3,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: (v) => _tap(() => onChanged(v)),
              activeColor: _primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _langDropdown() {
    return DropdownButton<String>(
      value: _language,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(16),
      dropdownColor: _surface,
      style: GoogleFonts.cairo(
        color: _textMain,
        fontWeight: FontWeight.w900,
        fontSize: 13,
      ),
      iconEnabledColor: _primary,
      items: const [
        DropdownMenuItem(value: 'ar', child: Text('العربية')),
        DropdownMenuItem(value: 'en', child: Text('English')),
      ],
      onChanged: (v) {
        if (v == null) return;
        _changeLang(v);
      },
    );
  }

  Widget _support() {
    return Row(
      children: [
        Expanded(
          child: _supportButton(
            icon: FontAwesomeIcons.whatsapp,
            text: 'WhatsApp',
            onTap: () => _contact('whatsapp'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _supportButton(
            icon: Icons.email_rounded,
            text: 'Email',
            onTap: () => _contact('email'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _supportButton(
            icon: Icons.phone_rounded,
            text: 'Call',
            onTap: () => _contact('call'),
          ),
        ),
      ],
    );
  }

  Widget _supportButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(20),
      child: _solidCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _iconBadge(icon, size: 50, iconSize: 22),
            const SizedBox(height: 10),
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: _textMain,
                fontWeight: FontWeight.w900,
                fontSize: 12.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logout() {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: Text(
          _isArabic ? 'تسجيل الخروج' : 'Logout',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 15.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _danger,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        },
      ),
    );
  }
}
