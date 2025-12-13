// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';
import 'package:doctor_car_app/screens/tracking/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/api_config.dart';

class SearchingTechnicianScreen extends StatefulWidget {
  final String userId;
  final String serviceType;
  final double lat;
  final double lng;
  final String orderId;

  const SearchingTechnicianScreen({
    super.key,
    required this.userId,
    required this.serviceType,
    required this.lat,
    required this.lng,
    required this.orderId,
  });

  @override
  State<SearchingTechnicianScreen> createState() =>
      _SearchingTechnicianScreenState();
}

class _SearchingTechnicianScreenState extends State<SearchingTechnicianScreen>
    with TickerProviderStateMixin {
  // ignore: unused_field
  GoogleMapController? _map;
  late AnimationController pulse;

  LatLng? userLocation;

  @override
  void initState() {
    super.initState();

    userLocation = LatLng(widget.lat, widget.lng);

    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
      lowerBound: 0.82,
      upperBound: 1.18,
    )..repeat(reverse: true);

    // 🚀 الانتقال التلقائي لتتبع الفني بعد 4 ثواني
    Future.delayed(const Duration(seconds: 4), () {
      goToTracking();
    });
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  void goToTracking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackingScreen(
          orderId: widget.orderId,
          userId: widget.userId,
          baseUrl: ApiConfig.baseUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildDarkMap(),
          _buildBackButton(),
          _buildSearchingPulse(),
          _buildBottomGlassSheet(),
        ],
      ),
    );
  }

  // ----------------------- MAP STYLE -----------------------
  Widget _buildDarkMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: userLocation!, zoom: 14.5),
      onMapCreated: (controller) {
        _map = controller;
        controller.setMapStyle(_uberMapStyle);
      },
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      markers: {
        Marker(
          markerId: const MarkerId("me"),
          position: userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      },
    );
  }

  // ----------------------- BACK BUTTON -----------------------
  Widget _buildBackButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.55),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.5),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------- SEARCH ANIMATION -----------------------
  Widget _buildSearchingPulse() {
    return Positioned(
      top: 200,
      left: 0,
      right: 0,
      child: ScaleTransition(
        scale: pulse,
        child: Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.06),
              border: Border.all(color: Colors.white.withOpacity(.9), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(.55),
                  blurRadius: 20,
                  spreadRadius: 4,
                )
              ],
            ),
            child: const Icon(
              Icons.search,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------- GLASS BOTTOM SHEET -----------------------
  Widget _buildBottomGlassSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 26),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.72),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(38),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.25),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGrabber(),
                const SizedBox(height: 20),
                _buildSearchingTexts(),
                const SizedBox(height: 22),
                _buildUberLoadingBar(),
                const SizedBox(height: 35),
                _buildNavigationButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrabber() {
    return Container(
      width: 52,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade500.withOpacity(.6),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildSearchingTexts() {
    return Column(
      children: [
        Text(
          "جارٍ البحث عن أقرب فني…",
          style: GoogleFonts.cairo(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "نحدد موقعك الآن ونجمع الفنيين الأقرب إليك...",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Colors.black.withOpacity(.65),
          ),
        ),
      ],
    );
  }

  Widget _buildUberLoadingBar() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueAccent, width: 4),
      ),
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildNavigationButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xff4A90E2), Color(0xff005EFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: goToTracking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            "الانتقال لتتبع الفني",
            style: GoogleFonts.cairo(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------- UBER DARK MAP STYLE -----------------------
  final String _uberMapStyle = '''
  [
    {"elementType": "geometry","stylers":[{"color":"#1c1c1c"}]},
    {"elementType": "labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
    {"elementType": "labels.text.stroke","stylers":[{"color":"#000000"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"road","stylers":[{"color":"#2b2b2b"}]},
    {"featureType":"water","stylers":[{"color":"#0d1117"}]}
  ]
  ''';
}
