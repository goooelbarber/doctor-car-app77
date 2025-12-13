import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'find_technician_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class MapPickerScreen extends StatefulWidget {
  final String selectedService;

  const MapPickerScreen({
    super.key,
    required this.selectedService,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _map;
  LatLng? userPosition;
  LatLng? selectedPosition;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // ========= الحصول على موقع المستخدم ===========
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => loading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => loading = false);
      return;
    }

    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      userPosition = LatLng(pos.latitude, pos.longitude);
      selectedPosition = userPosition;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading || userPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "تحديد موقعك",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),

      // ========= جسم الصفحة ===========
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userPosition!,
              zoom: 14.2,
            ),
            onMapCreated: (controller) => _map = controller,
            onTap: (LatLng point) {
              setState(() {
                selectedPosition = point;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId("selected"),
                position: selectedPosition!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),

          // ❗ العلامة الثابتة في وسط الشاشة
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Icon(
                  Icons.location_on,
                  size: 52,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ),

          // 🔵 زر الذهاب للموقع الحالي
          Positioned(
            bottom: 140,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                if (userPosition != null) {
                  _map?.animateCamera(
                    CameraUpdate.newLatLngZoom(userPosition!, 15),
                  );
                  setState(() => selectedPosition = userPosition);
                }
              },
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // زر التالي
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white.withOpacity(0.9),
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FindTechnicianScreen(
                          serviceType: widget.selectedService,
                          lat: selectedPosition!.latitude,
                          lng: selectedPosition!.longitude,
                          userId: '',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "تأكيد الموقع",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
