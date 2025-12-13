import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/socket_service.dart';

class TechnicianTrackingScreen extends StatefulWidget {
  final String orderId;

  const TechnicianTrackingScreen({super.key, required this.orderId});

  @override
  State<TechnicianTrackingScreen> createState() =>
      _TechnicianTrackingScreenState();
}

class _TechnicianTrackingScreenState extends State<TechnicianTrackingScreen> {
  late GoogleMapController _mapController;
  final SocketService socketService = SocketService();

  LatLng techPos = const LatLng(30.05, 31.23);

  @override
  void initState() {
    super.initState();

    socketService.connect(widget.orderId);

    socketService.onTechnicianLocation((lat, lng) {
      setState(() {
        techPos = LatLng(lat, lng);
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLng(techPos),
      );
    });
  }

  @override
  void dispose() {
    socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تتبع الفني")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: techPos, zoom: 15),
        markers: {
          Marker(
            markerId: const MarkerId("tech"),
            position: techPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(20),
          )
        },
        onMapCreated: (c) => _mapController = c,
      ),
    );
  }
}
