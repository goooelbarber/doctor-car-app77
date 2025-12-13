import 'dart:async';
// ignore: unused_import
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'dart:convert';

class CustomGoogleMap extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const CustomGoogleMap({super.key, required this.onLocationSelected});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  GoogleMapController? mapController;

  LatLng center = const LatLng(30.0444, 31.2357);
  LatLng? userLocation;

  BitmapDescriptor? userIcon;
  BitmapDescriptor? techIcon;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    loadIcons();
    getUserLocation();
  }

  Future<void> loadIcons() async {
    userIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        "assets/icons/user_pin.png");

    techIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        "assets/icons/tech_pin.png");

    setState(() {});
  }

  Future<void> getUserLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    userLocation = LatLng(pos.latitude, pos.longitude);
    center = userLocation!;
    updateUserMarker();
    setState(() {});
  }

  void updateUserMarker() {
    markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: center,
        icon: userIcon ?? BitmapDescriptor.defaultMarker,
      ),
    );
  }

  void onMapTap(LatLng location) {
    widget.onLocationSelected(location);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: center, zoom: 15),
          onMapCreated: (c) => mapController = c,
          onTap: onMapTap,
          markers: markers,
          polylines: polylines,
        ),

        /// Marker ثابت في منتصف الخريطة (Map Picker Pro)
        const Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 50,
              ),
            ),
          ),
        )
      ],
    );
  }
}
