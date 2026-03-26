// PATH: lib/screens/tracking/engines/socket_engine.dart
// ignore_for_file: library_prefixes

import 'dart:async';
import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef DriverLocationCallback = void Function(LatLng newPos);
typedef OrderStatusCallback = void Function(
  String status,
  Map<String, dynamic> data,
);

typedef SocketLogCallback = void Function(String msg);
typedef SocketConnectionCallback = void Function(bool connected);

class SocketEngine {
  IO.Socket? _socket;

  bool _joined = false;
  String? _orderId;

  LatLng? _lastPos;

  // فلتر الاهتزاز (meters)
  static const double _minMoveMeters = 2.0;

  // watchdog لو السيرفر وقف يبعت بيانات
  Timer? _watchdog;
  DateTime _lastMessageAt = DateTime.fromMillisecondsSinceEpoch(0);

  bool get isConnected => _socket?.connected == true;

  /// اتصال + Join order room + listeners
  void connect({
    required String baseUrl,
    required String orderId,
    required DriverLocationCallback onDriverUpdate,
    required OrderStatusCallback onStatusChange,
    SocketLogCallback? onLog,
    SocketConnectionCallback? onConnectionChanged,
    Duration watchdogTimeout = const Duration(seconds: 18),
  }) {
    _orderId = orderId;
    _joined = false;

    // اقفل أي اتصال قديم بالكامل
    dispose();

    void log(String m) => onLog?.call("[socket] $m");

    // ✅ مهم: socket.io عادة يحتاج http(s) مش ws
    final uri = _normalizeBaseUrl(baseUrl);

    _socket = IO.io(
      uri,
      <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": true,
        "reconnection": true,
        "reconnectionAttempts": 999999,
        "reconnectionDelay": 800,
        "reconnectionDelayMax": 3000,
        "timeout": 10000,
        "forceNew": true,
      },
    );

    _socket!.onConnect((_) {
      log("connected: ${_socket!.id}");
      onConnectionChanged?.call(true);
      _joinRoom(log);
    });

    _socket!.onDisconnect((_) {
      log("disconnected");
      onConnectionChanged?.call(false);
      _joined = false;
    });

    _socket!.onConnectError((err) => log("connect_error: $err"));
    _socket!.onError((err) => log("error: $err"));

    // ✅ بعض إصدارات socket_io_client قد لا تدعم onReconnect
    // لذلك نغطيه عن طريق connect + محاولة join عند الاتصال
    _socket!.on("reconnect", (_) {
      log("reconnect event");
      onConnectionChanged?.call(true);
      _joined = false;
      _joinRoom(log);
    });

    _socket!.on("reconnect_attempt", (n) {
      log("reconnect_attempt: $n");
    });

    // ==============================
    // DRIVER LOCATION UPDATES
    // ==============================
    _socket!.on("driverLocationUpdate", (data) {
      _touch();

      final parsed = _parseLatLng(data);
      if (parsed == null) return;

      if (_lastPos != null) {
        final d = _distanceMeters(_lastPos!, parsed);
        if (d < _minMoveMeters) return; // jitter
      }

      _lastPos = parsed;
      onDriverUpdate(parsed);
    });

    // ==============================
    // ORDER STATUS UPDATES
    // ==============================
    _socket!.on("orderStatusUpdated", (data) {
      _touch();

      final map = _toMap(data);
      if (map == null) return;

      final status = (map["status"] ?? "").toString();
      onStatusChange(status, map);
    });

    // ==============================
    // ORDER SNAPSHOT (optional)
    // ==============================
    _socket!.on("orderSnapshot", (data) {
      _touch();

      final map = _toMap(data);
      if (map == null) return;

      final status = (map["status"] ?? "").toString();
      onStatusChange(status, map);

      final pos = _parseLatLng(map["driver"] ?? map);
      if (pos != null) {
        _lastPos = pos;
        onDriverUpdate(pos);
      }
    });

    // ==============================
    // WATCHDOG (if server silent)
    // ==============================
    _startWatchdog(
      timeout: watchdogTimeout,
      onTimeout: () {
        log("watchdog timeout -> force reconnect()");
        try {
          _joined = false;
          _socket?.disconnect();
          _socket?.connect();
        } catch (_) {}
      },
    );
  }

  // ==========================
  // JOIN ROOM
  // ==========================
  void _joinRoom(void Function(String) log) {
    final s = _socket;
    if (s == null) return;
    if (_joined) return;
    if (s.connected != true) return;

    final id = _orderId;
    if (id == null || id.isEmpty) return;

    try {
      s.emit("joinOrderRoom", id);
      _joined = true;
      log("joinOrderRoom emitted: $id");
    } catch (e) {
      log("join room failed: $e");
    }
  }

  // ==========================
  // WATCHDOG HELPERS
  // ==========================
  void _touch() {
    _lastMessageAt = DateTime.now();
  }

  void _startWatchdog({
    required Duration timeout,
    required void Function() onTimeout,
  }) {
    _watchdog?.cancel();
    _touch();

    _watchdog = Timer.periodic(const Duration(seconds: 3), (_) {
      final diff = DateTime.now().difference(_lastMessageAt);
      if (diff > timeout) onTimeout();
    });
  }

  // ==========================
  // PARSERS
  // ==========================
  Map<String, dynamic>? _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;

    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }

    return null;
  }

  LatLng? _parseLatLng(dynamic data) {
    final map = _toMap(data);
    if (map == null) return null;

    dynamic lat = map["lat"];
    dynamic lng = map["lng"];

    // لو جوا driver
    if ((lat == null || lng == null) && map["driver"] != null) {
      final d = _toMap(map["driver"]);
      lat = d?["lat"];
      lng = d?["lng"];
    }

    final la = _num(lat);
    final lo = _num(lng);
    if (la == null || lo == null) return null;

    if (la.abs() > 90 || lo.abs() > 180) return null;

    return LatLng(la, lo);
  }

  double? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  // ==========================
  // DISTANCE
  // ==========================
  double _distanceMeters(LatLng a, LatLng b) {
    const double R = 6371000;

    final double lat1 = a.latitude * math.pi / 180;
    final double lat2 = b.latitude * math.pi / 180;

    final double dLat = (b.latitude - a.latitude) * math.pi / 180;
    final double dLng = (b.longitude - a.longitude) * math.pi / 180;

    final double h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return R * c;
  }

  // ==========================
  // URL NORMALIZATION
  // ==========================
  String _normalizeBaseUrl(String baseUrl) {
    var u = baseUrl.trim();

    // لو حد بعت ws:// نحوله لـ http:// (socket.io client expects http(s))
    if (u.startsWith("ws://")) u = "http://${u.substring(5)}";
    if (u.startsWith("wss://")) u = "https://${u.substring(6)}";

    // لو مفيش scheme
    if (!u.startsWith("http://") && !u.startsWith("https://")) {
      u = "http://$u";
    }

    // شيل slash في الآخر (اختياري)
    if (u.endsWith("/")) u = u.substring(0, u.length - 1);

    return u;
  }

  // ==========================
  // DISPOSE
  // ==========================
  void dispose() {
    _watchdog?.cancel();
    _watchdog = null;

    try {
      _socket?.off("driverLocationUpdate");
      _socket?.off("orderStatusUpdated");
      _socket?.off("orderSnapshot");
      _socket?.off("reconnect");
      _socket?.off("reconnect_attempt");

      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}

    _socket = null;
    _joined = false;
    _orderId = null;
    _lastPos = null;
  }
}
