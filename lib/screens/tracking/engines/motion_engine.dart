import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef PositionUpdateCallback = void Function(LatLng pos);
typedef RotationUpdateCallback = void Function(double bearing);

class MotionEngine {
  AnimationController? _ctrl;
  Animation<LatLng>? _posAnim;

  double _lastBearing = 0.0;

  /// إعدادات قابلة للتعديل حسب إحساس Uber
  final Duration minDuration;
  final Duration maxDuration;

  /// أقل مسافة (متر) نعتبرها حركة فعلية — لتقليل jitter
  final double minMoveMeters;

  /// درجة تنعيم الاتجاه (0..1)
  /// 0 = بدون تنعيم، 1 = تنعيم عالي (أبطأ في اللف)
  final double bearingSmoothing;

  /// منحنى الحركة
  final Curve moveCurve;

  MotionEngine({
    this.minDuration = const Duration(milliseconds: 450),
    this.maxDuration = const Duration(milliseconds: 1200),
    this.minMoveMeters = 1.5,
    this.bearingSmoothing = 0.35,
    this.moveCurve = Curves.easeOutCubic,
  });

  /// تحريك السيارة من old → new (Uber-like)
  ///
  /// - onMove: يُستدعى مع كل تحديث لموقع الماركر
  /// - onRotate: يُستدعى لتحديث زاوية دوران الماركر
  /// - onComplete: اختياري عند نهاية الحركة
  void animateDriver({
    required TickerProvider vsync,
    required LatLng oldPos,
    required LatLng newPos,
    required PositionUpdateCallback onMove,
    required RotationUpdateCallback onRotate,
    VoidCallback? onComplete,
  }) {
    // 1) تجاهل التحديثات الصغيرة جداً
    final dist = _distanceMeters(oldPos, newPos);
    if (dist < minMoveMeters) return;

    // 2) وقف أي أنيميشن شغال قبل ما نبدأ واحد جديد
    _ctrl?.stop();
    _ctrl?.dispose();

    final duration = _durationFromDistance(dist);

    _ctrl = AnimationController(vsync: vsync, duration: duration);

    _posAnim = LatLngTween(begin: oldPos, end: newPos).animate(
      CurvedAnimation(parent: _ctrl!, curve: moveCurve),
    );

    // 3) Bearing (الاتجاه) + تنعيم
    final targetBearing = _bearingBetween(oldPos, newPos);
    final smoothBearing =
        _smoothAngleDegrees(_lastBearing, targetBearing, bearingSmoothing);

    _lastBearing = smoothBearing;
    onRotate(smoothBearing);

    // 4) تحديث الموضع أثناء الأنيميشن
    _ctrl!.addListener(() {
      onMove(_posAnim!.value);
    });

    // 5) عند النهاية: ثبّت على newPos وحدث bearing النهائي (بدون “قطع”)
    _ctrl!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onMove(newPos);

        final finalBearing =
            _smoothAngleDegrees(_lastBearing, targetBearing, 0.15);
        _lastBearing = finalBearing;
        onRotate(finalBearing);

        onComplete?.call();
      }
    });

    _ctrl!.forward();
  }

  /// مدة الحركة بناء على المسافة (متر)
  /// إحساس Uber: المسافات الصغيرة تتحرك أسرع، الكبيرة أبطأ بس مش زيادة
  Duration _durationFromDistance(double meters) {
    // metersPerSecond تقديري لتحكم في الإحساس
    const double metersPerSecond = 18.0; // ~65km/h
    final ms = (meters / metersPerSecond * 1000).round();

    final clampedMs =
        ms.clamp(minDuration.inMilliseconds, maxDuration.inMilliseconds);
    return Duration(milliseconds: clampedMs);
  }

  /// حساب bearing بين نقطتين (0..360)
  double _bearingBetween(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  /// تنعيم دوران الزاوية مع مراعاة لفّ 360
  double _smoothAngleDegrees(double current, double target, double alpha) {
    alpha = alpha.clamp(0.0, 1.0);

    // فرق زاوية بأقصر طريق (-180..180)
    double diff = ((target - current + 540) % 360) - 180;
    return (current + diff * alpha + 360) % 360;
  }

  /// مسافة تقريبية بالمتر (Haversine)
  double _distanceMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0; // meters
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);

    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);

  void dispose() {
    _ctrl?.dispose();
    _ctrl = null;
    _posAnim = null;
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
