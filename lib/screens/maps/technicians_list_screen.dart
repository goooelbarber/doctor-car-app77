import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class TechniciansListScreen extends StatefulWidget {
  final List<String> selectedServices;

  const TechniciansListScreen({
    super.key,
    required this.selectedServices,
  });

  @override
  State<TechniciansListScreen> createState() => _TechniciansListScreenState();
}

class _TechniciansListScreenState extends State<TechniciansListScreen> {
  bool isLoading = true;

  List technicians = [];
  double userLat = 30.0444;
  double userLng = 31.2357;

  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getLocation();
    _fetchTechnicians();
  }

  Future<void> _getLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLat = pos.latitude;
        userLng = pos.longitude;
      });

      _updateMarkers();
    } catch (_) {}
  }

  Future<void> _fetchTechnicians() async {
    try {
      List allTechs = [];

      for (final s in widget.selectedServices) {
        final res = await http
            .get(Uri.parse('${ApiService.baseUrl}/technicians?service=$s'));

        if (res.statusCode == 200) {
          allTechs.addAll(jsonDecode(res.body));
        }
      }

      setState(() {
        technicians = allTechs;
        isLoading = false;
      });

      _updateMarkers();
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _updateMarkers() {
    Set<Marker> m = {};

    // موقع المستخدم
    m.add(
      Marker(
        markerId: const MarkerId("user"),
        position: LatLng(userLat, userLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // الفنيين
    for (var t in technicians) {
      m.add(
        Marker(
          markerId: MarkerId("tech_${t['id'] ?? t['name']}"),
          position: LatLng(
            (t['lat'] ?? userLat).toDouble(),
            (t['lng'] ?? userLng).toDouble(),
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }

    setState(() => markers = m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفنيين المتاحين'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(userLat, userLng),
                      zoom: 12.5,
                    ),
                    markers: markers,
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
                ),

                // قائمة الفنيين
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: technicians.length,
                    itemBuilder: (context, i) {
                      final t = technicians[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.engineering,
                              color: Colors.orange),
                          title: Text(t['name'] ?? 'فني'),
                          subtitle: Text(
                              'الخدمة: ${t['serviceType'] ?? 'غير محدد'}\nالتقييم: ⭐ ${t['rating'] ?? 4.5}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // TODO: اختر الفني
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                            ),
                            child: const Text('اختيار'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
