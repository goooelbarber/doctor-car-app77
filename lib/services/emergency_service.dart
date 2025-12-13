import 'package:geolocator/geolocator.dart';

class EmergencyService {
  static Future<Position> getLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  static Future<void> sendEmergencyTeam(Position location) async {
    // 🔥 جاهز لربط API
    print(
        "إرسال إسعاف ووَنْش إلى: ${location.latitude}, ${location.longitude}");
  }
}
