import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// ✅ Real BLE ELM327 Service (Android + iOS)
class ObdElm327Service {
  BluetoothDevice? _device;

  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;

  final StringBuffer _rx = StringBuffer();
  StreamSubscription<List<int>>? _notifySub;

  bool get isConnected => _device != null;

  /// Connect + discover characteristics + init ELM327
  Future<void> connect(BluetoothDevice device) async {
    _device = device;

    await device.connect(timeout: const Duration(seconds: 10));

    final services = await device.discoverServices();

    // Auto-pick write + notify characteristics (works for many OBD BLE adapters)
    for (final s in services) {
      for (final c in s.characteristics) {
        if (_writeChar == null &&
            (c.properties.write || c.properties.writeWithoutResponse)) {
          _writeChar = c;
        }
        if (_notifyChar == null && c.properties.notify) {
          _notifyChar = c;
        }
      }
    }

    if (_writeChar == null || _notifyChar == null) {
      throw Exception("OBD_BLE_CHARACTERISTICS_NOT_FOUND");
    }

    await _notifyChar!.setNotifyValue(true);
    _notifySub = _notifyChar!.onValueReceived.listen((data) {
      _rx.write(ascii.decode(data, allowInvalid: true));
    });

    // Init ELM327
    await _cmd("ATZ", timeout: const Duration(seconds: 4));
    await _cmd("ATE0");
    await _cmd("ATL0");
    await _cmd("ATS0");
    await _cmd("ATH0");
    await _cmd("ATSP0"); // auto protocol
  }

  Future<void> disconnect() async {
    await _notifySub?.cancel();
    _notifySub = null;

    if (_device != null) {
      await _device!.disconnect();
    }

    _device = null;
    _writeChar = null;
    _notifyChar = null;
    _rx.clear();
  }

  Future<String> _cmd(
    String cmd, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (_writeChar == null) throw Exception("OBD_NOT_CONNECTED");

    _rx.clear();

    final bytes = ascii.encode("$cmd\r");

    // بعض الأجهزة تفضل withoutResponse:true، لكن نخليها false افتراضيًا
    await _writeChar!.write(bytes, withoutResponse: false);

    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      final s = _rx.toString();
      if (s.contains(">")) {
        return _cleanResponse(s);
      }
      await Future.delayed(const Duration(milliseconds: 40));
    }

    throw TimeoutException("OBD_TIMEOUT: $cmd");
  }

  String _cleanResponse(String raw) {
    var s = raw
        .replaceAll("\r", "")
        .replaceAll("\n", "")
        .replaceAll(">", "")
        .trim();

    s = s.replaceAll("SEARCHING...", "");
    s = s.replaceAll("BUSINIT...", "");
    s = s.replaceAll("NO DATA", "");
    return s.trim();
  }

  /// Mode 03: Read stored DTCs
  Future<List<String>> readDtcCodes() async {
    final resp = await _cmd("03", timeout: const Duration(seconds: 5));
    return _parseDtcMode03(resp);
  }

  /// Mode 01 PID 0C: RPM
  Future<int?> readRpm() async {
    final resp = await _cmd("010C");
    final hex = resp.replaceAll(" ", "").toUpperCase();
    final idx = hex.indexOf("410C");
    if (idx < 0 || hex.length < idx + 8) return null;
    final a = int.parse(hex.substring(idx + 4, idx + 6), radix: 16);
    final b = int.parse(hex.substring(idx + 6, idx + 8), radix: 16);
    return ((a * 256) + b) ~/ 4;
  }

  /// Mode 01 PID 05: Coolant Temp (°C)
  Future<int?> readCoolantTemp() async {
    final resp = await _cmd("0105");
    final hex = resp.replaceAll(" ", "").toUpperCase();
    final idx = hex.indexOf("4105");
    if (idx < 0 || hex.length < idx + 6) return null;
    final a = int.parse(hex.substring(idx + 4, idx + 6), radix: 16);
    return a - 40;
  }

  List<String> _parseDtcMode03(String raw) {
    final s = raw.replaceAll(" ", "").toUpperCase();
    final start = s.indexOf("43");
    if (start < 0) return [];

    final data = s.substring(start + 2);
    final codes = <String>[];

    for (int i = 0; i + 4 <= data.length; i += 4) {
      final chunk = data.substring(i, i + 4);
      if (chunk == "0000") continue;
      final code = _decodeDtc(chunk);
      if (code.isNotEmpty) codes.add(code);
    }

    return codes;
  }

  String _decodeDtc(String hex4) {
    final a = int.tryParse(hex4.substring(0, 2), radix: 16);
    final b = int.tryParse(hex4.substring(2, 4), radix: 16);
    if (a == null || b == null) return "";

    final typeBits = (a & 0xC0) >> 6;
    final first = ["P", "C", "B", "U"][typeBits];

    final d1 = ((a & 0x30) >> 4);
    final d2 = (a & 0x0F);
    final d3 = ((b & 0xF0) >> 4);
    final d4 = (b & 0x0F);

    return "$first$d1"
        "${d2.toRadixString(16).toUpperCase()}"
        "${d3.toRadixString(16).toUpperCase()}"
        "${d4.toRadixString(16).toUpperCase()}";
  }
}
