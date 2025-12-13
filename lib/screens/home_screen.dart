// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';
import 'package:doctor_car_app/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// SCREENS
import 'contact_screen.dart';
import 'road_services_screen.dart';
import 'smart_accident_screen.dart';
import 'account_settings_screen.dart';
import 'package:doctor_car_app/screens/about/about_us_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // اللغة و الثيم
  bool _isArabic = true;
  final bool _isDark = true;

  // Slider
  late PageController _bannerCtrl;
  int _currentBanner = 0;

  // Fade Animation
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Button Animation
  double _btnScale = 1.0;

  // Bottom nav index
  int _navIndex = 0;

  // Call Button Animation
  late AnimationController _callCtrl;
  late Animation<double> _callAnim;

  // 🔔 Notification Animation
  bool _showNotif = false;
  late AnimationController _notifCtrl;
  late Animation<double> _notifAnim;

  @override
  void initState() {
    super.initState();

    _bannerCtrl = PageController();
    Future.delayed(const Duration(milliseconds: 700), _autoSlide);

    // Fade
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // Call button animation
    _callCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..forward();
    _callAnim = CurvedAnimation(parent: _callCtrl, curve: Curves.easeOutBack);

    // Notification Animation
    _notifCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _notifAnim = CurvedAnimation(parent: _notifCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    _fadeCtrl.dispose();
    _callCtrl.dispose();
    _notifCtrl.dispose();
    super.dispose();
  }

  // ---------------- THEME COLORS ----------------

  LinearGradient get _gold => const LinearGradient(
        colors: [Color(0xffE8C87A), Color(0xffB68A32)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  Color get _bgColor =>
      _isDark ? const Color(0xff0A0D14) : const Color(0xffF3F4F6);
  Color get _textColor => _isDark ? Colors.white : Colors.black87;
  Color get _iconColor => _isDark ? Colors.white : Colors.black87;

  // ---------------- HELPERS ----------------

  void _autoSlide() {
    if (!mounted) return;
    _currentBanner++;
    _bannerCtrl.animateToPage(_currentBanner % 9,
        duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
    Future.delayed(const Duration(seconds: 4), _autoSlide);
  }

  // ---------------- POPUP: CALL ACTION SHEET ----------------
  void _showCallSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _isDark
                  ? const Color.fromARGB(255, 218, 9, 9).withOpacity(.8)
                  : Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _callOption(Icons.support_agent, "خدمة العملاء", Colors.blue,
                    () {/* Call */}),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                _callOption(Icons.email, "إرسال بريد", Colors.orange, () {
                  /* Email */
                }),
                const SizedBox(height: 8),
                _callOption(
                    Icons.local_shipping, "طلب سحب سيارة", Colors.deepPurple,
                    () {/* Request Tow */}),
                const SizedBox(height: 8),
                _callOption(Icons.emergency, "طوارئ 112", Colors.red, () {
                  /* Emergency */
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _callOption(
      IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isDark ? Colors.white.withOpacity(.06) : Colors.black12,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 14),
            Text(text,
                style: TextStyle(
                    color: _textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ---------------- TOP NOTIFICATION ----------------
  void _showTopNotif() async {
    setState(() => _showNotif = true);
    _notifCtrl.forward();

    await Future.delayed(const Duration(seconds: 3));

    _notifCtrl.reverse();
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) setState(() => _showNotif = false);
  }

  Widget _notifWidget() {
    if (!_showNotif) return const SizedBox();

    return SizeTransition(
      sizeFactor: _notifAnim,
      axisAlignment: -1,
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: _gold,
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer, color: Colors.black, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isArabic
                    ? "🔥 عرض جديد: خصم 20% على السطحة!"
                    : "🔥 New Offer: 20% OFF!",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------- ROUTING ----------------

  void _goto(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: page),
      ),
    );
  }

  // ---------------- GLASS ----------------

  Widget _glass({required Widget child, double radius = 22}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isDark
                ? Colors.white.withOpacity(.07)
                : Colors.black.withOpacity(.03),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: _isDark ? Colors.white24 : Colors.black12,
            ),
          ),
          child: (child),
        ),
      ),
    );
  }

  // ---------------- APP BAR ----------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: ShaderMask(
        shaderCallback: (b) => _gold.createShader(b),
        child: Text(
          "Doctor Car",
          style: GoogleFonts.cairo(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.language, color: _iconColor, size: 26),
        onPressed: () => setState(() => _isArabic = !_isArabic),
      ),
      actions: [
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.notifications_active,
                color: Colors.amber, size: 28),
            onPressed: _showTopNotif,
          ),
        ),
        Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: _iconColor, size: 28),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ---------------- DRAWER ----------------

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: _bgColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(gradient: _gold),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.car_rental, size: 48, color: Colors.black),
                const SizedBox(height: 10),
                Text(
                  "Doctor Car",
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _isArabic ? "خدمات السيارات الذكية" : "Smart car services",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // MENU ITEMS
          _drawerItem(
            Icons.info_outline,
            _isArabic ? "من نحن" : "About Us",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
            ),
          ),

          _drawerItem(Icons.home, _isArabic ? "الرئيسية" : "Home", () {
            Navigator.pop(context);
          }),
          _drawerItem(
              Icons.local_shipping,
              _isArabic ? "خدمات الطرق" : "Road Services",
              () => _goto(const RoadServicesScreen())),
          _drawerItem(
              Icons.shield,
              _isArabic ? "التبليغ عن حادث" : "Accident Report",
              () => _goto(const SmartAccidentScreen())),
          _drawerItem(Icons.store, _isArabic ? "المتجر" : "Store",
              () => _goto(const HomePage())),
          _drawerItem(Icons.phone, _isArabic ? "تواصل معنا" : "Contact",
              () => _goto(const ContactScreen())),
          _drawerItem(Icons.person, _isArabic ? "حسابي" : "Account",
              () => _goto(const AccountSettingsScreen())),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(title, style: TextStyle(color: _textColor, fontSize: 16)),
      onTap: onTap,
    );
  }

  // ---------------- BANNER SLIDER (unchanged) ----------------

  Widget _bannerSlider() {
    final items = [
      "assets/images/offer1.png",
      "assets/images/off1.png",
      "assets/images/A1.png",
      "assets/images/A2.png",
      "assets/images/A3.png",
      "assets/images/A4.png",
      "assets/images/A5.png",
      "assets/images/A6.png",
      "assets/images/A7.png",
    ];

    return Column(
      children: [
        FadeTransition(
          opacity: _fadeAnim,
          child: AspectRatio(
            aspectRatio: 16 / 8,
            child: PageView.builder(
              controller: _bannerCtrl,
              itemCount: items.length,
              onPageChanged: (v) => setState(() => _currentBanner = v),
              itemBuilder: (_, i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    image: DecorationImage(
                      image: AssetImage(items[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final active = i == _currentBanner;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 22 : 10,
              height: 8,
              decoration: BoxDecoration(
                color: active ? Colors.amber : Colors.white30,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ---------------- BIG BUTTONS (unchanged) ----------------

  Widget _bigBtn(
      String titleAr, String titleEn, String img, Widget page, String heroTag) {
    final title = _isArabic ? titleAr : titleEn;
    return GestureDetector(
      onTapDown: (_) => setState(() => _btnScale = 0.95),
      onTapUp: (_) => setState(() => _btnScale = 1.0),
      onTapCancel: () => setState(() => _btnScale = 1.0),
      onTap: () => _goto(page),
      child: AnimatedScale(
        scale: _btnScale,
        duration: const Duration(milliseconds: 130),
        child: _glass(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  color: _textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    img,
                    height: 130,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- BOTTOM NAV (call sheet integrated) ----------------

  Widget _buildBottomNav() {
    return SizedBox(
      height: 95,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: _bgColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // حسابي
                  GestureDetector(
                    onTap: () {
                      setState(() => _navIndex = 1);
                      _goto(const AccountSettingsScreen());
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person,
                            color: _navIndex == 1 ? Colors.amber : _iconColor),
                        Text(_isArabic ? "حسابي" : "Account",
                            style: TextStyle(
                                color:
                                    _navIndex == 1 ? Colors.amber : _textColor))
                      ],
                    ),
                  ),

                  const SizedBox(width: 70),

                  // الرئيسية
                  GestureDetector(
                    onTap: () => setState(() => _navIndex = 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home,
                            color: _navIndex == 0 ? Colors.amber : _iconColor),
                        Text(_isArabic ? "الرئيسية" : "Home",
                            style: TextStyle(
                                color:
                                    _navIndex == 0 ? Colors.amber : _textColor))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // زر الاتصال الجديد
          Positioned(
            bottom: 22,
            child: ScaleTransition(
              scale: _callAnim,
              child: GestureDetector(
                onTap: _showCallSheet,
                onTapDown: (_) => _callCtrl.reverse(),
                onTapUp: (_) => _callCtrl.forward(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: _gold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(.4),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.call, size: 38, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: _buildAppBar(),
        endDrawer: _buildDrawer(),
        bottomNavigationBar: _buildBottomNav(),
        body: SafeArea(
          child: Column(
            children: [
              // 🔔 Notification Bar
              _notifWidget(),

              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Column(
                    children: [
                      _bannerSlider(),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Expanded(
                            child: _bigBtn(
                              "حادث",
                              "Accident",
                              "assets/images/acc.png",
                              const SmartAccidentScreen(),
                              "accHero",
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _bigBtn(
                              "خدمات الطرق",
                              "Road Services",
                              "assets/images/road.png",
                              const RoadServicesScreen(),
                              "roadHero",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _bigBtn(
                              "السابقة",
                              "Privacy",
                              "assets/images/privacy.png",
                              const ContactScreen(),
                              "privacyHero",
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _bigBtn(
                              "المتجر",
                              "Auto Store",
                              "assets/images/store.png",
                              const HomePage(),
                              "storeHero",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
