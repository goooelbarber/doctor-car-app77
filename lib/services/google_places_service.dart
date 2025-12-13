import 'dart:convert';
import 'package:http/http.dart' as http;

/// خدمة بسيطة للتعامل مع Google Places
class GooglePlacesService {
  GooglePlacesService(this.apiKey);

  final String apiKey;

  /// Autocomplete (اقتراحات البحث)
  Future<List<Map<String, dynamic>>> autocomplete(String input) async {
    if (input.isEmpty) return [];

    final url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$input"
        "&key=$apiKey"
        "&language=ar"
        "&components=country:eg"; // مصر فقط (اختياري)

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    if (data["status"] != "OK") return [];

    return List<Map<String, dynamic>>.from(data["predictions"]);
  }

  /// الحصول على إحداثيات مكان معيّن
  Future<LatLngResult?> getPlaceLatLng(String placeId) async {
    final url = "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&key=$apiKey";

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    if (data["status"] != "OK") return null;

    final loc = data["result"]["geometry"]["location"];
    return LatLngResult(
      lat: (loc["lat"] as num).toDouble(),
      lng: (loc["lng"] as num).toDouble(),
      name: data["result"]["name"] ?? "",
      address: data["result"]["formatted_address"] ?? "",
    );
  }
}

/// موديل بسيط للنتيجة
class LatLngResult {
  final double lat;
  final double lng;
  final String name;
  final String address;

  LatLngResult({
    required this.lat,
    required this.lng,
    required this.name,
    required this.address,
  });
}
