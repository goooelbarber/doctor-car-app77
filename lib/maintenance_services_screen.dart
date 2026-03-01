// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:doctor_car_app/screens/supplementary_services_screen.dart';
import 'package:doctor_car_app/pages/home/home_page.dart';

class MaintenanceServicesScreen extends StatefulWidget {
  const MaintenanceServicesScreen({super.key});

  @override
  State<MaintenanceServicesScreen> createState() =>
      _MaintenanceServicesScreenState();
}

class _MaintenanceServicesScreenState extends State<MaintenanceServicesScreen>
    with TickerProviderStateMixin {
  String? selected;
  bool _opening = false;

  // ===== Colors (same style as screenshot) =====
  static const Color kBgTop = Color(0xFF0B1220);
  static const Color kBgMid = Color(0xFF0A1628);
  static const Color kBgBottom = Color(0xFF07101E);

  static const Color kNeon = Color(0xFFB7F44A); // neon green
  static const Color kNeon2 = Color(0xFF8CFF4B);

  static const Color kText = Color(0xFFEAF2FF);
  static const Color kMuted = Color(0xFF9FB0C6);

  final List<Map<String, dynamic>> services = [
    {
      "key": "maintenance",
      "name": "صيانة",
      "subtitle": "ميكانيكا • كهرباء • فحص شامل",
      "icon": Icons.build_circle_rounded,
      "emoji": "🛠️",
    },
    {
      "key": "wash",
      "name": "غسيل و عناية",
      "subtitle": "غسيل خارجي/داخلي • تلميع",
      "icon": Icons.local_car_wash_rounded,
      "emoji": "🚿",
    },
    {
      "key": "accessories",
      "name": "إكسسوارات",
      "subtitle": "مستلزمات وإضافات للسيارة",
      "icon": Icons.shopping_bag_rounded,
      "emoji": "🛍️",
    },
    {
      "key": "check",
      "name": "كشف",
      "subtitle": "تشخيص سريع ودقيق للأعطال",
      "icon": Icons.assignment_rounded,
      "emoji": "🧾",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedItem = selected == null
        ? null
        : services.firstWhere((s) => s["key"] == selected);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kBgTop,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "خدمات الصيانة",
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // ===== Background =====
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kBgTop, kBgMid, kBgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ===== Neon glow blobs =====
          Positioned(
            top: -90,
            right: -80,
            child: _GlowBlob(color: kNeon.withOpacity(0.12), size: 240),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _GlowBlob(color: kNeon2.withOpacity(0.10), size: 300),
          ),

          // ===== Content =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
              child: Column(
                children: [
                  // ===== Header card =====
                  _GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kNeon.withOpacity(0.12),
                            border: Border.all(color: kNeon.withOpacity(0.35)),
                          ),
                          child: const Icon(
                            Icons.home_repair_service_rounded,
                            color: kNeon,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "اطلب خدمتك في ثواني",
                                style: GoogleFonts.cairo(
                                  color: kText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "اختار الخدمة • حدّد موقعك • نوصلك بأقرب فني",
                                style: GoogleFonts.cairo(
                                  color: kMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: kNeon.withOpacity(0.12),
                            border: Border.all(color: kNeon.withOpacity(0.35)),
                          ),
                          child: Text(
                            "مختار",
                            style: GoogleFonts.cairo(
                              color: kNeon,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ===== List =====
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 130),
                      itemCount: services.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final item = services[index];
                        final isSelected = selected == item["key"];

                        return _ServiceListTile(
                          title: item["name"] as String,
                          subtitle: item["subtitle"] as String,
                          icon: item["icon"] as IconData,
                          emoji: item["emoji"] as String,
                          selected: isSelected,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => selected = item["key"] as String);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== Bottom Section (like screenshot) =====
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selected hint panel (optional like "اختر خدمة للمتابعة")
                _GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        selected == null
                            ? Icons.info_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        color: selected == null ? kMuted : kNeon,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selected == null
                              ? "اختر خدمة للمتابعة"
                              : "الخدمة: ${(selectedItem?["name"] ?? "")}",
                          style: GoogleFonts.cairo(
                            color: selected == null ? kMuted : kText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                _BottomCTA(
                  enabled: selected != null && !_opening,
                  loading: _opening,
                  label:
                      selected == null ? "اختر خدمة أولاً" : "طلب الخدمة الآن",
                  onTap: selected == null || _opening
                      ? null
                      : () => _openService(selected!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== Navigation =====
  Future<void> _openService(String key) async {
    setState(() => _opening = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() => _opening = false);

    switch (key) {
      case "maintenance":
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const SupplementaryServicesScreen()),
        );
        break;

      case "accessories":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0F1D32),
            behavior: SnackBarBehavior.floating,
            content: Text(
              "الخدمة ستتوفر قريبًا",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
    }
  }
}

// ===================== Widgets =====================

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassCard({
    required this.child,
    required this.padding,
  });

  static const Color kNeon = Color(0xFFB7F44A);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: kNeon.withOpacity(0.10),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ServiceListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  static const Color kNeon = Color(0xFFB7F44A);
  static const Color kText = Color(0xFFEAF2FF);
  static const Color kMuted = Color(0xFF9FB0C6);

  @override
  Widget build(BuildContext context) {
    return _InkGlass(
      radius: 22,
      onTap: onTap,
      borderColor:
          selected ? kNeon.withOpacity(0.65) : Colors.white.withOpacity(0.10),
      fillOpacity: selected ? 0.06 : 0.04,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? kNeon.withOpacity(0.14)
                    : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: selected
                      ? kNeon.withOpacity(0.55)
                      : Colors.white.withOpacity(0.12),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: selected ? kNeon : kMuted,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$emoji  $title",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: kText,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: kMuted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Right indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: selected
                    ? kNeon.withOpacity(0.18)
                    : Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: selected
                      ? kNeon.withOpacity(0.55)
                      : Colors.white.withOpacity(0.10),
                ),
              ),
              child: Icon(
                selected
                    ? Icons.check_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 16,
                color: selected ? kNeon : kMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InkGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final VoidCallback onTap;
  final Color borderColor;
  final double fillOpacity;

  const _InkGlass({
    required this.child,
    required this.radius,
    required this.onTap,
    required this.borderColor,
    required this.fillOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.white.withOpacity(fillOpacity),
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: borderColor),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomCTA extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final String label;
  final VoidCallback? onTap;

  const _BottomCTA({
    required this.enabled,
    required this.loading,
    required this.label,
    required this.onTap,
  });

  static const Color kNeon = Color(0xFFB7F44A);
  static const Color kBgTop = Color(0xFF0B1220);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: enabled ? kNeon : Colors.white.withOpacity(0.06),
            border: Border.all(
              color: enabled
                  ? kNeon.withOpacity(0.70)
                  : Colors.white.withOpacity(0.10),
            ),
            boxShadow: [
              if (enabled)
                BoxShadow(
                  color: kNeon.withOpacity(0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: loading
                      ? Row(
                          key: const ValueKey("loading"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(kBgTop),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "جارٍ التنفيذ...",
                              style: GoogleFonts.cairo(
                                color: kBgTop,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          label,
                          key: const ValueKey("label"),
                          style: GoogleFonts.cairo(
                            color: enabled ? kBgTop : Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 90, spreadRadius: 30),
        ],
      ),
    );
  }
}
