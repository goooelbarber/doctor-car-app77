// PATH: lib/features/photo_diagnosis/photo_preview_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

/// ✅ Photo Preview + ChatGPT-like UI
/// يدعم: Android/iOS + Web
class PhotoPreviewScreen extends StatefulWidget {
  /// في الموبايل: بنستقبل XFile وبنستخدم path كـ File
  final XFile? pickedFile;

  /// في الويب: بنستقبل bytes مباشرة
  final Uint8List? webBytes;

  /// اسم الملف (للويب)
  final String? webFileName;

  /// نص السؤال (اختياري) يظهر فوق كرسالة user
  final String? initialPrompt;

  const PhotoPreviewScreen({
    super.key,
    this.pickedFile,
    this.webBytes,
    this.webFileName,
    this.initialPrompt,
  }) : assert(
          (pickedFile != null) || (webBytes != null),
          "Provide either pickedFile (mobile) or webBytes (web).",
        );

  /// ✅ Constructor مريح للموبايل
  factory PhotoPreviewScreen.mobile({required XFile file, String? prompt}) {
    return PhotoPreviewScreen(pickedFile: file, initialPrompt: prompt);
  }

  /// ✅ Constructor مريح للويب
  factory PhotoPreviewScreen.web({
    required Uint8List bytes,
    String? fileName,
    String? prompt,
  }) {
    return PhotoPreviewScreen(
      webBytes: bytes,
      webFileName: fileName ?? "photo.jpg",
      initialPrompt: prompt,
    );
  }

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

enum _MsgType { text, image }

enum _MsgFrom { user, ai, system }

class _ChatMsg {
  final _MsgFrom from;
  final _MsgType type;
  final String? text;
  final Uint8List? imageBytes; // للويب
  final File? imageFile; // للموبايل
  final DateTime at;

  _ChatMsg.text(this.from, this.text)
      : type = _MsgType.text,
        imageBytes = null,
        imageFile = null,
        at = DateTime.now();

  _ChatMsg.imageWeb(this.from, this.imageBytes)
      : type = _MsgType.image,
        text = null,
        imageFile = null,
        at = DateTime.now();

  _ChatMsg.imageMobile(this.from, this.imageFile)
      : type = _MsgType.image,
        text = null,
        imageBytes = null,
        at = DateTime.now();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  // =========================
  // ✅ CONFIG
  // =========================

  /// 🔥 مهم جدًا:
  /// - Android Emulator: 10.0.2.2
  /// - Mobile on same WiFi: IP جهازك
  /// - Web: غالبًا localhost (لو السيرفر شغال على نفس الجهاز)
  String get _baseUrl {
    if (kIsWeb) {
      // لو شغال Flutter Web + Backend على نفس الجهاز:
      return "http://localhost:5555";
      // لو عايز نفس الدومين: return Uri.base.origin; (بس لازم backend نفس البورت)
    }

    if (Platform.isAndroid) {
      // Emulator:
      // return "http://10.0.2.2:5555";

      // Mobile device:
      return "http://192.168.1.10:5555";
    }

    // iOS Simulator غالبًا localhost شغال
    return "http://localhost:5555";
  }

  Uri get _endpoint => Uri.parse("$_baseUrl/api/ai/photo-diagnosis");

  // =========================
  // ✅ STATE
  // =========================
  bool _loading = false;
  String? _error;

  final List<_ChatMsg> _messages = [];
  final ScrollController _scroll = ScrollController();

  static const Color _bg = Color(0xFF0B1220);
  static const Color _brand = Color(0xFF1FD55E);

  @override
  void initState() {
    super.initState();

    // 1) رسالة System بسيطة
    _messages.add(
      _ChatMsg.text(
        _MsgFrom.system,
        "ارفع صورة للمشكلة (كوتش، بطارية، زيت، تسريب…)، وهنحللها بالذكاء.",
      ),
    );

    // 2) رسالة user prompt (لو موجود)
    if ((widget.initialPrompt ?? "").trim().isNotEmpty) {
      _messages.add(_ChatMsg.text(_MsgFrom.user, widget.initialPrompt!.trim()));
    }

    // 3) الصورة كرسالة User
    if (widget.webBytes != null) {
      _messages.add(_ChatMsg.imageWeb(_MsgFrom.user, widget.webBytes));
    } else {
      final f = File(widget.pickedFile!.path);
      _messages.add(_ChatMsg.imageMobile(_MsgFrom.user, f));
    }

    // auto scroll
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canShare = !_loading && _lastAiText()?.trim().isNotEmpty == true;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "فحص بالصور",
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (canShare)
            IconButton(
              tooltip: "مشاركة",
              onPressed: _shareLastAi,
              icon: const Icon(Icons.share_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_error != null) _errorBanner(_error!),

            // ===== Chat list =====
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                itemCount: _messages.length,
                itemBuilder: (context, i) => _bubble(_messages[i]),
              ),
            ),

            // ===== Bottom action bar =====
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  // =========================
  // ✅ Bottom bar (buttons like ChatGPT)
  // =========================
  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.04),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(.10))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _analyzePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white),
                label: Text(
                  _loading ? "جاري التحليل..." : "حلّل الصورة",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 15.8,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 52,
            width: 52,
            child: OutlinedButton(
              onPressed: _loading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(.18)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: Colors.white,
              ),
              child: const Icon(Icons.photo_camera_back_rounded),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ✅ Network: upload image -> AI (Web + Mobile)
  // =========================
  Future<void> _analyzePhoto() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // أضف bubble للـ loading كأنه ChatGPT
    final loadingIndex = _messages.length;
    _messages.add(_ChatMsg.text(_MsgFrom.ai, "جاري التحليل بالذكاء…"));
    setState(() {});
    _jumpToBottom();

    try {
      final req = http.MultipartRequest("POST", _endpoint);

      // field name لازم يطابق multer: upload.single("image")
      if (kIsWeb) {
        final bytes = widget.webBytes!;
        req.files.add(
          http.MultipartFile.fromBytes(
            "image",
            bytes,
            filename: widget.webFileName ?? "photo.jpg",
          ),
        );
      } else {
        final path = widget.pickedFile!.path;
        req.files.add(
          await http.MultipartFile.fromPath(
            "image",
            path,
            filename: "photo.jpg",
          ),
        );
      }

      final streamed = await req.send().timeout(const Duration(seconds: 90));
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        final msg = _tryReadMessage(resp.body) ??
            "فشل التحليل. كود: ${resp.statusCode}";
        throw Exception(msg);
      }

      final data = json.decode(resp.body) as Map<String, dynamic>;
      final success = data["success"] == true;
      if (!success) throw Exception(data["message"]?.toString() ?? "AI failed");

      final diagnosis = (data["diagnosis"] ?? "").toString().trim();
      if (diagnosis.isEmpty) throw Exception("الرد فاضي من السيرفر.");

      // بدّل loading bubble بالرد الحقيقي
      if (!mounted) return;
      setState(() {
        _messages[loadingIndex] = _ChatMsg.text(_MsgFrom.ai, diagnosis);
      });

      _jumpToBottom();
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _messages[loadingIndex] =
            _ChatMsg.text(_MsgFrom.ai, "⏳ التحليل أخد وقت طويل… جرّب تاني.");
        _error = "التحليل أخد وقت طويل. جرّب تاني.";
      });
      _jumpToBottom();
    } catch (e) {
      final msg = e.toString().replaceFirst("Exception:", "").trim();
      if (!mounted) return;
      setState(() {
        _messages[loadingIndex] = _ChatMsg.text(_MsgFrom.ai, "❌ حصل خطأ: $msg");
        _error = msg;
      });
      _jumpToBottom();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _tryReadMessage(String body) {
    try {
      final d = json.decode(body);
      if (d is Map && d["message"] != null) return d["message"].toString();
      return null;
    } catch (_) {
      return null;
    }
  }

  // =========================
  // ✅ Share
  // =========================
  String? _lastAiText() {
    for (int i = _messages.length - 1; i >= 0; i--) {
      final m = _messages[i];
      if (m.from == _MsgFrom.ai && m.type == _MsgType.text) {
        return m.text;
      }
    }
    return null;
  }

  void _shareLastAi() {
    final text = _lastAiText()?.trim();
    if (text == null || text.isEmpty) return;

    // share_plus مش مضمون على كل المنصات بنفس الشكل
    try {
      Share.share("🧠 تشخيص Doctor Car بالذكاء:\n\n$text");
    } catch (_) {
      // fallback
      _snack("انسخ النص وشاركه يدويًا ✅");
    }
  }

  // =========================
  // ✅ UI: bubbles
  // =========================
  Widget _bubble(_ChatMsg msg) {
    final isUser = msg.from == _MsgFrom.user;
    final isAI = msg.from == _MsgFrom.ai;
    final isSystem = msg.from == _MsgFrom.system;

    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    Color bubbleColor;
    Border? border;
    if (isUser) {
      bubbleColor = _brand.withOpacity(.16);
      border = Border.all(color: _brand.withOpacity(.35));
    } else if (isAI) {
      bubbleColor = Colors.white.withOpacity(.06);
      border = Border.all(color: Colors.white.withOpacity(.12));
    } else {
      bubbleColor = Colors.white.withOpacity(.04);
      border = Border.all(color: Colors.white.withOpacity(.10));
    }

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          border: border,
        ),
        child: _bubbleContent(msg, isSystem: isSystem),
      ),
    );
  }

  Widget _bubbleContent(_ChatMsg msg, {required bool isSystem}) {
    if (msg.type == _MsgType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 1.1,
          child: (msg.imageBytes != null)
              ? Image.memory(msg.imageBytes!, fit: BoxFit.cover)
              : Image.file(msg.imageFile!, fit: BoxFit.cover),
        ),
      );
    }

    // text
    return Text(
      msg.text ?? "",
      style: GoogleFonts.cairo(
        color: Colors.white.withOpacity(isSystem ? .78 : .92),
        fontWeight: isSystem ? FontWeight.w800 : FontWeight.w700,
        height: 1.35,
        fontSize: 14.2,
      ),
    );
  }

  Widget _errorBanner(String msg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.withOpacity(.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black.withOpacity(.88),
        content: Text(
          text,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  void _jumpToBottom() {
    if (!_scroll.hasClients) return;
    // بسيط وآمن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }
}
