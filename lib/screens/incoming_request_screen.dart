import 'dart:async';
import 'package:doctor_car_app/screens/chat/technician_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/socket_service.dart';

class IncomingRequestScreen extends StatefulWidget {
  final String technicianToken;
  final String technicianId;

  const IncomingRequestScreen({
    super.key,
    required this.technicianToken,
    required this.technicianId,
  });

  @override
  State<IncomingRequestScreen> createState() => _IncomingRequestScreenState();
}

class _IncomingRequestScreenState extends State<IncomingRequestScreen>
    with TickerProviderStateMixin {
  late final SocketService socket;

  Map<String, dynamic>? currentRequest;

  bool accepting = false;
  bool connected = false;

  Timer? _timeoutTimer;
  Timer? _countdownTimer;
  int _secondsLeft = 25;

  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    socket = SocketService();
    _initSocket();
  }

  void _initSocket() {
    final techId = widget.technicianId.trim();
    final token = widget.technicianToken.trim();

    if (techId.isEmpty) {
      debugPrint("❌ technicianId is empty - can't init socket");
      setState(() => connected = false);
      return;
    }

    // ✅ مهم: امسح listeners القديمة قبل ما تسجل جديدة (علشان Singleton)
    socket.clearOrderListeners();

    // ✅ init technician + connect
    socket.initTechnician(
      technicianId: techId,
      token: token.isEmpty ? null : token,
    );

    // ✅ اتصال
    socket.onConnectionChanged((c) {
      if (!mounted) return;
      setState(() => connected = c);
    });

    // ✅ طلب جديد
    socket.onNewOrder(_onIncomingOrder);

    // ✅ لما يتم قبول الطلب (ممكن قبول منك أو من فني آخر حسب السيرفر)
    socket.onOrderAccepted(_onOrderAccepted);
  }

  // ===============================
  // SOCKET EVENTS
  // ===============================
  void _onIncomingOrder(Map<String, dynamic> data) {
    if (!mounted) return;

    // لو مشغول في طلب حالي — تجاهل
    if (currentRequest != null) return;
    if (_sheetOpen) return;

    HapticFeedback.heavyImpact();

    setState(() {
      currentRequest = data;
      accepting = false;
      _secondsLeft = 25;
    });

    _openUberSheet();
    _startTimeout();
    _startCountdown();
  }

  void _onOrderAccepted(Map<String, dynamic> order) {
    if (!mounted) return;

    _stopTimers();

    // حاول تطلع chatId (حسب السيرفر عندك)
    final chatId = (order["chatId"] ?? order["_id"] ?? order["orderId"])
            ?.toString()
            .trim() ??
        "";

    // اقفل الشيت لو مفتوح
    if (_sheetOpen && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    _resetState();

    if (chatId.isEmpty) {
      _snack("تم قبول الطلب لكن chatId غير موجود");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TechnicianChatScreen(
          chatId: chatId,
          technicianId: widget.technicianId,
        ),
      ),
    );
  }

  // ===============================
  // TIMERS
  // ===============================
  void _startTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 25), () {
      if (!mounted) return;
      if (currentRequest == null) return;

      final id = currentRequest?['_id']?.toString().trim();
      if (id != null && id.isNotEmpty) {
        socket.rejectOrder(id);
      }

      if (_sheetOpen && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      _resetState();
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (currentRequest == null) return;
      if (_secondsLeft <= 0) return;

      setState(() => _secondsLeft -= 1);
    });
  }

  void _stopTimers() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  // ===============================
  // ACTIONS
  // ===============================
  void _acceptOrder() {
    if (accepting || currentRequest == null) return;

    final id = currentRequest?['_id']?.toString().trim();
    if (id == null || id.isEmpty) return;

    HapticFeedback.mediumImpact();

    setState(() => accepting = true);
    _stopTimers();

    socket.acceptOrder(id);
  }

  void _rejectOrder() {
    final id = currentRequest?['_id']?.toString().trim();
    if (id != null && id.isNotEmpty) socket.rejectOrder(id);

    _stopTimers();

    if (_sheetOpen && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    _resetState();
  }

  void _resetState() {
    if (!mounted) return;
    setState(() {
      currentRequest = null;
      accepting = false;
      _secondsLeft = 25;
      _sheetOpen = false;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.cairo())),
    );
  }

  // ===============================
  // UBER STYLE SHEET
  // ===============================
  void _openUberSheet() {
    if (!mounted) return;
    _sheetOpen = true;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _uberSheet(),
    ).whenComplete(() {
      if (!mounted) return;
      _sheetOpen = false;
    });
  }

  Widget _uberSheet() {
    final userName = currentRequest?["userName"]?.toString() ?? "غير معروف";
    final serviceType = currentRequest?["serviceType"]?.toString() ?? "--";
    final distance = currentRequest?["distance"]?.toString() ?? "--";

    final progress = (_secondsLeft / 25).clamp(0.0, 1.0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.55),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Colors.amber,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "طلب خدمة جديد",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        "$_secondsLeft ث",
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _infoRow(Icons.person, "العميل", userName),
                const SizedBox(height: 10),
                _chipRow(
                  leftIcon: Icons.build,
                  leftText: serviceType,
                  rightIcon: Icons.location_on,
                  rightText: "$distance كم",
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: accepting ? null : _acceptOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23C16B),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: accepting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "قبول",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _rejectOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          "رفض",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white54),
        const SizedBox(width: 10),
        Text(
          "$title:",
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: Colors.white54,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _chipRow({
    required IconData leftIcon,
    required String leftText,
    required IconData rightIcon,
    required String rightText,
  }) {
    Widget chip(IconData i, String t) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Icon(i, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(leftIcon, leftText),
        const SizedBox(width: 10),
        chip(rightIcon, rightText),
      ],
    );
  }

  @override
  void dispose() {
    _stopTimers();

    // ✅ مهم: بما إن SocketService Singleton
    // ما تقفلش السوكيت هنا لو هتروح شاشات تانية للفني (شات/تتبع)
    // استخدم clearOrderListeners بس
    socket.clearOrderListeners();

    super.dispose();
  }

  // ===============================
  // MAIN UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: Text(
          "Doctor Car - Technician",
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Icon(
                  connected ? Icons.wifi : Icons.wifi_off,
                  color: connected ? Colors.greenAccent : Colors.orangeAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  connected ? "Online" : "Connecting",
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            connected
                ? "أنت متاح الآن\nفي انتظار طلب جديد"
                : "جاري الاتصال بالسيرفر...",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
