import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class OrderService {
  static Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String serviceType,
    required double lat,
    required double lng,
  }) async {
    final url = Uri.parse(ApiConfig.orders);

    final body = {
      "userId": userId,
      "serviceType": serviceType,
      "location": {
        "lat": lat,
        "lng": lng,
      }
    };

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception("فشل إنشاء الطلب: ${res.body}");
    }
  }
}
