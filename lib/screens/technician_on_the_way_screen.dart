// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

import 'package:url_launcher/url_launcher.dart';

class TechnicianOnTheWay extends StatefulWidget {
  final String technicianName;
  final String technicianPhone;
  final String serviceType;
  final LatLng userLocation;
  final LatLng initialDriverLocation;

  const TechnicianOnTheWay({
    super.key,
    required this.technicianName,
    required this.technicianPhone,
    required this.serviceType,
    required this.userLocation,
    required this.initialDriverLocation,
  });

  @override
  State<TechnicianOnTheWay> createState() => _TechnicianOnTheWayState();
}

class _TechnicianOnTheWayState extends State<TechnicianOnTheWay>
    with TickerProviderStateMixin {
  GoogleMapController? mapController;

  LatLng? driverLocation;
  double driverRotation = 0;

  late AnimationController moveCtrl;
  Animation<LatLng>? moveAnim;

  late AnimationController sheetCtrl;

  @override
  void initState() {
    super.initState();

    driverLocation = widget.initialDriverLocation;

    sheetCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();

    moveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    // مثال: حركة تجريبية كل 2 ثانية (انت هتربطها بالسوكت)
    _simulateDriverMovement();
  }

  void _simulateDriverMovement() async {
    // بين 5 نقاط مختلفة
    List<LatLng> mockPath = [
      widget.initialDriverLocation,
      LatLng(
          widget.userLocation.latitude - 0.002, widget.userLocation.longitude),
      LatLng(widget.userLocation.latitude - 0.001,
          widget.userLocation.longitude + 0.001),
      LatLng(widget.userLocation.latitude - 0.0005,
          widget.userLocation.longitude + 0.0005),
      widget.userLocation,
    ];

    for (var pos in mockPath) {
      await Future.delayed(const Duration(seconds: 2));
      _animateDriverMove(pos);
    }
  }

  void _animateDriverMove(LatLng newPos) {
    if (driverLocation == null) {
      setState(() => driverLocation = newPos);
      return;
    }

    final oldPos = driverLocation!;
    driverRotation = _bearingBetween(oldPos, newPos);

    moveAnim = LatLngTween(begin: oldPos, end: newPos).animate(
      CurvedAnimation(parent: moveCtrl, curve: Curves.easeOut),
    );

    moveCtrl.reset();

    moveCtrl.addListener(() {
      setState(() {
        driverLocation = moveAnim!.value;
      });
    });

    moveCtrl.forward();
  }

  double _bearingBetween(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildMap(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition:
          CameraPosition(target: widget.initialDriverLocation, zoom: 15),
      onMapCreated: (controller) => mapController = controller,
      markers: _markers(),
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
    );
  }

  Set<Marker> _markers() {
    final markers = <Marker>{};

    markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: widget.userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    if (driverLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: driverLocation!,
          rotation: driverRotation,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ),
      );
    }

    return markers;
  }

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(parent: sheetCtrl, curve: Curves.easeOutExpo)),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.local_shipping,
                            color: Colors.amber, size: 32),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          "🚗 الفني متجه إليك الآن…",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage("assets/images/driver.png"),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.technicianName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(widget.serviceType,
                              style: TextStyle(
                                  color: Colors.grey.shade300, fontSize: 15)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.star,
                                  color: Colors.amber.shade400, size: 18),
                              const Text(" 4.9",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final url = Uri(
                                scheme: "tel", path: widget.technicianPhone);
                            await launchUrl(url);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text("اتصال",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final url = Uri.parse(
                                "https://wa.me/${widget.technicianPhone}");
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text("واتساب",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    moveCtrl.dispose();
    sheetCtrl.dispose();
    super.dispose();
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) => LatLng(
        begin!.latitude + (end!.latitude - begin!.latitude) * t,
        begin!.longitude + (end!.longitude - begin!.longitude) * t,
      );
}
