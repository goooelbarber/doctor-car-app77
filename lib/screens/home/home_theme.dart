// PATH: lib/screens/home/home_theme.dart
// ignore_for_file: unused_element

part of '../home_screen.dart';

extension _HomeThemeTokens on _HomeScreenState {
  // ================== BRAND ==================
  // ✅ DoctorCar Neon Lime (موحّد مع باقي الشاشات)
  Color get brand => const Color(0xFFA8F12A);

  // ✅ 3-step palette for richer gradients
  Color get brand2 =>
      Color.lerp(brand, const Color(0xff0B1220), 0.22) ??
      const Color(0xff0B1220);
  Color get brand3 => Color.lerp(brand, Colors.white, 0.18) ?? Colors.white;

  // ================== COLORS (FOUNDATION) ==================
  Color get bgColor =>
      _isDarkMode ? const Color(0xff0B1220) : const Color(0xffF5F7FB);

  Color get surface => _isDarkMode ? const Color(0xff0E1626) : Colors.white;

  Color get surface2 =>
      _isDarkMode ? const Color(0xff0C1322) : const Color(0xffF9FAFB);

  Color get surface3 =>
      _isDarkMode ? const Color(0xff121C31) : const Color(0xffFFFFFF);

  // Text
  Color get textMain =>
      _isDarkMode ? const Color(0xffF9FAFB) : const Color(0xff111827);
  Color get textSub =>
      _isDarkMode ? const Color(0xffCBD5E1) : const Color(0xff6B7280);
  Color get textMute =>
      _isDarkMode ? const Color(0xff94A3B8) : const Color(0xff9CA3AF);

  // Borders / strokes
  Color get stroke => _isDarkMode
      ? Colors.white.withOpacity(.10)
      : Colors.black.withOpacity(.06);

  Color get strokeStrong => _isDarkMode
      ? Colors.white.withOpacity(.14)
      : Colors.black.withOpacity(.10);

  // Shadows
  Color get shadowSoft => Colors.black.withOpacity(_isDarkMode ? .30 : .08);
  Color get shadowMed => Colors.black.withOpacity(_isDarkMode ? .36 : .12);

  // Status colors
  Color get ok => const Color(0xff22C55E);
  Color get warn => const Color(0xffF59E0B);
  Color get danger => const Color(0xffEF4444);
  Color get info => brand;

  // ================== RADIUS ==================
  double get r12 => 12;
  double get r16 => 16;
  double get r18 => 18;
  double get r22 => 22;
  double get r26 => 26;
  double get r30 => 30;

  // ================== SPACING ==================
  double get s6 => 6;
  double get s8 => 8;
  double get s10 => 10;
  double get s12 => 12;
  double get s14 => 14;
  double get s16 => 16;
  double get s18 => 18;
  double get s20 => 20;
  double get s24 => 24;

  // ================== PRO EFFECTS ==================
  List<BoxShadow> get glowNeon => [
        BoxShadow(
          color: brand.withOpacity(_isDarkMode ? .30 : .22),
          blurRadius: 28,
          spreadRadius: 1,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: brand3.withOpacity(_isDarkMode ? .16 : .12),
          blurRadius: 50,
          spreadRadius: 2,
          offset: const Offset(0, 22),
        ),
      ];

  List<BoxShadow> get greenWhiteGlow => [
        BoxShadow(
          color: brand.withOpacity(_isDarkMode ? .24 : .18),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(_isDarkMode ? .26 : .08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get shSm => [
        BoxShadow(
          color: shadowSoft,
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ];

  List<BoxShadow> get shMd => [
        BoxShadow(
          color: shadowMed,
          blurRadius: 22,
          offset: const Offset(0, 12),
        ),
      ];

  List<BoxShadow> get shLg => [
        BoxShadow(
          color: shadowMed,
          blurRadius: 30,
          offset: const Offset(0, 16),
        ),
      ];

  // ================== GRADIENTS (PRO) ==================

  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          brand3,
          brand,
          brand2.withOpacity(.95),
        ],
        stops: const [0.0, 0.48, 1.0],
      );

  LinearGradient get ctaGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(brand3, brand, 0.50) ?? brand,
          brand,
          Color.lerp(brand, brand2, 0.55) ?? brand2,
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  // ✅ Green → White (Official)
  LinearGradient get greenWhiteGradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: _isDarkMode
            ? [
                brand.withOpacity(.92),
                (Color.lerp(brand, Colors.white, .58) ?? Colors.white)
                    .withOpacity(.85),
                Colors.white.withOpacity(.08),
              ]
            : [
                brand.withOpacity(.98),
                Color.lerp(brand, Colors.white, .64) ?? Colors.white,
                Colors.white,
              ],
        stops: const [0.0, 0.55, 1.0],
      );

  LinearGradient get greenWhiteGradientStrong => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDarkMode
            ? [
                Color.lerp(brand, Colors.white, .22) ?? brand3,
                brand.withOpacity(.98),
                Color.lerp(brand, Colors.white, .52) ?? brand3,
              ]
            : [
                Color.lerp(brand, Colors.white, .22) ?? brand3,
                brand,
                Color.lerp(brand, Colors.white, .58) ?? brand3,
              ],
        stops: const [0.0, 0.55, 1.0],
      );

  // Backward compatible alias
  LinearGradient get greenToWhiteGradient => greenWhiteGradient;

  LinearGradient get softGreenCardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDarkMode
            ? [
                brand.withOpacity(.18),
                Colors.white.withOpacity(.06),
                Colors.white.withOpacity(.03),
              ]
            : [
                brand.withOpacity(.18),
                Colors.white.withOpacity(.92),
                brand.withOpacity(.05),
              ],
        stops: const [0.0, 0.60, 1.0],
      );

  LinearGradient get appBarGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xff06101C),
          Color.lerp(const Color(0xff06101C), brand2, 0.10) ??
              const Color(0xff06101C),
          Color.lerp(const Color(0xff06101C), brand, 0.06) ??
              const Color(0xff06101C),
        ],
        stops: const [0.0, 0.65, 1.0],
      );

  LinearGradient get glassCardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDarkMode
            ? [
                Colors.white.withOpacity(.08),
                Colors.white.withOpacity(.05),
                Colors.white.withOpacity(.03),
              ]
            : [
                Colors.white.withOpacity(.90),
                Colors.white.withOpacity(.78),
                Colors.white.withOpacity(.86),
              ],
        stops: const [0.0, 0.55, 1.0],
      );

  LinearGradient get screenBgGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _isDarkMode
            ? [
                const Color(0xff0B1220),
                Color.lerp(const Color(0xff0B1220), brand2, 0.06) ??
                    const Color(0xff0B1220),
                const Color(0xff07101C),
              ]
            : const [
                Color(0xffF5F7FB),
                Color(0xffFFFFFF),
                Color(0xffF2F6FF),
              ],
      );

  // Backward compatible
  LinearGradient get cardGradient => glassCardGradient;

  // ================== TYPOGRAPHY ==================
  TextStyle get h1 => GoogleFonts.cairo(
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w900,
        color: textMain,
      );

  TextStyle get h2 => GoogleFonts.cairo(
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w900,
        color: textMain,
      );

  TextStyle get titleStyle => GoogleFonts.cairo(
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w900,
        color: textMain,
      );

  TextStyle get body => GoogleFonts.cairo(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: textMain,
      );

  TextStyle get bodyStrong => GoogleFonts.cairo(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w900,
        color: textMain,
      );

  TextStyle get sub => GoogleFonts.cairo(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: textSub,
      );

  TextStyle get small => GoogleFonts.cairo(
        fontSize: 12,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: textSub,
      );

  TextStyle smallStyle({Color? c, FontWeight w = FontWeight.w700}) =>
      GoogleFonts.cairo(
        fontSize: 13,
        height: 1.25,
        color: c ?? textSub,
        fontWeight: w,
      );

  TextStyle bodyStyle({Color? c, FontWeight w = FontWeight.w700}) =>
      GoogleFonts.cairo(
        fontSize: 14,
        height: 1.30,
        color: c ?? textMain,
        fontWeight: w,
      );
}
