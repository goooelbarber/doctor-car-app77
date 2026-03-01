import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationHelpScreen extends StatefulWidget {
  final bool isArabic;
  final bool isDarkMode;

  /// لازم Future عشان نقدر نعمل await قبل ما نقفل الشاشة
  final Future<void> Function() onRefresh;

  const LocationHelpScreen({
    super.key,
    required this.isArabic,
    required this.isDarkMode,
    required this.onRefresh,
  });

  @override
  State<LocationHelpScreen> createState() => _LocationHelpScreenState();
}

class _LocationHelpScreenState extends State<LocationHelpScreen> {
  bool _loading = false;

  // status badges
  bool _serviceEnabled = true;
  LocationPermission? _perm;

  Color get bg =>
      widget.isDarkMode ? const Color(0xff0E1320) : const Color(0xffF5F6FA);
  Color get surface =>
      widget.isDarkMode ? const Color(0xff151A2E) : Colors.white;
  Color get textMain =>
      widget.isDarkMode ? Colors.white : const Color(0xff111827);
  Color get textSub =>
      widget.isDarkMode ? Colors.white70 : const Color(0xff6B7280);

  static const Color primary = Color(0xff1F4BA5);

  @override
  void initState() {
    super.initState();
    _syncStatus();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.isDarkMode
            ? const Color(0xff0B1220)
            : const Color(0xff111827),
      ),
    );
  }

  Future<void> _syncStatus() async {
    try {
      final s = await Geolocator.isLocationServiceEnabled();
      final p = await Geolocator.checkPermission();
      if (!mounted) return;
      setState(() {
        _serviceEnabled = s;
        _perm = p;
      });
    } catch (_) {}
  }

  // ✅ فحص + طلب صلاحية الموقع قبل refresh
  Future<bool> _ensureLocationReady() async {
    try {
      // 1) Service
      _serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_serviceEnabled && !kIsWeb) {
        _snack(widget.isArabic
            ? "خدمة الموقع مقفولة.. هفتحلك إعدادات الـ GPS ✅"
            : "Location services are OFF. Opening GPS settings ✅");
        await _openLocationSettings();
        await _syncStatus();
        return false;
      }

      // 2) Permissions
      _perm = await Geolocator.checkPermission();

      if (_perm == LocationPermission.denied) {
        _perm = await Geolocator.requestPermission();
      }

      if (_perm == LocationPermission.denied) {
        _snack(widget.isArabic
            ? "تم رفض صلاحية الموقع. فعّلها من الإعدادات/المتصفح ❌"
            : "Location permission denied. Enable it from settings/browser ❌");
        await _syncStatus();
        return false;
      }

      if (_perm == LocationPermission.deniedForever) {
        _snack(widget.isArabic
            ? "الصلاحية مرفوضة نهائيًا.. هفتح إعدادات التطبيق ✅"
            : "Permission denied forever. Opening app settings ✅");
        await _openAppSettings();
        await _syncStatus();
        return false;
      }

      // 3) Quick test fetch
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 8));

      await _syncStatus();
      return true;
    } on TimeoutException {
      _snack(widget.isArabic
          ? "أخذ الموقع وقت طويل.. جرّب تاني بعد ما تفعّل Location ✅"
          : "Getting location timed out. Try again after enabling Location ✅");
      await _syncStatus();
      return false;
    } catch (e) {
      _snack(widget.isArabic
          ? "تعذر الحصول على الموقع: $e"
          : "Couldn't get location: $e");
      await _syncStatus();
      return false;
    }
  }

  Future<void> _handleRefresh() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final ok = await _ensureLocationReady();
      if (!ok) return;

      await widget.onRefresh();

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      _snack(widget.isArabic
          ? "حصل خطأ أثناء تحديث المراكز ❌"
          : "Error while refreshing centers ❌");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openLocationSettings() async {
    if (kIsWeb) {
      await _openWebHelp();
      return;
    }
    try {
      await Geolocator.openLocationSettings();
    } catch (_) {
      _snack(widget.isArabic
          ? "تعذر فتح إعدادات الموقع على هذا الجهاز"
          : "Cannot open location settings on this device");
    }
  }

  Future<void> _openAppSettings() async {
    if (kIsWeb) {
      await _openWebHelp();
      return;
    }
    try {
      // ✅ يفتح App settings مباشرة (مهم لـ deniedForever)
      await Geolocator.openAppSettings();
    } catch (_) {
      _snack(widget.isArabic
          ? "تعذر فتح إعدادات التطبيق على هذا الجهاز"
          : "Cannot open app settings on this device");
    }
  }

  Future<void> _openWebHelp() async {
    final help = Uri.parse('https://support.google.com/chrome/answer/142065');
    final ok = await launchUrl(help, mode: LaunchMode.externalApplication);

    if (!ok) {
      _snack(widget.isArabic
          ? "افتح 🔒 جنب الرابط > Location > Allow ثم Refresh ✅"
          : "Open 🔒 next to URL > Location > Allow then Refresh ✅");
    } else {
      _snack(widget.isArabic
          ? "لو لسه الموقع مش شغال: اضغط 🔒 جنب الرابط > Location > Allow ثم Refresh ✅"
          : "If still not working: click 🔒 next to URL > Location > Allow then Refresh ✅");
    }
  }

  Widget _badge({
    required String title,
    required bool ok,
    required IconData icon,
  }) {
    final c = ok ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: c.withOpacity(widget.isDarkMode ? .18 : .12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: c, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              color: textMain,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perm = _perm;

    final permOk = perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;

    final gpsOk =
        kIsWeb ? true : _serviceEnabled; // web has no GPS toggle concept

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.isArabic ? "حل مشكلة الموقع" : "Fix Location Problem",
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              color: textMain,
            ),
          ),
          iconTheme: IconThemeData(color: textMain),
          actions: [
            IconButton(
              onPressed: _syncStatus,
              icon: const Icon(Icons.sync),
              tooltip: tr("تحديث الحالة", "Refresh status"),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_off, color: textSub, size: 40),
                const SizedBox(height: 12),

                Text(
                  widget.isArabic
                      ? "عشان نعرض المراكز القريبة لازم تفعّل الموقع ✅"
                      : "To show nearby centers, enable location ✅",
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: textMain,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _badge(
                      title: widget.isArabic ? "GPS شغال" : "GPS ON",
                      ok: gpsOk,
                      icon: Icons.gps_fixed,
                    ),
                    _badge(
                      title: widget.isArabic
                          ? "Permission مسموح"
                          : "Permission OK",
                      ok: permOk,
                      icon: Icons.verified_user,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  widget.isArabic
                      ? "📌 لو بتستخدم Chrome (Web):\n1) اضغط 🔒 جنب الرابط\n2) Location = Allow\n3) اعمل Refresh"
                      : "📌 If you're using Chrome (Web):\n1) Click 🔒 next to the URL\n2) Location = Allow\n3) Refresh the page",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textSub,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                // ✅ زر تحديث المراكز
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      widget.isArabic ? "تحديث المراكز" : "Refresh Centers",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                    ),
                    onPressed: _handleRefresh,
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ أزرار الإعدادات
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primary, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.gps_fixed, color: primary),
                        label: Text(
                          widget.isArabic ? "إعدادات GPS" : "GPS Settings",
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900,
                            color: primary,
                          ),
                        ),
                        onPressed: _openLocationSettings,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primary, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.settings, color: primary),
                        label: Text(
                          widget.isArabic ? "إعدادات التطبيق" : "App Settings",
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900,
                            color: primary,
                          ),
                        ),
                        onPressed: _openAppSettings,
                      ),
                    ),
                  ],
                ),

                const Spacer(),
                Center(
                  child: Text(
                    widget.isArabic
                        ? "لو ما اشتغلش.. ابعتلي Screenshot من Console error ✅"
                        : "If it still doesn't work, send Console error screenshot ✅",
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textSub,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String tr(String ar, String en) => widget.isArabic ? ar : en;
}
