import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String apiKey = "YOUR_KEY"; // ضع مفتاحك هنا

  static Future<String?> chat(String message, List history) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {"role": "system", "content": "You are a smart auto assistant."},
            ...history,
            {"role": "user", "content": message}
          ]
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } catch (e) {
      return null;
    }
  }

  static Future<String?> diagnose(String text) async {
    return await chat("Analyze this car problem: $text", []);
  }
}
