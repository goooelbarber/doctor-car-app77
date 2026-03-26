import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/chat_message.dart';
import '../services/socket_service.dart';
import '../services/support_chat_service.dart';

class SupportChatScreen extends StatefulWidget {
  final String chatId;
  final String userId;

  const SupportChatScreen({
    super.key,
    required this.chatId,
    required this.userId,
  });

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final SocketService socket = SocketService();

  final TextEditingController controller = TextEditingController();
  final ScrollController scroll = ScrollController();

  bool loading = true;
  bool socketConnected = false;
  bool techTyping = false;

  final List<ChatMessage> messages = [];

  Timer? _typingTimer;
  bool _nearBottom = true;

  // ======================================================
  // INIT
  // ======================================================

  @override
  void initState() {
    super.initState();
    scroll.addListener(_onScroll);
    _init();
  }

  void _onScroll() {
    if (!scroll.hasClients) return;
    final max = scroll.position.maxScrollExtent;
    final cur = scroll.position.pixels;
    _nearBottom = (max - cur) < 160;
  }

  Future<void> _init() async {
    try {
      // ✅ init user socket (مرة واحدة)
      socket.initUser(userId: widget.userId);

      // 🧹 نظف أي listeners قديمة
      socket.clearSupportListeners();

      socket.onConnectionChanged((connected) {
        if (!mounted) return;
        setState(() => socketConnected = connected);

        // احتياط: join room بعد الاتصال
        if (connected) {
          socket.joinSupportChat(widget.chatId);

          // 👀 mark read عند الاتصال (اختياري)
          socket.emitSupportRead(
            chatId: widget.chatId,
            readerType: "user",
          );
        }
      });

      // 🚪 join chat room
      socket.joinSupportChat(widget.chatId);

      // 📜 load history
      final old = await SupportChatService.getMessages(widget.chatId);

      if (!mounted) return;
      setState(() {
        messages
          ..clear()
          ..addAll(old.map(ChatMessage.fromServer));
        loading = false;
      });

      // 👀 mark read
      socket.emitSupportRead(
        chatId: widget.chatId,
        readerType: "user",
      );

      // 🔴 realtime
      socket.onSupportMessage(_onNewMessage);
      socket.onSupportTyping(_onTyping);
      socket.onSupportAck(_onAck);

      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpDown());
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  // ======================================================
  // SOCKET EVENTS
  // ======================================================

  void _onNewMessage(Map<String, dynamic> data) {
    if (!mounted) return;

    final msg = ChatMessage.fromServer(data);

    // منع التكرار
    final exists = msg.id != null && messages.any((m) => m.id == msg.id);
    if (exists) return;

    setState(() => messages.add(msg));
    _maybeScrollDown();

    socket.emitSupportRead(
      chatId: widget.chatId,
      readerType: "user",
    );
  }

  void _onAck(Map<String, dynamic> ack) {
    final tempId = ack["clientTempId"]?.toString();
    final serverId = ack["serverId"]?.toString();
    if (tempId == null || serverId == null) return;

    final i = messages.indexWhere((m) => m.localId == tempId || m.id == tempId);
    if (i == -1 || !mounted) return;

    setState(() {
      // مهم: لازم ChatMessage.id و status يكونوا مش final في الموديل
      messages[i].id = serverId;
      messages[i].status = "sent";
    });
  }

  void _onTyping(Map<String, dynamic> payload) {
    if (!mounted) return;
    if (payload["senderType"] == "user") return;
    setState(() => techTyping = payload["typing"] == true);
  }

  // ======================================================
  // SEND
  // ======================================================

  void _send() {
    if (!socketConnected) return;

    final text = controller.text.trim();
    if (text.isEmpty) return;

    final tempId = DateTime.now().microsecondsSinceEpoch.toString();

    setState(() {
      messages.add(ChatMessage(
        localId: tempId,
        senderType: "user",
        text: text,
        createdAt: DateTime.now(),
        status: "sending",
      ));
      techTyping = false;
    });

    controller.clear();
    setState(() {}); // ✅ علشان زر الإرسال يطفي بعد المسح
    _jumpDown();

    socket.sendSupportMessage(
      chatId: widget.chatId,
      text: text,
      senderType: "user",
      clientTempId: tempId,
    );

    // timeout fallback
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      final i = messages.indexWhere((m) => m.localId == tempId);
      if (i != -1 && messages[i].status == "sending") {
        setState(() => messages[i].status = "failed");
      }
    });

    _emitTyping(false);
  }

  void _emitTyping(bool typing) {
    socket.emitSupportTyping(
      chatId: widget.chatId,
      typing: typing,
      senderType: "user",
    );
  }

  void _onTypingChanged(String _) {
    _emitTyping(true);

    // ✅ مهم: تحديث الواجهة علشان canSend يتحدث
    if (mounted) setState(() {});

    _typingTimer?.cancel();
    _typingTimer =
        Timer(const Duration(milliseconds: 600), () => _emitTyping(false));
  }

  // ======================================================
  // SCROLL
  // ======================================================

  void _maybeScrollDown() {
    if (_nearBottom) _jumpDown();
  }

  void _jumpDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients) return;

      try {
        final max = scroll.position.maxScrollExtent;
        // animateTo ألطف وأأمن من jumpTo
        scroll.animateTo(
          max,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } catch (_) {
        // تجاهل أي خطأ layout مؤقت
      }
    });
  }

  // ======================================================
  // DISPOSE
  // ======================================================

  @override
  void dispose() {
    _typingTimer?.cancel();

    // اطفّي typing قبل الخروج
    socket.emitSupportTyping(
      chatId: widget.chatId,
      typing: false,
      senderType: "user",
    );

    socket.leaveSupportChat(widget.chatId);
    socket.clearSupportListeners();

    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  // ======================================================
  // UI
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final canSend = socketConnected && controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        elevation: 0,
        title: Text(
          "الدعم الفني",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        bottom: techTyping
            ? PreferredSize(
                preferredSize: const Size.fromHeight(22),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    "الميكانيكي يكتب…",
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.amber,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: _messagesView()),
                _composer(canSend: canSend),
              ],
            ),
    );
  }

  Widget _messagesView() {
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.all(14),
      itemCount: messages.length,
      itemBuilder: (_, i) => _bubble(messages[i]),
    );
  }

  Widget _bubble(ChatMessage m) {
    final isUser = m.senderType == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFF7C948) : const Color(0xFF111A2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                m.text,
                style: GoogleFonts.cairo(
                  color: isUser ? Colors.black : Colors.white,
                  fontSize: 14.5,
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              Icon(
                m.status == "failed" ? Icons.error_outline : Icons.done,
                size: 16,
                color: m.status == "failed" ? Colors.red : Colors.black54,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _composer({required bool canSend}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: _onTypingChanged,
                minLines: 1,
                maxLines: 4,
                style: GoogleFonts.cairo(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "اكتب رسالة...",
                  hintStyle: GoogleFonts.cairo(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF111A2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.amber),
              onPressed: canSend ? _send : null,
            ),
          ],
        ),
      ),
    );
  }
}
