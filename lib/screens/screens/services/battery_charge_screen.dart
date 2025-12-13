import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class BatteryChargeScreen extends StatefulWidget {
  const BatteryChargeScreen({super.key});

  @override
  State<BatteryChargeScreen> createState() => _BatteryChargeScreenState();
}

class _BatteryChargeScreenState extends State<BatteryChargeScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLocating = true;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// ✅ تحديد موقع المستخدم الحالي
  Future<void> _determinePosition() async {
    setState(() => _isLocating = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final LatLng newPos = LatLng(pos.latitude, pos.longitude);

    setState(() {
      _currentPosition = newPos;
      _markers = {
        Marker(
          markerId: const MarkerId("user"),
          position: newPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      };
      _isLocating = false;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(newPos, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔋 شحن البطارية"),
        backgroundColor: const Color(0xFFFF6F00),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _determinePosition,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLocating || _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 15,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) => _mapController = controller,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
          ),

          /// زر طلب شحن البطارية
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("🚗 تم إرسال طلب شحن البطارية بنجاح!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon:
                  const Icon(Icons.battery_charging_full, color: Colors.white),
              label: const Text(
                "طلب شحن البطارية الآن",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
