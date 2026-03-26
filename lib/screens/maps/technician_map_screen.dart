import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TechnicianMapScreen extends StatefulWidget {
  const TechnicianMapScreen({super.key});

  @override
  State<TechnicianMapScreen> createState() => _TechnicianMapScreenState();
}

class _TechnicianMapScreenState extends State<TechnicianMapScreen> {
  GoogleMapController? _mapController;

  LatLng _center = const LatLng(30.0444, 31.2357);
  LatLng? _userLocation;
  final TextEditingController _searchController = TextEditingController();

  bool _loading = false;

  List<dynamic> _technicians = [];
  // ignore: prefer_final_fields
  Map<String, LatLng> _technicianPositions = {};

  IO.Socket? _socket;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initMap();
    _connectSocket();
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }

  // SOCKET.IO
  void _connectSocket() {
    _socket = IO.io(
      "http://10.0.2.2:5000",
      IO.OptionBuilder().setTransports(["websocket"]).build(),
    );

    _socket!.onConnect((_) {
      debugPrint("Connected to socket");
    });

    _socket!.on("locationUpdate", (data) {
      if (data["id"] != null) {
        setState(() {
          _technicianPositions[data["id"]] =
              LatLng(data["lat"].toDouble(), data["lng"].toDouble());
        });
        _updateMarkers();
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint("Socket disconnected");
    });
  }

  // INITIALIZATION
  Future<void> _initMap() async {
    await _getUserLocation();
    await _getTechnicians();
  }

  // GET USER LOCATION
  Future<void> _getUserLocation() async {
    setState(() => _loading = true);

    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) await Geolocator.openLocationSettings();

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;

      Position pos = await Geolocator.getCurrentPosition();

      _userLocation = LatLng(pos.latitude, pos.longitude);
      _center = _userLocation!;

      _updateMarkers();

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_center, 14),
      );
    } catch (e) {
      debugPrint("Location error: $e");
    }

    setState(() => _loading = false);
  }

  // FETCH TECHNICIANS FROM API
  Future<void> _getTechnicians() async {
    const url = "http://10.0.2.2:5000/api/technicians";

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        _technicians = jsonDecode(res.body);
        _updateMarkers();
      }
    } catch (e) {
      debugPrint("Technician fetch error: $e");
    }
  }

  // SEARCH PLACE USING GOOGLE PLACES
  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;

    setState(() => _loading = true);
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=YOUR_API_KEY";

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['results'].isNotEmpty) {
          final loc = data['results'][0]['geometry']['location'];
          LatLng newLoc = LatLng(loc['lat'], loc['lng']);

          _center = newLoc;
          _updateMarkers();

          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(newLoc, 14),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("لم يتم العثور على المكان المطلوب"),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }

    setState(() => _loading = false);
  }

  // UPDATE MARKERS
  void _updateMarkers() {
    Set<Marker> markers = {};

    // USER MARKER
    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("user"),
          position: _userLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // STATIC TECHNICIANS
    for (var tech in _technicians) {
      markers.add(
        Marker(
          markerId: MarkerId("static_${tech['id']}"),
          position: LatLng(tech['lat'], tech['lng']),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }

    // LIVE TECHNICIANS (SOCKET)
    _technicianPositions.forEach((id, loc) {
      markers.add(
        Marker(
          markerId: MarkerId("live_$id"),
          position: loc,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تتبع الفنيين مباشرة 🔧"),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            onPressed: _getUserLocation,
            icon: const Icon(Icons.my_location),
          ),
          IconButton(
            onPressed: _getTechnicians,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 7,
            ),
            onMapCreated: (c) => _mapController = c,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),

          // SEARCH BAR
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: SizedBox(
              height: 55,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "ابحث عن مكان...",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.blue),
                    onPressed: () =>
                        _searchPlace(_searchController.text.trim()),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (v) => _searchPlace(v.trim()),
              ),
            ),
          ),

          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
