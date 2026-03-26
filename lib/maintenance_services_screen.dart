// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/home/home_page.dart';
import 'screens/supplementary_services_screen.dart';

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

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  // =========================
  // Doctor Car Dark Blue Theme
  // =========================
  static const Color _bg0 = Color(0xFF081A36);
  static const Color _bg1 = Color(0xFF0B2348);
  static const Color _bg2 = Color(0xFF040D1D);

  static const Color _accent = Color(0xFF1B4F9C);
  static const Color _accentSoft = Color(0xFFE7EEF9);
  static const Color _accentDark = Color(0xFF143F7C);
  static const Color _accentDeep = Color(0xFF10386B);

  static const Color _whiteTint = Color(0xFFF7F9FC);
  static const Color _textPrimary = Color(0xFFF2F6FB);
  static const Color _textSecondary = Color(0xFFC9D6EA);
  static const Color _textMuted = Color(0xFF93A9C9);
  // ignore: unused_field
  static const Color _textOnDark = Colors.white;
  // ignore: unused_field
  static const Color _danger = Color(0xFFD96C6C);

  // ignore: unused_field
  static const LinearGradient _brandGradient = LinearGradient(
    colors: [
      Color(0xFF1B4F99),
      Color(0xFF245AA6),
      Color(0xFF153F78),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient _panelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF17345F),
      Color(0xFF122B50),
      Color(0xFF0D2140),
    ],
  );

  static const LinearGradient _cardBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1D4F99),
      Color(0xFF163F7E),
      Color(0xFF0E2D60),
    ],
    stops: [0.0, 0.55, 1.0],
  );

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
      "subtitle": "غسيل خارجي • داخلي • تلميع",
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
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: .985, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _accentDeep,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

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
            builder: (_) => const SupplementaryServicesScreen(),
          ),
        );
        break;

      case "accessories":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;

      case "wash":
      case "check":
        _showMessage("الخدمة ستتوفر قريبًا");
        break;

      default:
        _showMessage("الخدمة غير متاحة حاليًا");
    }
  }

  Color _serviceColor(String key) {
    switch (key) {
      case "maintenance":
        return const Color(0xFF2A5DAD);
      case "wash":
        return const Color(0xFF1E4D96);
      case "accessories":
        return const Color(0xFF355F9E);
      case "check":
        return const Color(0xFF244C88);
      default:
        return _accent;
    }
  }

  Widget _blurBlob({required double size, required Color color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 52, sigmaY: 52),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size),
          ),
        ),
      ),
    );
  }

  Widget _background() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bg0, _bg1, _bg2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -80,
          child: _blurBlob(size: 260, color: _accent.withOpacity(.16)),
        ),
        Positioned(
          bottom: -170,
          right: -90,
          child: _blurBlob(size: 320, color: _accentDark.withOpacity(.14)),
        ),
        Positioned(
          top: 120,
          right: -60,
          child: _blurBlob(size: 170, color: Colors.white.withOpacity(.04)),
        ),
        Positioned(
          bottom: 70,
          left: -40,
          child: _blurBlob(size: 180, color: _accent.withOpacity(.10)),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, 0.9),
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(.10),
                  Colors.black.withOpacity(.24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassPanel({
    required Widget child,
    EdgeInsets? padding,
    BorderRadius? radius,
  }) {
    final r = radius ?? BorderRadius.circular(24);

    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _panelGradient,
            borderRadius: r,
            border: Border.all(color: Colors.white.withOpacity(.10)),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: _whiteTint,
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.10),
                    border: Border.all(
                      color: Colors.white.withOpacity(.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(.18),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_repair_service_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    "خدمات الصيانة",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: _whiteTint,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: _cardBlueGradient,
        border: Border.all(
          color: Colors.white.withOpacity(.14),
        ),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.14),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -18,
            left: -14,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.05),
              ),
            ),
          ),
          Positioned(
            bottom: -24,
            right: -8,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.04),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withOpacity(.10),
                border: Border.all(
                  color: Colors.white.withOpacity(.14),
                ),
              ),
              child: Text(
                "واجهة مميزة",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.10),
                    border: Border.all(
                      color: Colors.white.withOpacity(.14),
                    ),
                  ),
                  child: const Icon(
                    Icons.miscellaneous_services_rounded,
                    color: Colors.white,
                    size: 24,
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
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "اختار الخدمة • حدّد احتياجك • وابدأ التنفيذ بسهولة",
                        style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(.82),
                          fontSize: 12.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withOpacity(0.10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                    ),
                  ),
                  child: Text(
                    "${services.length} خدمات",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedBar(Map<String, dynamic> selectedItem) {
    return _glassPanel(
      radius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.10),
              border: Border.all(
                color: Colors.white.withOpacity(.12),
              ),
            ),
            child: Icon(
              selectedItem["icon"] as IconData,
              color: _accentSoft,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "تم اختيار: ${selectedItem["name"]}",
              style: GoogleFonts.cairo(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: _accentSoft,
            size: 21,
          ),
        ],
      ),
    );
  }

  Widget _bottomAddBar(Map<String, dynamic>? selectedItem) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: _glassPanel(
        radius: BorderRadius.circular(22),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  selected == null
                      ? Icons.info_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: selected == null ? _textMuted : _accentSoft,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selected == null
                        ? "اختر خدمة للمتابعة"
                        : "الخدمة المختارة: ${selectedItem?["name"] ?? ""}",
                    style: GoogleFonts.cairo(
                      color: selected == null ? _textSecondary : _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _BottomCTA(
              enabled: selected != null && !_opening,
              loading: _opening,
              label: selected == null ? "اختر خدمة أولاً" : "طلب الخدمة الآن",
              onTap: selected == null || _opening
                  ? null
                  : () => _openService(selected!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(Map<String, dynamic> item, bool isSelected) {
    return _ServiceListTile(
      title: item["name"] as String,
      subtitle: item["subtitle"] as String,
      icon: item["icon"] as IconData,
      emoji: item["emoji"] as String,
      selected: isSelected,
      accentColor: _serviceColor(item["key"] as String),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => selected = item["key"] as String);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = selected == null
        ? null
        : services.firstWhere((s) => s["key"] == selected);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            _background(),
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Column(
                          children: [
                            _header(),
                            const SizedBox(height: 12),
                            _heroCard(),
                            if (selectedItem != null) ...[
                              const SizedBox(height: 12),
                              _selectedBar(selectedItem),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                          itemCount: services.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final item = services[index];
                            final isSelected = selected == item["key"];
                            return _serviceCard(item, isSelected);
                          },
                        ),
                      ),
                      _bottomAddBar(selectedItem),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== Widgets =====================

class _ServiceListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String emoji;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ServiceListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emoji,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  static const Color _textPrimary = Color(0xFFF2F6FB);
  static const Color _textSecondary = Color(0xFFC9D6EA);
  // ignore: unused_field
  static const Color _accent = Color(0xFF1B4F9C);
  static const Color _accentDark = Color(0xFFE7EEF9);

  @override
  Widget build(BuildContext context) {
    return _InkGlass(
      radius: 22,
      selected: selected,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          Colors.white.withOpacity(.22),
                          accentColor.withOpacity(.22),
                          accentColor.withOpacity(.42),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : Colors.white.withOpacity(.08),
                border: Border.all(
                  color: selected
                      ? accentColor.withOpacity(.36)
                      : Colors.white.withOpacity(.12),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accentColor.withOpacity(.22),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: selected ? _accentDark : _textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            color: _textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: _textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: selected
                    ? accentColor.withOpacity(.16)
                    : Colors.white.withOpacity(.08),
                border: Border.all(
                  color: selected
                      ? accentColor.withOpacity(.30)
                      : Colors.white.withOpacity(.12),
                ),
              ),
              child: Icon(
                selected
                    ? Icons.check_rounded
                    : Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: selected ? _accentDark : _textSecondary,
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
  final bool selected;

  const _InkGlass({
    required this.child,
    required this.radius,
    required this.onTap,
    required this.selected,
  });

  static const LinearGradient _selectedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF17345F),
      Color(0xFF122B50),
    ],
  );

  static const LinearGradient _normalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF122742),
      Color(0xFF0D1F35),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: selected ? _selectedGradient : _normalGradient,
        border: Border.all(
          color: selected
              ? const Color(0xFF1B4F9C).withOpacity(0.28)
              : Colors.white.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4F9C).withOpacity(selected ? 0.12 : 0.06),
            blurRadius: selected ? 16 : 10,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: child,
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

  static const Color _textPrimary = Color(0xFFF7F9FC);

  static const LinearGradient _brandGradient = LinearGradient(
    colors: [
      Color(0xFF1B4F99),
      Color(0xFF245AA6),
      Color(0xFF153F78),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? _brandGradient : null,
          color: enabled ? null : Colors.white.withOpacity(.10),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (enabled)
              BoxShadow(
                color: const Color(0xFF1B4F9C).withOpacity(.20),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
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
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "جارٍ التنفيذ...",
                        style: GoogleFonts.cairo(
                          color: _textPrimary,
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
                      color: enabled
                          ? _textPrimary
                          : Colors.white.withOpacity(.55),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
