// PATH: lib/screens/home/home_center_details.dart
part of '../home_screen.dart';

// ================== CENTER DETAILS (ULTRA PRO) ==================
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

  // ================== NEW THEME (MATCH HOME THEME) ==================
  // ✅ نفس أخضر الثيم
  static const Color _brand = Color.fromARGB(255, 26, 217, 105);
  static const Color _mintWhite = Color(0xffECFFF5);

  // ✅ دهبي للتقييم (مناسب جدًا مع الأخضر)
  static const Color _gold = Color(0xffF7B500);

  Color get brand => _brand;
  Color get mintWhite => _mintWhite;

  Color get brand2 => Color.lerp(brand, const Color(0xff0B1220), 0.12)!;
  Color get brand3 => Color.lerp(mintWhite, brand, 0.22)!;
  Color get brandSoft => Color.lerp(mintWhite, brand, 0.10)!;

  Color get bg =>
      isDarkMode ? const Color(0xff0B1220) : const Color(0xffF5F7FB);

  Color get surface => isDarkMode ? const Color(0xff0E1626) : Colors.white;
  Color get surface2 =>
      isDarkMode ? const Color(0xff0C1322) : const Color(0xffFFFFFF);

  Color get textMain =>
      isDarkMode ? const Color(0xffF9FAFB) : const Color(0xff111827);
  Color get textSub =>
      isDarkMode ? const Color(0xffCBD5E1) : const Color(0xff6B7280);

  Color get stroke => isDarkMode
      ? Colors.white.withOpacity(.10)
      : Colors.black.withOpacity(.06);

  // ✅ Gradients (Green → White)
  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [
                brand.withOpacity(.95),
                Color.lerp(brand, mintWhite, 0.30)!.withOpacity(.92),
                Color.lerp(brand, mintWhite, 0.55)!.withOpacity(.90),
              ]
            : [
                mintWhite,
                Color.lerp(mintWhite, brand, 0.32)!,
                Color.lerp(mintWhite, brand, 0.55)!,
              ],
        stops: const [0.0, 0.52, 1.0],
      );

  LinearGradient get ctaGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [
                brand.withOpacity(.96),
                Color.lerp(brand, mintWhite, 0.25)!.withOpacity(.94),
                Color.lerp(brand, mintWhite, 0.45)!.withOpacity(.92),
              ]
            : [
                Color.lerp(mintWhite, brand, 0.22)!,
                brand,
                Color.lerp(brand, mintWhite, 0.18)!,
              ],
        stops: const [0.0, 0.55, 1.0],
      );

  // ✅ Soft glow
  List<BoxShadow> get glowNeon => [
        BoxShadow(
          color: brand.withOpacity(isDarkMode ? .22 : .16),
          blurRadius: 22,
          spreadRadius: 1,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: brandSoft.withOpacity(isDarkMode ? .14 : .08),
          blurRadius: 44,
          spreadRadius: 2,
          offset: const Offset(0, 18),
        ),
      ];

  TextStyle get h1 => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: textMain,
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
      );
  TextStyle get body => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: textMain,
      );

  BoxShadow _softShadow({double blur = 24, double dy = 14, double op = .14}) {
    return BoxShadow(
      color: Colors.black.withOpacity(isDarkMode ? op * 1.15 : op),
      blurRadius: blur,
      offset: Offset(0, dy),
    );
  }

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

  // ================== Actions ==================
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
      barrierColor: Colors.black54,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: Container(
            color: surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(.16)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isArabic ? "مشاركة" : "Share",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: textMain,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: textSub),
                      splashRadius: 20,
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: stroke),
                  ),
                  child: SelectableText(
                    msg,
                    style: GoogleFonts.cairo(
                      color: textMain,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: msg));
                      if (!mounted) return;
                      Navigator.pop(context);
                      _snack(isArabic ? "تم النسخ ✅" : "Copied ✅");
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: brand,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.copy_rounded, color: Colors.white),
                    label: Text(
                      isArabic ? "نسخ" : "Copy",
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
      if (phone.trim().isNotEmpty) "${isArabic ? "هاتف" : "Phone"}: $phone",
      if (maps.isNotEmpty) maps,
    ].join("\n");
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================== Build ==================
  @override
  Widget build(BuildContext context) {
    final heroImg = center.bestImage.trim();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 260,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      isArabic
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: isArabic ? "مشاركة" : "Share",
                      onPressed: _shareCenter,
                      icon:
                          const Icon(Icons.share_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (heroImg.isNotEmpty)
                          Image(
                            image: heroImg.startsWith("http")
                                ? NetworkImage(heroImg)
                                : AssetImage(heroImg) as ImageProvider,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _heroFallback(),
                          )
                        else
                          _heroFallback(),

                        // ✅ Premium overlay (black + green tint)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(.62),
                                brand.withOpacity(.10),
                                Colors.transparent,
                                Colors.black.withOpacity(.42),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.22, 0.65, 1.0],
                            ),
                          ),
                        ),

                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                center.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: [
                                  _chip(
                                    icon: Icons.star_rounded,
                                    color: _gold,
                                    text: center.rating.toStringAsFixed(1),
                                    textColor: const Color(0xff1a1a1a),
                                  ),
                                  if (center.distanceText.isNotEmpty)
                                    _chip(
                                      icon: Icons.location_on_rounded,
                                      color: Colors.white,
                                      text: center.distanceText,
                                      outline: true,
                                      textColor: Colors.white,
                                    ),
                                  if (center.openNow != null)
                                    _chip(
                                      icon: center.openNow!
                                          ? Icons.schedule_rounded
                                          : Icons.do_not_disturb_on_rounded,
                                      color: center.openNow!
                                          ? Colors.green
                                          : Colors.red,
                                      text: center.openNow!
                                          ? (isArabic ? "مفتوح" : "Open")
                                          : (isArabic ? "مغلق" : "Closed"),
                                      textColor: Colors.white,
                                    ),
                                  _chip(
                                    icon: Icons.verified_rounded,
                                    color: brand,
                                    text: isArabic ? "موثوق" : "Verified",
                                    textColor: Colors.white,
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
                    preferredSize: const Size.fromHeight(56),
                    child: Container(
                      color: bg,
                      child: TabBar(
                        controller: _tab,
                        labelColor: textMain,
                        unselectedLabelColor: textSub,
                        indicatorColor: brand,
                        indicatorWeight: 3,
                        labelStyle: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900, fontSize: 13),
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
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: stroke),
                        boxShadow: [_softShadow(op: .10)],
                      ),
                      child: SizedBox(
                        height: 520,
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

            // Bottom sticky actions
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: surface,
                  border: Border(top: BorderSide(color: stroke)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? .35 : .10),
                      blurRadius: 22,
                      offset: const Offset(0, -10),
                    )
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: ctaGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: glowNeon,
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _snack(isArabic
                                  ? "الحجز قريبًا (هنعملها معاك)"
                                  : "Booking coming soon");
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.event_available_rounded,
                                color: Colors.white),
                            label: Text(
                              isArabic ? "احجز الآن" : "Book now",
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _circleAction(
                        icon: Icons.call_rounded,
                        tooltip: isArabic ? "اتصال" : "Call",
                        enabled: _phone != null,
                        onTap: _callCenter,
                      ),
                      const SizedBox(width: 10),
                      _circleAction(
                        icon: Icons.mark_chat_unread_rounded,
                        tooltip: isArabic ? "واتساب" : "WhatsApp",
                        enabled: _phone != null,
                        onTap: _openWhatsApp,
                      ),
                      const SizedBox(width: 10),
                      _circleAction(
                        icon: Icons.map_rounded,
                        tooltip: isArabic ? "خريطة" : "Map",
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
    );
  }

  Widget _heroFallback() {
    return Container(
      color: isDarkMode ? Colors.white.withOpacity(.06) : Colors.grey.shade300,
      child: Center(
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: brand.withOpacity(.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(.22)),
          ),
          child: Center(
            child: Text(
              center.initials,
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================== Tabs ==================
  Widget _overviewTab() {
    final addr = center.address?.trim() ?? "";
    final phone = center.phone?.trim() ?? "";
    final hours = center.openHours?.trim() ?? "";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(isArabic ? "معلومات المركز" : "Center info", style: h2),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.store_rounded,
            title: isArabic ? "الاسم" : "Name",
            value: center.name,
          ),
          const SizedBox(height: 10),
          _infoRow(
            icon: Icons.star_rounded,
            title: isArabic ? "التقييم" : "Rating",
            value: center.rating.toStringAsFixed(1),
            pill: _pillText(isArabic ? "ممتاز" : "Top"),
            pillColor: _gold,
          ),
          if (center.distanceText.isNotEmpty) ...[
            const SizedBox(height: 10),
            _infoRow(
              icon: Icons.location_on_rounded,
              title: isArabic ? "المسافة" : "Distance",
              value: center.distanceText,
              pill: _pillText(isArabic ? "قريب" : "Near"),
              pillColor: brand,
            ),
          ],
          if (addr.isNotEmpty) ...[
            const SizedBox(height: 10),
            _infoRow(
              icon: Icons.place_rounded,
              title: isArabic ? "العنوان" : "Address",
              value: addr,
            ),
          ],
          if (hours.isNotEmpty) ...[
            const SizedBox(height: 10),
            _infoRow(
              icon: Icons.schedule_rounded,
              title: isArabic ? "ساعات العمل" : "Working hours",
              value: hours,
              pill: center.openNow == null
                  ? null
                  : _pillText(center.openNow!
                      ? (isArabic ? "مفتوح" : "Open")
                      : (isArabic ? "مغلق" : "Closed")),
              pillColor: center.openNow == null
                  ? null
                  : (center.openNow! ? Colors.green : Colors.red),
            ),
          ],
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 10),
            _infoRow(
              icon: Icons.call_rounded,
              title: isArabic ? "الهاتف" : "Phone",
              value: phone,
              pill: _pillText(isArabic ? "اتصل" : "Call"),
              pillColor: brand,
            ),
          ],
          const SizedBox(height: 14),
          if (center.tags.isNotEmpty) ...[
            Text(isArabic ? "التخصصات" : "Specialties", style: h2),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: center.tags.take(10).map((t) => _tagChip(t)).toList(),
            ),
            const SizedBox(height: 14),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: stroke),
            ),
            child: Text(
              isArabic
                  ? "وصف مختصر للمركز (هنربطه بالـ API بعدين)."
                  : "Short center description (we’ll connect it to API later).",
              style: sub.copyWith(height: 1.25),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: center.hasCoords ? _openMaps : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: brand.withOpacity(.35), width: 1.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 52),
            ),
            icon: Icon(Icons.map_outlined, color: brand.withOpacity(.95)),
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
          Text(isArabic ? "الخدمات المتاحة" : "Available services", style: h2),
          const SizedBox(height: 12),
          if (services.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(18),
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
          const SizedBox(height: 16),
          if (center.types.isNotEmpty) ...[
            Text(isArabic ? "النوع" : "Types", style: h2),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: center.types.take(12).map((t) => _tagChip(t)).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            isArabic
                ? "لو عايز الخدمات تيجي من السيرفر ابعتلي response مركز واحد."
                : "If you want services from API, send one center response.",
            style: sub,
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
        comment:
            isArabic ? "خدمة ممتازة وسريعة." : "Excellent and fast service.",
      ),
      ReviewItem(
        name: isArabic ? "سارة" : "Sara",
        rating: 4.4,
        comment: isArabic
            ? "التعامل محترم والأسعار كويسة."
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(isArabic ? "آراء العملاء" : "Customer reviews",
                    style: h2),
              ),
              _chip(
                icon: Icons.star_rounded,
                color: _gold,
                text: center.rating.toStringAsFixed(1),
                textColor: const Color(0xff1a1a1a),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final r = list[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surface2,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: stroke),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: brand.withOpacity(.12),
                            child: Icon(Icons.person_rounded, color: brand),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(r.name, style: body)),
                          _chip(
                            icon: Icons.star_rounded,
                            color: _gold,
                            text: r.rating.toStringAsFixed(1),
                            textColor: const Color(0xff1a1a1a),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        r.comment,
                        style: sub.copyWith(height: 1.25),
                      ),
                      if ((r.dateShort).isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          r.dateShort,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: textSub,
                          ),
                        )
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                _snack(isArabic ? "إضافة تقييم قريبًا" : "Add review soon"),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: brand.withOpacity(.35), width: 1.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size(double.infinity, 52),
            ),
            icon:
                Icon(Icons.rate_review_rounded, color: brand.withOpacity(.95)),
            label: Text(
              isArabic ? "اكتب تقييم" : "Write a review",
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900, color: textMain),
            ),
          ),
        ],
      ),
    );
  }

  // ================== UI helpers ==================
  String? _pillText(String t) => t.trim().isEmpty ? null : t;

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    String? pill,
    Color? pillColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: brand.withOpacity(isDarkMode ? .18 : .10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: brand.withOpacity(.18)),
          ),
          child: Icon(icon, color: brand, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: sub),
              const SizedBox(height: 2),
              Text(value, style: body),
            ],
          ),
        ),
        if (pill != null && pillColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: pillColor.withOpacity(.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: pillColor.withOpacity(.25)),
            ),
            child: Text(
              pill,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: textMain,
              ),
            ),
          ),
      ],
    );
  }

  Widget _circleAction({
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : () => _snack(isArabic ? "غير متاح حالياً" : "Not available"),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: surface2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: stroke),
            boxShadow: [_softShadow(blur: 18, dy: 10, op: .10)],
          ),
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, color: brand, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required Color color,
    required String text,
    required Color textColor,
    bool outline = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : color.withOpacity(.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color:
              outline ? Colors.white.withOpacity(.35) : color.withOpacity(.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: outline ? Colors.white : color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
              color: outline ? Colors.white : textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:
            isDarkMode ? Colors.white.withOpacity(.05) : brand.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brand.withOpacity(.18)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w900,
          fontSize: 13,
          color: textMain,
        ),
      ),
    );
  }

  Widget _tagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: stroke),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
          color: textMain,
        ),
      ),
    );
  }
}
