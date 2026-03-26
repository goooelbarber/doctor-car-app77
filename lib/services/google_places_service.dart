import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;

/// ✅ Uber-like Google Places helper
/// - Uri.https (Encoding صح)
/// - Timeout + error handling
/// - Session Token (مهم للتكلفة/الدقة)
/// - Fields في Place Details (أخف وأسرع)
/// - Country restriction optional
class GooglePlacesService {
  GooglePlacesService(
    this.apiKey, {
    http.Client? client,
    this.country = "eg",
    this.language = "ar",
    Duration timeout = const Duration(seconds: 10),
    this.debugLog = false,
  })  : _client = client ?? http.Client(),
        _timeout = timeout;

  final String apiKey;
  final http.Client _client;
  final Duration _timeout;

  /// مصر فقط (غيرها لو حابب)
  final String country;

  /// لغة النتائج
  final String language;

  /// ✅ اطبع Errors في Console (مفيد للتشخيص)
  final bool debugLog;

  void _log(String msg) {
    if (!debugLog) return;
    if (kDebugMode) {
      // ignore: avoid_print
      print("[GooglePlacesService] $msg");
    }
  }

  /// Autocomplete
  /// ✅ مهم: sessionToken يفضل يبقى ثابت أثناء جلسة البحث
  Future<List<Map<String, dynamic>>> autocomplete(
    String input, {
    String? sessionToken,
    LatLngBias? locationBias,
    int? radiusMeters, // bias radius
  }) async {
    final q = input.trim();
    if (q.isEmpty) return [];

    if (apiKey.trim().isEmpty) {
      _log("API key is empty");
      return [];
    }

    try {
      final params = <String, String>{
        "input": q,
        "key": apiKey.trim(),
        "language": language,
        "components": "country:$country",
        if (sessionToken != null && sessionToken.isNotEmpty)
          "sessiontoken": sessionToken,
        // ✅ location bias (اختياري لتحسين الدقة زي أوبر)
        if (locationBias != null)
          "location": "${locationBias.lat},${locationBias.lng}",
        if (locationBias != null && radiusMeters != null)
          "radius": radiusMeters.toString(),
        if (locationBias != null) "strictbounds": "false",
      };

      final uri = Uri.https(
        "maps.googleapis.com",
        "/maps/api/place/autocomplete/json",
        params,
      );

      final res = await _client.get(uri).timeout(_timeout);

      if (res.statusCode != 200) {
        _log("HTTP ${res.statusCode}: ${res.body}");
        return [];
      }

      final data = jsonDecode(res.body);
      final status = (data["status"] ?? "").toString();

      if (status == "ZERO_RESULTS") return [];

      if (status != "OK") {
        final err = (data["error_message"] ?? "").toString();
        _log("Autocomplete status=$status, error=$err, body=${res.body}");
        return [];
      }

      final preds = data["predictions"];
      if (preds is! List) return [];

      return List<Map<String, dynamic>>.from(preds);
    } on TimeoutException {
      _log("Autocomplete timeout");
      return [];
    } catch (e) {
      _log("Autocomplete exception: $e");
      return [];
    }
  }

  /// Place Details -> LatLng + address + name
  /// ✅ fields لتسريع وتقليل payload
  Future<LatLngResult?> getPlaceLatLng(
    String placeId, {
    String? sessionToken,
  }) async {
    final id = placeId.trim();
    if (id.isEmpty) return null;

    if (apiKey.trim().isEmpty) {
      _log("API key is empty");
      return null;
    }

    try {
      final params = <String, String>{
        "place_id": id,
        "key": apiKey.trim(),
        "language": language,
        // ✅ fields مهمة جدًا
        "fields": "geometry/location,name,formatted_address",
        if (sessionToken != null && sessionToken.isNotEmpty)
          "sessiontoken": sessionToken,
      };

      final uri = Uri.https(
        "maps.googleapis.com",
        "/maps/api/place/details/json",
        params,
      );

      final res = await _client.get(uri).timeout(_timeout);

      if (res.statusCode != 200) {
        _log("HTTP ${res.statusCode}: ${res.body}");
        return null;
      }

      final data = jsonDecode(res.body);
      final status = (data["status"] ?? "").toString();

      if (status != "OK") {
        final err = (data["error_message"] ?? "").toString();
        _log("Details status=$status, error=$err, body=${res.body}");
        return null;
      }

      final result = data["result"];
      if (result is! Map) return null;

      final geo = result["geometry"];
      if (geo is! Map) return null;

      final loc = geo["location"];
      if (loc is! Map) return null;

      final lat = (loc["lat"] as num?)?.toDouble();
      final lng = (loc["lng"] as num?)?.toDouble();
      if (lat == null || lng == null) return null;

      return LatLngResult(
        lat: lat,
        lng: lng,
        name: (result["name"] ?? "").toString(),
        address: (result["formatted_address"] ?? "").toString(),
      );
    } on TimeoutException {
      _log("Details timeout");
      return null;
    } catch (e) {
      _log("Details exception: $e");
      return null;
    }
  }

  /// اختياري: اقفل الـ client لو انت عامل instance بنفسك وعايز تنظف
  void dispose() {
    _client.close();
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

/// Bias helper
class LatLngBias {
  final double lat;
  final double lng;
  const LatLngBias(this.lat, this.lng);
}
