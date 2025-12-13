import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleRoadsService {
  static const String apiKey = "YOUR_API_KEY";

  static Future<List<LatLng>> snapToRoad(List<LatLng> points) async {
    final url = Uri.parse(
      "https://roads.googleapis.com/v1/snapToRoads?interpolate=true&key=$apiKey&path=${points.map((p) => '${p.latitude},${p.longitude}').join('|')}",
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    return (data["snappedPoints"] as List)
        .map((p) =>
            LatLng(p["location"]["latitude"], p["location"]["longitude"]))
        .toList();
  }
}
