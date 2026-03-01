// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:ui';

import 'package:doctor_car_app/screens/searching_technician_screen.dart';
import 'package:doctor_car_app/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class ConfirmOrderScreen extends StatefulWidget {
  final String userId;
  final String serviceType;
  final String serviceName;
  final double lat;
  final double lng;

  const ConfirmOrderScreen({
    super.key,
    required this.userId,
    required this.serviceType,
    required this.serviceName,
    required this.lat,
    required this.lng,
  });

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  bool loadingEstimate = true;
  bool creatingOrder = false;

  Map<String, dynamic>? response;
  String? error;

  bool isFinished = false; // swipe state

  late final LatLng userLatLng = LatLng(widget.lat, widget.lng);

  // Uber dark style (اختياري)
  final String _uberMapStyle = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#0b1220"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#0b1220"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"road","stylers":[{"color":"#1c2433"}]},
    {"featureType":"water","stylers":[{"color":"#07101d"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _loadEstimate();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.cairo())),
    );
  }

  Map<String, dynamic> _asMap(dynamic x) {
    if (x is Map<String, dynamic>) return x;
    if (x is Map) return Map<String, dynamic>.from(x);
    return <String, dynamic>{};
  }

  ({num? price, int? etaMin, num? distanceKm}) _parseEstimate(
      Map<String, dynamic> raw) {
    final est = _asMap(raw["estimate"]);

    num? price;
    int? etaMin;
    num? distanceKm;

    final p = est["price"];
    if (p is num) price = p;
    if (p is String) price = num.tryParse(p);

    final e = est["etaMinutes"];
    if (e is num) etaMin = e.toInt();
    if (e is String) etaMin = int.tryParse(e);

    final d = est["distanceKm"];
    if (d is num) distanceKm = d;
    if (d is String) distanceKm = num.tryParse(d);

    return (price: price, etaMin: etaMin, distanceKm: distanceKm);
  }

  Future<void> _loadEstimate() async {
    setState(() {
      loadingEstimate = true;
      error = null;
    });

    try {
      final raw = await OrderService.estimate(
        serviceType: widget.serviceType,
        lat: widget.lat,
        lng: widget.lng,
      );

      final map = _asMap(raw);
      final ok = map["success"] == true;
      final parsed = _parseEstimate(map);

      if (!ok || parsed.price == null || parsed.etaMin == null) {
        throw Exception("Invalid estimate response");
      }

      if (!mounted) return;
      setState(() => response = map);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = "تعذر حساب السعر/الوقت. جرّب تاني.");
    } finally {
      if (!mounted) return;
      setState(() => loadingEstimate = false);
    }
  }

  String _extractOrderId(Map<String, dynamic> res) {
    final order = res["order"] != null ? _asMap(res["order"]) : res;
    final id = order["_id"] ?? order["id"] ?? res["orderId"] ?? res["_id"];
    return (id ?? "").toString();
  }

  Future<void> _confirmCreateOrder() async {
    if (creatingOrder) return;
    setState(() => creatingOrder = true);

    try {
      final raw = await OrderService.createOrder(
        userId: widget.userId,
        serviceName: widget.serviceName,
        serviceType: widget.serviceType,
        lat: widget.lat,
        lng: widget.lng,
      );

      final res = _asMap(raw);
      final orderId = _extractOrderId(res);
      if (orderId.isEmpty) throw Exception("orderId missing");

      setState(() => isFinished = true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SearchingTechnicianScreen(
            userId: widget.userId,
            serviceType: widget.serviceType,
            lat: widget.lat,
            lng: widget.lng,
            orderId: orderId, selectedServices: [], address: '',
          ),
        ),
      );
    } catch (e) {
      _snack("فشل إنشاء الطلب: ${e.toString()}");
      setState(() => isFinished = false);
    } finally {
      if (mounted) setState(() => creatingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = response != null ? _parseEstimate(_asMap(response)) : null;
    final price = parsed?.price;
    final eta = parsed?.etaMin;
    final distanceKm = parsed?.distanceKm;

    final canSwipe =
        !loadingEstimate && error == null && !creatingOrder && price != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          // ===== Map preview (top) =====
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userLatLng,
                zoom: 15.2,
              ),
              onMapCreated: (c) {
                c.setMapStyle(_uberMapStyle);
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              buildingsEnabled: false,
              indoorViewEnabled: false,
              trafficEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId("u"),
                  position: userLatLng,
                )
              },
            ),
          ),

          // ===== dark gradient overlay like Uber =====
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(.0),
                      Colors.black.withOpacity(.15),
                      Colors.black.withOpacity(.55),
                      Colors.black.withOpacity(.85),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== Top bar =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _circleIcon(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    "تأكيد الطلب",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44), // balance
                ],
              ),
            ),
          ),

          // ===== Bottom sheet =====
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(26)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.75),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(26)),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Service title
                      Row(
                        children: [
                          const Icon(Icons.build,
                              color: Colors.amber, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.serviceName,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Estimate cards
                      if (loadingEstimate)
                        _loadingRow()
                      else if (error != null)
                        _errorBox()
                      else
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                title: "السعر",
                                value: price != null
                                    ? "${price.toInt()} ج.م"
                                    : "--",
                                icon: Icons.payments,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                title: "الوقت",
                                value: eta != null ? "$eta دقيقة" : "--",
                                icon: Icons.timer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                title: "المسافة",
                                value: distanceKm != null
                                    ? "${distanceKm.toStringAsFixed(1)} كم"
                                    : "--",
                                icon: Icons.route,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Swipe to confirm
                      SwipeableButtonView(
                        isFinished: isFinished,
                        onWaitingProcess: () async {
                          if (!canSwipe) return;
                          await _confirmCreateOrder();
                        },
                        onFinish: () async {},
                        activeColor: Colors.amber,
                        buttonText: "اسحب لتأكيد الطلب",
                        buttontextstyle: GoogleFonts.cairo(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        buttonWidget: creatingOrder
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.black,
                              ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "بالسحب أنت تؤكد إرسال الطلب لأقرب الفنيين المتاحين.",
                        style: GoogleFonts.cairo(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _loadingRow() {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        const SizedBox(width: 12),
        Text("جارٍ حساب السعر والوقت...",
            style: GoogleFonts.cairo(color: Colors.white70)),
      ],
    );
  }

  Widget _errorBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error ?? "خطأ",
              style: GoogleFonts.cairo(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: _loadEstimate,
            child: Text("إعادة", style: GoogleFonts.cairo(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 6),
          Text(title,
              style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
