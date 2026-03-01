// PATH: lib/services/support_chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class SupportChatService {
  static Map<String, String> _headers({String? token}) {
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // =====================================================
  // 💬 Get or Create Chat (User)
  // GET /api/support/me
  // =====================================================
  static Future<Map<String, dynamic>> getOrCreateChat({
    String? token,
  }) async {
    final uri = Uri.parse("${ApiConfig.support}/me");

    final res = await http
        .get(uri, headers: _headers(token: token))
        .timeout(ApiConfig.requestTimeout);

    if (res.statusCode != 200) {
      throw Exception(
          "❌ getOrCreateChat failed: ${res.statusCode} ${res.body}");
    }

    final data = jsonDecode(res.body);

    if (data is! Map) {
      throw Exception("❌ Invalid response format from getOrCreateChat");
    }

    return Map<String, dynamic>.from(data);
  }

  // =====================================================
  // 📜 Get Messages History
  // يقرأ List مباشرة أو {messages: []}
  // =====================================================
  static Future<List<Map<String, dynamic>>> getMessages(
    String chatId, {
    String? token,
  }) async {
    // ✅ استخدم المسار الموحد من ApiConfig
    final uri = Uri.parse(ApiConfig.supportMessages(chatId));

    final res = await http
        .get(uri, headers: _headers(token: token))
        .timeout(ApiConfig.requestTimeout);

    if (res.statusCode != 200) {
      throw Exception("❌ getMessages failed: ${res.statusCode} ${res.body}");
    }

    final decoded = jsonDecode(res.body);

    // 1) لو السيرفر بيرجع List مباشرة
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    // 2) لو السيرفر بيرجع { messages: [...] }
    if (decoded is Map) {
      final msg = decoded["messages"];
      if (msg is List) {
        return msg
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    return [];
  }
}
