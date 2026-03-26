import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/socket_service.dart';

class TechnicianTrackingScreen extends StatefulWidget {
  final String orderId;
  final String userId;

  const TechnicianTrackingScreen({
    super.key,
    required this.orderId,
    required this.userId,
  });

  @override
  State<TechnicianTrackingScreen> createState() =>
      _TechnicianTrackingScreenState();
}

class _TechnicianTrackingScreenState extends State<TechnicianTrackingScreen> {
  GoogleMapController? _mapController;
  final SocketService socketService = SocketService();

  LatLng _techPos = const LatLng(30.05, 31.23);
  double _bearing = 0.0;

  bool _socketConnected = false;
  bool _followMode = true;

  // throttle لتحريك الكاميرا
  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);

  // Bottom sheet
  static const double _sheetPeekHeight = 160;

  // بيانات ETA/Distance (Placeholder — جاهزة لربط Directions)
  String _etaText = "—";
  String _distanceText = "—";

  static const double _followZoom = 17.0;
  static const double _followTilt = 45.0;

  @override
  void initState() {
    super.initState();

    socketService.initUser(userId: widget.userId);

    socketService.onConnectionChanged((connected) {
      if (!mounted) return;
      setState(() => _socketConnected = connected);

      if (connected) {
        socketService.joinOrderRoom(widget.orderId);
      }
    });

    socketService.joinOrderRoom(widget.orderId);

    socketService.onTechnicianLocation((lat, lng) {
      if (!mounted) return;

      final newPos = LatLng(lat, lng);
      final newBearing = _computeBearing(_techPos, newPos);

      setState(() {
        _techPos = newPos;
        _bearing = newBearing;

        // placeholders
        _etaText = "جارٍ الحساب...";
        _distanceText = "جارٍ الحساب...";
      });

      _maybeMoveCameraToFollow();
    });
  }

  @override
  void dispose() {
    // لو عندك dispose/leave في SocketService استعمله هنا
    // socketService.leaveOrderRoom(widget.orderId);
    // socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          _buildMap(context),
          _buildTopBar(context, theme),
          _buildMapControls(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _techPos,
        zoom: 15,
      ),

      // ✅ padding من الـ widget نفسه (بديل setPadding)
      padding: EdgeInsets.fromLTRB(12, 90, 12, _sheetPeekHeight + 12),

      onMapCreated: (controller) async {
        _mapController = controller;

        if (_followMode) {
          _moveCameraFollow(force: true);
        }
      },

      // نفس سلوك أوبر: لو المستخدم لمس الخريطة وقف follow
      onCameraMoveStarted: () {
        if (_followMode) {
          setState(() => _followMode = false);
        }
      },

      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      zoomControlsEnabled: false,

      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,

      markers: {_buildTechnicianMarker()},
    );
  }

  Marker _buildTechnicianMarker() {
    return Marker(
      markerId: const MarkerId("tech"),
      position: _techPos,
      rotation: _bearing,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );
  }

  Widget _buildTopBar(BuildContext context, ThemeData theme) {
    final statusColor = _socketConnected ? Colors.green : Colors.red;
    final statusText = _socketConnected ? "متصل" : "غير متصل";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Row(
          children: [
            _roundButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                      color: Colors.black.withOpacity(0.10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      "تتبع الفني",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _socketConnected ? Icons.wifi : Icons.wifi_off,
                      color: statusColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 14,
      bottom: _sheetPeekHeight + 20,
      child: Column(
        children: [
          _floatingIconButton(
            icon: _followMode ? Icons.gps_fixed : Icons.gps_not_fixed,
            label: _followMode ? "Follow" : "Free",
            onTap: () {
              setState(() => _followMode = !_followMode);
              if (_followMode) _moveCameraFollow(force: true);
            },
          ),
          const SizedBox(height: 10),
          _floatingIconButton(
            icon: Icons.my_location,
            label: "Recenter",
            onTap: () {
              setState(() => _followMode = true);
              _moveCameraFollow(force: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: _sheetPeekHeight,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, -6),
              color: Colors.black.withOpacity(0.10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "الفني في الطريق",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "رقم الطلب: ${widget.orderId}",
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _statusPill(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoTile(title: "ETA", value: _etaText),
                const SizedBox(width: 10),
                _infoTile(title: "المسافة", value: _distanceText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill() {
    final color = _socketConnected ? Colors.green : Colors.red;
    final text = _socketConnected ? "Live" : "Offline";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({required String title, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon),
        ),
      ),
    );
  }

  Widget _floatingIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Camera helpers ----------

  void _maybeMoveCameraToFollow() {
    if (!_followMode) return;

    final now = DateTime.now();
    if (now.difference(_lastCameraMove).inMilliseconds < 350) return;
    _lastCameraMove = now;

    _moveCameraFollow();
  }

  Future<void> _moveCameraFollow({bool force = false}) async {
    if (_mapController == null) return;
    if (!_followMode && !force) return;

    final camera = CameraPosition(
      target: _techPos,
      zoom: _followZoom,
      tilt: _followTilt,
      bearing: _bearing,
    );

    await _mapController!.animateCamera(CameraUpdate.newCameraPosition(camera));
  }

  // ---------- Bearing helpers ----------

  double _computeBearing(LatLng from, LatLng to) {
    final lat1 = _degToRad(from.latitude);
    final lon1 = _degToRad(from.longitude);
    final lat2 = _degToRad(to.latitude);
    final lon2 = _degToRad(to.longitude);

    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    var brng = math.atan2(y, x);
    brng = _radToDeg(brng);
    brng = (brng + 360) % 360;

    return brng.isNaN ? 0.0 : brng;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
  double _radToDeg(double rad) => rad * (180.0 / math.pi);
}
