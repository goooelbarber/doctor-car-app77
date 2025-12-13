// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../payment_screen.dart';
import 'engines/socket_engine.dart';
import 'engines/motion_engine.dart';
import 'engines/map_engine.dart';
import 'engines/status_engine.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  final String userId;
  final String baseUrl;

  const TrackingScreen({
    super.key,
    required this.orderId,
    required this.userId,
    required this.baseUrl,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  final SocketEngine socketEngine = SocketEngine();
  final MotionEngine motion = MotionEngine();
  final MapEngine mapEngine = MapEngine();
  final StatusEngine statusEngine = StatusEngine();

  LatLng userLocation = const LatLng(31.416, 31.813);
  LatLng? driverLocation;
  LatLng? oldDriverLocation;

  GoogleMapController? mapController;

  // Animations
  late AnimationController rippleCtrl;
  late AnimationController sheetCtrl;
  late Animation<double> rippleAnim;

  // Live Metrics
  double driverRotation = 0;
  double speedMs = 0;
  double distanceToUser = 0;
  int eta = 3;

  Timer? calcTimer;

  @override
  void initState() {
    super.initState();

    sheetCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();

    rippleCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    rippleAnim = Tween<double>(begin: 0, end: 130).animate(
      CurvedAnimation(parent: rippleCtrl, curve: Curves.easeOut),
    );

    mapEngine.loadIcons();
    _connectSocket();

    calcTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateMetrics();
    });
  }

  // CONNECT SOCKET
  void _connectSocket() {
    socketEngine.connect(
      baseUrl: widget.baseUrl,
      orderId: widget.orderId,
      onDriverUpdate: (pos) => _handleDriverMovement(pos),
      onStatusChange: (status, data) {
        statusEngine.update(status);

        if (status == "assigned") {
          driverLocation = LatLng(
            data["driver"]["lat"],
            data["driver"]["lng"],
          );
        }

        setState(() {});
      },
    );
  }

  // DRIVER MOVEMENT HANDLER
  void _handleDriverMovement(LatLng newPos) {
    mapEngine.addTrailPoint(newPos);

    if (driverLocation == null) {
      setState(() => driverLocation = newPos);
      return;
    }

    oldDriverLocation = driverLocation;

    motion.animateDriver(
      vsync: this,
      oldPos: oldDriverLocation!,
      newPos: newPos,
      onMove: (pos) => setState(() => driverLocation = pos),
      onRotate: (rot) => setState(() => driverRotation = rot),
    );
  }

  // METRICS UPDATE
  void _updateMetrics() {
    if (driverLocation == null || oldDriverLocation == null) return;

    speedMs = _distanceBetween(oldDriverLocation!, driverLocation!);
    distanceToUser = _distanceBetween(driverLocation!, userLocation);

    setState(() {});
  }

  double _distanceBetween(LatLng a, LatLng b) {
    const double R = 6371e3; // Earth
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;

    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return R * c;
  }

  // CALL DRIVER
  Future<void> _callTech() async {
    await launchUrl(Uri(scheme: "tel", path: "0123456789"));
  }

  // WHATSAPP DRIVER
  Future<void> _whatsappTech() async {
    await launchUrl(
      Uri.parse("https://wa.me/201234567890"),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildMap(),
          if (driverLocation != null) _buildRipple(),
          _buildTopPanel(),
          _buildEtaBanner(),
          _buildRecenterButton(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  // GOOGLE MAP
  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: userLocation, zoom: 14),
      onMapCreated: (c) {
        mapController = c;
        c.setMapStyle(mapEngine.darkMapStyle);
      },
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      markers: mapEngine.buildMarkers(
        userLocation: userLocation,
        driverLocation: driverLocation,
        rotation: driverRotation,
      ),
      polylines: mapEngine.buildPolylines(),
    );
  }

  // RIPPLE EFFECT
  Widget _buildRipple() {
    return AnimatedBuilder(
      animation: rippleAnim,
      builder: (_, __) {
        final size = rippleAnim.value;
        final op = 1 - (size / 130);
        return Positioned.fill(
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(op),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  // TOP PANEL
  Widget _buildTopPanel() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 18,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _metric(Icons.speed, "${speedMs.toStringAsFixed(1)} m/s", "السرعة"),
            _metric(Icons.route,
                "${(distanceToUser / 1000).toStringAsFixed(2)} كم", "المسافة"),
            _metric(Icons.timer, "$eta دقيقة", "الوصول"),
          ],
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String v, String l) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 22),
        const SizedBox(height: 4),
        Text(v,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        Text(l, style: TextStyle(color: Colors.grey.shade300, fontSize: 11)),
      ],
    );
  }

  // ETA BANNER
  Widget _buildEtaBanner() {
    if (driverLocation == null) return const SizedBox();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 90,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(.80),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          eta <= 1
              ? "✔ الفني وصل الآن"
              : "🚗 الفني في الطريق — $eta دقيقة للوصول",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // RECENTER BUTTON
  Widget _buildRecenterButton() {
    return Positioned(
      right: 16,
      bottom: 180,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, color: Colors.black),
        onPressed: () {
          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              driverLocation ?? userLocation,
              driverLocation != null ? 16 : 14,
            ),
          );
        },
      ),
    );
  }

  // ---------------- Bottom Sheet ----------------

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: sheetCtrl, curve: Curves.easeOutExpo),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.60),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDriverStatus(),
                  const SizedBox(height: 20),
                  _buildDriverCard(),
                  const SizedBox(height: 20),
                  _buildContactButtons(),
                  const SizedBox(height: 20),
                  _buildEndServiceButton(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withOpacity(.25),
            ),
            child: Icon(
              eta <= 1 ? Icons.check_circle : Icons.directions_car,
              color: Colors.amber,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              eta <= 1
                  ? "✔ الفني وصل لموقعك الآن"
                  : "🚗 الفني في الطريق — سيصل خلال $eta دقيقة",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            "assets/images/driver.png",
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "محمد إبراهيم",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "هيونداي النترا — ط ن د 1234",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 18),
                SizedBox(width: 4),
                Text("4.9", style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget _buildContactButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _callTech,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "اتصال",
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _whatsappTech,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "واتساب",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
        ),
      ],
    );
  }

  // END SERVICE → PAYMENT SCREEN
  Widget _buildEndServiceButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                orderId: widget.orderId,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "إنهاء الخدمة (الدفع)",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  @override
  void dispose() {
    socketEngine.dispose();
    motion.dispose();
    rippleCtrl.dispose();
    sheetCtrl.dispose();
    calcTimer?.cancel();
    super.dispose();
  }
}
