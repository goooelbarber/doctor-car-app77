import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrent({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
    bool openSettingsIfOff = true,
  }) async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      if (openSettingsIfOff) {
        await Geolocator.openLocationSettings();
      }
      throw Exception("SERVICE_OFF");
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) throw Exception("DENIED");
    if (perm == LocationPermission.deniedForever)
      throw Exception("DENIED_FOREVER");

    return Geolocator.getCurrentPosition(
      desiredAccuracy: accuracy,
      timeLimit: timeLimit,
    );
  }
}
