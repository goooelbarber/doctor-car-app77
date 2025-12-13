// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/openai_service.dart';
import '../widgets/siri_button.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController ctrl = TextEditingController();
  final ScrollController list = ScrollController();

  List<Map<String, String>> messages = [];
  bool loading = false;

  Future<void> send(String msg) async {
    if (msg.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": msg});
      loading = true;
    });
    ctrl.clear();
    scroll();

    final reply =
        await OpenAIService.chat(msg, messages.map((e) => e).toList());

    setState(() {
      messages.add({"role": "assistant", "content": reply ?? "❌ خطأ"});
      loading = false;
    });

    scroll();
  }

  void scroll() {
    Future.delayed(const Duration(milliseconds: 200), () {
      list.animateTo(
        list.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget bubble(bool me, String text) {
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 270),
        decoration: BoxDecoration(
          color: me ? Colors.blueAccent : Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style:
              GoogleFonts.cairo(color: Colors.white, fontSize: 16, height: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A1124),
      appBar: AppBar(
        title: Text("ChatGPT مساعدك",
            style: GoogleFonts.cairo(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff0D1A33),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: list,
            padding: const EdgeInsets.only(bottom: 200),
            itemCount: messages.length,
            itemBuilder: (_, i) {
              final me = messages[i]["role"] == "user";
              return bubble(me, messages[i]["content"]!);
            },
          ),
          if (loading)
            const Positioned(
              bottom: 160,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
            ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SiriButton(
                onResult: (speech) => send(speech),
                onSpeechResult: (String text) {},
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              color: const Color(0xff0D1A33),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "اكتب…",
                        hintStyle: GoogleFonts.cairo(
                          color: Colors.white54,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: send,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.blueAccent, size: 30),
                    onPressed: () => send(ctrl.text),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
