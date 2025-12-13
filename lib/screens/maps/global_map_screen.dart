import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GlobalMapScreen extends StatefulWidget {
  const GlobalMapScreen({super.key});

  @override
  State<GlobalMapScreen> createState() => _GlobalMapScreenState();
}

class _GlobalMapScreenState extends State<GlobalMapScreen> {
  GoogleMapController? _controller;

  LatLng _center = const LatLng(26.8206, 30.8025); // مصر
  LatLng? _userLocation;

  final TextEditingController _searchController = TextEditingController();
  bool _loadingLocation = false;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// 📍 جلب موقع المستخدم
  Future<void> _getCurrentLocation() async {
    setState(() => _loadingLocation = true);

    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) Geolocator.openLocationSettings();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
        _center = _userLocation!;
        _loadingLocation = false;

        _markers = {
          Marker(
            markerId: const MarkerId("user"),
            position: _center,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          )
        };
      });

      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(_center, 14),
      );
    } catch (e) {
      debugPrint("Error locating user: $e");
    }
  }

  /// 🔍 البحث في جوجل ماب باستخدام Places API
  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;

    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=YOUR_API_KEY";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data["results"].isNotEmpty) {
        final loc = data["results"][0]["geometry"]["location"];
        final LatLng newLoc = LatLng(loc["lat"], loc["lng"]);

        setState(() {
          _center = newLoc;
          _markers = {
            Marker(
              markerId: const MarkerId("search"),
              position: newLoc,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            )
          };
        });

        _controller?.animateCamera(
          CameraUpdate.newLatLngZoom(newLoc, 14),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("لم يتم العثور على المكان")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الخريطة العالمية 🌍"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 6,
            ),
            onMapCreated: (controller) => _controller = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
          ),

          // مربع البحث
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: "ابحث عن مكان…",
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.blue),
                    onPressed: () {
                      _searchPlace(_searchController.text.trim());
                    },
                  ),
                ),
                onSubmitted: (value) => _searchPlace(value.trim()),
              ),
            ),
          ),

          if (_loadingLocation)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
