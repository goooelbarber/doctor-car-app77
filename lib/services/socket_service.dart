// PATH: lib/services/socket_service.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config/api_config.dart';

enum SocketRole { user, technician }

typedef _ConnCb = void Function(bool connected);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  SocketRole? _role;
  String? _userId;
  String? _technicianId;
  String? _token;

  bool debugLogs = true;

  bool get isConnected => _socket?.connected ?? false;

  final List<_PendingEmit> _pending = [];
  final Set<String> _joinedOrderRooms = <String>{};

  DateTime _lastTechLocationEmit = DateTime.fromMillisecondsSinceEpoch(0);

  final Map<String, Map<int, Function>> _listeners = {};
  int _listenerAutoId = 0;

  final Map<int, _ConnCb> _connectionListeners = {};
  bool _connectionHooked = false;

  void initUser({required String userId}) {
    _role = SocketRole.user;
    _userId = userId;
    _technicianId = null;
    _token = null;
    _connect();
  }

  void initTechnician({required String technicianId, String? token}) {
    _role = SocketRole.technician;
    _technicianId = technicianId;
    _userId = null;
    _token = token;
    _connect();
  }

  void ensureConnected() {
    if (_socket == null || !(_socket?.connected ?? false)) {
      _connect();
    }
  }

  void _connect() {
    if (_socket != null) {
      if (!_socket!.connected) {
        _socket!.connect();
      } else {
        _emitPresence();
        _flushPending();
        _rejoinCachedRooms();
      }

      _hookConnectionEventsOnce();
      _bindAllRegisteredListeners();
      return;
    }

    final url = ApiConfig.socketUrl;
    _log("🌐 socketUrl = $url");

    final opts = IO.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .disableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(999999)
        .setReconnectionDelay(700)
        .setTimeout(20000)
        .enableForceNew()
        .build();

    if (_token != null && _token!.isNotEmpty) {
      opts['auth'] = {'token': _token};
    }

    _socket = IO.io(url, opts);

    _socket!.onConnect((_) {
      _log("✅ Socket connected: ${_socket!.id}");
      _emitPresence();
      _flushPending();
      _rejoinCachedRooms();
      _bindAllRegisteredListeners();
      _notifyConn(true);
    });

    _socket!.onReconnect((attempt) {
      _log("🟢 Socket reconnected (attempt=$attempt)");
      _emitPresence();
      _flushPending();
      _rejoinCachedRooms();
      _bindAllRegisteredListeners();
      _notifyConn(true);
    });

    _socket!.onDisconnect((_) {
      _log("🔴 Socket disconnected");
      _notifyConn(false);
    });

    _socket!.onConnectError((e) {
      _log("❌ Socket connect error: $e");
      _notifyConn(false);
    });

    _socket!.onError((e) {
      _log("❌ Socket error: $e");
      _notifyConn(false);
    });

    _hookConnectionEventsOnce();
    _bindAllRegisteredListeners();
    _socket!.connect();
  }

  void _hookConnectionEventsOnce() {
    if (_connectionHooked) return;
    _connectionHooked = true;
  }

  void _notifyConn(bool connected) {
    for (final cb in _connectionListeners.values) {
      try {
        cb(connected);
      } catch (e) {
        _log("⚠️ Connection listener error: $e");
      }
    }
  }

  void _emitPresence() {
    if (_socket == null || !_socket!.connected) return;

    if (_role == SocketRole.user && _userId != null) {
      _socket!.emit("user:online", {"userId": _userId});
      _log("👤 user:online emitted ($_userId)");
    }

    if (_role == SocketRole.technician && _technicianId != null) {
      _socket!.emit("technician:online", {"technicianId": _technicianId});
      _log("🛠️ technician:online emitted ($_technicianId)");
    }
  }

  void safeEmit(String event, dynamic data) {
    if (_socket == null) {
      _pending.add(_PendingEmit(event, data));
      _log("🕒 queued emit($event) socket=null");
      _connect();
      return;
    }

    if (!_socket!.connected) {
      _pending.add(_PendingEmit(event, data));
      _log("🕒 queued emit($event) not connected");
      _socket!.connect();
      return;
    }

    _socket!.emit(event, data);
  }

  Future<T?> emitWithAck<T>(
    String event,
    dynamic data, {
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final s = _socket;
    if (s == null || !s.connected) {
      safeEmit(event, data);
      return null;
    }

    final completer = Completer<T?>();
    Timer? t;

    t = Timer(timeout, () {
      if (!completer.isCompleted) completer.complete(null);
    });

    try {
      s.emitWithAck(event, data, ack: (res) {
        t?.cancel();
        if (!completer.isCompleted) {
          try {
            completer.complete(res as T?);
          } catch (_) {
            completer.complete(null);
          }
        }
      });
    } catch (_) {
      s.emit(event, data);
      t.cancel();
      if (!completer.isCompleted) completer.complete(null);
    }

    return completer.future;
  }

  void _flushPending() {
    if (_socket == null || !_socket!.connected) return;
    if (_pending.isEmpty) return;

    final copy = List<_PendingEmit>.from(_pending);
    _pending.clear();

    for (final p in copy) {
      _socket!.emit(p.event, p.data);
    }

    _log("✅ flushed pending emits: ${copy.length}");
  }

  int onConnectionChanged(_ConnCb cb) {
    final id = ++_listenerAutoId;
    _connectionListeners[id] = cb;
    cb(isConnected);
    return id;
  }

  void removeConnectionListener(int token) {
    _connectionListeners.remove(token);
  }

  int onEvent(String event, void Function(dynamic data) cb) {
    final id = ++_listenerAutoId;

    _listeners.putIfAbsent(event, () => {});
    _listeners[event]![id] = cb;

    _bindEventIfNeeded(event);

    return id;
  }

  void _bindEventIfNeeded(String event) {
    final s = _socket;
    if (s == null) return;
    final listeners = _listeners[event];
    if (listeners == null || listeners.isEmpty) return;

    s.off(event);
    s.on(event, (data) {
      final map = _listeners[event];
      if (map == null || map.isEmpty) return;

      for (final fn in map.values) {
        try {
          fn(data);
        } catch (e) {
          _log("⚠️ listener($event) error: $e");
        }
      }
    });
  }

  void _bindAllRegisteredListeners() {
    final s = _socket;
    if (s == null) return;

    for (final event in _listeners.keys) {
      s.off(event);
      s.on(event, (data) {
        final map = _listeners[event];
        if (map == null || map.isEmpty) return;

        for (final fn in map.values) {
          try {
            fn(data);
          } catch (e) {
            _log("⚠️ listener($event) error: $e");
          }
        }
      });
    }
  }

  void offEventByToken(String event, int token) {
    final map = _listeners[event];
    if (map == null) return;

    map.remove(token);

    if (map.isEmpty) {
      _listeners.remove(event);
      _socket?.off(event);
    }
  }

  int onceEvent(String event, void Function(dynamic data) cb) {
    int token = 0;
    token = onEvent(event, (data) {
      cb(data);
      offEventByToken(event, token);
    });
    return token;
  }

  void clearSupportListeners() {
    _socket?.off("supportMessage:new");
    _socket?.off("supportMessage:ack");
    _socket?.off("supportChat:typing");
    _socket?.off("supportChat:read");
  }

  void clearOrderListeners() {
    _socket?.off("order:new");
    _socket?.off("order:accepted");
    _socket?.off("order:accept:failed");
    _socket?.off("orderStatusUpdated");
    _socket?.off("order:timeout");
    _socket?.off("order:canceled");
    _socket?.off("order:failed");
    _socket?.off("technicianLocationUpdate");
    _socket?.off("technician:location:update");
    _socket?.off("technician:location:updated");

    _socket?.off("technician:online:ok");
    _socket?.off("joinOrderRoom:ok");
    _socket?.off("joinOrderRoom:error");
    _socket?.off("leaveOrderRoom:ok");
    _socket?.off("leaveOrderRoom:error");

    _socket?.off("order:match:status");
  }

  void onNewOrder(void Function(Map<String, dynamic> order) cb) {
    onEvent("order:new", (data) {
      if (data == null) return;
      if (data is Map) cb(Map<String, dynamic>.from(data));
    });
  }

  void acceptOrder(String orderId) {
    if (_technicianId == null) return;

    safeEmit("order:accept", {
      "orderId": orderId,
      "technicianId": _technicianId,
    });
  }

  void rejectOrder(String orderId) {
    if (_technicianId == null) return;

    safeEmit("order:reject", {
      "orderId": orderId,
      "technicianId": _technicianId,
    });
  }

  void joinOrderRoom(String orderId) {
    if (orderId.trim().isEmpty) return;
    _joinedOrderRooms.add(orderId);
    safeEmit("joinOrderRoom", orderId);
  }

  void leaveOrderRoom(String orderId) {
    _joinedOrderRooms.remove(orderId);
    safeEmit("leaveOrderRoom", orderId);
  }

  void cancelOrder(String orderId) {
    safeEmit("order:cancel", {
      "orderId": orderId,
      if (_userId != null) "userId": _userId,
      "by": _role?.name ?? "unknown",
    });

    _log("🛑 cancelOrder emitted for $orderId");
  }

  void onOrderAccepted(void Function(Map<String, dynamic>) cb) {
    onEvent("order:accepted", (data) {
      if (data == null) return;
      if (data is Map) cb(Map<String, dynamic>.from(data));
    });
  }

  void onOrderAcceptFailed(void Function(Map<String, dynamic>) cb) {
    onEvent("order:accept:failed", (data) {
      if (data == null) return;
      if (data is Map) cb(Map<String, dynamic>.from(data));
    });
  }

  void onTechnicianOnlineOk(void Function(Map<String, dynamic>) cb) {
    onEvent("technician:online:ok", (data) {
      if (data == null) return;
      if (data is Map) cb(Map<String, dynamic>.from(data));
    });
  }

  void onOrderStatusUpdated(
    void Function(String status, Map<String, dynamic> data) cb,
  ) {
    onEvent("orderStatusUpdated", (data) {
      if (data == null) return;

      if (data is String) {
        cb(data, const {});
        return;
      }

      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        final status = (m["status"] ?? "").toString();
        cb(status, m);
        return;
      }

      _log("⚠️ orderStatusUpdated unknown payload: $data");
    });
  }

  void onTechnicianLocation(void Function(double lat, double lng) cb) {
    void handle(dynamic data) {
      if (data == null || data is! Map) return;

      final m = Map<String, dynamic>.from(data);

      double? lat;
      double? lng;

      final loc = m["location"];
      if (loc is Map) {
        final lm = Map<String, dynamic>.from(loc);
        lat = (lm["lat"] as num?)?.toDouble() ??
            (lm["latitude"] as num?)?.toDouble();
        lng = (lm["lng"] as num?)?.toDouble() ??
            (lm["longitude"] as num?)?.toDouble();
      }

      lat ??=
          (m["lat"] as num?)?.toDouble() ?? (m["latitude"] as num?)?.toDouble();
      lng ??= (m["lng"] as num?)?.toDouble() ??
          (m["longitude"] as num?)?.toDouble();

      if (lat == null || lng == null) return;

      cb(lat, lng);
    }

    onEvent("technicianLocationUpdate", handle);
    onEvent("technician:location:updated", handle);
    onEvent("technician:location:update", handle);
  }

  void requestBestMatch({
    required String orderId,
    required double lat,
    required double lng,
    required String serviceType,
    required List<String> selectedServices,
  }) {
    safeEmit("order:match:best", {
      "orderId": orderId,
      "userId": _userId,
      "serviceType": serviceType,
      "selectedServices": selectedServices,
      "location": {"lat": lat, "lng": lng},
      "ts": DateTime.now().toIso8601String(),
    });
  }

  void onMatchStatus(void Function(Map<String, dynamic> data) cb) {
    onEvent("order:match:status", (data) {
      if (data == null) return;
      if (data is Map) cb(Map<String, dynamic>.from(data));
    });
  }

  void emitTechnicianLocation({
    required double lat,
    required double lng,
    String? orderId,
    double? heading,
    double? speed,
    Duration throttle = const Duration(milliseconds: 800),
    String eventName = "technician:location:update",
  }) {
    if (_role != SocketRole.technician) return;

    final now = DateTime.now();
    if (now.difference(_lastTechLocationEmit) < throttle) return;
    _lastTechLocationEmit = now;

    safeEmit(eventName, {
      "technicianId": _technicianId,
      if (orderId != null) "orderId": orderId,
      "location": {
        "lat": lat,
        "lng": lng,
        if (heading != null) "heading": heading,
        if (speed != null) "speed": speed,
      },
      if (heading != null) "heading": heading,
      if (speed != null) "speed": speed,
      "ts": now.toIso8601String(),
    });
  }

  void joinSupportChat(String chatId) {
    safeEmit("joinSupportChat", {"chatId": chatId});
  }

  void leaveSupportChat(String chatId) {
    safeEmit("leaveSupportChat", {"chatId": chatId});
  }

  void sendSupportMessage({
    required String chatId,
    required String text,
    required String senderType,
    String? senderId,
    String? clientTempId,
  }) {
    safeEmit("supportMessage:send", {
      "chatId": chatId,
      "text": text,
      "senderType": senderType,
      if (senderId != null) "senderId": senderId,
      if (clientTempId != null) "clientTempId": clientTempId,
    });
  }

  void onSupportMessage(void Function(Map<String, dynamic>) cb) {
    onEvent("supportMessage:new", (data) {
      if (data == null) return;
      if (data is Map) cb(Map<String, dynamic>.from(data));
    });
  }

  void onSupportAck(void Function(Map<String, dynamic>) cb) {
    onEvent("supportMessage:ack", (data) {
      if (data == null) return;
      if (data is Map) cb(Map<String, dynamic>.from(data));
    });
  }

  void emitSupportTyping({
    required String chatId,
    required bool typing,
    required String senderType,
  }) {
    safeEmit("supportChat:typing", {
      "chatId": chatId,
      "typing": typing,
      "senderType": senderType,
    });
  }

  void onSupportTyping(void Function(Map<String, dynamic>) cb) {
    onEvent("supportChat:typing", (data) {
      if (data == null) return;
      if (data is Map) cb(Map<String, dynamic>.from(data));
    });
  }

  void emitSupportRead({
    required String chatId,
    required String readerType,
  }) {
    safeEmit("supportChat:read", {
      "chatId": chatId,
      "readerType": readerType,
    });
  }

  void _rejoinCachedRooms() {
    if (_socket == null || !_socket!.connected) return;
    if (_joinedOrderRooms.isEmpty) return;

    for (final orderId in _joinedOrderRooms) {
      _socket!.emit("joinOrderRoom", orderId);
    }

    _log("🔁 rejoined order rooms: ${_joinedOrderRooms.length}");
  }

  void disconnect() {
    try {
      _socket?.clearListeners();
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}

    _socket = null;
    _role = null;
    _userId = null;
    _technicianId = null;
    _token = null;

    _pending.clear();
    _joinedOrderRooms.clear();
    _listeners.clear();
    _connectionListeners.clear();
    _connectionHooked = false;
  }

  void dispose() => disconnect();

  void _log(String msg) {
    if (!debugLogs) return;
    if (kDebugMode) debugPrint(msg);
  }
}

class _PendingEmit {
  final String event;
  final dynamic data;

  _PendingEmit(this.event, this.data);
}
