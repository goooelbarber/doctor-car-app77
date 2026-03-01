import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// يرجع Position أو null لو المستخدم رفض أو الخدمة مقفولة
  static Future<Position?> getBestEffortPosition() async {
    // Request permission
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) return null;

    // Check service enabled
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    // Try last known first (fast)
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) return last;

    // Otherwise get current (with timeout)
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 8),
    );
  }
}
