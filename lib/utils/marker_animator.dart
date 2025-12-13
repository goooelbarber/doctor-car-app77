import 'dart:async';
// ignore: unused_import
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerAnimator {
  static Timer? _timer;

  static void animateMarker({
    required LatLng from,
    required LatLng to,
    required Function(LatLng) onUpdate,
    int durationMs = 1500,
  }) {
    _timer?.cancel();

    const int ticks = 60;
    int currentTick = 0;

    _timer = Timer.periodic(
      Duration(milliseconds: (durationMs / ticks).round()),
      (timer) {
        currentTick++;
        if (currentTick >= ticks) {
          timer.cancel();
        }

        double t = currentTick / ticks;
        double lat = from.latitude + (to.latitude - from.latitude) * t;
        double lng = from.longitude + (to.longitude - from.longitude) * t;

        onUpdate(LatLng(lat, lng));
      },
    );
  }
}
