import 'dart:math' as math;
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

  /// إعدادات Uber-like
  final int maxTrailPoints;
  final double minTrailMoveMeters;

  MapEngine({
    this.maxTrailPoints = 120,
    this.minTrailMoveMeters = 2.0,
  });

  /// تحميل أيقونات افتراضية (Fallback)
  Future<void> loadIcons() async {
    userIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    driverIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
  }

  /// تحميل أيقونات من assets (اختياري)
  /// مثال:
  /// await mapEngine.setDriverIconFromAsset("assets/images/car.png");
  Future<void> setDriverIconFromAsset(
    String assetPath, {
    int sizePx = 96,
  }) async {
    try {
      driverIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(),
        assetPath,
      );
    } catch (_) {
      // fallback
      driverIcon ??=
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }

  Future<void> setUserIconFromAsset(
    String assetPath, {
    int sizePx = 96,
  }) async {
    try {
      userIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(),
        assetPath,
      );
    } catch (_) {
      userIcon ??=
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
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

  /// مسافة بين نقطتين بالمتر (Haversine)
  double _distanceMeters(LatLng a, LatLng b) {
    const R = 6371e3;
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return R * c;
  }

  /// إضافة نقطة جديدة للـ Trail (مع فلترة jitter + limit)
  void addTrailPoint(LatLng pos) {
    if (trail.isEmpty) {
      trail.add(pos);
      return;
    }

    // ignore micro-moves
    final last = trail.last;
    final d = _distanceMeters(last, pos);
    if (d < minTrailMoveMeters) return;

    trail.add(pos);

    // limit length for performance
    if (trail.length > maxTrailPoints) {
      trail.removeRange(0, trail.length - maxTrailPoints);
    }
  }

  void clearTrail() => trail.clear();

  /// بناء Markers (Uber-like: driver marker flat + anchored center)
  Set<Marker> buildMarkers({
    required LatLng userLocation,
    required LatLng? driverLocation,
    required double rotation,
  }) {
    final markers = <Marker>{};

    markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: userLocation,
        icon: userIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.9),
      ),
    );

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
          zIndex: 5,
        ),
      );
    }

    return markers;
  }

  /// Polyline Uber-like (طبقتين: outline + main)
  Set<Polyline> buildPolylines() {
    if (trail.length < 2) return {};

    // outer (outline)
    final outer = Polyline(
      polylineId: const PolylineId("trail_outer"),
      points: trail,
      width: 10,
      color: Colors.black.withOpacity(0.55),
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      zIndex: 1,
    );

    // inner (main)
    final inner = Polyline(
      polylineId: const PolylineId("trail_inner"),
      points: trail,
      width: 6,
      color: Colors.amber,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      zIndex: 2,
    );

    return {outer, inner};
  }

  /// تطبيق MapStyle على GoogleMapController
  Future<void> applyDarkMap(GoogleMapController controller) async {
    if (darkMapStyle != null) {
      await controller.setMapStyle(darkMapStyle);
    }
  }

  Future<void> applyLightMap(GoogleMapController controller) async {
    if (lightMapStyle != null) {
      await controller.setMapStyle(lightMapStyle);
    }
  }
}
