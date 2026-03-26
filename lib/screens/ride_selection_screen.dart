// PATH: lib/screens/ride_selection_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'tracking/tracking_screen.dart';

// ✅ غيّر import ده لو مسار SelectLocationScreen مختلف عندك
import 'select_location_screen.dart';

class RideSelectionScreen extends StatefulWidget {
  final String userId;
  final String serviceType;

  /// لو عندك orderId جاهز من السيرفر ابعته هنا
  final String? orderId;

  /// لو true هيفتح Tracking بــ Fake movement (مفيد للتجربة)
  final bool fakeTracking;

  const RideSelectionScreen({
    super.key,
    required this.userId,
    required this.serviceType,
    this.orderId,
    this.fakeTracking = true,
  });

  @override
  State<RideSelectionScreen> createState() => _RideSelectionScreenState();
}

class _RideSelectionScreenState extends State<RideSelectionScreen> {
  // ======================
  // DoctorCar THEME
  // ======================
  static const Color _bg = Color(0xFF0B1220);
  static const Color _bg2 = Color(0xFF081837);
  static const Color _bg3 = Color(0xFF0A2038);

  static const Color _card = Color(0xFF121B2E);
  static const Color _card2 = Color(0xFF0F1A30);

  static const Color _brand = Color(0xFFA8F12A); // neon lime
  static const Color _danger = Color(0xFFFF4D4D);

  PickedLocation? _serviceLocation;

  String get _baseUrl => (dotenv.env['BASE_URL'] ?? '').trim();

  LinearGradient get _ctaGradient => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.lerp(_brand, Colors.white, 0.20)!,
          _brand,
          Color.lerp(_brand, _bg, 0.18)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(.92),
        content: Text(
          msg,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ======================
  // Actions
  // ======================
  Future<void> _pickServiceLocation() async {
    HapticFeedback.selectionClick();

    final picked = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectLocationScreen(
          serviceType: widget.serviceType,
          userId: widget.userId,
          selectedServices: const [], // لو عندك خدمات مختارة ابعتها هنا
        ),
      ),
    );

    if (picked == null) return;

    setState(() => _serviceLocation = picked);
    HapticFeedback.mediumImpact();
  }

  void _startTracking() {
    if (_serviceLocation == null) {
      _toast("اختار موقع الخدمة الأول");
      return;
    }

    final orderId = (widget.orderId?.trim().isNotEmpty ?? false)
        ? widget.orderId!.trim()
        : "FAKE_${DateTime.now().millisecondsSinceEpoch}";

    final baseUrl = _baseUrl.isNotEmpty ? _baseUrl : "https://example.com";

    HapticFeedback.heavyImpact();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackingScreen(
          orderId: orderId,
          userId: widget.userId,
          baseUrl: baseUrl,
          serviceType: widget.serviceType,
          fakeMode: widget.fakeTracking,
          userLat: _serviceLocation!.lat,
          userLng: _serviceLocation!.lng,
        ),
      ),
    );
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _backgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _topBar(),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                    children: [
                      _sectionTitle("تفاصيل الخدمة"),
                      const SizedBox(height: 10),
                      _serviceTypeCard(),
                      const SizedBox(height: 14),
                      _sectionTitle("موقع الخدمة"),
                      const SizedBox(height: 10),
                      _locationCard(),
                      const SizedBox(height: 18),
                      _hintCard(),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: _ctaBar(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundGlow() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_bg, _bg2, _bg3],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.30),
              Colors.transparent,
              Colors.black.withOpacity(0.15),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.30),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _brand.withOpacity(.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: _brand.withOpacity(.22)),
                ),
                child: const Icon(Icons.route_rounded, color: _brand, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "طلب خدمة",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.25),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  widget.serviceType,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.cairo(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _serviceTypeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card.withOpacity(.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _brand.withOpacity(.14),
              shape: BoxShape.circle,
              border: Border.all(color: _brand.withOpacity(.20)),
            ),
            child: const Icon(Icons.build_circle, color: _brand, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.serviceType,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationCard() {
    final has = _serviceLocation != null;
    final addr = has ? _serviceLocation!.address : "لم يتم اختيار موقع بعد";

    return InkWell(
      onTap: _pickServiceLocation,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card2.withOpacity(.88),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: has ? _brand.withOpacity(.14) : Colors.white10,
                shape: BoxShape.circle,
                border: Border.all(
                  color: has ? _brand.withOpacity(.20) : Colors.white12,
                ),
              ),
              child: Icon(
                has ? Icons.place_rounded : Icons.add_location_alt_rounded,
                color: has ? _brand : Colors.white70,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    addr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (has)
                    Text(
                      "${_serviceLocation!.lat.toStringAsFixed(5)}, ${_serviceLocation!.lng.toStringAsFixed(5)}",
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      "اضغط لاختيار موقع الخدمة على الخريطة",
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.cairo(
                        color: Colors.white54,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_left, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _hintCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "بعد اختيار الموقع اضغط (ابدأ التتبع) علشان تشوف المسار وتتبع الفني. (بدون أسعار)",
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 12.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctaBar() {
    final enabled = _serviceLocation != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _card.withOpacity(.70),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _brand.withOpacity(0.28),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedOpacity(
                          opacity: enabled ? 1 : 0.35,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                              decoration: BoxDecoration(
                            gradient: _ctaGradient,
                          )),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: enabled ? _startTracking : null,
                            child: Center(
                              child: Text(
                                "ابدأ التتبع",
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickServiceLocation,
                      icon: const Icon(Icons.edit_location_alt_rounded,
                          color: Colors.white),
                      label: Text(
                        "تغيير الموقع",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.cancel, color: _danger),
                      label: Text(
                        "إلغاء",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
