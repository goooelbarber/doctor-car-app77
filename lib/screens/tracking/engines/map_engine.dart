import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class MapEngine {
  /// Trail points (History of technician movement)
  final List<LatLng> trail = [];

  /// Custom map style
  String? darkMapStyle;
  String? lightMapStyle;

  /// Icons
  BitmapDescriptor? userIcon;
  BitmapDescriptor? driverIcon;

  /// تحميل أيقونات مخصصة (اختياري)
  Future<void> loadIcons() async {
    userIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    driverIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
  }

  /// تحميل Uber Map Style
  Future<void> loadMapStyles() async {
    darkMapStyle = await rootBundle.loadString(
      "assets/map_styles/uber_dark.json",
    );

    lightMapStyle = await rootBundle.loadString(
      "assets/map_styles/uber_light.json",
    );
  }

  /// إضافة نقطة جديدة للـ Trail
  void addTrailPoint(LatLng pos) {
    if (trail.isEmpty || trail.last != pos) {
      trail.add(pos);
    }
  }

  /// بناء Markers
  Set<Marker> buildMarkers({
    required LatLng userLocation,
    required LatLng? driverLocation,
    required double rotation,
  }) {
    final markers = <Marker>{};

    // Marker المستخدم
    markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: userLocation,
        icon: userIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Marker الفني
    if (driverLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: driverLocation,
          icon: driverIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          flat: true,
          rotation: rotation,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    return markers;
  }

  /// بناء Polyline للـ Trail فقط (بدون Directions API)
  Set<Polyline> buildPolylines() {
    if (trail.length < 2) return {};

    return {
      Polyline(
        polylineId: const PolylineId("trail"),
        points: trail,
        width: 6,
        color: Colors.amber,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      )
    };
  }

  /// تطبيق MapStyle على GoogleMapController
  void applyDarkMap(GoogleMapController controller) {
    if (darkMapStyle != null) {
      controller.setMapStyle(darkMapStyle);
    }
  }

  void applyLightMap(GoogleMapController controller) {
    if (lightMapStyle != null) {
      controller.setMapStyle(lightMapStyle);
    }
  }
}
