import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef PositionUpdateCallback = void Function(LatLng pos);
typedef RotationUpdateCallback = void Function(double bearing);

class MotionEngine {
  AnimationController? ctrl;
  Animation<LatLng>? anim;

  /// تحريك السيارة من old → new
  void animateDriver({
    required TickerProvider vsync,
    required LatLng oldPos,
    required LatLng newPos,
    required PositionUpdateCallback onMove,
    required RotationUpdateCallback onRotate,
  }) {
    ctrl?.dispose();
    ctrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 900),
    );

    anim = LatLngTween(begin: oldPos, end: newPos).animate(
      CurvedAnimation(parent: ctrl!, curve: Curves.easeOut),
    );

    // الاتجاه (rotation)
    final bearing = _bearingBetween(oldPos, newPos);
    onRotate(bearing);

    ctrl!.addListener(() {
      onMove(anim!.value);
    });

    ctrl!.forward();
  }

  double _bearingBetween(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  void dispose() {
    ctrl?.dispose();
  }
}

/// Tween لتحريك LatLng
class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    return LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}
