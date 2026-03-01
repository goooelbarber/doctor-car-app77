import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/obd/obd_ble_service.dart';

class ObdLiveScreen extends StatefulWidget {
  final bool isArabic;
  final bool isDarkMode;
  final ObdBleService service;

  const ObdLiveScreen({
    super.key,
    required this.isArabic,
    required this.isDarkMode,
    required this.service,
  });

  @override
  State<ObdLiveScreen> createState() => _ObdLiveScreenState();
}

class _ObdLiveScreenState extends State<ObdLiveScreen> {
  late Timer _timer;
  bool _running = false;

  int? rpm;
  int? speed;
  int? coolant;
  double? throttle;
  double? engineLoad;
  int? intakeTemp;

  String tr(String ar, String en) => widget.isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    _startLive();
  }

  void _startLive() {
    _running = true;
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!widget.service.isConnected) {
        _stopLive();
        return;
      }
      _fetchLive();
    });
  }

  void _stopLive() {
    _timer.cancel();
    setState(() => _running = false);
  }

  Future<void> _fetchLive() async {
    try {
      final rpmResp = await widget.service.readLiveOnce("010C");
      final speedResp = await widget.service.readLiveOnce("010D");
      final coolantResp = await widget.service.readLiveOnce("0105");
      final throttleResp = await widget.service.readLiveOnce("0111");
      final loadResp = await widget.service.readLiveOnce("0104");
      final intakeResp = await widget.service.readLiveOnce("010F");

      setState(() {
        rpm = _parseRpm(rpmResp);
        speed = _parseSpeed(speedResp);
        coolant = _parseCoolant(coolantResp);
        throttle = _parsePercentage(throttleResp);
        engineLoad = _parsePercentage(loadResp);
        intakeTemp = _parseIntake(intakeResp);
      });
    } catch (e) {
      // ممكن نعلّق الرسائل لو حصل خطأ
    }
  }

  int? _parseSpeed(String resp) {
    final up = resp.toUpperCase();
    final hex = up.replaceAll(RegExp(r'[^0-9A-F]'), '');
    final idx = hex.indexOf("410D");
    if (idx == -1 || hex.length < idx + 4) return null;
    final a = int.tryParse(hex.substring(idx + 4, idx + 6), radix: 16);
    return a;
  }

  double? _parsePercentage(String resp) {
    final up = resp.toUpperCase();
    final hex = up.replaceAll(RegExp(r'[^0-9A-F]'), '');
    if (hex.length < 4) return null;
    final idx = hex.indexOf(RegExp(r"41.."));
    if (idx == -1 || hex.length < idx + 4) return null;
    final a = int.tryParse(hex.substring(idx + 4, idx + 6), radix: 16);
    if (a == null) return null;
    return (a * 100) / 255.0;
  }

  int? _parseIntake(String resp) {
    final up = resp.toUpperCase();
    final hex = up.replaceAll(RegExp(r'[^0-9A-F]'), '');
    final idx = hex.indexOf("410F");
    if (idx == -1 || hex.length < idx + 4) return null;
    final a = int.tryParse(hex.substring(idx + 4, idx + 6), radix: 16);
    if (a == null) return null;
    return a - 40;
  }

  int? _parseCoolant(String resp) {
    final up = resp.toUpperCase();
    final hex = up.replaceAll(RegExp(r'[^0-9A-F]'), '');
    final idx = hex.indexOf("4105");
    if (idx == -1 || hex.length < idx + 4) return null;
    final a = int.tryParse(hex.substring(idx + 4, idx + 6), radix: 16);
    if (a == null) return null;
    return a - 40;
  }

  int? _parseRpm(String resp) {
    final up = resp.toUpperCase();
    final hex = up.replaceAll(RegExp(r'[^0-9A-F]'), '');
    final idx = hex.indexOf("410C");
    if (idx == -1 || hex.length < idx + 8) return null;
    final a = int.tryParse(hex.substring(idx + 4, idx + 6), radix: 16);
    final b = int.tryParse(hex.substring(idx + 6, idx + 8), radix: 16);
    if (a == null || b == null) return null;
    return ((a * 256) + b) ~/ 4;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr("Live Data", "Live Data")),
          actions: [
            IconButton(
              icon: Icon(_running ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (_running)
                  _stopLive();
                else
                  _startLive();
              },
            ),
          ],
          backgroundColor: widget.isDarkMode ? Colors.black : Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _liveTile(tr("RPM", "RPM"), rpm?.toString() ?? "-", Icons.speed),
              _liveTile(tr("Speed", "Speed"), speed?.toString() ?? "-",
                  Icons.directions_car),
              _liveTile(tr("Coolant", "Coolant"),
                  coolant != null ? "$coolant°C" : "-", Icons.thermostat),
              _liveTile(
                  tr("Throttle", "Throttle"),
                  throttle != null ? "${throttle!.toStringAsFixed(1)}%" : "-",
                  Icons.tune),
              _liveTile(
                  tr("Engine Load", "Engine Load"),
                  engineLoad != null
                      ? "${engineLoad!.toStringAsFixed(1)}%"
                      : "-",
                  Icons.bolt),
              _liveTile(tr("Intake Temp", "Intake Temp"),
                  intakeTemp != null ? "$intakeTemp°C" : "-", Icons.air),
            ],
          ),
        ),
      ),
    );
  }

  Widget _liveTile(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title:
            Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
        trailing: Text(value,
            style:
                GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 18)),
      ),
    );
  }

  @override
  void dispose() {
    if (_running) _timer.cancel();
    super.dispose();
  }
}
