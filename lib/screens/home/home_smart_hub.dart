// PATH: lib/screens/home/home_smart_hub.dart
part of '../home_screen.dart';

extension _HomeSmartHub on _HomeScreenState {
  // ===================== tiny helpers =====================
  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
  }

  BoxShadow _hubShadow(
      {double blur = 28, double dy = 16, double opacity = .12}) {
    return BoxShadow(
      color: Colors.black.withOpacity(_isDarkMode ? (opacity * 1.15) : opacity),
      blurRadius: blur,
      offset: Offset(0, dy),
    );
  }

  // ✅ NEW: تدرج الأخضر/الأبيض (لايت) + تينت أخضر في الدارك
  LinearGradient get _brandWhiteGradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: _isDarkMode
            ? [
                const Color(0xff0B1220),
                Color.lerp(const Color(0xff0B1220), brand, 0.16)!,
                Color.lerp(const Color(0xff0B1220), brand2, 0.10)!,
              ]
            : [
                Color.lerp(brand, Colors.white, 0.35)!, // أخضر فاتح
                const Color(0xffffffff), // أبيض
                const Color(0xffF6FFF9), // أبيض بلمسة خضرا
              ],
      );

  // ✅ NEW: Glow أخضر بسيط احترافي
  List<BoxShadow> get _brandGlow => [
        BoxShadow(
          color: brand.withOpacity(_isDarkMode ? .16 : .18),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];

  Widget _glowDot({double size = 8}) {
    final Color g = (_HomeScreenState._gold ?? Colors.amber);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: g.withOpacity(.95),
        boxShadow: [
          BoxShadow(
            color: g.withOpacity(.45),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
    );
  }

  // ✅ NEW: route helper (real OBD flow)
  void _goToObdScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ObdScanScreen(
          isArabic: _isArabic,
          isDarkMode: _isDarkMode,
        ),
      ),
    );
  }

  // ===================== Smart Hub (PRO) =====================
  // ignore: unused_element
  Widget _smartHubBarPro() {
    return Semantics(
      button: true,
      label: _isArabic ? "فتح Smart Hub" : "Open Smart Hub",
      child: InkWell(
        onTap: () => _tap(_openSmartHubSheet),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: stroke),
            boxShadow: [
              ..._brandGlow,
              _hubShadow(opacity: .09, blur: 22, dy: 12)
            ],
            gradient: _brandWhiteGradient,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [brand, brand2.withOpacity(.80)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brand.withOpacity(.20),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Smart Hub",
                          style: GoogleFonts.cairo(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _hubBadgePro("PRO"),
                        const SizedBox(width: 8),
                        _glowDot(size: 6.5),
                        const SizedBox(width: 6),
                        Text(
                          _isArabic ? "جديد" : "New",
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: textSub,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isArabic
                          ? "تشخيص ذكي + فحص OBD بضغطة"
                          : "AI diagnosis + OBD scan in one tap",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12.2,
                        fontWeight: FontWeight.w700,
                        color: textSub,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _chip(icon: Icons.auto_awesome, text: "AI"),
                          const SizedBox(width: 8),
                          _chip(
                              icon: Icons.qr_code_scanner_rounded, text: "OBD"),
                          const SizedBox(width: 8),
                          _chip(
                              icon: Icons.speed_rounded,
                              text: _isArabic ? "سريع" : "Fast"),
                          const SizedBox(width: 8),
                          _chip(
                              icon: Icons.verified_rounded,
                              text: _isArabic ? "موثوق" : "Trusted"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                _isArabic
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 26,
                color: textSub,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _isDarkMode
            ? Colors.white.withOpacity(.06)
            : brand.withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: brand.withOpacity(.95)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hubBadgePro(String text) {
    final Color g = (_HomeScreenState._gold ?? Colors.amber);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: g.withOpacity(_isDarkMode ? .18 : .16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: g.withOpacity(.30)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          color: _isDarkMode ? Colors.white : const Color(0xff7A5400),
        ),
      ),
    );
  }

  // ===================== Smart Hub Sheet (PRO) =====================
  void _openSmartHubSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          child: Container(
            color: surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? Colors.white.withOpacity(.18)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: brand.withOpacity(_isDarkMode ? .18 : .10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: brand.withOpacity(.18)),
                        ),
                        child: Icon(Icons.auto_awesome_rounded, color: brand),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isArabic ? "Smart Hub" : "Smart Hub",
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isArabic
                                  ? "اختار تجربة التشخيص المناسبة"
                                  : "Choose the best diagnosis experience",
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                color: textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _hubBadgePro("PRO"),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _smartToolsCard(),
                  const SizedBox(height: 14),
                  _scanRescueCard(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===================== Smart Tools Card (PRO) =====================
  Widget _smartToolsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: stroke),
        boxShadow: [_hubShadow(blur: 22, dy: 12, opacity: .08)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [brand.withOpacity(.95), brand2.withOpacity(.70)],
                  ),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isArabic ? "أدوات ذكية" : "Smart Tools",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isArabic
                          ? "تشخيص سريع بطرق مختلفة"
                          : "Quick diagnosis in multiple ways",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: textSub,
                      ),
                    ),
                  ],
                ),
              ),
              _pill(icon: Icons.auto_awesome, text: _isArabic ? "AI" : "AI"),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _smartToolTile(
                  icon: Icons.flash_on_rounded,
                  title: _isArabic ? "فحص سريع" : "Quick Check",
                  subtitle: _isArabic ? "تشخيص فوري" : "Instant diagnosis",
                  onTap: _quickCheck,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _smartToolTile(
                  icon: Icons.verified_user_rounded,
                  title: _isArabic ? "هل يمكنني القيادة؟" : "Can I Drive?",
                  subtitle: _isArabic ? "أمان القيادة" : "Safety check",
                  onTap: _canIDrive,
                  emphasize: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _smartToolTile(
                  icon: Icons.photo_camera_rounded,
                  title: _isArabic ? "فحص بالصور" : "Photo Check",
                  subtitle: _isArabic ? "ارفع صورة" : "Upload a photo",
                  onTap: _photoCheck, // ✅ REAL FLOW
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _smartToolTile(
                  icon: Icons.graphic_eq_rounded,
                  title: _isArabic ? "فحص بالصوت" : "Sound Check",
                  subtitle: _isArabic ? "سجل الصوت" : "Record a sound",
                  onTap: _soundCheck,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smartToolTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool emphasize = false,
  }) {
    final bg = emphasize
        ? brand.withOpacity(_isDarkMode ? .22 : .10)
        : (_isDarkMode
            ? Colors.white.withOpacity(.05)
            : brand.withOpacity(.05));

    final border = emphasize ? brand.withOpacity(.32) : stroke;

    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: brand.withOpacity(_isDarkMode ? .18 : .10),
                    border: Border.all(color: brand.withOpacity(.18)),
                  ),
                  child: Icon(icon, color: brand, size: 20),
                ),
                const Spacer(),
                Icon(
                  _isArabic
                      ? Icons.arrow_back_ios_new
                      : Icons.arrow_forward_ios,
                  size: 14,
                  color: textSub,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 13.2,
                color: textMain,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
                fontSize: 11.8,
                color: textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Scan & Rescue Card (PRO) =====================
  Widget _scanRescueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: stroke),
        boxShadow: [_hubShadow(blur: 22, dy: 12, opacity: .08)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: brand.withOpacity(_isDarkMode ? .18 : .10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brand.withOpacity(.18)),
                ),
                child: Icon(Icons.qr_code_scanner_rounded, color: brand),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Scan & Rescue",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isArabic
                          ? "فحص أعطال كامل بالـ OBD"
                          : "Full OBD diagnostics",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: textSub,
                      ),
                    ),
                  ],
                ),
              ),
              _pill(icon: Icons.bluetooth_rounded, text: "Bluetooth"),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _miniFeature(Icons.code_rounded,
                  _isArabic ? "أكواد الأعطال (DTC)" : "DTC Codes"),
              _miniFeature(Icons.translate_rounded,
                  _isArabic ? "تفسير بالعربي" : "Explanation"),
              _miniFeature(Icons.traffic_rounded,
                  _isArabic ? "درجة الخطورة" : "Severity"),
              _miniFeature(Icons.price_change_rounded,
                  _isArabic ? "تقدير تكلفة" : "Cost Estimate"),
              _miniFeature(Icons.handyman_rounded,
                  _isArabic ? "ترشيح الفني" : "Right Technician"),
              _miniFeature(Icons.assignment_rounded,
                  _isArabic ? "تقرير جاهز" : "Shareable Report"),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openScanRescueSheet,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: brand,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon:
                      const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: Text(
                    _isArabic ? "ابدأ الفحص" : "Start Scan",
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: _showObdHowItWorks,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: brand.withOpacity(.35), width: 1.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(52, 48),
                ),
                child: Icon(Icons.info_outline_rounded,
                    color: brand.withOpacity(.95)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== UI atoms =====================
  Widget _pill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: brand.withOpacity(_isDarkMode ? .18 : .08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: brand.withOpacity(.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: brand),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniFeature(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _isDarkMode
            ? Colors.white.withOpacity(.04)
            : brand.withOpacity(.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: brand.withOpacity(.95)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              fontSize: 12.2,
              color: textMain,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Scan & Rescue Sheet (PRO) =====================
  void _openScanRescueSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            color: surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? Colors.white.withOpacity(.18)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: brand.withOpacity(_isDarkMode ? .18 : .10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: brand.withOpacity(.18)),
                      ),
                      child: Icon(Icons.qr_code_scanner_rounded,
                          color: brand, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Scan & Rescue",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isArabic
                                ? "فحص أعطال كامل عبر OBD بلوتوث"
                                : "Full scan via Bluetooth OBD",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _pill(icon: Icons.bluetooth_rounded, text: "OBD"),
                  ],
                ),
                const SizedBox(height: 14),
                _sheetBullet(
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    text: _isArabic
                        ? "أكواد الأعطال (DTC)"
                        : "DTC Trouble codes"),
                _sheetBullet(
                    icon: Icons.translate_rounded,
                    color: brand,
                    text: _isArabic
                        ? "تفسير بالعربي بشكل بسيط"
                        : "Simple explanation"),
                _sheetBullet(
                    icon: Icons.traffic_rounded,
                    color: Colors.orange,
                    text: _isArabic
                        ? "درجة الخطورة (تكمّل ولا توقف)"
                        : "Severity (drive or stop)"),
                _sheetBullet(
                    icon: Icons.payments_rounded,
                    color: Colors.amber,
                    text: _isArabic
                        ? "سعر تقديري للإصلاح"
                        : "Estimated repair cost"),
                _sheetBullet(
                    icon: Icons.engineering_rounded,
                    color: Colors.purple,
                    text:
                        _isArabic ? "ترشيح الفني المناسب" : "Recommended tech"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _goToObdScan();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: brand,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white),
                        label: Text(
                          _isArabic ? "ابدأ الفحص" : "Start scan",
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showObdHowItWorks();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: brand.withOpacity(.35), width: 1.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size(56, 52),
                      ),
                      child: Icon(Icons.info_outline_rounded,
                          color: brand.withOpacity(.95)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetBullet(
      {required IconData icon, required Color color, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(.22)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 13.2,
                color: textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== OBD How it works =====================
  void _showObdHowItWorks() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            color: surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? Colors.white.withOpacity(.18)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Text(
                  _isArabic ? "إزاي تشتغل الميزة؟" : "How does it work?",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 10),
                _howStep(
                    n: "1",
                    text: _isArabic
                        ? "اشتري قطعة OBD (الأفضل BLE زي Vgate vLinker MC+ أو OBDLink MX+)."
                        : "Buy an OBD adapter (prefer BLE like vLinker MC+ or OBDLink MX+)."),
                _howStep(
                    n: "2",
                    text: _isArabic
                        ? "ركّبها في منفذ OBD (غالباً تحت الدركسيون)."
                        : "Plug it into the OBD port (often under steering wheel)."),
                _howStep(
                    n: "3",
                    text: _isArabic
                        ? "افتح Doctor Car واضغط ابدأ الفحص."
                        : "Open Doctor Car and tap Start scan."),
                _howStep(
                    n: "4",
                    text: _isArabic
                        ? "هتاخد تقرير: أكواد + تفسير + خطورة + اقتراحات."
                        : "Get a report: codes, explanation, severity, suggestions."),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: brand,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: Text(
                      _isArabic ? "تمام" : "Got it",
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900, color: Colors.white),
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

  Widget _howStep({required String n, required String text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDarkMode
            ? Colors.white.withOpacity(.04)
            : Colors.black.withOpacity(.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: brand.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: brand.withOpacity(.18)),
            ),
            child: Center(
              child: Text(
                n,
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900, color: textMain),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: textMain,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Actions =====================
  void _quickCheck() => _openSmartSheet(
        _isArabic ? "فحص سريع" : "Quick Check",
        _isArabic
            ? "تشخيص سريع لحالة السيارة (قريباً هنربطه بالـ API)."
            : "Quick diagnosis (will connect to API soon).",
      );

  // ✅✅ PHOTO CHECK (IMPROVED UI + REAL AI CALL)
  void _photoCheck() {
    // اقفل SmartHub sheet الأول
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) => _photoCheckSheetPro(),
    );
  }

  Widget _photoCheckSheetPro() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        color: surface,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 6,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: _isDarkMode
                      ? Colors.white.withOpacity(.18)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: brand.withOpacity(_isDarkMode ? .18 : .10),
                      border: Border.all(color: brand.withOpacity(.22)),
                    ),
                    child: Icon(Icons.photo_camera_rounded,
                        color: brand, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isArabic ? "فحص بالصور" : "Photo Check",
                          style: GoogleFonts.cairo(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isArabic
                              ? "اختار صورة لتشخيص المشكلة (تقريبًا)"
                              : "Pick a photo to diagnose (approx.)",
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _pill(icon: Icons.auto_awesome_rounded, text: "AI"),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _sheetActionBtn(
                      icon: Icons.photo_library_rounded,
                      text: _isArabic ? "المعرض" : "Gallery",
                      onTap: () async {
                        Navigator.pop(context);
                        await _pickImageAndAnalyze(ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _sheetActionBtn(
                      icon: Icons.photo_camera_rounded,
                      text: _isArabic ? "الكاميرا" : "Camera",
                      onTap: () async {
                        Navigator.pop(context);
                        await _pickImageAndAnalyze(ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _pickImageAndAnalyze(ImageSource.gallery);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: brand,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Text(
                    _isArabic ? "تمام" : "OK",
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.5,
                      color: Colors.white,
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

  Widget _sheetActionBtn({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isDarkMode
              ? Colors.white.withOpacity(.05)
              : brand.withOpacity(.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: stroke),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: brand, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                color: textMain,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 1) pick image 2) show preview 3) call AI (server) 4) show result
  Future<void> _pickImageAndAnalyze(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1800,
    );

    if (file == null || !mounted) return;

    // (اختياري) افتح Preview الأول
    // ignore: unused_element
    Future<void> _pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (file == null) return;
      if (!mounted) return;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoPreviewScreen.web(
              bytes: bytes,
              fileName: file.name,
              prompt: "شخّص المشكلة من الصورة دي",
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoPreviewScreen.mobile(
              file: file,
              prompt: "شخّص المشكلة من الصورة دي",
            ),
          ),
        );
      }
    }

    // اعمل Loading
    if (!mounted) return;
    _showLoading();

    try {
      final result = await _diagnosePhotoByServer(File(file.path));
      if (!mounted) return;
      Navigator.pop(context); // close loading
      _showAiResultSheet(result);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic ? "حصل خطأ في التحليل: $e" : "AI failed: $e",
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
          ),
        ),
      );
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  // ===================== REAL AI (SERVER) =====================
  // ✅ هنا بتحط لينك السيرفر بتاعك اللي بيكلم OpenAI Vision
  // مثال: https://yourdomain.com/api/diagnose/photo
  static const String _aiPhotoDiagnoseUrl =
      "https://YOUR_DOMAIN.com/api/diagnose/photo";

  Future<Map<String, dynamic>> _diagnosePhotoByServer(File image) async {
    final dioClient = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    final form = FormData.fromMap({
      "image": await MultipartFile.fromFile(image.path, filename: "photo.jpg"),
      "lang": _isArabic ? "ar" : "en",
    });

    final res = await dioClient.post(_aiPhotoDiagnoseUrl, data: form);

    if (res.statusCode != 200) {
      throw "Server error ${res.statusCode}";
    }

    final data = res.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw "Invalid response";
  }

  void _showAiResultSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) => _aiResultSheet(data),
    );
  }

  Widget _aiResultSheet(Map<String, dynamic> data) {
    final title =
        (data["title"] ?? (_isArabic ? "نتيجة الفحص" : "Result")).toString();
    final severity = (data["severity"] ?? "unknown").toString();
    final advice = (data["advice"] ?? "").toString();

    List<String> causes = [];
    final pc = data["possible_causes"];
    if (pc is List) causes = pc.map((e) => e.toString()).toList();

    List<String> steps = [];
    final ns = data["next_steps"];
    if (ns is List) steps = ns.map((e) => e.toString()).toList();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: Container(
        color: surface,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? Colors.white.withOpacity(.18)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: brand.withOpacity(_isDarkMode ? .18 : .10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: brand.withOpacity(.20)),
                      ),
                      child: Icon(Icons.auto_awesome_rounded, color: brand),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: textMain,
                        ),
                      ),
                    ),
                    _severityPill(severity),
                  ],
                ),
                const SizedBox(height: 12),
                if (advice.trim().isNotEmpty) ...[
                  Text(
                    advice,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (causes.isNotEmpty) ...[
                  Text(
                    _isArabic ? "أسباب محتملة" : "Possible causes",
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900, color: textMain),
                  ),
                  const SizedBox(height: 8),
                  ...causes.take(6).map((c) => _bullet(c)),
                  const SizedBox(height: 12),
                ],
                if (steps.isNotEmpty) ...[
                  Text(
                    _isArabic ? "الخطوات القادمة" : "Next steps",
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900, color: textMain),
                  ),
                  const SizedBox(height: 8),
                  ...steps.take(6).map((s) => _bullet(s)),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: brand,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: Text(
                      _isArabic ? "تمام" : "OK",
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _severityPill(String severity) {
    Color c;
    String t = severity;
    if (severity.toLowerCase().contains("high")) {
      c = Colors.red;
      t = _isArabic ? "عالي" : "High";
    } else if (severity.toLowerCase().contains("medium")) {
      c = Colors.orange;
      t = _isArabic ? "متوسط" : "Medium";
    } else if (severity.toLowerCase().contains("low")) {
      c = Colors.green;
      t = _isArabic ? "منخفض" : "Low";
    } else {
      c = brand;
      t = _isArabic ? "غير معروف" : "Unknown";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(.25)),
      ),
      child: Text(
        t,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: textMain,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(color: brand, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                height: 1.3,
                color: textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _soundCheck() => _openSmartSheet(
        _isArabic ? "فحص بالصوت" : "Sound Check",
        _isArabic
            ? "سجّل صوت المحرك لتحديد المشكلة (قريباً)."
            : "Record sound (soon).",
      );

  void _canIDrive() => _openSmartSheet(
        _isArabic ? "هل يمكنني القيادة؟" : "Can I Drive?",
        _isArabic
            ? "هنحدد مستوى الخطورة وننصحك تكمل ولا توقف (قريباً)."
            : "We’ll estimate severity and advise (soon).",
      );

  // ===================== universal smart sheet =====================
  void _openSmartSheet(String title, String body) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: textSub,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: Text(
                      _isArabic ? "تمام" : "OK",
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900, color: Colors.white),
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
}
