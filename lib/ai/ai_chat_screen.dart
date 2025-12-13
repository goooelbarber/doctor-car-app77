import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _msg = TextEditingController();
  final List<Map<String, String>> messages = [];

  bool typing = false;

  Future<void> sendMessage() async {
    String text = _msg.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "msg": text});
      typing = true;
    });

    _msg.clear();

    final res = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer YOUR_API_KEY"
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are an automotive AI assistant."},
          ...messages.map((e) => {"role": e["role"], "content": e["msg"]})
        ]
      }),
    );

    final data = jsonDecode(res.body);
    String reply = data["choices"][0]["message"]["content"];

    setState(() {
      messages.add({"role": "assistant", "msg": reply});
      typing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("AI Assistant", style: GoogleFonts.cairo()),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var m in messages) _buildBubble(m),
                if (typing)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
              ],
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, String> m) {
    bool isUser = m["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.white12,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          m["msg"]!,
          style: GoogleFonts.cairo(
            color: isUser ? Colors.white : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msg,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "اكتب رسالتك...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: sendMessage,
          )
        ],
      ),
    );
  }
}
