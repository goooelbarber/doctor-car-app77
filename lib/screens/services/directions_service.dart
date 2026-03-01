import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsResult {
  final List<LatLng> polyline;
  final int durationSeconds;
  final int distanceMeters;

  DirectionsResult({
    required this.polyline,
    required this.durationSeconds,
    required this.distanceMeters,
  });
}

class DirectionsService {
  static const String _baseUrl =
      "https://maps.googleapis.com/maps/api/directions/json";

  static const String _apiKey = "PUT_YOUR_GOOGLE_MAPS_KEY_HERE";

  static Future<DirectionsResult> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url = "$_baseUrl?origin=${origin.latitude},${origin.longitude}"
        "&destination=${destination.latitude},${destination.longitude}"
        "&key=$_apiKey&language=ar";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception("فشل تحميل المسار");
    }

    final data = jsonDecode(res.body);

    if (data["routes"].isEmpty) {
      throw Exception("لا يوجد مسار متاح");
    }

    final route = data["routes"][0];
    final leg = route["legs"][0];

    final polyline = _decodePolyline(
      route["overview_polyline"]["points"],
    );

    return DirectionsResult(
      polyline: polyline,
      durationSeconds: leg["duration"]["value"],
      distanceMeters: leg["distance"]["value"],
    );
  }

  // Polyline decoder
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
