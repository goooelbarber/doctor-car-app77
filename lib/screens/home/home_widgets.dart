// PATH: lib/screens/home/home_widgets.dart
// ignore_for_file: invalid_use_of_protected_member

part of '../home_screen.dart';

extension _HomeWidgets on _HomeScreenState {
  // ================== Helpers ==================
  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
  }

  // ignore: unused_element
  BoxShadow _softShadow({
    double blur = 22,
    double dy = 12,
    double opacity = .14,
  }) {
    return BoxShadow(
      color: Colors.black.withOpacity(_isDarkMode ? (opacity * 1.15) : opacity),
      blurRadius: blur,
      offset: Offset(0, dy),
    );
  }

// ================== LOGIN / APP PALETTE ==================
// ignore: unused_element
  Color get _bgStart => const Color(0xFF081A36);
// ignore: unused_element
  Color get _bgEnd => const Color(0xFF040D1D);

  Color get _panel => const Color(0xFF143F7C);
// ignore: unused_element
  Color get _panelTop => const Color(0xFF1B4F9C);

  Color get _accent => const Color(0xFF1B4F9C);
  Color get _accentDark => const Color(0xFF10386B);
  Color get _accentSoft => const Color(0xFFE7EEF9);

  Color get _text => const Color(0xFFFFFFFF);
  Color get _muted => const Color(0xFFC9D6EA);
// ignore: unused_element
  Color get _hint => const Color(0xFF93A9C9);

// ignore: unused_element
  Color get _line => const Color(0xFF29496F);
// ignore: unused_element
  Color get _lime => const Color(0xFFE8F09E);

  Color get _ink => const Color(0xFFF2F6FB);
  Color get _inkSoft => const Color(0xFF93A9C9);

// ignore: deprecated_member_use
  Color get _lineColor =>
      _isDarkMode ? Colors.white.withOpacity(.12) : const Color(0xFF29496F);

  // ==================   ASSET IMAGES  ==================
  static const String _imgRoadService = 'assets/images/4.png';
  static const String _imgMaintenance = 'assets/images/44.png';
  // ignore: unused_field
  static const String _imgDiagnosis = 'assets/icons/diagnosis.png';
  static const String _imgStore = 'assets/images/444.png';

  // ================== GRADIENTS ==================
// ================== GRADIENTS ==================
  LinearGradient get _aquaCreamGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF17345F),
          Color(0xFF143F7C),
          Color(0xFF1B4F9C),
        ],
        stops: [0.0, 0.55, 1.0],
      );

  LinearGradient get _ctaAquaGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1B4F99),
          Color(0xFF245AA6),
          Color(0xFF153F78),
        ],
        stops: [0.0, 0.50, 1.0],
      );

  LinearGradient get _premiumAppBarGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1D4F99),
          Color(0xFF163F7E),
          Color(0xFF0E2D60),
        ],
      );

  LinearGradient get _darkGlassGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF17345F),
          Color(0xFF122B50),
          Color(0xFF0D2140),
        ],
      );

  LinearGradient get _panelGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF17345F),
          Color(0xFF122B50),
        ],
      );

// ignore: unused_element
  LinearGradient get _quickCardGradientDark => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1B4F9C),
          Color(0xFF10386B),
        ],
      );

// ignore: unused_element
  LinearGradient get _quickCardGradientLight => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF17345F),
          Color(0xFF0D2140),
        ],
      );

  List<BoxShadow> get _aquaGlow => [
        BoxShadow(
          color: _accent.withOpacity(_isDarkMode ? .22 : .16),
          blurRadius: 26,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: const Color(0xFF5F9FD3).withOpacity(.16),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  // ================== Shared asset image widget ==================
  // ignore: unused_element
  Widget _assetIcon(
    String path, {
    double size = 26,
    double radius = 10,
    BoxFit fit = BoxFit.contain,
    bool withBackground = false,
    bool active = false,
  }) {
    return Container(
      width: withBackground ? size + 16 : size,
      height: withBackground ? size + 16 : size,
      decoration: withBackground
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: active ? _ctaAquaGradient : null,
              color: active
                  ? null
                  : (_isDarkMode
                      ? Colors.white.withOpacity(.08)
                      : Colors.white.withOpacity(.95)),
              border: Border.all(
                color: active
                    ? _accent.withOpacity(.30)
                    : (_isDarkMode
                        ? Colors.white.withOpacity(.12)
                        : _accent.withOpacity(.16)),
              ),
              boxShadow: active ? _aquaGlow.take(1).toList() : null,
            )
          : null,
      padding: EdgeInsets.all(withBackground ? 8 : 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          path,
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (_, __, ___) => Icon(
            Icons.image_not_supported_outlined,
            size: size,
            color: _isDarkMode ? _muted : _inkSoft,
          ),
        ),
      ),
    );
  }

  // ================== PRO Buttons ==================
  Widget _gradientPillButton({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
    bool compact = true,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 16,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          gradient: _ctaAquaGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accent.withOpacity(.20)),
          boxShadow: _aquaGlow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: _isDarkMode ? Colors.black : _ink,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 13.2,
                color: _isDarkMode ? Colors.black : _ink,
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
          gradient: _ctaAquaGradient,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _accent.withOpacity(.20)),
          boxShadow: _aquaGlow,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: _isDarkMode ? Colors.black : _ink,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: _isDarkMode ? Colors.black : _ink,
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

  // ================== Call sheet ==================
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
                decoration: BoxDecoration(
                  color: surface,
                  gradient: _isDarkMode ? _darkGlassGradient : _panelGradient,
                ),
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
                              : const Color(0xFFF2F8FD),
                          iconColor: _accent,
                          onTap: _openSupportChatFromSheet,
                        ),
                        const SizedBox(height: 12),
                        _sheetCard(
                          icon: Icons.emergency_rounded,
                          title: trKey("emergency"),
                          subtitle: trKey("emergencySub"),
                          bg: _isDarkMode
                              ? Colors.white.withOpacity(.06)
                              : const Color(0xFFF8FBFF),
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
          border: Border.all(color: _lineColor),
          boxShadow: _isDarkMode ? _aquaGlow.take(1).toList() : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: _isDarkMode ? _darkGlassGradient : null,
                color: _isDarkMode ? null : Colors.white,
                borderRadius: BorderRadius.circular(r16),
                border: Border.all(color: _lineColor),
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

  // ================== My location card ==================
  Widget _myLocationCard() {
    if (_myPos == null) return const SizedBox.shrink();

    final lat = _myPos!.latitude.toStringAsFixed(5);
    final lng = _myPos!.longitude.toStringAsFixed(5);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: _isDarkMode ? _panelGradient : null,
        color: _isDarkMode ? null : surface,
        borderRadius: BorderRadius.circular(r18),
        border: Border.all(color: _lineColor),
        boxShadow: shSm,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _accent.withOpacity(_isDarkMode ? .20 : .10),
              borderRadius: BorderRadius.circular(r16),
              border: Border.all(color: _accent.withOpacity(.18)),
            ),
            child: Icon(Icons.my_location, color: _accent, size: 20),
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

  // ================== Radius selector ==================
  Widget _radiusSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: _isDarkMode ? _panelGradient : null,
        color: _isDarkMode ? null : surface,
        border: Border.all(color: _lineColor),
        borderRadius: BorderRadius.circular(r18),
        boxShadow: shSm,
      ),
      child: Row(
        children: [
          Icon(Icons.radar_rounded, color: _accent.withOpacity(.95)),
          const SizedBox(width: 10),
          Text(
            "${trKey("radius")}: ",
            style: bodyStrong.copyWith(fontSize: 13),
          ),
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
                          color: selected ? Colors.black : textMain,
                        ),
                      ),
                      onSelected: (_) => _setRadiusKm(km),
                      selectedColor: _accent,
                      backgroundColor: _isDarkMode
                          ? Colors.white.withOpacity(.06)
                          : Colors.grey.shade100,
                      side: BorderSide(color: selected ? _accent : _lineColor),
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

  // ================== APP BAR ==================
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 78,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: _premiumAppBarGradient),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(.10),
                Colors.transparent,
              ],
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
                onTap: () => _snack(
                  _isArabic ? "لا توجد إشعارات الآن" : "No notifications yet",
                ),
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
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(.26)),
                ),
                child:
                    const Icon(Icons.car_repair, color: Colors.white, size: 18),
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
              color: Colors.white.withOpacity(.78),
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
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(r16),
              border: Border.all(color: Colors.white.withOpacity(.16)),
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

  // ================== BANNER ==================
  Widget _bannerSlider() {
    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r22),
            boxShadow: [
              ...shMd,
              BoxShadow(
                color: _accent.withOpacity(.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
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
                          child: Icon(Icons.image, size: 44, color: textSub),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(.20),
                        Colors.transparent,
                        _accent.withOpacity(.10),
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
                      _isArabic ? "أقرب العروض قريبًا" : "Top offers soon",
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white.withOpacity(.16),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r16),
                        side: BorderSide(color: Colors.white.withOpacity(.20)),
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
                    ? _accent
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
    return Column(
      children: [
        _serviceWideTopCard(
          title: _isArabic ? "خدمات الطريق" : "Road Services",
          subtitle: _isArabic ? "المساعدة على الطريق" : "Roadside Assistance",
          imagePath: _imgRoadService,
          onTap: () => _goto(const RoadServicesScreen()),
          showEmergencyBadge: true,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _serviceBottomCard(
                title: _isArabic ? "المتجر" : "Store",
                imagePath: _imgStore,
                onTap: () => _goto(const HomePage()),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _serviceBottomCard(
                title: _isArabic ? "الصيانة" : "Maintenance",
                imagePath: _imgMaintenance,
                onTap: () => _goto(const MaintenanceServicesScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _serviceWideTopCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
    bool showEmergencyBadge = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => _tap(onTap),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isDarkMode
                ? const [
                    Color(0xFF477CB1),
                    Color(0xFF2F67A1),
                    Color(0xFF1F5D99),
                  ]
                : const [
                    Color(0xFF4D86BF),
                    Color(0xFF2F67A1),
                    Color(0xFF1C5388),
                  ],
          ),
          border: Border.all(
            color: const Color(0xFF7CC4F5).withOpacity(.60),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(.14),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(_isDarkMode ? .28 : .08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(.10),
                        Colors.transparent,
                        Colors.black.withOpacity(.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    color: const Color(0xFF325D8F).withOpacity(.55),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.black.withOpacity(.22),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 36,
                          color: _muted,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: _isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showEmergencyBadge)
                          Align(
                            alignment: _isArabic
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4C57),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                "EMERGENCY",
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          textAlign:
                              _isArabic ? TextAlign.right : TextAlign.left,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          textAlign:
                              _isArabic ? TextAlign.right : TextAlign.left,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFD8F0FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.10),
                    border: Border.all(
                      color: Colors.white.withOpacity(.08),
                    ),
                  ),
                  child: Icon(
                    _isArabic
                        ? Icons.arrow_back_rounded
                        : Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceBottomCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => _tap(onTap),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isDarkMode
                ? const [
                    Color(0xFF4A82BA),
                    Color(0xFF2F67A1),
                    Color(0xFF1F5D99),
                  ]
                : const [
                    Color(0xFF4B80B7),
                    Color(0xFF2F67A1),
                    Color(0xFF1F5D99),
                  ],
            stops: const [0.0, 0.58, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFF2A5886).withOpacity(.60),
            width: 1.15,
          ),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(_isDarkMode ? .14 : .10),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(_isDarkMode ? .25 : .05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF315F93).withOpacity(.62),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF264F7D).withOpacity(.90),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 36,
                          color: _muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ retained old cards ------------------
  // ignore: unused_element
  Widget _serviceCardPro({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    final darkish = gradient.colors.last.computeLuminance() < .45;

    return InkWell(
      borderRadius: BorderRadius.circular(r22),
      onTap: () => _tap(onTap),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(r22),
          border: Border.all(
            color: darkish
                ? Colors.white.withOpacity(.14)
                : _accent.withOpacity(.18),
          ),
          boxShadow: _aquaGlow,
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: _isDarkMode
                    ? Colors.white.withOpacity(.10)
                    : Colors.white.withOpacity(.88),
                borderRadius: BorderRadius.circular(r18),
                border: Border.all(
                  color: iconColor.withOpacity(_isDarkMode ? .22 : .18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(.12),
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
                color: darkish ? Colors.white : _ink,
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
                color: darkish ? Colors.white.withOpacity(.78) : _inkSoft,
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

  // ignore: unused_element
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
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: Colors.white.withOpacity(.85),
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

  // ================== OFFERS ==================
  // ignore: unused_element
  void _openOfferDetails(OfferItem o) {
    return;
  }

  // ignore: unused_element
  Widget _offersSlider() {
    return const SizedBox.shrink();
  }

  // ---------------- DRAWER ----------------
  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 14),
            decoration: BoxDecoration(
              gradient: _premiumAppBarGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(.16),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Doctor Car",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isArabic
                              ? "خدمات السيارات الذكية"
                              : "Smart car services",
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          _drawerItem(
            Icons.info_outline,
            _isArabic ? "من نحن" : "About Us",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
            ),
          ),
          _drawerItem(
            Icons.home_rounded,
            _isArabic ? "الرئيسية" : "Home",
            () {},
          ),
          _drawerItem(
            Icons.local_shipping_rounded,
            _isArabic ? "خدمات الطرق" : "Road Services",
            () => _goto(const RoadServicesScreen()),
          ),
          _drawerItem(
            Icons.shield_rounded,
            _isArabic ? "التبليغ عن حادث" : "Accident Report",
            () => _goto(const SmartAccidentScreen()),
          ),
          _drawerItem(
            Icons.store_rounded,
            _isArabic ? "المتجر" : "Store",
            () => _goto(const HomePage()),
          ),
          _drawerItem(
            Icons.phone_rounded,
            _isArabic ? "تواصل معنا" : "Contact",
            () => _goto(const ContactScreen()),
          ),
          _drawerItem(
            Icons.person_rounded,
            _isArabic ? "حسابي" : "Account",
            () => _goto(const AccountSettingsScreen()),
          ),
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
      leading: Icon(icon, color: _accent),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          color: textMain,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      trailing: Icon(
        _isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        color: textSub,
      ),
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
              border: Border.all(color: _lineColor),
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
        border: Border.all(color: _lineColor),
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
                  _snack(_isArabic
                      ? "تعذر فتح خرائط جوجل"
                      : "Could not open Google Maps");
                }
                return;
              }

              try {
                await Geolocator.openLocationSettings();
              } catch (_) {
                try {
                  await _openGoogleMapsNearby();
                } catch (_) {
                  _snack(_isArabic
                      ? "افتح إعدادات الموقع يدويًا"
                      : "Please open location settings manually");
                }
              }
            },
            child: Text(
              kIsWeb
                  ? (_isArabic ? "فتح خرائط جوجل" : "Open Google Maps")
                  : trKey("openSettings"),
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                color: _accent,
              ),
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
        border: Border.all(color: _lineColor),
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
                  side: BorderSide(
                    color: _accent.withOpacity(.35),
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r16),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(
                  trKey("retry"),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                ),
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
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: _accent),
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
        border: Border.all(color: _lineColor),
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
                    Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStrong.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _chip(
                          Icons.star_rounded,
                          Colors.amber,
                          c.rating.toStringAsFixed(1),
                        ),
                        if (c.distanceText.isNotEmpty)
                          _chip(
                            Icons.location_on_rounded,
                            _accent,
                            c.distanceText,
                          ),
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
              isDark: _isDarkMode,
            ),
            _HowCard(
              icon: Icons.payment,
              text:
                  _isArabic ? "الدفع اون لاين\nأو كاش" : "Pay Online\nor Cash",
              isDark: _isDarkMode,
            ),
            _HowCard(
              icon: Icons.assignment_turned_in,
              text: _isArabic ? "احجز\nو تابع" : "Book\n& Track",
              isDark: _isDarkMode,
            ),
            _HowCard(
              icon: Icons.location_on,
              text: _isArabic ? "اختر\nالخدمة" : "Choose\nService",
              isDark: _isDarkMode,
            ),
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
        border: Border.all(color: _lineColor),
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
                  color: _accent,
                  borderRadius: BorderRadius.circular(6),
                ),
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
        _isDarkMode ? Colors.white.withOpacity(.04) : _accent.withOpacity(.05);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withOpacity(.18), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: _ctaAquaGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: _isDarkMode ? Colors.black : _ink,
              size: 26,
            ),
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
              gradient: _ctaAquaGradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: _aquaGlow,
            ),
            child: Center(
              child: Icon(
                Icons.phone_in_talk_rounded,
                size: 34,
                color: _isDarkMode ? Colors.black : _ink,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: titleStyle),
      );

  // ================== BOTTOM NAV ==================
  Widget _buildBottomNavCurvedWithCall() {
    return SizedBox(
      height: 128,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 102,
            padding: const EdgeInsets.only(top: 8, bottom: 14),
            decoration: BoxDecoration(
              gradient: _aquaCreamGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                ..._aquaGlow,
                BoxShadow(
                  color: Colors.black.withOpacity(.14),
                  blurRadius: 14,
                  offset: const Offset(0, -1),
                ),
              ],
              border: Border.all(color: _accent.withOpacity(.18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _navItemBottom(
                  icon: Icons.cottage_rounded,
                  label: "الرئيسية",
                  index: 0,
                ),
                _navItemBottom(
                  icon: Icons.fact_check_rounded,
                  label: "الطلبات",
                  index: 1,
                  badge: 2,
                ),
                const SizedBox(width: 88),
                _navItemBottom(
                  icon: Icons.time_to_leave_rounded,
                  label: "مركباتي",
                  index: 3,
                ),
                _navItemBottom(
                  icon: Icons.account_circle_rounded,
                  label: "حسابي",
                  index: 4,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            child: GestureDetector(
              onTap: _showCallSheet,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _ctaAquaGradient,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    ..._aquaGlow,
                    BoxShadow(
                      color: Colors.black.withOpacity(.20),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.08),
                    border: Border.all(
                      color: Colors.white.withOpacity(.14),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.call_rounded,
                      size: 38,
                      color: _isDarkMode ? Colors.black : _ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItemBottom({
    required IconData icon,
    required String label,
    required int index,
    int badge = 0,
  }) {
    final isActive = _navIndex == index;

    return GestureDetector(
      onTap: () async {
        _tap(() => setState(() => _navIndex = index));

        switch (index) {
          case 0:
            break;

          case 1:
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            );
            break;

          case 3:
            _snack(
              _isArabic ? "صفحة مركباتي قريبًا" : "My vehicles coming soon",
            );
            break;

          case 4:
            _goto(const AccountSettingsScreen());
            break;

          default:
            break;
        }
      },
      child: SizedBox(
        width: 74,
        child: Semantics(
          button: true,
          selected: isActive,
          label: label,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: isActive ? 52 : 48,
                    height: isActive ? 52 : 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      gradient: isActive
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(.20),
                                Colors.white.withOpacity(.08),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(.16),
                                Colors.black.withOpacity(.08),
                              ],
                            ),
                      border: Border.all(
                        color: isActive
                            ? Colors.white.withOpacity(.34)
                            : Colors.white.withOpacity(.12),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isActive
                              ? Colors.white.withOpacity(.05)
                              : Colors.black.withOpacity(.10),
                          blurRadius: isActive ? 12 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: isActive ? 26 : 23,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(.90),
                    ),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -1,
                      top: -5,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 22,
                          minHeight: 20,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A52),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5A52).withOpacity(.30),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          badge > 99 ? "99+" : "$badge",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              SizedBox(
                height: 16,
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 10.6,
                      fontWeight: isActive ? FontWeight.w900 : FontWeight.w800,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(.84),
                      height: 1.0,
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
}
