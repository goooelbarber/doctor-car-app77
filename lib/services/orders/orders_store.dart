import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import

enum OrderStatus { active, completed, cancelled }

class OrderItem {
  final String id;
  final String serviceKey;
  final String title;
  final String externalId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final OrderStatus status;

  const OrderItem({
    required this.id,
    required this.serviceKey,
    required this.title,
    required this.externalId,
    required this.createdAt,
    required this.status,
    this.completedAt,
  });

  OrderItem copyWith({
    String? id,
    String? serviceKey,
    String? title,
    String? externalId,
    DateTime? createdAt,
    DateTime? completedAt,
    OrderStatus? status,
  }) {
    return OrderItem(
      id: id ?? this.id,
      serviceKey: serviceKey ?? this.serviceKey,
      title: title ?? this.title,
      externalId: externalId ?? this.externalId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "serviceKey": serviceKey,
        "title": title,
        "externalId": externalId,
        "createdAt": createdAt.toIso8601String(),
        "completedAt": completedAt?.toIso8601String(),
        "status": status.name,
      };

  static OrderItem fromJson(Map<String, dynamic> j) {
    final st = (j["status"] ?? "active").toString();
    return OrderItem(
      id: (j["id"] ?? "").toString(),
      serviceKey: (j["serviceKey"] ?? "").toString(),
      title: (j["title"] ?? "").toString(),
      externalId: (j["externalId"] ?? "").toString(),
      createdAt: DateTime.tryParse((j["createdAt"] ?? "").toString()) ??
          DateTime.now(),
      completedAt: (j["completedAt"] == null ||
              (j["completedAt"] as String).toString().isEmpty)
          ? null
          : DateTime.tryParse((j["completedAt"] ?? "").toString()),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == st,
        orElse: () => OrderStatus.active,
      ),
    );
  }
}

class OrdersStore extends ChangeNotifier {
  static const _kKey = "doctorcar_orders_v1";

  /// ✅ منع التكرار خلال مدة قصيرة (مثلاً لو المستخدم ضغط مرتين بسرعة)
  static const Duration _dedupWindow = Duration(seconds: 25);

  final List<OrderItem> _orders = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  List<OrderItem> get all => List.unmodifiable(_orders);

  List<OrderItem> get active =>
      _orders.where((o) => o.status == OrderStatus.active).toList();

  List<OrderItem> get completed =>
      _orders.where((o) => o.status == OrderStatus.completed).toList();

  List<OrderItem> get cancelled =>
      _orders.where((o) => o.status == OrderStatus.cancelled).toList();

  int get activeCount => active.length;
  int get completedCount => completed.length;
  int get cancelledCount => cancelled.length;

  /// ✅ لازم تتنادي مرة واحدة عند بداية التطبيق
  Future<void> init() async {
    if (_loaded) return;
    await _load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      _orders
        ..clear()
        ..addAll(
          decoded.map(
            (e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)),
          ),
        );
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_orders.map((e) => e.toJson()).toList());
      await prefs.setString(_kKey, raw);
    } catch (_) {}
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// ✅ هيلبر: رجّع الطلب بالـ id
  OrderItem? getById(String id) {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx == -1) return null;
    return _orders[idx];
  }

  /// ✅ فحص التكرار: نفس الخدمة + نفس العنوان خلال وقت قصير
  OrderItem? _findRecentDuplicate({
    required String serviceKey,
    required String title,
  }) {
    final now = DateTime.now();
    for (final o in _orders) {
      final same = o.serviceKey == serviceKey && o.title == title;
      final within = now.difference(o.createdAt).abs() <= _dedupWindow;
      if (same && within && o.status == OrderStatus.active) {
        return o;
      }
    }
    return null;
  }

  /// ✅ الدالة الأساسية لإنشاء الطلب (زي ما كانت)
  Future<OrderItem> createOrder({
    required String serviceKey,
    required String title,
    String externalId = "",
    bool preventDuplicate = true,
  }) async {
    // ✅ منع تكرار الطلب
    if (preventDuplicate) {
      final dup = _findRecentDuplicate(serviceKey: serviceKey, title: title);
      if (dup != null) return dup;
    }

    final item = OrderItem(
      id: _newId(),
      serviceKey: serviceKey,
      title: title,
      externalId: externalId,
      createdAt: DateTime.now(),
      status: OrderStatus.active,
    );

    _orders.insert(0, item);
    await _save();
    notifyListeners();
    return item;
  }

  /// ✅ إضافة “سهلة” من أي مكان (بدون ما تكتب createOrder كل مرة)
  /// - لو serviceKey مش موجود، بنستخدم title كـ fallback
  Future<OrderItem> addOrder({
    required String title,
    String serviceKey = "",
    String externalId = "",
    bool preventDuplicate = true,
  }) async {
    final key = serviceKey.trim().isEmpty ? title.trim() : serviceKey.trim();
    return createOrder(
      serviceKey: key,
      title: title.trim(),
      externalId: externalId.trim(),
      preventDuplicate: preventDuplicate,
    );
  }

  /// ✅ تحديث رقم خارجي بعد ما يرجع من API
  Future<void> updateExternalId({
    required String id,
    required String externalId,
  }) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx == -1) return;

    _orders[idx] = _orders[idx].copyWith(externalId: externalId.trim());
    await _save();
    notifyListeners();
  }

  Future<void> completeOrder(String id) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx == -1) return;

    _orders[idx] = _orders[idx].copyWith(
      status: OrderStatus.completed,
      completedAt: DateTime.now(),
    );

    await _save();
    notifyListeners();
  }

  Future<void> cancelOrder(String id) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx == -1) return;

    _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled);
    await _save();
    notifyListeners();
  }

  /// ✅ إرجاع الطلب نشط تاني (اختياري بس مفيد)
  Future<void> reOpenOrder(String id) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx == -1) return;

    _orders[idx] = _orders[idx].copyWith(
      status: OrderStatus.active,
      completedAt: null,
    );

    await _save();
    notifyListeners();
  }

  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _orders.clear();
    await _save();
    notifyListeners();
  }

  /// ✅ تنظيف الطلبات القديمة (ميزة مهمة لو عايز تمنع تضخم البيانات)
  /// مثال: store.pruneOlderThan(const Duration(days: 30));
  Future<void> pruneOlderThan(Duration maxAge) async {
    final now = DateTime.now();
    _orders.removeWhere((o) => now.difference(o.createdAt) > maxAge);
    await _save();
    notifyListeners();
  }
}
