import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ObdSnapshot {
  final List<String> dtc;
  final int? rpm;
  final int? coolant;

  const ObdSnapshot({
    required this.dtc,
    required this.rpm,
    required this.coolant,
  });
}

class ObdBleService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _tx; // write
  BluetoothCharacteristic? _rx; // notify/read/indicate

  String _buffer = "";
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothConnectionState>? _connSub;

  BluetoothConnectionState _connState = BluetoothConnectionState.disconnected;

  // UUIDs common for BLE UART devices (Nordic UART)
  static final Guid _nordicService =
      Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  static final Guid _nordicTx =
      Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E"); // write
  static final Guid _nordicRx =
      Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E"); // notify

  // HM-10 style
  static final Guid _hm10Service = Guid("0000FFE0-0000-1000-8000-00805F9B34FB");
  static final Guid _hm10Char = Guid("0000FFE1-0000-1000-8000-00805F9B34FB");

  bool get isConnected => _connState == BluetoothConnectionState.connected;

  BluetoothConnectionState get connectionState => _connState;

  BluetoothDevice? get device => _device;

  // ===================== PUBLIC =====================

  Future<void> connect(BluetoothDevice device) async {
    // لو في جهاز قديم متوصل -> افصل
    if (_device != null && _device!.remoteId != device.remoteId) {
      await disconnect();
    }

    _device = device;
    _buffer = "";

    // تابع حالة الاتصال
    await _connSub?.cancel();
    _connSub = device.connectionState.listen((s) {
      _connState = s;
    });

    // لو متوصل بالفعل، ما تعملش connect تاني
    final currentState = await device.connectionState.first;
    _connState = currentState;

    if (currentState != BluetoothConnectionState.connected) {
      await device.connect(
        timeout: const Duration(seconds: 12),
        autoConnect: false,
      );
      _connState = BluetoothConnectionState.connected;
    }

    // Android: request bigger MTU (مش كل الأجهزة بتقبل)
    try {
      await device.requestMtu(185);
    } catch (_) {}

    // بعض الأجهزة محتاجة تأخير بسيط قبل discover
    await Future.delayed(const Duration(milliseconds: 180));

    final services = await _discoverWithRetry(device);

    // 1) Try Nordic UART
    BluetoothCharacteristic? tx;
    BluetoothCharacteristic? rx;

    for (final s in services) {
      if (s.uuid == _nordicService) {
        for (final c in s.characteristics) {
          if (c.uuid == _nordicTx) tx = c;
          if (c.uuid == _nordicRx) rx = c;
        }
      }
    }

    // 2) Fallback HM-10
    if (tx == null || rx == null) {
      for (final s in services) {
        if (s.uuid == _hm10Service) {
          for (final c in s.characteristics) {
            if (c.uuid == _hm10Char) {
              // HM10 غالبًا characteristic واحدة للـ write + notify/read
              tx ??= c;
              rx ??= c;
            }
          }
        }
      }
    }

    // 3) Fallback: heuristic pick
    tx ??= _pickWritable(services);
    rx ??= _pickNotifiableOrIndicate(services) ?? tx;

    _tx = tx;
    _rx = rx;

    if (_rx == null || _tx == null) {
      throw Exception("OBD BLE characteristics not found.");
    }

    await _setupNotifications();

    // ✅ Robust init handshake (بعض الأجهزة بتحتاج محاولات)
    await _initElmSessionWithRetry();
  }

  Future<void> disconnect() async {
    await _notifySub?.cancel();
    _notifySub = null;

    await _connSub?.cancel();
    _connSub = null;

    _buffer = "";

    if (_rx != null) {
      try {
        await _rx!.setNotifyValue(false);
      } catch (_) {}
    }

    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (_) {}
    }

    _connState = BluetoothConnectionState.disconnected;
    _device = null;
    _tx = null;
    _rx = null;
  }

  /// قراءة سريعة (مرة واحدة)
  Future<ObdSnapshot> scanOnce() async {
    _ensureReady();

    // DTC
    final dtcResp = await _cmd("03", timeout: const Duration(seconds: 8));
    final dtc = _parseDtc(dtcResp);

    // RPM
    final rpmResp = await _cmd("010C", timeout: const Duration(seconds: 6));
    final rpm = _parseRpm(rpmResp);

    // Coolant
    final tempResp = await _cmd("0105", timeout: const Duration(seconds: 6));
    final coolant = _parseCoolant(tempResp);

    return ObdSnapshot(dtc: dtc, rpm: rpm, coolant: coolant);
  }

  /// ✅ إضافة مفيدة: قراءة PID واحدة بسرعة (مثلاً 010D للسرعة)
  Future<String> readLiveOnce(String pid,
      {Duration timeout = const Duration(seconds: 6)}) async {
    _ensureReady();
    return _cmd(pid, timeout: timeout);
  }

  // ===================== INTERNAL =====================

  void _ensureReady() {
    if (_device == null || _tx == null || _rx == null) {
      throw Exception("OBD is not connected.");
    }
    if (!isConnected) {
      throw Exception("OBD is not connected (state).");
    }
  }

  Future<List<BluetoothService>> _discoverWithRetry(
      BluetoothDevice device) async {
    Object? lastErr;
    for (var i = 0; i < 3; i++) {
      try {
        final services = await device.discoverServices();
        if (services.isNotEmpty) return services;
        throw Exception("No services discovered");
      } catch (e) {
        lastErr = e;
        await Future.delayed(Duration(milliseconds: 250 + i * 250));
      }
    }
    throw Exception(lastErr?.toString() ?? "discoverServices failed");
  }

  Future<void> _setupNotifications() async {
    await _notifySub?.cancel();
    _notifySub = null;

    final rx = _rx!;

    // لو notify/indicate متاح
    final canNotify = rx.properties.notify;
    final canIndicate = rx.properties.indicate;

    if (canNotify || canIndicate) {
      try {
        await rx.setNotifyValue(true);
      } catch (_) {
        // بعض الأجهزة بترفض notify بس still شغالة read
      }

      _notifySub = rx.onValueReceived.listen((data) {
        if (data.isEmpty) return;
        final chunk = utf8.decode(data, allowMalformed: true);
        _buffer += chunk;
      });
    }
  }

  Future<void> _initElmSessionWithRetry() async {
    // بعض ELMs بتأخر بعد connect
    await Future.delayed(const Duration(milliseconds: 200));

    // ATZ ممكن يرجع garbage أول مرة
    await _tryInitSequence([
      "ATZ",
      "ATE0", // echo off
      "ATL0", // linefeeds off
      "ATS0", // spaces off
      "ATH0", // headers off
      "ATSP0", // auto protocol
    ]);
  }

  Future<void> _tryInitSequence(List<String> cmds) async {
    Object? lastErr;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        for (final c in cmds) {
          final t = (attempt == 0 && c == "ATZ")
              ? const Duration(seconds: 8)
              : const Duration(seconds: 5);

          await _cmd(c, timeout: t);

          // pacing بسيط
          await Future.delayed(const Duration(milliseconds: 90));
        }

        // Ping سريع للتأكد
        final r = await _cmd("0100", timeout: const Duration(seconds: 7));
        if (_looksBadResponse(r)) {
          throw Exception("ELM init failed: bad response");
        }
        return;
      } catch (e) {
        lastErr = e;
        await Future.delayed(Duration(milliseconds: 300 + attempt * 300));
      }
    }

    throw Exception(lastErr?.toString() ?? "ELM init failed.");
  }

  bool _looksBadResponse(String resp) {
    final s = resp.toUpperCase();
    return s.contains("UNABLETOCONNECT") ||
        s.contains("UNABLE TO CONNECT") ||
        s.contains("NO DATA") ||
        s.contains("STOPPED") ||
        s.trim().isEmpty;
  }

  // ------------------- low-level command -------------------

  Future<String> _cmd(
    String command, {
    Duration timeout = const Duration(seconds: 6),
  }) async {
    _ensureReady();

    // reset buffer per command
    _buffer = "";

    final cmd = "$command\r";
    final bytes = ascii.encode(cmd);

    await _writeBytes(bytes);

    final raw = await _readUntilPrompt(timeout: timeout);

    final cleaned = _cleanElm(raw, sentCommand: command);
    if (cleaned.trim().isEmpty) {
      // لو الرد فاضي، رجّع raw للتشخيص (أحيانًا بيكون فيه حاجة اتشالت بالغلط)
      return _cleanElm(raw, sentCommand: null);
    }
    return cleaned;
  }

  Future<void> _writeBytes(List<int> bytes) async {
    final tx = _tx!;

    // choose write mode
    final useWithoutResponse =
        tx.properties.writeWithoutResponse && !tx.properties.write;

    // chunk size conservative
    const chunkSize = 20;

    for (var i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      final chunk = bytes.sublist(i, end);

      await tx.write(chunk, withoutResponse: useWithoutResponse);

      // pacing بسيط يمنع “hang”
      await Future.delayed(const Duration(milliseconds: 25));
    }
  }

  Future<String> _readUntilPrompt({required Duration timeout}) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      // بعض الأجهزة بترسل prompt '>' لوحده في Chunk
      if (_buffer.contains('>')) return _buffer;

      final noNotify = !(_rx?.properties.notify ?? false) &&
          !(_rx?.properties.indicate ?? false);
      final canRead = (_rx?.properties.read ?? false);

      if (noNotify && canRead) {
        try {
          final data = await _rx!.read();
          if (data.isNotEmpty) {
            final chunk = utf8.decode(data, allowMalformed: true);
            _buffer += chunk;
          }
        } catch (_) {}
      }

      await Future.delayed(const Duration(milliseconds: 55));
    }

    // Timeout: رجّع اللي اتجمع (ونسيبه يتفسر)
    if (_buffer.isEmpty) {
      throw TimeoutException("ELM response timeout");
    }
    return _buffer;
  }

  String _cleanElm(String raw, {String? sentCommand}) {
    var s = raw;

    // remove prompt
    s = s.replaceAll('>', '');

    // normalize
    s = s.replaceAll('\r', '\n');

    // remove common noise
    s = s.replaceAll('SEARCHING...', '');
    s = s.replaceAll('SEARCHING..', '');
    s = s.replaceAll('SEARCHING.', '');
    s = s.replaceAll('BUS INIT', '');
    s = s.replaceAll('BUSINIT', '');
    s = s.replaceAll('NO DATA', '');
    s = s.replaceAll('STOPPED', '');

    // sometimes echo is still on
    if (sentCommand != null) {
      final cmdUpper = sentCommand.toUpperCase();
      s = s
          .split('\n')
          .where((line) => line.trim().toUpperCase() != cmdUpper)
          .join('\n');
    }

    // normalize whitespace + remove empties
    s = s
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');

    return s;
  }

  BluetoothCharacteristic? _pickWritable(List<BluetoothService> services) {
    // Prefer characteristics that look like UART TX:
    // writeWithoutResponse OR write
    for (final s in services) {
      for (final c in s.characteristics) {
        if (c.properties.writeWithoutResponse) return c;
      }
    }
    for (final s in services) {
      for (final c in s.characteristics) {
        if (c.properties.write) return c;
      }
    }
    return null;
  }

  BluetoothCharacteristic? _pickNotifiableOrIndicate(
      List<BluetoothService> services) {
    // Prefer notify/indicate
    for (final s in services) {
      for (final c in s.characteristics) {
        if (c.properties.notify || c.properties.indicate) return c;
      }
    }
    // fallback read
    for (final s in services) {
      for (final c in s.characteristics) {
        if (c.properties.read) return c;
      }
    }
    return null;
  }

  // ===================== PARSERS =====================

  int? _parseRpm(String resp) {
    final up = resp.toUpperCase();
    if (_looksBadResponse(up)) return null;

    final hex = up.replaceAll(RegExp(r'[^0-9A-F]'), '');

    final idx = hex.indexOf("410C");
    if (idx == -1) return null;
    if (hex.length < idx + 8) return null;

    final a = int.tryParse(hex.substring(idx + 4, idx + 6), radix: 16);
    final b = int.tryParse(hex.substring(idx + 6, idx + 8), radix: 16);
    if (a == null || b == null) return null;

    return ((a * 256) + b) ~/ 4;
  }

  int? _parseCoolant(String resp) {
    final up = resp.toUpperCase();
    if (_looksBadResponse(up)) return null;

    final hex = up.replaceAll(RegExp(r'[^0-9A-F]'), '');

    final idx = hex.indexOf("4105");
    if (idx == -1) return null;
    if (hex.length < idx + 6) return null;

    final a = int.tryParse(hex.substring(idx + 4, idx + 6), radix: 16);
    if (a == null) return null;
    return a - 40;
  }

  List<String> _parseDtc(String resp) {
    final up = resp.toUpperCase();
    if (_looksBadResponse(up)) return [];

    // robust: شيل أي غير hex
    final hex = up.replaceAll(RegExp(r'[^0-9A-F]'), '');

    // Response for mode 03 often starts with 43
    final idx = hex.indexOf("43");
    if (idx == -1) return [];

    final payload = hex.substring(idx + 2);

    final bytes = <int>[];
    for (var i = 0; i + 2 <= payload.length; i += 2) {
      final v = int.tryParse(payload.substring(i, i + 2), radix: 16);
      if (v == null) break;
      bytes.add(v);
    }

    final codes = <String>[];
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      final a = bytes[i];
      final b = bytes[i + 1];

      if (a == 0 && b == 0) continue;

      final first = (a & 0xC0) >> 6;
      final letter = switch (first) {
        0 => 'P',
        1 => 'C',
        2 => 'B',
        _ => 'U',
      };

      final digit1 = (a & 0x30) >> 4;
      final digit2 = (a & 0x0F);

      final d1 = digit1.toString();
      final d2 = digit2.toRadixString(16).toUpperCase();
      final last = b.toRadixString(16).padLeft(2, '0').toUpperCase();

      final code = "$letter$d1$d2$last";
      codes.add(code);
    }

    // unique + ثابت الترتيب قدر الإمكان
    final unique = <String>{};
    final out = <String>[];
    for (final c in codes) {
      if (unique.add(c)) out.add(c);
    }
    return out;
  }
}
