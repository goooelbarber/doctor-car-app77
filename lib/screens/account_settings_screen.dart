// ================================================================
// FILE: lib/screens/account/account_settings_screen.dart
// DOCTOR CAR - ULTRA PREMIUM DASHBOARD VERSION
// ================================================================

import 'dart:io';
import 'dart:ui';

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

class _AccountSettingsScreenState extends State<AccountSettingsScreen>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  String _language = 'ar';
  String _userName = 'مستخدم التطبيق';

  File? _profileImage;
  String? _profileImagePath;

  static const String _kNoti = 'notifications';
  static const String _kLang = 'lang';
  static const String _kName = 'name';
  static const String _kProfilePath = 'profileImagePath';

  late final AnimationController _bgController;
  late final AnimationController _pulseController;

  bool get _isArabic => _language == 'ar';

  Color get _primary => AppTheme.accent;
  Color get _primaryDark => AppTheme.accentDark;
  Color get _danger => AppTheme.danger;

  Color get _bg => const Color(0xFF050B14);
  Color get _surface => const Color(0xFF0B1422);
  Color get _surface2 => const Color(0xFF101B2A);
  // ignore: unused_element
  Color get _surface3 => const Color(0xFF17273B);

  Color get _textMain => const Color(0xFFF7FAFF);
  Color get _textSub => const Color(0xFFD4E3F7);
  // ignore: unused_element
  Color get _hint => const Color(0xFFA8BDD8);
  Color get _border => Colors.white.withOpacity(.07);

  LinearGradient get _pageGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF06101B),
          Color(0xFF081321),
          Color(0xFF040913),
        ],
      );

  LinearGradient get _heroGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF183A74),
          Color(0xFF0E2A57),
          Color(0xFF09172F),
        ],
      );

  LinearGradient get _primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF7AB3FF),
          Color(0xFF4A8FFF),
          Color(0xFF2A65D9),
        ],
      );

  List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.28),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];

  List<BoxShadow> get _strongGlow => [
        BoxShadow(
          color: _primary.withOpacity(.14),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(.24),
          blurRadius: 26,
          offset: const Offset(0, 14),
        ),
      ];

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _load();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pulseController.dispose();
    super.dispose();
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
        margin: const EdgeInsets.all(14),
        backgroundColor: const Color(0xFF11243E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
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
        if (f.existsSync()) {
          _profileImage = f;
        }
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
    _snack(
      lang == 'ar'
          ? 'تم تغيير اللغة بنجاح ✅'
          : 'Language changed successfully ✅',
    );
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
        _isArabic ? 'تم تحديث الصورة الشخصية ✅' : 'Profile image updated ✅',
      );
    } catch (_) {
      _snack(_isArabic ? 'تعذر اختيار الصورة' : 'Could not pick image');
    }
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

    if (p >= 90) {
      return _isArabic ? 'الحساب مكتمل تقريبًا' : 'Profile almost complete';
    }
    if (p >= 70) {
      return _isArabic ? 'الحساب في حالة ممتازة' : 'Profile looks great';
    }
    if (p >= 50) {
      return _isArabic
          ? 'يمكن تحسين بعض البيانات'
          : 'Some details can be improved';
    }
    return _isArabic
        ? 'استكمل بياناتك للحصول على أفضل تجربة'
        : 'Complete your profile for a better experience';
  }

  String _membershipLabel(double completion) {
    final p = (completion * 100).round();
    if (p >= 85) return _isArabic ? 'عضوية Elite' : 'Elite Member';
    if (p >= 65) return _isArabic ? 'عضوية Plus' : 'Plus Member';
    return _isArabic ? 'عضوية أساسية' : 'Basic Member';
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (_isArabic) {
      if (hour < 12) return 'صباح الخير';
      if (hour < 18) return 'مساء الخير';
      return 'مساء النور';
    } else {
      if (hour < 12) return 'Good morning';
      if (hour < 18) return 'Good afternoon';
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = mq.textScaler.scale(1.0);
    final clamped = scale.clamp(1.0, 1.10);
    final fixedMq = mq.copyWith(
      textScaler: TextScaler.linear(clamped),
    );

    return MediaQuery(
      data: fixedMq,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: _bg,
          body: AnimatedBuilder(
            animation: Listenable.merge([_bgController, _pulseController]),
            builder: (context, _) {
              return Stack(
                children: [
                  Container(decoration: BoxDecoration(gradient: _pageGradient)),
                  _backgroundDecor(),
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildSliverAppBar(),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                          child: Column(
                            children: [
                              _premiumProfileHeader(),
                              const SizedBox(height: 16),
                              _quickInsightRow(),
                              const SizedBox(height: 18),
                              const AccountQuickActions(),
                              const SizedBox(height: 22),
                              _sectionTitle(
                                _isArabic ? 'لوحة التحكم' : 'Dashboard',
                              ),
                              const SizedBox(height: 12),
                              _dashboard(),
                              const SizedBox(height: 22),
                              _sectionTitle(
                                _isArabic ? 'الإعدادات' : 'Settings',
                              ),
                              const SizedBox(height: 12),
                              _settingsBlock(),
                              const SizedBox(height: 22),
                              _sectionTitle(
                                _isArabic ? 'الدعم الفني' : 'Support',
                              ),
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _backgroundDecor() {
    final progress = _bgController.value;
    final pulse = 1 + (_pulseController.value * 0.04);

    return Stack(
      children: [
        Positioned(
          top: -90,
          right: -40,
          child: Transform.scale(
            scale: pulse,
            child: _glowOrb(240, _primary.withOpacity(.09)),
          ),
        ),
        Positioned(
          top: 230,
          left: -70,
          child: _glowOrb(170, const Color(0xFF4F8FFF).withOpacity(.07)),
        ),
        Positioned(
          bottom: -50,
          right: -20,
          child: _glowOrb(200, const Color(0xFF73A8FF).withOpacity(.05)),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _AccountBackgroundPainter(progress: progress),
          ),
        ),
      ],
    );
  }

  Widget _glowOrb(double size, Color color) {
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
              blurRadius: 90,
              spreadRadius: 20,
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
      expandedHeight: 132,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 16,
          bottom: 16,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isArabic ? 'حسابي' : 'My Account',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 17.5,
              ),
            ),
            Text(
              _isArabic
                  ? 'إدارة الحساب والإعدادات'
                  : 'Manage account and settings',
              style: GoogleFonts.cairo(
                color: Colors.white.withOpacity(.82),
                fontWeight: FontWeight.w700,
                fontSize: 10.6,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(gradient: _heroGradient),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -10,
                child: _glowOrb(120, Colors.white.withOpacity(.06)),
              ),
              Positioned(
                bottom: -30,
                left: -20,
                child: _glowOrb(90, Colors.white.withOpacity(.04)),
              ),
            ],
          ),
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
            borderRadius: BorderRadius.circular(999),
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

  Widget _glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(30)),
    bool glow = false,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _surface.withOpacity(.94),
            borderRadius: borderRadius,
            border: Border.all(color: _border),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(.045),
                Colors.white.withOpacity(.012),
              ],
            ),
            boxShadow: glow ? _strongGlow : _cardShadow,
          ),
          child: child,
        ),
      ),
    );
  }

  _DashboardPalette _paletteByIndex(int index) {
    const palettes = [
      _DashboardPalette(
        base: Color(0xFF4E8DFF),
        strong: Color(0xFF2563EB),
        soft: Color(0xFF93C5FD),
        tagBg: Color(0x1F60A5FA),
      ),
      _DashboardPalette(
        base: Color(0xFF00B8D9),
        strong: Color(0xFF0284C7),
        soft: Color(0xFF67E8F9),
        tagBg: Color(0x1F06B6D4),
      ),
      _DashboardPalette(
        base: Color(0xFF8B5CF6),
        strong: Color(0xFF6D28D9),
        soft: Color(0xFFC4B5FD),
        tagBg: Color(0x1F8B5CF6),
      ),
      _DashboardPalette(
        base: Color(0xFF10B981),
        strong: Color(0xFF059669),
        soft: Color(0xFF86EFAC),
        tagBg: Color(0x1F10B981),
      ),
      _DashboardPalette(
        base: Color(0xFFF59E0B),
        strong: Color(0xFFD97706),
        soft: Color(0xFFFCD34D),
        tagBg: Color(0x1FF59E0B),
      ),
      _DashboardPalette(
        base: Color(0xFFEF5DA8),
        strong: Color(0xFFDB2777),
        soft: Color(0xFFF9A8D4),
        tagBg: Color(0x1FEF5DA8),
      ),
    ];

    return palettes[index % palettes.length];
  }

  Widget _premiumIconShell({
    required IconData icon,
    required _DashboardPalette palette,
    double size = 58,
    double iconSize = 22,
    String? imagePath,
    bool compact = false,
  }) {
    final radius = compact ? 16.0 : 18.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius + 4),
        boxShadow: [
          BoxShadow(
            color: palette.base.withOpacity(.28),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius + 4),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    palette.soft.withOpacity(.32),
                    palette.base.withOpacity(.22),
                    palette.strong.withOpacity(.18),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(.08),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.alphaBlend(
                        Colors.white.withOpacity(.24),
                        palette.base,
                      ),
                      palette.base,
                      palette.strong,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(.20),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          if (imagePath != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Opacity(
                  opacity: 0.10,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 7,
            left: 8,
            right: 8,
            child: Container(
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(.42),
                    Colors.white.withOpacity(.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 7,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.08),
              ),
            ),
          ),
          Center(
            child: Container(
              width: size * .52,
              height: size * .52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.10),
                border: Border.all(
                  color: Colors.white.withOpacity(.10),
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumProfileHeader() {
    final progress = _profileCompletion();
    final percent = (progress * 100).round();
    final membership = _membershipLabel(progress);

    return Container(
      decoration: BoxDecoration(
        gradient: _heroGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: _strongGlow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -35,
            right: -18,
            child: _glowOrb(120, Colors.white.withOpacity(.08)),
          ),
          Positioned(
            bottom: -34,
            left: -8,
            child: _glowOrb(100, Colors.white.withOpacity(.05)),
          ),
          Positioned(
            top: 18,
            left: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(.10)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isArabic ? 'حساب موثّق' : 'Verified Account',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(.20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(.06),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(.16),
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
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Color(0xFFEAF3FF),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(.18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.12),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
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
                            _greeting(),
                            style: GoogleFonts.cairo(
                              color: Colors.white.withOpacity(.78),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 21,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            membership,
                            style: GoogleFonts.cairo(
                              color: Colors.white.withOpacity(.88),
                              fontWeight: FontWeight.w800,
                              fontSize: 12.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(.10)),
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
                                fontSize: 13.8,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
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
                      const SizedBox(height: 11),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 11,
                          backgroundColor: Colors.white.withOpacity(.16),
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
                            color: Colors.white.withOpacity(.82),
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

  Widget _quickInsightRow() {
    final palettes = [
      _paletteByIndex(0),
      _paletteByIndex(2),
      _paletteByIndex(3),
    ];

    return Row(
      children: [
        Expanded(
          child: _insightCard(
            icon: Icons.directions_car_filled_rounded,
            value: '3',
            label: _isArabic ? 'مركبات' : 'Vehicles',
            palette: palettes[0],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _insightCard(
            icon: Icons.receipt_long_rounded,
            value: '12',
            label: _isArabic ? 'طلبات' : 'Orders',
            palette: palettes[1],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _insightCard(
            icon: Icons.shield_rounded,
            value: '100%',
            label: _isArabic ? 'موثّق' : 'Verified',
            palette: palettes[2],
          ),
        ),
      ],
    );
  }

  Widget _insightCard({
    required IconData icon,
    required String value,
    required String label,
    required _DashboardPalette palette,
  }) {
    return _glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        children: [
          _premiumIconShell(
            icon: icon,
            palette: palette,
            size: 50,
            iconSize: 18,
            compact: true,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: _textMain,
              fontSize: 17.5,
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
    final items = <_DashboardItemData>[
      _DashboardItemData(
        icon: FontAwesomeIcons.store,
        title: _isArabic ? 'المتجر' : 'Store',
        subtitle:
            _isArabic ? 'تصفح المنتجات والعروض' : 'Browse products and offers',
        tag: _isArabic ? 'مميز' : 'Featured',
        imagePath: 'assets/icons_bg/store_bg.png',
        palette: _paletteByIndex(0),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        ),
      ),
      _DashboardItemData(
        icon: Icons.account_balance_wallet_rounded,
        title: _isArabic ? 'المحفظة' : 'Wallet',
        subtitle: _isArabic ? 'رصيدك وعمليات الدفع' : 'Balance and payments',
        tag: _isArabic ? 'قريبًا' : 'Soon',
        imagePath: 'assets/icons_bg/wallet_bg.png',
        palette: _paletteByIndex(1),
        onTap: () => _snack(
          _isArabic
              ? 'ميزة المحفظة قريبًا 💳'
              : 'Wallet feature coming soon 💳',
        ),
      ),
      _DashboardItemData(
        icon: Icons.history_rounded,
        title: _isArabic ? 'الطلبات' : 'Orders',
        subtitle:
            _isArabic ? 'طلباتك السابقة والحالية' : 'Past and current orders',
        tag: _isArabic ? 'نشط' : 'Active',
        imagePath: 'assets/icons_bg/orders_bg.png',
        palette: _paletteByIndex(2),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrdersScreen()),
        ),
      ),
      _DashboardItemData(
        icon: Icons.directions_car_filled_rounded,
        title: _isArabic ? 'مركباتي' : 'My Vehicles',
        subtitle:
            _isArabic ? 'إدارة سياراتك بسهولة' : 'Manage your cars easily',
        tag: _isArabic ? '3 مركبات' : '3 vehicles',
        imagePath: 'assets/icons_bg/cars_bg.png',
        palette: _paletteByIndex(3),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VehiclesScreen()),
        ),
      ),
      _DashboardItemData(
        icon: Icons.shield_rounded,
        title: _isArabic ? 'الأمان' : 'Security',
        subtitle:
            _isArabic ? 'الحماية وكلمات المرور' : 'Protection and passwords',
        tag: _isArabic ? 'آمن' : 'Safe',
        imagePath: 'assets/icons_bg/security_bg.png',
        palette: _paletteByIndex(4),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecurityCenterScreen()),
        ),
      ),
      _DashboardItemData(
        icon: Icons.notifications_active_rounded,
        title: _isArabic ? 'الإشعارات' : 'Alerts',
        subtitle:
            _isArabic ? 'تنبيهاتك وآخر التحديثات' : 'Alerts and latest updates',
        tag: _isArabic ? 'جديد' : 'New',
        imagePath: 'assets/icons_bg/alerts_bg.png',
        palette: _paletteByIndex(5),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        ),
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _dashboardCard(item: item);
      },
    );
  }

  Widget _dashboardCard({
    required _DashboardItemData item,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _tap(item.onTap),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: item.palette.base.withOpacity(.08),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: _glassCard(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            borderRadius: BorderRadius.circular(28),
            glow: true,
            child: Stack(
              children: [
                Positioned(
                  top: -18,
                  right: -12,
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.palette.base.withOpacity(.08),
                      boxShadow: [
                        BoxShadow(
                          color: item.palette.base.withOpacity(.12),
                          blurRadius: 34,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _premiumIconShell(
                          icon: item.icon,
                          palette: item.palette,
                          size: 48,
                          iconSize: 18,
                          imagePath: item.imagePath,
                          compact: true,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: item.palette.tagBg,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: item.palette.base.withOpacity(.18),
                            ),
                          ),
                          child: Text(
                            item.tag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: _textMain,
                              fontSize: 9.8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFF8FBFF),
                        fontSize: 15.6,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFD8E6FA),
                        fontSize: 11.3,
                        fontWeight: FontWeight.w700,
                        height: 1.32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          _isArabic ? 'فتح' : 'Open',
                          style: GoogleFonts.cairo(
                            color: item.palette.soft,
                            fontWeight: FontWeight.w900,
                            fontSize: 12.2,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          _isArabic
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded,
                          color: item.palette.soft,
                          size: 17,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
          palette: _paletteByIndex(0),
        ),
        _settingSwitchTile(
          icon: Icons.notifications_active_rounded,
          title: _isArabic ? 'الإشعارات' : 'Notifications',
          value: _notificationsEnabled,
          palette: _paletteByIndex(5),
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
          palette: _paletteByIndex(4),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SecurityCenterScreen()),
          ),
        ),
        _settingTile(
          icon: Icons.notifications_none_rounded,
          title: _isArabic ? 'مركز الإشعارات' : 'Notification Center',
          subtitle: _isArabic ? 'عرض آخر التنبيهات' : 'View latest alerts',
          palette: _paletteByIndex(2),
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
    required _DashboardPalette palette,
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
          borderRadius: BorderRadius.circular(22),
          child: _glassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            borderRadius: BorderRadius.circular(22),
            child: Row(
              children: [
                _premiumIconShell(
                  icon: icon,
                  palette: palette,
                  size: 48,
                  iconSize: 18,
                  compact: true,
                ),
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
                          fontSize: 15.4,
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
    required _DashboardPalette palette,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _glassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderRadius: BorderRadius.circular(22),
        child: Row(
          children: [
            _premiumIconShell(
              icon: icon,
              palette: palette,
              size: 48,
              iconSize: 18,
              compact: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontSize: 15.4,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: (v) => _tap(() => onChanged(v)),
              activeColor: palette.base,
              activeTrackColor: palette.soft.withOpacity(.45),
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
      dropdownColor: _surface2,
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
            palette: _paletteByIndex(3),
            onTap: () => _contact('whatsapp'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _supportButton(
            icon: Icons.email_rounded,
            text: 'Email',
            palette: _paletteByIndex(1),
            onTap: () => _contact('email'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _supportButton(
            icon: Icons.phone_rounded,
            text: 'Call',
            palette: _paletteByIndex(4),
            onTap: () => _contact('call'),
          ),
        ),
      ],
    );
  }

  Widget _supportButton({
    required IconData icon,
    required String text,
    required _DashboardPalette palette,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(22),
      child: _glassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            _premiumIconShell(
              icon: icon,
              palette: palette,
              size: 48,
              iconSize: 17,
              compact: true,
            ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _danger.withOpacity(.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SizedBox(
        height: 58,
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          label: Text(
            _isArabic ? 'تسجيل الخروج' : 'Logout',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 15.6,
            ),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: _danger,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          },
        ),
      ),
    );
  }
}

class _DashboardItemData {
  const _DashboardItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.palette,
    required this.onTap,
    this.imagePath,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final _DashboardPalette palette;
  final VoidCallback onTap;
  final String? imagePath;
}

class _DashboardPalette {
  const _DashboardPalette({
    required this.base,
    required this.strong,
    required this.soft,
    required this.tagBg,
  });

  final Color base;
  final Color strong;
  final Color soft;
  final Color tagBg;
}

class _AccountBackgroundPainter extends CustomPainter {
  _AccountBackgroundPainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double shift = progress * 140;

    final Paint softLine = Paint()
      ..color = Colors.white.withOpacity(.016)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    final Paint brightLine = Paint()
      ..color = const Color(0xFF8FBFFF).withOpacity(.045)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    for (double x = -size.width; x < size.width * 2; x += 96) {
      canvas.drawLine(
        Offset(x - shift, -40),
        Offset(x + size.height * .54 - shift, size.height + 50),
        softLine,
      );
    }

    for (double x = -size.width + 30; x < size.width * 2; x += 180) {
      canvas.drawLine(
        Offset(x - shift * .55, -40),
        Offset(x + size.height * .48 - shift * .55, size.height + 60),
        brightLine,
      );
    }

    final Paint wave = Paint()
      ..color = const Color(0xFF9BC8FF).withOpacity(.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final Path topWave = Path()
      ..moveTo(0, size.height * .16)
      ..quadraticBezierTo(
        size.width * .25,
        size.height * .08,
        size.width * .54,
        size.height * .16,
      )
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .22,
        size.width,
        size.height * .13,
      );

    final Path bottomWave = Path()
      ..moveTo(0, size.height * .82)
      ..quadraticBezierTo(
        size.width * .20,
        size.height * .78,
        size.width * .42,
        size.height * .86,
      )
      ..quadraticBezierTo(
        size.width * .74,
        size.height * .96,
        size.width,
        size.height * .89,
      );

    canvas.drawPath(topWave, wave);
    canvas.drawPath(bottomWave, wave);

    final Paint dotPaint = Paint()
      ..color = const Color(0xFFB9D8FF).withOpacity(.05);

    for (double x = 18; x < size.width; x += 56) {
      canvas.drawCircle(Offset(x, size.height * .24), 1.25, dotPaint);
    }

    for (double x = 14; x < size.width; x += 62) {
      canvas.drawCircle(Offset(x, size.height * .72), 1.15, dotPaint);
    }

    final Paint ringPaint = Paint()
      ..color = const Color(0xFF9BC8FF).withOpacity(.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(
      Offset(size.width * .86, size.height * .18),
      34,
      ringPaint,
    );
    canvas.drawCircle(
      Offset(size.width * .16, size.height * .58),
      26,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AccountBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
