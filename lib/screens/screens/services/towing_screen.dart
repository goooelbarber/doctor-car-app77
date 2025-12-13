import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TowingScreen extends StatefulWidget {
  const TowingScreen({super.key});

  @override
  State<TowingScreen> createState() => _TowingScreenState();
}

class _TowingScreenState extends State<TowingScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _isLoading = true;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // 🧭 جلب موقع المستخدم الحالي
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق من تفعيل GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ من فضلك فعّل خدمة الموقع (GPS)')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    // طلب الإذن
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🚫 تم رفض إذن الوصول إلى الموقع')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('🚫 إذن الموقع مرفوض بشكل دائم. فعّله من الإعدادات')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    // الحصول على الموقع
    final position = await Geolocator.getCurrentPosition();

    final LatLng posLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLocation = posLatLng;
      _markers = {
        Marker(
          markerId: const MarkerId("user_location"),
          position: posLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
      _isLoading = false;
    });

    // تحريك الخريطة للموقع
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(posLatLng, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مساعدة الطريق السريعة"),
        backgroundColor: const Color(0xFFFF6F00),
      ),
      body: Column(
        children: [
          // 🗺️ الخريطة (Google Maps)
          Expanded(
            child: _isLoading || _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 13,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) => _mapController = controller,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
          ),

          // ⚙️ الخيارات + زر الخدمة
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _optionTile("🚛 ونش وسحب السيارة"),
                _optionTile("🧰 ميكانيكي متنقل"),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ تم إرسال طلب المساعدة بنجاح'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.car_repair, color: Colors.white),
                  label: const Text(
                    "طلب الخدمة الآن",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile(String title) {
    return ListTile(
      leading: const Icon(Icons.circle, size: 10, color: Colors.orange),
      title: Text(title),
    );
  }
}
