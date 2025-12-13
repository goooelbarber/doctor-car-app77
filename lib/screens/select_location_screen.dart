import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';

import '../services/google_places_service.dart';
// ignore: unused_import
import '../config/api_config.dart';
import 'searching_technician_screen.dart'; // ✅ تحويل صحيح

class SelectLocationScreen extends StatefulWidget {
  final String serviceType;
  final String userId;
  final List<String> selectedServices;

  const SelectLocationScreen({
    super.key,
    required this.serviceType,
    required this.userId,
    required this.selectedServices,
  });

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _map;
  LatLng _selected = const LatLng(31.4175, 31.8153);

  static const String _googleApiKey =
      "AIzaSyD9BGSScE-DU9nbdFgIbJV4fbNspNdPg_M&libraries";

  late final GooglePlacesService _places = GooglePlacesService(_googleApiKey);

  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _showResults = false;

  late final AnimationController _pinAnim;
  String _currentAddress = "جارِ تحديد العنوان…";

  String? _mapStyle;

  @override
  void initState() {
    super.initState();

    _pinAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0,
      upperBound: 10,
    )..repeat(reverse: true);

    _loadMapStyle();
    _initMyLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pinAnim.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString(
        'assets/map_styles/uber_dark.json',
      );
    } catch (_) {}
  }

  Future<void> _initMyLocation() async {
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      setState(() => _selected = LatLng(pos.latitude, pos.longitude));

      _map?.animateCamera(
        CameraUpdate.newLatLngZoom(_selected, 16),
      );
    } catch (_) {}
  }

  void _onMapCreated(GoogleMapController c) {
    _map = c;
    if (_mapStyle != null) {
      _map!.setMapStyle(_mapStyle);
    }
  }

  void _onTap(LatLng point) {
    setState(() {
      _selected = point;
      _currentAddress = "تم اختيار موقع جديد";
    });
    _pinAnim.forward(from: 0);
    _map?.animateCamera(CameraUpdate.newLatLng(point));
  }

  Future<void> _onSearchChanged(String value) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final items = await _places.autocomplete(value);
      setState(() {
        _results = items;
        _showResults = items.isNotEmpty;
      });
    });
  }

  Future<void> _onSelectPlace(Map<String, dynamic> item) async {
    final placeId = item["place_id"] as String;
    final details = await _places.getPlaceLatLng(placeId);
    if (details == null) return;

    final point = LatLng(details.lat, details.lng);

    setState(() {
      _selected = point;
      _currentAddress = details.address;
      _search.text = details.name;
      _showResults = false;
    });

    _pinAnim.forward(from: 0);
    _map?.animateCamera(
      CameraUpdate.newLatLngZoom(point, 16),
    );
  }

  Future<void> _goToMyLocation() async {
    await _initMyLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selected, zoom: 15),
            onMapCreated: _onMapCreated,
            onTap: _onTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          /// Marker Animation
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _pinAnim,
                builder: (_, __) {
                  return Center(
                    child: Transform.translate(
                      offset: Offset(0, -_pinAnim.value),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/icons/user_pin.png",
                            width: 55,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          /// Search box
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _search,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "ابحث عن مدينة أو شارع…",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                if (_showResults)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 230),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final item = _results[i];
                        return ListTile(
                          leading: const Icon(Icons.place, color: Colors.red),
                          title: Text(
                            item["description"],
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                          ),
                          onTap: () => _onSelectPlace(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          /// Address card
          Positioned(
            bottom: 110,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _goToMyLocation,
                  ),
                ],
              ),
            ),
          ),

          /// CONFIRM BUTTON — FIXED ✔
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                /// 👉 الآن يذهب للبحث عن الفني وليس للتتبع
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchingTechnicianScreen(
                      userId: widget.userId,
                      serviceType: widget.serviceType,
                      lat: _selected.latitude,
                      lng: _selected.longitude,
                      orderId: '',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
              ),
              child: const Text(
                "تأكيد الموقع",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
