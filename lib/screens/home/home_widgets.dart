// PATH: lib/screens/home/home_widgets.dart
// ignore_for_file: invalid_use_of_protected_member

part of '../home_screen.dart';

extension _HomeWidgets on _HomeScreenState {
  // ================== Helpers ==================
  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
  }

  // shadow preset (لو مش عايز تستخدم shMd/shLg من theme)
  BoxShadow _softShadow(
      {double blur = 22, double dy = 12, double opacity = .14}) {
    return BoxShadow(
      color: Colors.black.withOpacity(_isDarkMode ? (opacity * 1.15) : opacity),
      blurRadius: blur,
      offset: Offset(0, dy),
    );
  }

  // ================== PRO: brand tint for icons (matches header green) ==================
  Color get _roadIconColor => brand; // نفس الأخضر الأساسي
  Color get _roadIconBg => _isDarkMode
      ? Colors.white.withOpacity(.10)
      : Colors.white.withOpacity(.70);

  // ✅ أخضر/أبيض متدرج (زي ما طلبت)
  LinearGradient get _greenWhiteGradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          brand.withOpacity(_isDarkMode ? .88 : .96),
          Color.lerp(brand, Colors.white, _isDarkMode ? .52 : .62)!,
          Colors.white.withOpacity(_isDarkMode ? .06 : 1),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  // ✅ نسخة أقوى للـ CTA (زر الاتصال/الأكشن)
  LinearGradient get _ctaGreenWhiteGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(brand, Colors.white, _isDarkMode ? .20 : .26)!,
          brand.withOpacity(_isDarkMode ? .92 : 1),
          Color.lerp(brand, Colors.white, _isDarkMode ? .48 : .58)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  // Glow subtle
  List<BoxShadow> get _greenGlow => [
        BoxShadow(
          color: brand.withOpacity(_isDarkMode ? .22 : .18),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(_isDarkMode ? .28 : .08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  // ================== PRO Buttons ==================
  Widget _gradientPillButton({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
    bool compact = true,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 16,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          gradient: _greenWhiteGradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: brand.withOpacity(.22)),
          boxShadow: _greenGlow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: _isDarkMode ? Colors.white : const Color(0xff0B1220),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 13.2,
                color: _isDarkMode ? Colors.white : const Color(0xff0B1220),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientWideButton({
    required String text,
    required VoidCallback onTap,
    double height = 54,
    IconData? icon,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(30),
      child: Ink(
        height: height,
        decoration: BoxDecoration(
          gradient: _greenWhiteGradient,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: brand.withOpacity(.22)),
          boxShadow: _greenGlow,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: _isDarkMode ? Colors.white : const Color(0xff0B1220),
                    size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: _isDarkMode ? Colors.white : const Color(0xff0B1220),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== Image (asset or network) ==================
  Widget smartImage(
    String pathOrUrl, {
    double width = 60,
    double height = 60,
    double radius = 12,
  }) {
    final v = pathOrUrl.trim();
    if (v.isEmpty) return _imgFallback(width, height, radius);

    final isUrl = v.startsWith("http://") || v.startsWith("https://");

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: isUrl
          ? Image.network(
              v,
              width: width,
              height: height,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSync) {
                if (wasSync) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 220),
                  child: child,
                );
              },
              errorBuilder: (_, __, ___) => _imgFallback(width, height, radius),
              loadingBuilder: (context, child, p) =>
                  p == null ? child : _imgFallback(width, height, radius),
            )
          : Image.asset(
              v,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imgFallback(width, height, radius),
            ),
    );
  }

  Widget _imgFallback(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: stroke),
      ),
      child: Icon(Icons.image_not_supported, color: textSub),
    );
  }

  // ================== Calls ==================
  Future<void> _callEmergency() async {
    final uri = Uri.parse("tel:112");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _snack(trKey("callFail"));
      }
    } catch (_) {
      _snack(trKey("callFail"));
    }
  }

  Future<void> _openSupportChatFromSheet() async {
    Navigator.pop(context);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      if (!mounted) return;

      if (userId == null || userId.isEmpty) {
        _snack(trKey("loginFirst"));
        return;
      }

      final chatData = await SupportChatService.getOrCreateChat();
      final chatId = chatData["_id"]?.toString();

      if (chatId == null || chatId.isEmpty) {
        _snack(trKey("chatError"));
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SupportChatScreen(chatId: chatId, userId: userId),
        ),
      );
    } catch (_) {
      _snack(trKey("chatError"));
    }
  }

  // ================== Call sheet (PRO) ==================
  void _showCallSheet() {
    _tap(() {});
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.42,
          minChildSize: 0.25,
          maxChildSize: 0.65,
          builder: (context, scrollCtrl) {
            return ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(r26)),
              child: Container(
                color: surface,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 6,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: _isDarkMode
                                ? Colors.white.withOpacity(.16)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _isArabic ? "تواصل سريع" : "Quick Contact",
                                style: h2,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: textSub),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _sheetCard(
                          icon: Icons.support_agent_rounded,
                          title: trKey("supportChat"),
                          subtitle: trKey("supportSub"),
                          bg: _isDarkMode
                              ? Colors.white.withOpacity(.06)
                              : const Color(0xffE8F0FF),
                          iconColor: brand,
                          onTap: _openSupportChatFromSheet,
                        ),
                        const SizedBox(height: 12),
                        _sheetCard(
                          icon: Icons.emergency_rounded,
                          title: trKey("emergency"),
                          subtitle: trKey("emergencySub"),
                          bg: _isDarkMode
                              ? Colors.white.withOpacity(.06)
                              : const Color(0xffFFE5E5),
                          iconColor: danger,
                          onTap: () async {
                            Navigator.pop(context);
                            _callEmergency();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(r18),
      onTap: () => _tap(onTap),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(r18),
          border: Border.all(color: stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(r16),
                border: Border.all(color: stroke),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: bodyStrong),
                  const SizedBox(height: 3),
                  Text(subtitle, style: sub),
                ],
              ),
            ),
            Icon(
              _isArabic
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              size: 22,
              color: textSub,
            ),
          ],
        ),
      ),
    );
  }

  // ================== My location card (PRO) ==================
  Widget _myLocationCard() {
    if (_myPos == null) return const SizedBox.shrink();

    final lat = _myPos!.latitude.toStringAsFixed(5);
    final lng = _myPos!.longitude.toStringAsFixed(5);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(r18),
        border: Border.all(color: stroke),
        boxShadow: shSm,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: brand.withOpacity(_isDarkMode ? .20 : .10),
              borderRadius: BorderRadius.circular(r16),
              border: Border.all(color: brand.withOpacity(.18)),
            ),
            child: Icon(Icons.my_location, color: brand, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${trKey("yourLocation")}: $lat , $lng",
              style: bodyStrong.copyWith(fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: _openGoogleMapsNearby,
            icon: Icon(Icons.map_outlined, color: textSub),
            splashRadius: 20,
            tooltip: _isArabic ? "فتح الخريطة" : "Open map",
          ),
        ],
      ),
    );
  }

  // ================== Radius selector (PRO) ==================
  Widget _radiusSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(r18),
        border: Border.all(color: stroke),
        boxShadow: shSm,
      ),
      child: Row(
        children: [
          Icon(Icons.radar_rounded, color: brand.withOpacity(.95)),
          const SizedBox(width: 10),
          Text("${trKey("radius")}: ",
              style: bodyStrong.copyWith(fontSize: 13)),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _HomeScreenState._radiusOptionsKm.map((km) {
                  final selected = km == _selectedRadiusKm;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      selected: selected,
                      label: Text(
                        _isArabic ? "$km كم" : "$km km",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          color: selected ? Colors.white : textMain,
                        ),
                      ),
                      onSelected: (_) => _setRadiusKm(km),
                      selectedColor: brand,
                      backgroundColor: _isDarkMode
                          ? Colors.white.withOpacity(.06)
                          : Colors.grey.shade100,
                      side: BorderSide(color: selected ? brand : stroke),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== APP BAR (PRO+) ==================
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 78,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: appBarGradient),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(.18), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      leadingWidth: 118,
      leading: Builder(
        builder: (ctx) => Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              _appBarIcon(
                icon: Icons.menu_rounded,
                tooltip: _isArabic ? "القائمة" : "Menu",
                onTap: () => Scaffold.of(ctx).openEndDrawer(),
              ),
              const SizedBox(width: 8),
              _appBarIcon(
                icon: Icons.notifications_none_rounded,
                tooltip: _isArabic ? "الإشعارات" : "Notifications",
                onTap: () => _snack(_isArabic
                    ? "لا توجد إشعارات الآن"
                    : "No notifications yet"),
              ),
            ],
          ),
        ),
      ),
      centerTitle: true,
      title: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: brand2.withOpacity(.16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: brand2.withOpacity(.35)),
                ),
                child: Icon(Icons.car_repair, color: brand2, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                "Doctor Car",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _isArabic ? "خدمات سيارات ذكية" : "Smart Car Services",
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(.72),
            ),
          ),
        ],
      ),
      actions: [
        _appBarIcon(
          icon: Icons.search_rounded,
          tooltip: _isArabic ? "بحث" : "Search",
          onTap: () =>
              _snack(_isArabic ? "ميزة البحث قريبًا" : "Search coming soon"),
        ),
        const SizedBox(width: 6),
        _appBarIcon(icon: Icons.language_rounded, onTap: _toggleLanguage),
        const SizedBox(width: 6),
        _appBarIcon(
          icon:
              _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          onTap: _toggleTheme,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _appBarIcon({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Semantics(
      button: true,
      label: tooltip ?? "",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _tap(onTap),
          borderRadius: BorderRadius.circular(r16),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.10),
              borderRadius: BorderRadius.circular(r16),
              border: Border.all(color: Colors.white.withOpacity(.14)),
            ),
            child: Tooltip(
              message: tooltip ?? "",
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  // ================== BANNER (PRO) ==================
  Widget _bannerSlider() {
    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r22),
            boxShadow: shMd,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(r22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _bannerController,
                  itemCount: banners.length,
                  onPageChanged: (i) {
                    if (!mounted) return;
                    setState(() => _currentBanner = i);
                  },
                  itemBuilder: (_, i) {
                    return Image.asset(
                      banners[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: surface2,
                        child: Center(
                            child: Icon(Icons.image, size: 44, color: textSub)),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                        Colors.black.withOpacity(0.25),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: _isArabic ? null : 14,
                  right: _isArabic ? 14 : null,
                  bottom: 14,
                  child: ElevatedButton.icon(
                    onPressed: () => _snack(
                        _isArabic ? "أقرب العروض قريبًا" : "Top offers soon"),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white.withOpacity(.14),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r16),
                        side: BorderSide(color: Colors.white.withOpacity(.18)),
                      ),
                    ),
                    icon: const Icon(Icons.local_offer_rounded, size: 18),
                    label: Text(
                      _isArabic ? "شوف العروض" : "View offers",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBanner == i ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBanner == i
                    ? brand
                    : (_isDarkMode ? Colors.white24 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================== QUICK SERVICES ==================
  Widget _quickServicesRow() {
    return Row(
      children: [
        Expanded(
          child: _serviceCardPro(
            title: trKey("urgent"),
            subtitle:
                _isArabic ? "مساعدة فورية على الطريق" : "Instant road help",
            icon: Icons.local_shipping_rounded,
            iconColor: _roadIconColor,
            gradient: _greenWhiteGradient,
            onTap: () => _goto(const RoadServicesScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _serviceCardPro(
            title: trKey("maint"),
            subtitle: _isArabic ? "احجز صيانة بسهولة" : "Book maintenance",
            icon: Icons.build_circle_rounded,
            iconColor: Color.lerp(brand, brand2, .35)!,
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.lerp(brand, Colors.white, _isDarkMode ? .22 : .28)!,
                Colors.white.withOpacity(_isDarkMode ? .06 : 1),
              ],
            ),
            onTap: () => _goto(const MaintenanceServicesScreen()),
          ),
        ),
      ],
    );
  }

  Widget _serviceCardPro({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(r22),
      onTap: () => _tap(onTap),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(r22),
          border: Border.all(color: stroke),
          boxShadow: _greenGlow,
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: _roadIconBg,
                borderRadius: BorderRadius.circular(r18),
                border: Border.all(
                  color: iconColor.withOpacity(_isDarkMode ? .22 : .18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(_isDarkMode ? .10 : .12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: _isDarkMode ? Colors.white : const Color(0xff0B1220),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: _isDarkMode
                    ? Colors.white.withOpacity(.75)
                    : const Color(0xff334155),
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ (OLD) serviceCard kept as-is (no deletion) ------------------
  Widget _serviceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(r22),
      onTap: () => _tap(onTap),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(r22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.22),
              blurRadius: 22,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.16),
                borderRadius: BorderRadius.circular(r18),
                border: Border.all(color: Colors.white.withOpacity(.16)),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                )),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: Colors.white.withOpacity(.85),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  height: 1.15,
                )),
          ],
        ),
      ),
    );
  }

  // ================== OFFERS ==================
  void _openOfferDetails(OfferItem o) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(r26)),
          child: Container(
            color: surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? Colors.white.withOpacity(.16)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isArabic ? "تفاصيل العرض" : "Offer details",
                          style: h2,
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface2,
                      borderRadius: BorderRadius.circular(r22),
                      border: Border.all(color: stroke),
                    ),
                    child: Row(
                      children: [
                        smartImage(o.image, width: 72, height: 72, radius: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: bodyStrong),
                              const SizedBox(height: 6),
                              Text(o.until, style: sub),
                              const SizedBox(height: 6),
                              Text(o.distance,
                                  style: smallStyle(w: FontWeight.w900)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _openGoogleMapsNearby();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: brand.withOpacity(.35), width: 1.4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(r16)),
                          ),
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: Text(
                            _isArabic ? "على الخريطة" : "Open map",
                            style:
                                GoogleFonts.cairo(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _gradientPillButton(
                          text: _isArabic ? "احفظ" : "Save",
                          icon: Icons.bookmark_add_rounded,
                          compact: false,
                          onTap: () {
                            Navigator.pop(context);
                            _snack(_isArabic
                                ? "تم حفظ العرض (قريبًا)"
                                : "Saved (soon)");
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _offersSlider() {
    if (offers.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final o = offers[i];
          return InkWell(
            borderRadius: BorderRadius.circular(r22),
            onTap: () => _tap(() => _openOfferDetails(o)),
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(r22),
                border: Border.all(color: stroke),
                boxShadow: shSm,
              ),
              child: Row(
                children: [
                  smartImage(o.image, width: 86, height: 86, radius: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: bodyStrong),
                        const SizedBox(height: 4),
                        Text(o.until,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: sub),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    brand.withOpacity(_isDarkMode ? .18 : .08),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: brand.withOpacity(.15)),
                              ),
                              child: Text(
                                o.distance,
                                style: smallStyle(c: brand, w: FontWeight.w900),
                              ),
                            ),
                            const Spacer(),
                            _gradientPillButton(
                              text: trKey("getOffer"),
                              onTap: () => _openOfferDetails(o),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- DRAWER (PRO) ----------------
  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [brand2, brand2.withOpacity(.70)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.black.withOpacity(.14),
                    child:
                        const Icon(Icons.person, color: Colors.black, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Doctor Car",
                            style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.black)),
                        const SizedBox(height: 2),
                        Text(
                          _isArabic
                              ? "خدمات السيارات الذكية"
                              : "Smart car services",
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          _drawerItem(
              Icons.info_outline,
              _isArabic ? "من نحن" : "About Us",
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()))),
          _drawerItem(
              Icons.home_rounded, _isArabic ? "الرئيسية" : "Home", () {}),
          _drawerItem(
              Icons.local_shipping_rounded,
              _isArabic ? "خدمات الطرق" : "Road Services",
              () => _goto(const RoadServicesScreen())),
          _drawerItem(
              Icons.shield_rounded,
              _isArabic ? "التبليغ عن حادث" : "Accident Report",
              () => _goto(const SmartAccidentScreen())),
          _drawerItem(Icons.store_rounded, _isArabic ? "المتجر" : "Store",
              () => _goto(const HomePage())),
          _drawerItem(Icons.phone_rounded, _isArabic ? "تواصل معنا" : "Contact",
              () => _goto(const ContactScreen())),
          _drawerItem(Icons.person_rounded, _isArabic ? "حسابي" : "Account",
              () => _goto(const AccountSettingsScreen())),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: () => _tap(() {
        Navigator.pop(context);
        onTap();
      }),
      leading: Icon(icon, color: brand),
      title: Text(title,
          style: GoogleFonts.cairo(
              color: textMain, fontSize: 16, fontWeight: FontWeight.w900)),
      trailing: Icon(
          _isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          color: textSub),
    );
  }

  // ================== CENTERS LIST ==================
  Widget _centersList() {
    return FutureBuilder<List<CenterItem>>(
      future: _centersFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _centersLoading();
        }

        final items = snap.data ?? <CenterItem>[];

        if (_locationError != null) return _locationNeededCard();
        if (items.isEmpty) return _emptyCentersCard();

        return Column(children: items.map(_centerTile).toList());
      },
    );
  }

  Widget _centersLoading() {
    return Column(
      children: [
        _miniInfoCard(Icons.my_location, trKey("locating")),
        const SizedBox(height: 10),
        ...List.generate(4, (_) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 86,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(r18),
              border: Border.all(color: stroke),
            ),
          );
        }),
      ],
    );
  }

  Widget _locationNeededCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(r18),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off, color: textSub),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _locationError ?? trKey("needLocation"),
              style: bodyStrong,
            ),
          ),
          TextButton(
            onPressed: () async {
              if (kIsWeb) {
                try {
                  await _openGoogleMapsNearby();
                } catch (_) {
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocationHelpScreen(
                        isArabic: _isArabic,
                        isDarkMode: _isDarkMode,
                        onRefresh: () async => _refresh(),
                      ),
                    ),
                  );
                }
                return;
              }

              try {
                await Geolocator.openLocationSettings();
              } catch (_) {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocationHelpScreen(
                      isArabic: _isArabic,
                      isDarkMode: _isDarkMode,
                      onRefresh: () async => _refresh(),
                    ),
                  ),
                );
              }
            },
            child: Text(
              kIsWeb
                  ? (_isArabic ? "فتح خرائط جوجل" : "Open Google Maps")
                  : trKey("openSettings"),
              style:
                  GoogleFonts.cairo(fontWeight: FontWeight.w900, color: brand),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCentersCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(r18),
        border: Border.all(color: stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: textSub),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isArabic
                      ? "لا يوجد مراكز ضمن $_selectedRadiusKm كم حالياً"
                      : "No centers within $_selectedRadiusKm km right now",
                  style: bodyStrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _refresh,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: brand.withOpacity(.35), width: 1.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r16)),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(trKey("retry"),
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
              ),
              _gradientPillButton(
                text: _isArabic ? "بحث في خرائط جوجل" : "Search on Google Maps",
                icon: Icons.map,
                compact: false,
                onTap: _openGoogleMapsNearby,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfoCard(IconData icon, String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(r18),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: [
          Icon(icon, color: brand),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: bodyStrong)),
        ],
      ),
    );
  }

  Widget _centerTile(CenterItem c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(r22),
        border: Border.all(color: stroke),
        boxShadow: shSm,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(r22),
        onTap: () => _tap(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _CenterDetailsScreen(
                center: c,
                isArabic: _isArabic,
                isDarkMode: _isDarkMode,
              ),
            ),
          );
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              smartImage(c.image, width: 62, height: 62, radius: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: bodyStrong.copyWith(fontSize: 14)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _chip(Icons.star_rounded, Colors.amber,
                            c.rating.toStringAsFixed(1)),
                        if (c.distanceText.isNotEmpty)
                          _chip(
                              Icons.location_on_rounded, brand, c.distanceText),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                _isArabic
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: textSub,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(_isDarkMode ? .16 : .10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
              color: textMain,
            ),
          ),
        ],
      ),
    );
  }

  // ================== HOW / WHY / CUSTOMER ==================
  Widget _howToUseDoctorCar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(trKey("how")),
        const SizedBox(height: 12),
        Row(
          children: [
            _HowCard(
                icon: Icons.star,
                text: _isArabic ? "قيم\nخدمتك" : "Rate\nService",
                isDark: _isDarkMode),
            _HowCard(
                icon: Icons.payment,
                text: _isArabic
                    ? "الدفع اون لاين\nأو كاش"
                    : "Pay Online\nor Cash",
                isDark: _isDarkMode),
            _HowCard(
                icon: Icons.assignment_turned_in,
                text: _isArabic ? "احجز\nو تابع" : "Book\n& Track",
                isDark: _isDarkMode),
            _HowCard(
                icon: Icons.location_on,
                text: _isArabic ? "اختر\nالخدمة" : "Choose\nService",
                isDark: _isDarkMode),
          ],
        ),
      ],
    );
  }

  Widget _whyDoctorCar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: stroke),
        boxShadow: shLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 34,
                decoration: BoxDecoration(
                    color: brand, borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(width: 12),
              Text(trKey("why"), textAlign: TextAlign.center, style: h2),
            ],
          ),
          const SizedBox(height: 18),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              // ✅ Fix overflow on real phones
              childAspectRatio: 0.95,
            ),
            children: [
              _whyGridItem(
                icon: Icons.verified_rounded,
                title: _isArabic ? "فنيين معتمدين" : "Certified",
                subtitle:
                    _isArabic ? "خبراء موثوقين بخبرة عالية" : "Trusted experts",
              ),
              _whyGridItem(
                icon: Icons.attach_money_rounded,
                title: _isArabic ? "تسعير شفاف" : "Pricing",
                subtitle: _isArabic ? "بدون أي رسوم مخفية" : "No hidden fees",
              ),
              _whyGridItem(
                icon: Icons.security_rounded,
                title: _isArabic ? "دعم التأمين" : "Insurance",
                subtitle:
                    _isArabic ? "تغطية كاملة للحوادث" : "Accident coverage",
              ),
              _whyGridItem(
                icon: Icons.map_rounded,
                title: _isArabic ? "مراكز قريبة" : "Nearby",
                subtitle:
                    _isArabic ? "أقرب مركز ليك على الخريطة" : "Closest on map",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _whyGridItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bg =
        _isDarkMode ? Colors.white.withOpacity(.04) : brand.withOpacity(.04);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.withOpacity(.18), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: brand, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 14.2,
              fontWeight: FontWeight.w900,
              color: textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 12.2,
              color: textSub,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerService() {
    return Row(
      children: [
        Expanded(
          child: _gradientWideButton(
            text: trKey("contact"),
            icon: Icons.headset_mic_rounded,
            onTap: _showCallSheet,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _showCallSheet,
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              gradient: _ctaGreenWhiteGradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: _greenGlow,
            ),
            child: Icon(Icons.call_rounded,
                color: _isDarkMode ? Colors.white : const Color(0xff0B1220),
                size: 32),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: titleStyle),
      );

  // ================== BOTTOM NAV (GRADIENT + BADGE + ACTIVE INDICATOR) ==================
  // ✅ مميزات:
  // - البار نفسه متدرج أخضر→أبيض
  // - زر الاتصال الدائري متدرج + Glow
  // - Badge للطلبات (اختياري)
  // - Indicator صغير تحت الأيقونة الفعالة

  int get _ordersBadgeCount => 2; // ✅ عدّلها لاحقًا من API/Prefs

  Widget _buildBottomNavCurvedWithCall() {
    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 76,
            decoration: BoxDecoration(
              gradient: _greenWhiteGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
              ),
              boxShadow: _greenGlow,
              border: Border.all(color: brand.withOpacity(.20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItemPro(Icons.person_outline, trKey("account"), 0),
                _navItemPro(Icons.directions_car, trKey("vehicles"), 1),
                const SizedBox(width: 62),
                _navItemPro(
                  Icons.receipt_long,
                  trKey("orders"),
                  2,
                  badge: _ordersBadgeCount,
                ),
                _navItemPro(Icons.home_rounded, trKey("home"), 4),
              ],
            ),
          ),

          // ✅ Floating Call Button
          Positioned(
            bottom: 32,
            child: GestureDetector(
              onTap: _showCallSheet,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: _ctaGreenWhiteGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: _greenGlow,
                ),
                child: Icon(
                  Icons.call_rounded,
                  color: _isDarkMode ? Colors.white : const Color(0xff0B1220),
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItemPro(
    IconData icon,
    String label,
    int index, {
    int badge = 0,
  }) {
    final isActive = _navIndex == index;

    return GestureDetector(
      onTap: () async {
        _tap(() => setState(() => _navIndex = index));
        switch (index) {
          case 0:
            _goto(const AccountSettingsScreen());
            break;
          case 1:
            _snack(_isArabic ? "صفحة المركبات قريبًا" : "Vehicles coming soon");
            break;
          case 2:
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            );
            break;
          default:
            break;
        }
      },
      child: SizedBox(
        width: 72,
        child: Semantics(
          button: true,
          selected: isActive,
          label: label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 140),
                    scale: isActive ? 1.06 : 1,
                    child: Icon(
                      icon,
                      color: _isDarkMode
                          ? (isActive
                              ? Colors.white
                              : Colors.white.withOpacity(.70))
                          : (isActive
                              ? const Color(0xff0B1220)
                              : const Color(0xff0B1220).withOpacity(.55)),
                      size: 26,
                    ),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -6,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: danger,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: Colors.white.withOpacity(.85), width: 1),
                        ),
                        child: Text(
                          badge > 99 ? "99+" : "$badge",
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: _isDarkMode
                      ? (isActive
                          ? Colors.white
                          : Colors.white.withOpacity(.70))
                      : (isActive
                          ? const Color(0xff0B1220)
                          : const Color(0xff0B1220).withOpacity(.55)),
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isActive ? 18 : 6,
                height: 4,
                decoration: BoxDecoration(
                  color: isActive
                      ? (_isDarkMode
                          ? Colors.white.withOpacity(.90)
                          : const Color(0xff0B1220).withOpacity(.90))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
