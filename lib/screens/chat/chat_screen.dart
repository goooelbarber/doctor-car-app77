import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String apiKey;

  const ChatScreen({super.key, required this.apiKey});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  List<Map<String, String>> messages = [];

  Future<void> sendMessage() async {
    String userMsg = controller.text.trim();
    if (userMsg.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "msg": userMsg});
      controller.clear();
    });

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.apiKey}",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": messages
            .map((m) => {"role": m["role"], "content": m["msg"]})
            .toList(),
      }),
    );

    if (response.statusCode == 200) {
      String reply =
          jsonDecode(response.body)["choices"][0]["message"]["content"];

      setState(() {
        messages.add({"role": "assistant", "msg": reply});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A1124),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("AI Chat Assistant"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                bool isMe = messages[i]["role"] == "user";
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      messages[i]["msg"]!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "اكتب رسالتك...",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.send, color: Colors.blueAccent),
              )
            ],
          ),
        ],
      ),
    );
  }
}
