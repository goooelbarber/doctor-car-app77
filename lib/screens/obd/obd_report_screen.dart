import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/obd/obd_ble_service.dart';
import 'obd_scan_screen.dart';
import 'obd_live_screen.dart';

/// ✅ Severity
enum DtcSeverity { low, medium, high }

class ObdReportScreen extends StatelessWidget {
  final bool isArabic;
  final bool isDarkMode;

  final List<String> dtc;
  final int? rpm;
  final int? coolant;

  /// ✅ مهم: لو بعت الـ service هنا نقدر:
  /// - Live data
  /// - Clear codes
  final ObdBleService? service;

  const ObdReportScreen({
    super.key,
    required this.isArabic,
    required this.isDarkMode,
    required this.dtc,
    required this.rpm,
    required this.coolant,
    this.service,
  });

  // ================== TOKENS (Doctor Car Neon) ==================
  Color get bg =>
      isDarkMode ? const Color(0xff0B1220) : const Color(0xffF5F7FB);
  Color get surface => isDarkMode ? const Color(0xff0E1626) : Colors.white;
  Color get surface2 =>
      isDarkMode ? const Color(0xff0C1322) : const Color(0xffF9FAFB);

  Color get textMain =>
      isDarkMode ? const Color(0xffF9FAFB) : const Color(0xff111827);
  Color get textSub =>
      isDarkMode ? const Color(0xffCBD5E1) : const Color(0xff6B7280);

  Color get brand => const Color.fromARGB(255, 26, 217, 105);
  Color get brand2 => Color.lerp(brand, const Color(0xff0B1220), 0.22)!;
  Color get brand3 => Color.lerp(brand, Colors.white, 0.18)!;

  Color get stroke => isDarkMode
      ? Colors.white.withOpacity(.10)
      : Colors.black.withOpacity(.06);

  LinearGradient get greenWhiteGradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          brand.withOpacity(isDarkMode ? .85 : .92),
          Color.lerp(brand, Colors.white, isDarkMode ? .55 : .62)!,
          Colors.white.withOpacity(isDarkMode ? .06 : 1),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  LinearGradient get screenBgGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDarkMode
            ? [
                const Color(0xff0B1220),
                Color.lerp(const Color(0xff0B1220), brand2, 0.06)!,
                const Color(0xff07101C),
              ]
            : const [
                Color(0xffF5F7FB),
                Color(0xffFFFFFF),
                Color(0xffF2F6FF),
              ],
      );

  LinearGradient get appBarGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xff06101C),
          Color.lerp(const Color(0xff06101C), brand2, 0.10)!,
          Color.lerp(const Color(0xff06101C), brand, 0.06)!,
        ],
        stops: const [0.0, 0.65, 1.0],
      );

  List<BoxShadow> get shSm => [
        BoxShadow(
          color: Colors.black.withOpacity(isDarkMode ? .30 : .08),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ];

  List<BoxShadow> get greenGlow => [
        BoxShadow(
          color: brand.withOpacity(isDarkMode ? .22 : .18),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(isDarkMode ? .28 : .08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  // ================== Labels ==================
  String tr(String ar, String en) => isArabic ? ar : en;

  bool get hasDtc => dtc.isNotEmpty;

  int get highCount =>
      dtc.where((c) => _severity(c) == DtcSeverity.high).length;
  int get medCount =>
      dtc.where((c) => _severity(c) == DtcSeverity.medium).length;

  String get healthTitle {
    if (!hasDtc) return tr("الحالة ممتازة", "All good");
    if (highCount > 0) {
      return tr("أعطال خطيرة محتاجة تدخل", "Critical issues detected");
    }
    return tr("تم رصد أعطال", "Issues detected");
  }

  Color get healthColor {
    if (!hasDtc) return const Color(0xff22C55E);
    if (highCount > 0) return const Color(0xffEF4444);
    return const Color(0xffF59E0B);
  }

  String rpmText() => rpm?.toString() ?? tr("غير متاح", "N/A");
  String coolText() => coolant == null ? tr("غير متاح", "N/A") : "$coolant°C";

  Color coolantColor() {
    if (coolant == null) return textSub;
    if (coolant! >= 110) return const Color(0xffEF4444);
    if (coolant! >= 95) return const Color(0xffF59E0B);
    return const Color(0xff22C55E);
  }

  // ================== DTC Dictionary (مبدئي) ==================
  Map<String, Map<String, String>> get _dtcDict => {
        "P0300": {
          "ar": "تقطيع/فقدان اشتعال عشوائي",
          "en": "Random/Multiple Cylinder Misfire"
        },
        "P0301": {"ar": "تقطيع في السلندر 1", "en": "Cylinder 1 Misfire"},
        "P0302": {"ar": "تقطيع في السلندر 2", "en": "Cylinder 2 Misfire"},
        "P0303": {"ar": "تقطيع في السلندر 3", "en": "Cylinder 3 Misfire"},
        "P0304": {"ar": "تقطيع في السلندر 4", "en": "Cylinder 4 Misfire"},
        "P0420": {
          "ar": "كفاءة الكاتالايزر أقل من الطبيعي",
          "en": "Catalyst System Efficiency Below Threshold"
        },
        "P0171": {"ar": "خليط فقير (Bank 1)", "en": "System Too Lean (Bank 1)"},
        "P0172": {"ar": "خليط غني (Bank 1)", "en": "System Too Rich (Bank 1)"},
        "P0101": {"ar": "خلل حساس الهواء MAF", "en": "MAF Sensor issue"},
        "P0115": {
          "ar": "خلل حساس حرارة المحرك",
          "en": "Coolant Temp Sensor Circuit"
        },
        "P0128": {
          "ar": "حرارة التشغيل أقل من الطبيعي",
          "en": "Coolant Thermostat"
        },
        "P0401": {"ar": "تدفق EGR غير كافي", "en": "EGR Flow Insufficient"},
      };

  String _dtcTitle(String code) {
    final item = _dtcDict[code];
    if (item == null) return tr("كود يحتاج تفسير", "Code needs interpretation");
    return isArabic ? item["ar"]! : item["en"]!;
  }

  DtcSeverity _severity(String code) {
    if (code.startsWith("P03")) return DtcSeverity.high; // misfire غالبًا مهم
    if (code == "P0420") return DtcSeverity.medium;
    if (code == "P0171" || code == "P0172") return DtcSeverity.medium;
    if (code == "P0115" || code == "P0128") return DtcSeverity.medium;
    return DtcSeverity.low;
  }

  Color _severityColor(DtcSeverity s) {
    switch (s) {
      case DtcSeverity.high:
        return const Color(0xffEF4444);
      case DtcSeverity.medium:
        return const Color(0xffF59E0B);
      case DtcSeverity.low:
        return const Color(0xff22C55E);
    }
  }

  String _severityText(DtcSeverity s) {
    switch (s) {
      case DtcSeverity.high:
        return tr("خطر", "High");
      case DtcSeverity.medium:
        return tr("متوسط", "Medium");
      case DtcSeverity.low:
        return tr("خفيف", "Low");
    }
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: screenBgGradient)),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                children: [
                  _summaryCard(context),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          icon: Icons.speed_rounded,
                          title: tr("RPM", "RPM"),
                          value: rpmText(),
                          valueColor: brand3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _metricCard(
                          icon: Icons.thermostat_rounded,
                          title: tr("حرارة المحرك", "Coolant"),
                          value: coolText(),
                          valueColor: coolantColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _dtcCard(context),
                  const SizedBox(height: 14),
                  _actionsGrid(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleSpacing: 0,
      flexibleSpace:
          Container(decoration: BoxDecoration(gradient: appBarGradient)),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: greenWhiteGradient,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(.10)),
              boxShadow: greenGlow,
            ),
            child: const Icon(Icons.car_repair, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            tr("تقرير الفحص", "Scan Report"),
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              fontSize: 16.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: tr("إعادة فحص", "Rescan"),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ObdScanScreen(isArabic: isArabic, isDarkMode: isDarkMode),
              ),
            );
          },
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _summaryCard(BuildContext context) {
    final score = _healthScore();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stroke),
        boxShadow: shSm,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: healthColor.withOpacity(isDarkMode ? .18 : .10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: healthColor.withOpacity(.25)),
            ),
            child: Icon(
              hasDtc ? Icons.warning_rounded : Icons.verified_rounded,
              color: healthColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  healthTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _miniChip(
                      icon: Icons.health_and_safety_rounded,
                      text: tr("صحة: $score%", "Health: $score%"),
                      color: hasDtc
                          ? const Color(0xffF59E0B)
                          : const Color(0xff22C55E),
                    ),
                    _miniChip(
                      icon: Icons.code_rounded,
                      text: tr("أكواد: ${dtc.length}", "DTC: ${dtc.length}"),
                      color: brand,
                    ),
                    if (highCount > 0)
                      _miniChip(
                        icon: Icons.priority_high_rounded,
                        text: tr("خطير: $highCount", "High: $highCount"),
                        color: const Color(0xffEF4444),
                      ),
                    _miniChip(
                      icon: Icons.thermostat_rounded,
                      text: tr("حرارة: ${coolText()}", "Temp: ${coolText()}"),
                      color: coolantColor(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _healthScore() {
    var score = 100;
    score -= dtc.length * 8;
    score -= highCount * 18;
    score -= medCount * 10;

    if (coolant != null && coolant! >= 110) score -= 20;
    if (coolant != null && coolant! >= 95) score -= 10;

    if (score < 0) score = 0;
    if (score > 100) score = 100;
    return score;
  }

  Widget _miniChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? .16 : .10),
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

  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: glassCardGradient(),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stroke),
        boxShadow: shSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: brand.withOpacity(isDarkMode ? .18 : .10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: brand.withOpacity(.22)),
            ),
            child: Icon(icon, color: brand3, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.2,
                    color: textSub,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient glassCardGradient() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [
                Colors.white.withOpacity(.08),
                Colors.white.withOpacity(.05),
                Colors.white.withOpacity(.03),
              ]
            : [
                Colors.white.withOpacity(.92),
                Colors.white.withOpacity(.82),
                Colors.white.withOpacity(.88),
              ],
        stops: const [0.0, 0.55, 1.0],
      );

  Widget _dtcCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stroke),
        boxShadow: shSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr("أكواد الأعطال (DTC)", "DTC Codes"),
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    color: textMain,
                    fontSize: 15,
                  ),
                ),
              ),
              if (dtc.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _copyAll(context),
                  icon: Icon(Icons.copy_all_rounded, color: brand3, size: 18),
                  label: Text(
                    tr("نسخ", "Copy"),
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w900,
                      color: brand3,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (dtc.isEmpty)
            Text(
              tr("لا يوجد أكواد أعطال ✅", "No trouble codes ✅"),
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                color: textSub,
              ),
            )
          else
            Column(
              children: dtc.map((c) => _dtcRow(context, c)).toList(),
            ),
          if (dtc.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              tr(
                "ملاحظة: التفسير ده مبدئي، وقد يختلف حسب موديل العربية.",
                "Note: This interpretation is generic and may vary by vehicle model.",
              ),
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: textSub,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dtcRow(BuildContext context, String code) {
    final sev = _severity(code);
    final sevColor = _severityColor(sev);
    final title = _dtcTitle(code);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sevColor.withOpacity(.30)),
        color: surface2.withOpacity(isDarkMode ? .55 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: sevColor.withOpacity(isDarkMode ? .18 : .10),
              border: Border.all(color: sevColor.withOpacity(.22)),
            ),
            child: Icon(
              sev == DtcSeverity.high
                  ? Icons.report_gmailerrorred_rounded
                  : sev == DtcSeverity.medium
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
              color: sevColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        code,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          color: textMain,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    _pill(_severityText(sev), sevColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w800,
                    color: textSub,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _snack(
                          context,
                          tr(
                            "هنضيف شرح أعمق وخطوات إصلاح قريبًا",
                            "We’ll add deeper fix steps soon",
                          ),
                        );
                      },
                      icon: Icon(Icons.lightbulb_outline_rounded,
                          color: brand3, size: 18),
                      label: Text(
                        tr("نصائح", "Tips"),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          color: brand3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: tr("نسخ الكود", "Copy code"),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: code));
                        _snack(context, tr("تم نسخ $code ✅", "Copied $code ✅"));
                      },
                      icon: Icon(Icons.copy_rounded, color: textSub),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? .16 : .10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: textMain,
        ),
      ),
    );
  }

  // ✅ Actions grid
  Widget _actionsGrid(BuildContext context) {
    final hasService = service != null && service!.isConnected;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionBtn(
                icon: Icons.timeline_rounded,
                text: tr("Live Data", "Live Data"),
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (!hasService) {
                    _snack(
                      context,
                      tr(
                        "لازم تفتح التقرير من نفس جلسة الاتصال (service)",
                        "Open report from same connection session (service)",
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ObdLiveScreen(
                        isArabic: isArabic,
                        isDarkMode: isDarkMode,
                        service: service!,
                      ),
                    ),
                  );
                },
                gradient: greenWhiteGradient,
                textColor: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionBtn(
                icon: Icons.cleaning_services_rounded,
                text: tr("مسح الأعطال", "Clear Codes"),
                onTap: () async {
                  HapticFeedback.selectionClick();
                  if (!hasService) {
                    _snack(
                      context,
                      tr(
                        "لازم تفتح التقرير من نفس جلسة الاتصال (service)",
                        "Open report from same connection session (service)",
                      ),
                    );
                    return;
                  }
                  final ok = await _confirmClear(context);
                  if (!ok) return;

                  try {
                    await service!.readLiveOnce(
                      "04",
                      timeout: const Duration(seconds: 10),
                    );
                    _snack(
                      context,
                      tr("تم إرسال أمر مسح الأعطال ✅", "Clear command sent ✅"),
                    );
                  } catch (e) {
                    _snack(
                      context,
                      tr("فشل مسح الأعطال: $e", "Clear failed: $e"),
                    );
                  }
                },
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color(0xffEF4444).withOpacity(isDarkMode ? .60 : .85),
                    Colors.white.withOpacity(isDarkMode ? .06 : .92),
                  ],
                ),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionBtn(
                icon: Icons.ios_share_rounded,
                text: tr("مشاركة", "Share"),
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final text = _buildShareText();
                  await Clipboard.setData(ClipboardData(text: text));
                  _snack(
                    context,
                    tr(
                      "تم نسخ التقرير ✅ (شاركّه من أي مكان)",
                      "Report copied ✅ (share it anywhere)",
                    ),
                  );
                },
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.white.withOpacity(isDarkMode ? .10 : .92),
                    Colors.white.withOpacity(isDarkMode ? .06 : .78),
                  ],
                ),
                textColor: textMain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionBtn(
                icon: Icons.picture_as_pdf_rounded,
                text: tr("حفظ PDF", "Save PDF"),
                onTap: () {
                  HapticFeedback.selectionClick();
                  _snack(
                    context,
                    tr(
                      "ميزة PDF جاهزة للربط (لو تحب أضيفها فعليًا في الملف الجاي)",
                      "PDF is ready to wire up (I can add it next)",
                    ),
                  );
                },
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.white.withOpacity(isDarkMode ? .10 : .92),
                    Colors.white.withOpacity(isDarkMode ? .06 : .78),
                  ],
                ),
                textColor: textMain,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required LinearGradient gradient,
    required Color textColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: stroke),
          boxShadow: greenGlow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmClear(BuildContext context) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              backgroundColor: surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                tr("تأكيد مسح الأعطال", "Confirm clear codes"),
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  color: textMain,
                ),
              ),
              content: Text(
                tr(
                  "مسح الأعطال ممكن يطفي لمبة Check Engine مؤقتًا، لكن لو العطل موجود هيرجع تاني.\nهل تريد المتابعة؟",
                  "Clearing codes may turn off the Check Engine light temporarily. If the issue remains, it may return.\nContinue?",
                ),
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                  color: textSub,
                  height: 1.3,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    tr("إلغاء", "Cancel"),
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w900,
                      color: textSub,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    tr("متابعة", "Continue"),
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w900,
                      color: brand3,
                    ),
                  ),
                ),
              ],
            );
          },
        )) ??
        false;
  }

  Future<void> _copyAll(BuildContext context) async {
    final text = dtc.join(" , ");
    await Clipboard.setData(ClipboardData(text: text));
    _snack(context, tr("تم نسخ الأكواد ✅", "Codes copied ✅"));
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.black.withOpacity(.85),
      ),
    );
  }

  String _buildShareText() {
    return [
      "Doctor Car OBD Report",
      "RPM: ${rpmText()}",
      "Coolant: ${coolText()}",
      "DTC: ${dtc.isEmpty ? 'None' : dtc.join(', ')}",
    ].join("\n");
  }
}
