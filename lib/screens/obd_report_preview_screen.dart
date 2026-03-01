// PATH: lib/screens/obd_report_preview_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ObdReportPreviewScreen extends StatelessWidget {
  final bool isArabic;
  final bool isDarkMode;

  const ObdReportPreviewScreen({
    super.key,
    required this.isArabic,
    required this.isDarkMode,
  });

  static const Color _primary = Color(0xff1F4BA5);

  Color get bg =>
      isDarkMode ? const Color(0xff0E1320) : const Color(0xffF5F6FA);
  Color get surface => isDarkMode ? const Color(0xff151A2E) : Colors.white;
  Color get surface2 => isDarkMode ? const Color(0xff11182A) : Colors.white;
  Color get stroke => isDarkMode
      ? Colors.white.withOpacity(.10)
      : Colors.black.withOpacity(.08);
  Color get shadow => Colors.black.withOpacity(isDarkMode ? .28 : .06);
  Color get textMain => isDarkMode ? Colors.white : const Color(0xff111827);
  Color get textSub => isDarkMode ? Colors.white70 : const Color(0xff6B7280);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            isArabic ? "تقرير الفحص" : "Scan Report",
            style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: stroke),
                boxShadow: [
                  BoxShadow(
                    color: shadow,
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: 14),
                  _severityRow(),
                  const SizedBox(height: 14),
                  _sectionTitle(isArabic ? "أكواد الأعطال (DTC)" : "DTC Codes"),
                  const SizedBox(height: 10),
                  _dtcTile(
                    code: "P0420",
                    title: isArabic
                        ? "كفاءة المحول الحفاز أقل من المطلوب"
                        : "Catalyst system efficiency below threshold",
                    subtitle: isArabic
                        ? "ينصح بالفحص خلال أسبوع"
                        : "Recommended: check within 1 week",
                    level: SeverityLevel.medium,
                  ),
                  _dtcTile(
                    code: "P0301",
                    title: isArabic
                        ? "حريق ناقص في السلندر 1"
                        : "Cylinder 1 misfire detected",
                    subtitle: isArabic
                        ? "قد يؤثر على أداء المحرك"
                        : "May affect engine performance",
                    level: SeverityLevel.high,
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle(
                      isArabic ? "إصلاحات مقترحة" : "Suggested fixes"),
                  const SizedBox(height: 10),
                  _fixTile(
                    icon: Icons.handyman,
                    title: isArabic
                        ? "فحص بوجيهات/كويلات"
                        : "Check spark plugs / coils",
                    subtitle: isArabic
                        ? "احتمال سبب مباشر للـ Misfire"
                        : "Common cause for misfire",
                  ),
                  _fixTile(
                    icon: Icons.local_gas_station,
                    title: isArabic ? "فحص حساس الأكسجين" : "Check O2 sensor",
                    subtitle:
                        isArabic ? "قد يسبب كود P0420" : "May trigger P0420",
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: isDarkMode
                                    ? const Color(0xff0B1220)
                                    : const Color(0xff111827),
                                content: Text(
                                  isArabic
                                      ? "دي شاشة معاينة. المشاركة الحقيقية هتتعمل بعد ربط بيانات الفحص ✅"
                                      : "This is a preview. Sharing will work after wiring real scan data ✅",
                                  style: GoogleFonts.cairo(),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: Text(
                            isArabic ? "مشاركة التقرير" : "Share report",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: _primary.withOpacity(.35), width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(56, 52),
                        ),
                        child:
                            Icon(Icons.close, color: _primary.withOpacity(.95)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _primary.withOpacity(isDarkMode ? .18 : .10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _primary.withOpacity(.18)),
          ),
          child: const Icon(Icons.qr_code_scanner, color: _primary, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? "Scan & Rescue" : "Scan & Rescue",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isArabic
                    ? "تقرير معاينة — شكل النتيجة بعد الفحص"
                    : "Preview report — sample result layout",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: textSub,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _primary.withOpacity(isDarkMode ? .18 : .08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _primary.withOpacity(.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bluetooth, size: 16, color: _primary),
              const SizedBox(width: 6),
              Text(
                "OBD",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: textMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        fontWeight: FontWeight.w900,
        fontSize: 14.5,
        color: textMain,
      ),
    );
  }

  Widget _severityRow() {
    // Preview severity
    final level = SeverityLevel.medium;

    final Color c = _severityColor(level);
    final IconData icon = _severityIcon(level);

    final title = isArabic
        ? (level == SeverityLevel.low
            ? "منخفض"
            : level == SeverityLevel.medium
                ? "متوسط"
                : "مرتفع")
        : (level == SeverityLevel.low
            ? "Low"
            : level == SeverityLevel.medium
                ? "Medium"
                : "High");

    final subtitle = isArabic
        ? (level == SeverityLevel.high
            ? "يفضل عدم القيادة حتى الإصلاح"
            : level == SeverityLevel.medium
                ? "ينفع تكمل لكن راجع قريبًا"
                : "الوضع طبيعي")
        : (level == SeverityLevel.high
            ? "Avoid driving until fixed"
            : level == SeverityLevel.medium
                ? "You can drive, but check soon"
                : "All good");

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withOpacity(.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withOpacity(.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.withOpacity(.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.withOpacity(.24)),
            ),
            child: Icon(icon, color: c, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? "درجة الخطورة: $title" : "Severity: $title",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: textSub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _dot(c),
          const SizedBox(width: 6),
          _dot(Colors.orange),
          const SizedBox(width: 6),
          _dot(Colors.red),
        ],
      ),
    );
  }

  Widget _dot(Color c) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _dtcTile({
    required String code,
    required String title,
    required String subtitle,
    required SeverityLevel level,
  }) {
    final c = _severityColor(level);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(.04)
            : Colors.black.withOpacity(.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _primary.withOpacity(.18)),
            ),
            child: Text(
              code,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
                color: textMain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: textSub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: c.withOpacity(.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: c.withOpacity(.25)),
            ),
            child: Text(
              _severityText(level),
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fixTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: textSub,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: textSub),
        ],
      ),
    );
  }

  String _severityText(SeverityLevel level) {
    if (isArabic) {
      switch (level) {
        case SeverityLevel.low:
          return "منخفض";
        case SeverityLevel.medium:
          return "متوسط";
        case SeverityLevel.high:
          return "مرتفع";
      }
    } else {
      switch (level) {
        case SeverityLevel.low:
          return "Low";
        case SeverityLevel.medium:
          return "Medium";
        case SeverityLevel.high:
          return "High";
      }
    }
  }

  Color _severityColor(SeverityLevel level) {
    switch (level) {
      case SeverityLevel.low:
        return Colors.green;
      case SeverityLevel.medium:
        return Colors.orange;
      case SeverityLevel.high:
        return Colors.red;
    }
  }

  IconData _severityIcon(SeverityLevel level) {
    switch (level) {
      case SeverityLevel.low:
        return Icons.check_circle;
      case SeverityLevel.medium:
        return Icons.warning_amber_rounded;
      case SeverityLevel.high:
        return Icons.error;
    }
  }
}

enum SeverityLevel { low, medium, high }
