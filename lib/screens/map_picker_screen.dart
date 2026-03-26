import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  LatLng? selectedPosition; // ده اللي هنرجّعه

  bool loading = true;
  bool _moving = false;
  String errorMsg = "";

  CameraPosition? _lastCameraPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // ================== GET USER LOCATION ==================
  Future<void> _getUserLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          errorMsg = "الرجاء تفعيل خدمة الموقع";
          loading = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMsg = "إذن الموقع مرفوض نهائيًا.. افتح الإعدادات وفعّل الإذن";
          loading = false;
        });
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          errorMsg = "تم رفض إذن الموقع";
          loading = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final me = LatLng(pos.latitude, pos.longitude);

      setState(() {
        userPosition = me;
        selectedPosition = me;
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = "حدث خطأ في تحديد الموقع";
        loading = false;
      });
    }
  }

  void _goToMyLocation() {
    if (userPosition == null) return;
    _map?.animateCamera(
      CameraUpdate.newLatLngZoom(userPosition!, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("خطأ", style: GoogleFonts.cairo()),
          backgroundColor: Colors.redAccent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              errorMsg.isEmpty ? "تعذر تحديد الموقع" : errorMsg,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 18),
            ),
          ),
        ),
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userPosition!,
              zoom: 14.5,
            ),
            onMapCreated: (controller) => _map = controller,

            // ✅ الاختيار صار بالسحب (Center Pin)
            onCameraMove: (pos) {
              _lastCameraPosition = pos;
              if (!_moving) setState(() => _moving = true);
            },
            onCameraIdle: () {
              final cam = _lastCameraPosition;
              if (cam != null) {
                setState(() {
                  selectedPosition = cam.target;
                  _moving = false;
                });
              } else {
                setState(() => _moving = false);
              }
            },

            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // ✅ Center Pin فقط (بدون markers)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 54,
                      color: Colors.red.shade700,
                    ),
                    if (_moving)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "حرّك الخريطة لتحديد الموقع",
                          style: GoogleFonts.cairo(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // My Location
          Positioned(
            bottom: 140,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // Confirm
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.95),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12.withOpacity(.15),
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedPosition == null) return;
                    Navigator.pop(context, selectedPosition);
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
