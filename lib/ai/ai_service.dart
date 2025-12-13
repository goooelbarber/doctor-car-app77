import 'dart:convert';
import 'package:http/http.dart' as http;

const String openAIKey = "YOUR_API_KEY";

class AIService {
  static Future<String?> classifyProblem(String text) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $openAIKey",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a car diagnostic assistant. Classify the user's issue into one of the following services ONLY: [accident, tire, battery, fuel, tow, diagnostic, emergency]. Reply with ONLY the service name."
          },
          {"role": "user", "content": text}
        ],
        "max_tokens": 10
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["choices"][0]["message"]["content"]
          .toString()
          .trim()
          .toLowerCase();
    }

    // ignore: avoid_print
    print("AI Error: ${response.body}");
    return null;
  }
}
