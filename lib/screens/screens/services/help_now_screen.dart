import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: unused_import
import 'package:geolocator/geolocator.dart';

class HelpNowScreen extends StatefulWidget {
  const HelpNowScreen({super.key});

  @override
  State<HelpNowScreen> createState() => _HelpNowScreenState();
}

class _HelpNowScreenState extends State<HelpNowScreen> {
  // ignore: unused_field
  GoogleMapController? _mapController;

  final LatLng cairo = const LatLng(30.0444, 31.2357);

  final Set<Marker> markers = {
    Marker(
      markerId: const MarkerId("cairo_marker"),
      position: const LatLng(30.0444, 31.2357),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'طلب مساعدة الآن',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🌍 Google Map
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: cairo,
                  zoom: 13,
                ),
                markers: markers,
                onMapCreated: (controller) => _mapController = controller,
              ),
            ),

            const SizedBox(height: 10),

            // قائمة الخدمات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  _buildServiceTile(
                    title: 'فحص الأعطال الذكي',
                    subtitle: 'تحليل العطل واقتراح السبب تلقائياً.',
                    icon: Icons.search,
                    color: Colors.blue.shade800,
                    onTap: () => _showServiceMessage('فحص الأعطال الذكي'),
                  ),
                  _buildServiceTile(
                    title: 'خدمة مساعدة الطريق السريعة',
                    subtitle: 'طلب فوري لميكانيكي أو ونش بناءً على موقعك.',
                    icon: Icons.handyman,
                    color: Colors.orange,
                    onTap: () =>
                        _showServiceMessage('خدمة مساعدة الطريق السريعة'),
                  ),
                  _buildServiceTile(
                    title: 'فني متنقل',
                    subtitle: 'فني يصل لموقعك مباشرة ويتتبعه على الخريطة.',
                    icon: Icons.directions_bike,
                    color: Colors.purple,
                    onTap: () => _showServiceMessage('فني متنقل'),
                  ),
                  _buildServiceTile(
                    title: 'تزويد الوقود الطارئ',
                    subtitle: 'تحديد نوع وكمية الوقود المطلوبة.',
                    icon: Icons.local_gas_station,
                    color: Colors.lightBlue,
                    onTap: () => _showServiceMessage('تزويد الوقود الطارئ'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () => _showServiceMessage('طلب الخدمة الآن'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'طلب الخدمة الآن',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // 🔹 عنصر الخدمة
  Widget _buildServiceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_back_ios, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 رسالة SnackBar
  void _showServiceMessage(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم النقر على خدمة: $name')),
    );
  }
}
