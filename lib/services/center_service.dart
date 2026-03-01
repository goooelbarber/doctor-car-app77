import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/center_model.dart';

class CenterService {
  static Future<List<CenterModel>> fetchNearby({
    required double lat,
    required double lng,
    int limit = 50,
    double radiusKm = 20, // ✅ جديد
  }) async {
    final url = ApiConfig.nearbyCenters(lat: lat, lng: lng, limit: limit);
    final uri = Uri.parse(url);

    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception("Failed to load centers: ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) return [];

    final radiusMeters = radiusKm * 1000.0;

    // ✅ نطلع مراكز صالحة + عندها Coordinates
    final centers = decoded
        .whereType<Map<String, dynamic>>()
        .map(CenterModel.fromJson)
        .where((c) =>
            c.id.isNotEmpty &&
            c.name.isNotEmpty &&
            c.lat != null &&
            c.lng != null)
        .toList();

    // ✅ حساب المسافة + فلترة + ترتيب
    final filtered = <CenterModel>[];

    for (final c in centers) {
      final d = Geolocator.distanceBetween(lat, lng, c.lat!, c.lng!);

      // مهم: لو عندك distanceMeters داخل CenterModel استخدمه، لو مش موجود سيبه
      // وفلتر/رتب هنا
      if (d <= radiusMeters) {
        filtered.add(c.copyWith(distanceMeters: d)); // لازم تكون عندك copyWith
      }
    }

    filtered.sort((a, b) {
      final da = a.distanceMeters ?? double.infinity;
      final db = b.distanceMeters ?? double.infinity;
      return da.compareTo(db);
    });

    return filtered;
  }

  static Future<List<CenterModel>> fetchAll() async {
    final uri = Uri.parse(ApiConfig.centers);

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception("Failed to load centers: ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CenterModel.fromJson)
        .where((c) => c.id.isNotEmpty && c.name.isNotEmpty)
        .toList();
  }
}
