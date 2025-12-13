import 'package:dart_openai/dart_openai.dart';

class AIService {
  AIService() {
    OpenAI.apiKey = "YOUR_KEY_HERE"; // ضع مفتاح OpenAI الحقيقي
  }

  Future<String> diagnose(String query) async {
    try {
      final response = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  "You are a smart car diagnostic assistant. "
                  "Analyze the user's problem and tell them exactly what service they need."),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(query),
            ],
          ),
        ],
      );

      return response.choices.first.message.content!.first.text!;
    } catch (e) {
      return "AI Error: $e";
    }
  }
}
