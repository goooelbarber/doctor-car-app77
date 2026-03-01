import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/socket_service.dart';
import '../../storage/technician_session.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  final SocketService socket = SocketService();

  bool connected = false;
  Map<String, dynamic>? latestOrder;

  String? technicianId;
  bool _loadingTech = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final id = await TechnicianSession.getTechnicianId();

    if (!mounted) return;

    setState(() {
      technicianId = id;
      _loadingTech = false;
    });

    if (id == null || id.isEmpty) {
      // مفيش session
      return;
    }

    // ✅ شغّل socket بالفني الحقيقي
    socket.initTechnician(technicianId: id);

    socket.onConnectionChanged((c) {
      if (!mounted) return;
      setState(() => connected = c);
    });

    socket.onNewOrder((order) {
      if (!mounted) return;
      setState(() => latestOrder = order);

      final orderId = (order["_id"] ?? order["id"] ?? "").toString();
      if (orderId.isNotEmpty) {
        socket.joinOrderRoom(orderId);
      }
    });
  }

  void _accept() {
    final id = (latestOrder?["_id"] ?? latestOrder?["id"] ?? "").toString();
    if (id.isEmpty) return;

    socket.acceptOrder(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("تم إرسال قبول الطلب", style: GoogleFonts.cairo())),
    );
  }

  void _reject() {
    final id = (latestOrder?["_id"] ?? latestOrder?["id"] ?? "").toString();
    if (id.isEmpty) return;

    socket.rejectOrder(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم رفض الطلب", style: GoogleFonts.cairo())),
    );

    setState(() => latestOrder = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingTech) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0D15),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (technicianId == null || technicianId!.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0D15),
        body: Center(
          child: Text(
            "لا يوجد تسجيل دخول للفني.\nارجع لصفحة تسجيل الدخول.",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    final orderId =
        (latestOrder?["_id"] ?? latestOrder?["id"] ?? "").toString();

    final loc = (latestOrder?["location"] is Map)
        ? Map<String, dynamic>.from(latestOrder!["location"])
        : {};
    final lat = loc["lat"];
    final lng = loc["lng"];

    final userId = (latestOrder?["userId"] ??
            latestOrder?["user"] ??
            latestOrder?["user"]?["_id"] ??
            "--")
        .toString();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D15),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D15),
        elevation: 0,
        title: Text("الفني", style: GoogleFonts.cairo(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: connected
                      ? Colors.green.withOpacity(.18)
                      : Colors.red.withOpacity(.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: (connected ? Colors.green : Colors.red)
                        .withOpacity(.35),
                  ),
                ),
                child: Text(
                  connected ? "Online" : "Offline",
                  style: GoogleFonts.cairo(
                    color: connected ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _card(
              title: "جاهز لاستقبال الطلبات",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "لو المستخدم عمل طلب، هيوصلك هنا فورًا.",
                    style: GoogleFonts.cairo(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "TechnicianId: $technicianId",
                    style:
                        GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (latestOrder == null)
              Expanded(
                child: Center(
                  child: Text(
                    "لا توجد طلبات الآن…",
                    style:
                        GoogleFonts.cairo(color: Colors.white38, fontSize: 16),
                  ),
                ),
              )
            else
              _card(
                title: "طلب جديد",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row("OrderId", orderId.isEmpty ? "--" : orderId),
                    _row("Service",
                        (latestOrder?["serviceType"] ?? "--").toString()),
                    _row("UserId", userId),
                    _row("Location",
                        (lat != null && lng != null) ? "$lat , $lng" : "--"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: orderId.isEmpty ? null : _accept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "قبول",
                              style: GoogleFonts.cairo(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: orderId.isEmpty ? null : _reject,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "رفض",
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              k,
              style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
