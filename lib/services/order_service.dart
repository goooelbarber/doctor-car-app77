import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class OrderService {
  static const Duration _timeout = Duration(seconds: 20);

  static String _extractMessage(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body["message"] != null)
        return body["message"].toString();
      if (body is Map && body["error"] != null) return body["error"].toString();
    } catch (_) {}
    return "حدث خطأ غير متوقع";
  }

  /// ✅ Estimate price + ETA
  /// POST /api/orders/estimate
  static Future<Map<String, dynamic>> estimate({
    required String serviceType,
    required double lat,
    required double lng,
  }) async {
    final res = await http
        .post(
          Uri.parse("${ApiConfig.baseUrl}/api/orders/estimate"),
          headers: ApiConfig.jsonHeaders(),
          body: jsonEncode({
            "serviceType": serviceType,
            "lat": lat,
            "lng": lng,
          }),
        )
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception(_extractMessage(res));
    }

    final data = jsonDecode(res.body);
    if (data is! Map<String, dynamic>) {
      throw Exception("صيغة الاستجابة غير صحيحة");
    }
    return data;
  }

  /// ✅ Create real order
  /// POST /api/orders
  ///
  /// ✅ (اختياري) لو السيرفر عندك فيه start-timeout endpoint:
  /// POST /api/orders/:id/start-timeout
  static Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String serviceName,
    required String serviceType,
    required double lat,
    required double lng,
    bool startTimeoutAfterCreate = false, // 👈 جديد
  }) async {
    final res = await http
        .post(
          Uri.parse("${ApiConfig.baseUrl}/api/orders"),
          headers: ApiConfig.jsonHeaders(),
          body: jsonEncode({
            "userId": userId,
            "serviceName": serviceName,
            "serviceType": serviceType,
            "location": {"lat": lat, "lng": lng},
          }),
        )
        .timeout(_timeout);

    if (res.statusCode != 201) {
      throw Exception(_extractMessage(res));
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("صيغة الاستجابة غير صحيحة");
    }

    // order ممكن يكون داخل order أو مباشرة
    final order = (decoded["order"] is Map)
        ? Map<String, dynamic>.from(decoded["order"])
        : decoded;

    final orderId = (order["_id"] ?? "").toString();
    if (orderId.isEmpty) {
      throw Exception("orderId غير موجود في response");
    }

    // ✅ (اختياري) شغل تايم اوت في السيرفر بعد الإنشاء
    if (startTimeoutAfterCreate) {
      try {
        await startOrderTimeout(orderId: orderId);
      } catch (_) {
        // لو فشل مش هنوقف التطبيق، بس لو تحب ترفع الخطأ قولّي
      }
    }

    return decoded;
  }

  /// ✅ (اختياري) start-timeout endpoint
  /// POST /api/orders/:id/start-timeout
  static Future<void> startOrderTimeout({required String orderId}) async {
    final res = await http
        .post(
          Uri.parse("${ApiConfig.baseUrl}/api/orders/$orderId/start-timeout"),
          headers: ApiConfig.jsonHeaders(),
        )
        .timeout(_timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractMessage(res));
    }
  }

  /// ✅ Cancel endpoint (لو موجود عندك)
  /// POST /api/orders/:id/cancel
  static Future<void> cancelOrder({required String orderId}) async {
    final res = await http
        .post(
          Uri.parse("${ApiConfig.baseUrl}/api/orders/$orderId/cancel"),
          headers: ApiConfig.jsonHeaders(),
        )
        .timeout(_timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_extractMessage(res));
    }
  }
}
