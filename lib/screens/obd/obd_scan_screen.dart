import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/obd/obd_ble_service.dart';
import 'obd_report_screen.dart';

class ObdScanScreen extends StatefulWidget {
  final bool isArabic;
  final bool isDarkMode;

  const ObdScanScreen({
    super.key,
    required this.isArabic,
    required this.isDarkMode,
  });

  @override
  State<ObdScanScreen> createState() => _ObdScanScreenState();
}

class _ObdScanScreenState extends State<ObdScanScreen> {
  final ObdBleService _service = ObdBleService();

  final Map<String, ScanResult> _devices = {};

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;

  bool _scanning = false;
  bool _loading = false;
  String? _error;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  bool _showAllDevices = false;

  static const Duration _scanDuration = Duration(seconds: 7);

  bool get isArabic => widget.isArabic;
  bool get isDark => widget.isDarkMode;

  Color get brand => const Color.fromARGB(255, 26, 217, 105);
  Color get brand2 => Color.lerp(brand, const Color(0xff0B1220), 0.22)!;
  Color get brand3 => Color.lerp(brand, Colors.white, 0.18)!;

  Color get bg => isDark ? const Color(0xff0B1220) : const Color(0xffF5F7FB);
  Color get surface => isDark ? const Color(0xff0E1626) : Colors.white;
  Color get surface2 =>
      isDark ? const Color(0xff0C1322) : const Color(0xffF9FAFB);

  Color get textMain =>
      isDark ? const Color(0xffF9FAFB) : const Color(0xff111827);
  Color get textSub =>
      isDark ? const Color(0xffCBD5E1) : const Color(0xff6B7280);

  Color get stroke =>
      isDark ? Colors.white.withOpacity(.10) : Colors.black.withOpacity(.06);

  LinearGradient get screenBgGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
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

  LinearGradient get greenWhiteGradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          brand.withOpacity(isDark ? .85 : .92),
          Color.lerp(brand, Colors.white, isDark ? .55 : .62)!,
          Colors.white.withOpacity(isDark ? .06 : 1),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  List<BoxShadow> get shSm => [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? .30 : .08),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ];

  List<BoxShadow> get greenGlow => [
        BoxShadow(
          color: brand.withOpacity(isDark ? .22 : .18),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? .28 : .08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  String tr(String ar, String en) => isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    _adapterState = FlutterBluePlus.adapterStateNow;
    _listenAdapter();
    _boot();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _adapterSub?.cancel();
    try {
      FlutterBluePlus.stopScan();
    } catch (_) {}
    _service.disconnect();
    super.dispose();
  }

  void _listenAdapter() {
    _adapterSub = FlutterBluePlus.adapterState.listen((s) {
      if (!mounted) return;
      setState(() => _adapterState = s);
    });
  }

  Future<void> _boot() async {
    final supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      _setError(tr(
        "الموبايل لا يدعم Bluetooth LE.",
        "This device doesn't support Bluetooth LE.",
      ));
      return;
    }

    final okPerms = await _ensureBlePermissions();
    if (!okPerms) return;

    await _ensureBluetoothOn();
    await _startScan();
  }

  Future<bool> _ensureBlePermissions() async {
    try {
      if (Platform.isAndroid) {
        final perms = <Permission>[
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
          Permission.notification,
        ];

        final statuses = await perms.request();

        final scanOk = statuses[Permission.bluetoothScan]?.isGranted ?? false;
        final connectOk =
            statuses[Permission.bluetoothConnect]?.isGranted ?? false;

        if (!scanOk || !connectOk) {
          _setError(tr(
            "لازم صلاحيات Bluetooth Scan/Connect.",
            "Bluetooth Scan/Connect permissions are required.",
          ));
          return false;
        }

        final locOk =
            statuses[Permission.locationWhenInUse]?.isGranted ?? false;
        if (!locOk) {
          _setError(tr(
            "ملاحظة: بعض الأجهزة تحتاج تفعيل Location علشان تظهر الأجهزة.",
            "Note: Some devices require Location enabled to discover BLE devices.",
          ));
        }

        return true;
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> _ensureBluetoothOn() async {
    if (Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (_) {}
    }
  }

  Future<void> _startScan() async {
    if (_loading || _scanning) return;

    _clearError();

    if (_adapterState != BluetoothAdapterState.on) {
      _setError(tr(
        "فعّل البلوتوث الأول وبعدين اعمل Scan.",
        "Turn on Bluetooth, then scan.",
      ));
      return;
    }

    setState(() {
      _devices.clear();
      _scanning = true;
    });

    try {
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}

      await _scanSub?.cancel();

      _scanSub = FlutterBluePlus.scanResults.listen((list) {
        if (!mounted) return;

        bool changed = false;
        for (final r in list) {
          final id = r.device.remoteId.toString();

          final name = r.device.platformName.trim();
          final adv = r.advertisementData.advName.trim();
          final combined = "${name.toLowerCase()} ${adv.toLowerCase()}";

          final looksLikeObd = _looksLikeObd(combined);

          if (!_showAllDevices && !looksLikeObd) continue;

          final prev = _devices[id];
          if (prev == null || prev.rssi != r.rssi) {
            _devices[id] = r;
            changed = true;
          }
        }

        if (changed && mounted) {
          setState(() {});
        }
      });

      await FlutterBluePlus.startScan(timeout: _scanDuration);
    } catch (e) {
      _setError(_prettyBleError(e));
    } finally {
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}

      if (mounted) {
        setState(() => _scanning = false);
      }
    }
  }

  bool _looksLikeObd(String combined) {
    return combined.contains('obd') ||
        combined.contains('elm') ||
        combined.contains('vgate') ||
        combined.contains('v-link') ||
        combined.contains('vlink') ||
        combined.contains('icar') ||
        combined.contains('car scanner') ||
        combined.contains('obdii') ||
        combined.contains('obd2') ||
        combined.contains('ble');
  }

  List<ScanResult> get _sortedResults {
    final list = _devices.values.toList();
    list.sort((a, b) => b.rssi.compareTo(a.rssi));
    return list;
  }

  Future<void> _connectAndScan(BluetoothDevice device) async {
    if (_loading) return;

    _clearError();
    setState(() => _loading = true);

    try {
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}

      await _service.connect(device);
      final snap = await _service.scanOnce();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ObdReportScreen(
            isArabic: widget.isArabic,
            isDarkMode: widget.isDarkMode,
            dtc: snap.dtc,
            rpm: snap.rpm,
            coolant: snap.coolant,
            service: _service,
          ),
        ),
      );
    } catch (e) {
      _setError(_prettyBleError(e));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _prettyBleError(Object e) {
    final s = e.toString().toLowerCase();

    if (s.contains('permission')) {
      return tr(
        "مشكلة صلاحيات Bluetooth. راجع الإعدادات.",
        "Bluetooth permission issue. Check settings.",
      );
    }
    if (s.contains('timeout')) {
      return tr(
        "انتهت مهلة الاتصال. قرّب الجهاز وحاول تاني.",
        "Connection timeout. Move closer and retry.",
      );
    }
    if (s.contains('unavailable') || s.contains('off')) {
      return tr("البلوتوث غير متاح.", "Bluetooth is unavailable.");
    }
    if (s.contains('gatt')) {
      return tr(
        "حصل خطأ في الاتصال (GATT). افصل الجهاز واعمل Pairing تاني.",
        "GATT error. Re-pair the device and try again.",
      );
    }
    return e.toString();
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() => _error = msg);
  }

  void _clearError() {
    if (!mounted) return;
    setState(() => _error = null);
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final results = _sortedResults;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: bg,
            appBar: _buildAppBar(),
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(gradient: screenBgGradient),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _bluetoothStatusCard(),
                      const SizedBox(height: 12),
                      if (_error != null) _errorCard(_error!),
                      _headerRow(scanning: _scanning, count: results.length),
                      const SizedBox(height: 10),
                      Expanded(
                        child: results.isEmpty
                            ? _emptyState()
                            : _devicesList(results),
                      ),
                      const SizedBox(height: 12),
                      _scanCtaButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_loading) _loadingOverlay(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: true,
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
            child: const Icon(
              Icons.bluetooth_searching,
              color: Colors.black,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            tr("اختيار جهاز OBD", "Pick OBD Device"),
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
          onPressed: _loading
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  setState(() => _showAllDevices = !_showAllDevices);
                  _startScan();
                },
          icon: Icon(
            _showAllDevices ? Icons.filter_alt_off : Icons.filter_alt,
          ),
          tooltip: _showAllDevices
              ? tr("عرض أجهزة OBD فقط", "Show OBD only")
              : tr("عرض كل الأجهزة", "Show all devices"),
        ),
        IconButton(
          onPressed: _loading ? null : _startScan,
          icon: const Icon(Icons.refresh),
          tooltip: tr("تحديث", "Refresh"),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _bluetoothStatusCard() {
    final on = _adapterState == BluetoothAdapterState.on;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
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
              color:
                  (on ? brand : Colors.orange).withOpacity(isDark ? .18 : .10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (on ? brand : Colors.orange).withOpacity(.25),
              ),
            ),
            child: Icon(
              on ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: on ? brand3 : Colors.orange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  on
                      ? tr("البلوتوث شغال", "Bluetooth is ON")
                      : tr("البلوتوث مقفول", "Bluetooth is OFF"),
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tr("لو مش شغال افتح الإعدادات", "If it's off, open settings"),
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: textSub,
                  ),
                ),
              ],
            ),
          ),
          if (!on)
            TextButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await _ensureBluetoothOn();
              },
              child: Text(
                tr("تشغيل", "Turn on"),
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  color: brand3,
                ),
              ),
            ),
          TextButton(
            onPressed: _openAppSettings,
            child: Text(
              tr("الإعدادات", "Settings"),
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                color: brand3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xffEF4444).withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEF4444).withOpacity(.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xffEF4444)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                color: textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerRow({required bool scanning, required int count}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            scanning
                ? tr("جاري البحث...", "Scanning...")
                : tr("الأجهزة المتاحة ($count)", "Available devices ($count)"),
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              color: textMain,
            ),
          ),
        ),
        if (scanning)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: brand,
            ),
          ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: stroke),
          boxShadow: shSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bluetooth_searching, color: brand3, size: 40),
            const SizedBox(height: 10),
            Text(
              tr("مش لاقي جهاز BLE OBD", "No BLE OBD found"),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                color: textMain,
                fontSize: 15.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tr(
                "⚠️ لو جهازك ELM327 العادي (Classic) مش هيظهر هنا.\nلازم تشتري OBD BLE.",
                "⚠️ Classic ELM327 (SPP) won't appear here.\nYou need an OBD BLE adapter.",
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
                color: textSub,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _scanning ? null : _startScan,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: brand.withOpacity(.35), width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                tr("إعادة البحث", "Rescan"),
                style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _devicesList(List<ScanResult> results) {
    return RefreshIndicator(
      color: brand,
      onRefresh: _startScan,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final r = results[i];

          final name = r.device.platformName.trim();
          final adv = r.advertisementData.advName.trim();
          final displayName = (name.isNotEmpty ? name : adv).trim();

          final shownName = displayName.isEmpty
              ? tr("جهاز غير معروف", "Unknown device")
              : displayName;

          final isStrong = r.rssi >= -60;

          return InkWell(
            onTap: _loading ? null : () => _connectAndScan(r.device),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(isDark ? .06 : .80),
                    Colors.white.withOpacity(isDark ? .04 : .92),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: stroke),
                boxShadow: shSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: brand.withOpacity(isDark ? .18 : .10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: brand.withOpacity(.22)),
                    ),
                    child: Icon(Icons.bluetooth, color: brand3, size: 24),
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
                                shownName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w900,
                                  color: textMain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _badge(text: "OBD", color: brand),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.device.remoteId.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700,
                            color: textSub,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.network_cell, size: 16, color: textSub),
                            const SizedBox(width: 6),
                            Text(
                              "RSSI: ${r.rssi}",
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w900,
                                color: isStrong
                                    ? const Color(0xff22C55E)
                                    : textSub,
                                fontSize: 12.8,
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (isStrong)
                              _badge(
                                text: tr("قوي", "Strong"),
                                color: const Color(0xff22C55E),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isArabic
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: textSub,
                    size: 26,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _badge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? .16 : .10),
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

  Widget _scanCtaButton() {
    final disabled = _loading || _scanning;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AbsorbPointer(
        absorbing: disabled,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _startScan();
          },
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              gradient: disabled
                  ? LinearGradient(
                      colors: [
                        Colors.white.withOpacity(.14),
                        Colors.white.withOpacity(.08),
                      ],
                    )
                  : greenWhiteGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: disabled ? Colors.white12 : brand.withOpacity(.22),
              ),
              boxShadow: disabled ? null : greenGlow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.radar_rounded, color: Colors.black),
                const SizedBox(width: 10),
                Text(
                  _scanning
                      ? tr("جاري البحث...", "Scanning...")
                      : tr("بحث عن أجهزة OBD", "Scan for OBD devices"),
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(.35),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: stroke),
                boxShadow: shSm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: brand),
                  const SizedBox(height: 12),
                  Text(
                    tr("جاري الاتصال والفحص...", "Connecting & scanning..."),
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w900,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr("متقفلش الشاشة", "Please keep the screen on"),
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      color: textSub,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
