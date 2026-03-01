// PATH: lib/screens/request_technician_screen.dart
// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'offers_waiting_screen.dart';

class RequestTechnicianScreen extends StatefulWidget {
  final String userId;
  final String serviceType;
  final LatLng pickup;
  final String address;
  final List<String> selectedServices;

  const RequestTechnicianScreen({
    super.key,
    required this.userId,
    required this.serviceType,
    required this.pickup,
    required this.address,
    required this.selectedServices,
  });

  @override
  State<RequestTechnicianScreen> createState() =>
      _RequestTechnicianScreenState();
}

class _RequestTechnicianScreenState extends State<RequestTechnicianScreen> {
  // ignore: unused_field
  GoogleMapController? _map;

  // UI values
  int _offerPrice = 89;
  bool _autoAccept = true;

  // Fake partners count like screenshot
  final int _partnersCount = 6;

  // Fake timer like screenshot (لو عايزه يبدأ من 00:00 سيبه 0)
  int _seconds = 92; // 01:32
  late final Ticker _ticker;
  bool _tickerStarted = false;

  // Theme close to screenshot
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _line = Color(0xFFE5E7EB);
  static const Color _green = Color(0xFFB7FF3C);
  // ignore: unused_field
  static const Color _danger = Color(0xFF111827);

  @override
  void initState() {
    super.initState();

    // timer tick each second
    _ticker = Ticker((_) {
      // handled by periodic below
    });
    _startTimer();
  }

  void _startTimer() {
    if (_tickerStarted) return;
    _tickerStarted = true;

    // بسيط: زود ثانية كل ثانية
    Future.doWhile(() async {
      if (!mounted) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _seconds++);
      return true;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapPadding = EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 70,
      bottom: 340,
    );

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: mapPadding,
            initialCameraPosition:
                CameraPosition(target: widget.pickup, zoom: 15),
            onMapCreated: (c) => _map = c,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId("pickup"),
                position: widget.pickup,
              ),
            },
          ),

          // Top bar (زي الصورة الأولى)
          _buildTopSearchBar(),

          // Arrow button right (زي الصورة)
          Positioned(
            right: 14,
            top: MediaQuery.of(context).padding.top + 80,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(blurRadius: 14, color: Colors.black26)
                ],
              ),
              child: const Icon(Icons.arrow_forward, color: _text),
            ),
          ),

          // Bottom sheet (زي الصورة اللي بعتها)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  boxShadow: [BoxShadow(blurRadius: 18, color: Colors.black12)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // handle
                    Container(
                      width: 56,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // avatars + "يعرض 6..."
                    Row(
                      children: [
                        _buildMiniAvatars(_partnersCount),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "يعرض $_partnersCount شركاء سائقين طلبك",
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _text,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // row: time left + hint text (زي الصورة)
                    Row(
                      children: [
                        Text(
                          _formatSeconds(_seconds),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "الأجرة أقل من المتوسط. توقع عروضًا أقل",
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _text,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // thin progress line like screenshot
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // price stepper area (زي الصورة: +1 | 89 E£ | -1)
                    Row(
                      children: [
                        _smallStepper(
                          label: "+ 1",
                          onTap: () => setState(() => _offerPrice += 1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 62,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _line),
                            ),
                            child: Text(
                              "$_offerPrice E£",
                              style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: _text,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _smallStepper(
                          label: "- 1",
                          onTap: () {
                            setState(() {
                              if (_offerPrice > 1) _offerPrice -= 1;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // "رفع الأجرة" like screenshot
                    Text(
                      "رفع الأجرة",
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _muted,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Container(height: 1, color: _line),
                    const SizedBox(height: 10),

                    // auto accept toggle + send icon (زي الصورة)
                    Row(
                      children: [
                        Switch(
                          value: _autoAccept,
                          onChanged: (v) => setState(() => _autoAccept = v),
                        ),
                        Expanded(
                          child: Text(
                            "قبول تلقائي لعرض بسعر $_offerPrice E£ ووقت انتظار 5 من الدقائق",
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.cairo(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w800,
                              color: _text,
                            ),
                          ),
                        ),
                        const Icon(Icons.send, size: 20, color: _muted),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // cash row (يمين)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.payments_outlined,
                            size: 18, color: _muted),
                        const SizedBox(width: 6),
                        Text(
                          "$_offerPrice E£ نقدًا",
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Container(height: 1, color: _line),
                    const SizedBox(height: 10),

                    // locations (الموقع الحالي + الوجهة) زي الصورة
                    _locationRow(
                      dotColor: Colors.blue,
                      title: "الموقع الحالي",
                      value: widget.address,
                    ),
                    const SizedBox(height: 8),
                    _locationRow(
                      dotColor: Colors.green,
                      title: "الوجهة",
                      value: "(Ras El-Bar City) الجربي", // عدلها حسب وجهتك
                    ),

                    const SizedBox(height: 14),

                    // CTA (لو عايز نفس شاشة الصورة زرها مش ظاهر هنا لأنها شاشة waiting،
                    // لكن انت قلت دي "بعد البحث" -> هنا نروح لانتظار العروض)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OffersWaitingScreen(
                                userId: widget.userId,
                                serviceType: widget.serviceType,
                                pickup: widget.pickup,
                                address: widget.address,
                                selectedServices: widget.selectedServices,
                                initialPrice: _offerPrice.toDouble(),
                                autoAccept: _autoAccept,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "بحث عن فني",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Cancel (زي الصورة: زر كبير)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _text,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: _line),
                          ),
                        ),
                        child: Text(
                          "إلغاء الطلب",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearchBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: Colors.white.withOpacity(0.92),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 26, color: _text),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.circle, color: Colors.green, size: 14),
                  const SizedBox(width: 10),
                  const Icon(Icons.circle, color: Colors.red, size: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallStepper({required String label, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 74,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _line),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: _text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniAvatars(int count) {
    final items = List.generate(count, (i) => i);
    return SizedBox(
      width: 18.0 * (count - 1) + 26,
      height: 26,
      child: Stack(
        children: [
          for (int i = 0; i < items.length; i++)
            Positioned(
              left: i * 18.0,
              child: const CircleAvatar(
                radius: 13,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFE2E8F0),
                  child: Icon(Icons.person, size: 14, color: _muted),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _locationRow({
    required Color dotColor,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: _text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    final mm = m.toString().padLeft(2, '0');
    final rr = r.toString().padLeft(2, '0');
    return "$mm:$rr";
  }
}
