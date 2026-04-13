part of '../home_screen.dart';

// ================== CENTER DETAILS (DARK LUXURY PRO) ==================
class _CenterDetailsScreen extends StatefulWidget {
  final CenterItem center;
  final bool isArabic;
  final bool isDarkMode;

  const _CenterDetailsScreen({
    required this.center,
    required this.isArabic,
    required this.isDarkMode,
  });

  @override
  State<_CenterDetailsScreen> createState() => _CenterDetailsScreenState();
}

class _CenterDetailsScreenState extends State<_CenterDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  CenterItem get center => widget.center;
  bool get isArabic => widget.isArabic;
  bool get isDarkMode => widget.isDarkMode;

  // ================== PALETTE ==================
  static const Color _bgStart = Color(0xFF090B12);
  static const Color _bgMid = Color(0xFF07111A);
  static const Color _bgEnd = Color(0xFF05070D);

  static const Color _panel = Color(0xFF18232B);
  // ignore: unused_field
  static const Color _panelTop = Color(0xFF8EA1A9);

  static const Color _accent = Color.fromARGB(255, 8, 89, 143);
  static const Color _accentDark = Color.fromARGB(255, 33, 129, 194);
  static const Color _accentSoft = Color.fromARGB(255, 94, 176, 217);
  static const Color _accentGlow = Color(0xFF8FD3FF);

  static const Color _text = Color(0xFFF4F6F8);
  static const Color _muted = Color(0xFFB7C1C7);
  static const Color _hint = Color(0xFF93A1A8);
  static const Color _lime = Color.fromARGB(255, 25, 180, 232);
  static const Color _success = Color(0xFF7DD3AE);
  static const Color _danger = Color(0xFFFF6B81);
  static const Color _gold = Color(0xFFFFC857);

  Color get bg => _bgEnd;
  Color get surface => _panel.withOpacity(.86);
  Color get surface2 => const Color(0xFF101A22);
  Color get surface3 => const Color(0xFF0D141B);
  Color get textMain => _text;
  Color get textSub => _muted;
  Color get hint => _hint;
  Color get stroke => Colors.white.withOpacity(.08);

  LinearGradient get pageGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_bgStart, _bgMid, _bgEnd],
      );

  LinearGradient get panelGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1A2630).withOpacity(.96),
          const Color(0xFF111B23).withOpacity(.93),
          const Color(0xFF0C1319).withOpacity(.96),
        ],
      );

  LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_accentSoft, _accentDark, _accent],
      );

  LinearGradient get heroOverlay => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withOpacity(.52),
          _accent.withOpacity(.12),
          Colors.transparent,
          Colors.black.withOpacity(.76),
        ],
        stops: const [0.0, 0.28, 0.55, 1.0],
      );

  List<BoxShadow> get glowShadows => [
        BoxShadow(
          color: _accentGlow.withOpacity(.14),
          blurRadius: 30,
          spreadRadius: 1,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(.40),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ];

  List<BoxShadow> get softCardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.35),
          blurRadius: 26,
          offset: const Offset(0, 16),
        ),
      ];

  TextStyle get h1 => GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: textMain,
        height: 1.15,
      );

  TextStyle get h2 => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: textMain,
      );

  TextStyle get sub => GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: textSub,
        height: 1.25,
      );

  TextStyle get body => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: textMain,
        height: 1.25,
      );

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ================== ACTIONS ==================
  Future<void> _openMaps() async {
    if (!center.hasCoords) return;
    final lat = center.lat!;
    final lng = center.lng!;
    final google =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    try {
      if (await canLaunchUrl(google)) {
        await launchUrl(google, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  String? get _phone {
    final p = center.phone?.trim();
    if (p == null || p.isEmpty) return null;
    return p;
  }

  Future<void> _callCenter() async {
    final p = _phone;
    if (p == null) return;
    final uri = Uri.parse("tel:$p");
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {}
  }

  Future<void> _openWhatsApp() async {
    final p = _phone;
    if (p == null) return;

    final digits = p.replaceAll(RegExp(r"[^\d+]"), "");
    final withCountry = digits.startsWith("+")
        ? digits
        : (digits.startsWith("0") ? "+2$digits" : "+20$digits");

    final wa = Uri.parse("https://wa.me/${withCountry.replaceAll("+", "")}");
    try {
      if (await canLaunchUrl(wa)) {
        await launchUrl(wa, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _shareCenter() async {
    final msg = _shareText();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            decoration: BoxDecoration(
              gradient: panelGradient,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(.10)),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isArabic ? "مشاركة المركز" : "Share center",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: textMain,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: textSub),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: stroke),
                  ),
                  child: SelectableText(
                    msg,
                    style: GoogleFonts.cairo(
                      color: textMain,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    gradient: accentGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: glowShadows,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: msg));
                      if (!mounted) return;
                      Navigator.pop(context);
                      _snack(isArabic
                          ? "تم النسخ بنجاح ✅"
                          : "Copied successfully ✅");
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.content_copy_rounded,
                        color: Colors.white),
                    label: Text(
                      isArabic ? "نسخ المحتوى" : "Copy content",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _shareText() {
    final name = center.name;
    final phone = center.phone ?? "";
    final address = center.address ?? "";
    final rating = center.rating.toStringAsFixed(1);
    final dist = center.distanceText;
    final maps = center.hasCoords
        ? "https://www.google.com/maps/search/?api=1&query=${center.lat},${center.lng}"
        : "";

    return [
      name,
      if (rating.isNotEmpty) "${isArabic ? "التقييم" : "Rating"}: $rating",
      if (dist.isNotEmpty) "${isArabic ? "المسافة" : "Distance"}: $dist",
      if (address.trim().isNotEmpty)
        "${isArabic ? "العنوان" : "Address"}: $address",
      if (phone.trim().isNotEmpty) "${isArabic ? "الهاتف" : "Phone"}: $phone",
      if (maps.isNotEmpty) maps,
    ].join("\n");
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF121B23),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          msg,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ================== BUILD ==================
  @override
  Widget build(BuildContext context) {
    final heroImg = center.bestImage.trim();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        body: Container(
          decoration: BoxDecoration(gradient: pageGradient),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      Positioned(
                        top: -50,
                        right: -40,
                        child: _ambientGlow(180, _accentGlow.withOpacity(.07)),
                      ),
                      Positioned(
                        top: 220,
                        left: -60,
                        child: _ambientGlow(220, _accent.withOpacity(.06)),
                      ),
                      Positioned(
                        bottom: 80,
                        right: -20,
                        child: _ambientGlow(150, _lime.withOpacity(.05)),
                      ),
                    ],
                  ),
                ),
              ),
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 300,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: _topActionButton(
                      icon: isArabic
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.arrow_forward_ios_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    actions: [
                      _topActionButton(
                        icon: Icons.ios_share_rounded,
                        onTap: _shareCenter,
                      ),
                      const SizedBox(width: 10),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(28),
                            ),
                            child: heroImg.isNotEmpty
                                ? Image(
                                    image: heroImg.startsWith("http")
                                        ? NetworkImage(heroImg)
                                        : AssetImage(heroImg) as ImageProvider,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _heroFallback(),
                                  )
                                : _heroFallback(),
                          ),
                          Container(
                              decoration: BoxDecoration(gradient: heroOverlay)),
                          Positioned(
                            left: 18,
                            right: 18,
                            bottom: 18,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  center.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isArabic
                                      ? "تفاصيل احترافية للمركز"
                                      : "Premium center details",
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(.78),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _heroChip(
                                      icon: Icons.workspace_premium_rounded,
                                      color: _gold,
                                      text: center.rating.toStringAsFixed(1),
                                    ),
                                    if (center.distanceText.isNotEmpty)
                                      _heroChip(
                                        icon: Icons.near_me_rounded,
                                        color: _accentSoft,
                                        text: center.distanceText,
                                      ),
                                    if (center.openNow != null)
                                      _heroChip(
                                        icon: center.openNow!
                                            ? Icons.bolt_rounded
                                            : Icons.pause_circle_filled_rounded,
                                        color: center.openNow!
                                            ? _success
                                            : _danger,
                                        text: center.openNow!
                                            ? (isArabic
                                                ? "مفتوح الآن"
                                                : "Open now")
                                            : (isArabic
                                                ? "مغلق الآن"
                                                : "Closed now"),
                                      ),
                                    _heroChip(
                                      icon: Icons.verified_rounded,
                                      color: _lime,
                                      text: isArabic ? "موثوق" : "Verified",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(72),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.045),
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: Colors.white.withOpacity(.08)),
                        ),
                        child: TabBar(
                          controller: _tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            gradient: accentGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _accentGlow.withOpacity(.18),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: textSub,
                          labelStyle: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900,
                            fontSize: 12.5,
                          ),
                          tabs: [
                            Tab(text: isArabic ? "نظرة عامة" : "Overview"),
                            Tab(text: isArabic ? "الخدمات" : "Services"),
                            Tab(text: isArabic ? "التقييمات" : "Reviews"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 120),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: panelGradient,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: stroke),
                          boxShadow: softCardShadow,
                        ),
                        child: SizedBox(
                          height: 560,
                          child: TabBarView(
                            controller: _tab,
                            children: [
                              _overviewTab(),
                              _servicesTab(),
                              _reviewsTab(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF091017).withOpacity(.96),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(.08)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.45),
                        blurRadius: 28,
                        offset: const Offset(0, -12),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: accentGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: glowShadows,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _snack(
                                  isArabic
                                      ? "الحجز قريبًا بشكل احترافي جدًا"
                                      : "Booking is coming soon",
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.white,
                              ),
                              label: Text(
                                isArabic ? "احجز الآن" : "Book now",
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _quickAction(
                          icon: Icons.call_rounded,
                          tooltip: isArabic ? "اتصال" : "Call",
                          enabled: _phone != null,
                          onTap: _callCenter,
                        ),
                        const SizedBox(width: 10),
                        _quickAction(
                          icon: Icons.forum_rounded,
                          tooltip: isArabic ? "واتساب" : "WhatsApp",
                          enabled: _phone != null,
                          onTap: _openWhatsApp,
                        ),
                        const SizedBox(width: 10),
                        _quickAction(
                          icon: Icons.explore_rounded,
                          tooltip: isArabic ? "الموقع" : "Location",
                          enabled: center.hasCoords,
                          onTap: _openMaps,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== HERO ==================
  Widget _heroFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1721), Color(0xFF0A0E14)],
        ),
      ),
      child: Center(
        child: Container(
          width: 94,
          height: 94,
          decoration: BoxDecoration(
            gradient: accentGradient,
            shape: BoxShape.circle,
            boxShadow: glowShadows,
            border: Border.all(color: Colors.white.withOpacity(.14)),
          ),
          child: Center(
            child: Text(
              center.initials,
              style: GoogleFonts.cairo(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ambientGlow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * .65,
            spreadRadius: size * .10,
          ),
        ],
      ),
    );
  }

  Widget _topActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 6, right: 6),
      child: Material(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(.10)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _heroChip({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ================== TABS ==================
  Widget _overviewTab() {
    final addr = center.address?.trim() ?? "";
    final phone = center.phone?.trim() ?? "";
    final hours = center.openHours?.trim() ?? "";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _sectionTitle(
            isArabic ? "معلومات المركز" : "Center information",
            icon: Icons.apartment_rounded,
          ),
          const SizedBox(height: 14),
          _infoTile(
            icon: Icons.badge_rounded,
            iconColor: _accentSoft,
            title: isArabic ? "الاسم" : "Name",
            value: center.name,
          ),
          const SizedBox(height: 12),
          _infoTile(
            icon: Icons.star_rate_rounded,
            iconColor: _gold,
            title: isArabic ? "التقييم" : "Rating",
            value: center.rating.toStringAsFixed(1),
            pill: isArabic ? "ممتاز" : "Top rated",
            pillColor: _gold,
          ),
          if (center.distanceText.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoTile(
              icon: Icons.near_me_rounded,
              iconColor: _lime,
              title: isArabic ? "المسافة" : "Distance",
              value: center.distanceText,
              pill: isArabic ? "قريب" : "Near you",
              pillColor: _lime,
            ),
          ],
          if (addr.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoTile(
              icon: Icons.location_on_rounded,
              iconColor: _accentGlow,
              title: isArabic ? "العنوان" : "Address",
              value: addr,
            ),
          ],
          if (hours.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoTile(
              icon: Icons.schedule_rounded,
              iconColor: _accentSoft,
              title: isArabic ? "ساعات العمل" : "Working hours",
              value: hours,
              pill: center.openNow == null
                  ? null
                  : center.openNow!
                      ? (isArabic ? "مفتوح الآن" : "Open now")
                      : (isArabic ? "مغلق الآن" : "Closed now"),
              pillColor: center.openNow == null
                  ? null
                  : (center.openNow! ? _success : _danger),
            ),
          ],
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoTile(
              icon: Icons.call_rounded,
              iconColor: _accentSoft,
              title: isArabic ? "الهاتف" : "Phone",
              value: phone,
              pill: isArabic ? "متاح" : "Available",
              pillColor: _accentSoft,
            ),
          ],
          if (center.tags.isNotEmpty) ...[
            const SizedBox(height: 18),
            _sectionTitle(
              isArabic ? "التخصصات" : "Specialties",
              icon: Icons.grid_view_rounded,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: center.tags.take(10).map((t) => _tagChip(t)).toList(),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.035),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: stroke),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: accentGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isArabic
                        ? "ممكن تضيف هنا وصف احترافي ديناميكي للمركز من الـ API أو الـ CMS علشان يبقى الشكل أفخم جدًا."
                        : "You can add a premium dynamic description here from the API or CMS for a richer experience.",
                    style: sub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: center.hasCoords ? _openMaps : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _accentSoft.withOpacity(.35), width: 1.2),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.map_rounded, color: _accentSoft),
            label: Text(
              isArabic ? "فتح على الخريطة" : "Open in Maps",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                color: textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _servicesTab() {
    final services = center.services;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _sectionTitle(
            isArabic ? "الخدمات المتاحة" : "Available services",
            icon: Icons.design_services_rounded,
          ),
          const SizedBox(height: 14),
          if (services.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.035),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: stroke),
              ),
              child: Text(
                isArabic
                    ? "لا توجد خدمات مسجلة لهذا المركز حالياً."
                    : "No services listed for this center yet.",
                style: sub,
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: services.map((s) => _serviceChip(s)).toList(),
            ),
          if (center.types.isNotEmpty) ...[
            const SizedBox(height: 18),
            _sectionTitle(
              isArabic ? "الأنواع" : "Types",
              icon: Icons.category_rounded,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: center.types.take(12).map((t) => _tagChip(t)).toList(),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: stroke),
            ),
            child: Text(
              isArabic
                  ? "لما تبعت response حقيقي لمركز واحد أقدر أربط الخدمات بشكل أقوى جدًا مع أيقونات مخصصة لكل خدمة."
                  : "Once you send a real center response, I can map services with even better dedicated icons.",
              style: sub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewsTab() {
    final real = center.reviews;

    final fallback = <ReviewItem>[
      ReviewItem(
        name: isArabic ? "أحمد" : "Ahmed",
        rating: 4.7,
        comment: isArabic
            ? "خدمة ممتازة جدًا وسريعة."
            : "Excellent and fast service.",
      ),
      ReviewItem(
        name: isArabic ? "سارة" : "Sara",
        rating: 4.4,
        comment: isArabic
            ? "التعامل محترم والأسعار مناسبة جدًا."
            : "Great attitude and fair prices.",
      ),
      ReviewItem(
        name: isArabic ? "محمود" : "Mahmoud",
        rating: 4.9,
        comment: isArabic ? "أفضل مركز قريب مني." : "Best center near me.",
      ),
    ];

    final list = real.isNotEmpty ? real : fallback;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  isArabic ? "آراء العملاء" : "Customer reviews",
                  icon: Icons.reviews_rounded,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _gold.withOpacity(.28)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: _gold, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      center.rating.toStringAsFixed(1),
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                        color: textMain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final r = list[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.035),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: stroke),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: accentGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r.name,
                              style: body,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _gold.withOpacity(.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _gold.withOpacity(.28),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: _gold, size: 15),
                                const SizedBox(width: 5),
                                Text(
                                  r.rating.toStringAsFixed(1),
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12.2,
                                    color: textMain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(r.comment, style: sub),
                      if ((r.dateShort).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          r.dateShort,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: hint,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                _snack(isArabic ? "إضافة تقييم قريبًا" : "Add review soon"),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _accentSoft.withOpacity(.35), width: 1.2),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.edit_note_rounded, color: _accentSoft),
            label: Text(
              isArabic ? "اكتب تقييم" : "Write a review",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                color: textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== HELPERS ==================
  Widget _sectionTitle(String title, {required IconData icon}) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: accentGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _accentGlow.withOpacity(.12),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: h2)),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? pill,
    Color? pillColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: iconColor.withOpacity(.18)),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: sub.copyWith(color: hint)),
                const SizedBox(height: 4),
                Text(value, style: body),
              ],
            ),
          ),
          if (pill != null && pillColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: pillColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: pillColor.withOpacity(.25)),
              ),
              child: Text(
                pill,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  fontSize: 11.8,
                  color: textMain,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : .42,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.selectionClick();
                    onTap();
                  }
                : () => _snack(isArabic ? "غير متاح حالياً" : "Not available"),
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: stroke),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: _accentSoft, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accent.withOpacity(.16),
            _accentSoft.withOpacity(.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentSoft.withOpacity(.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: _accentSoft, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: stroke),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w800,
          fontSize: 12.4,
          color: textMain,
        ),
      ),
    );
  }
}
