class CenterModel {
  final String id;
  final String name;
  final double rating;
  final String imageUrl;
  final String address;

  /// Coordinates (nullable)
  final double? lat;
  final double? lng;

  /// From API (optional)
  final double? distanceKm;
  final String distanceTextFromApi;

  /// Computed/local or from API (meters)
  final double? distanceMeters;

  /// Services / Types
  final List<String> services;

  const CenterModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.imageUrl,
    required this.address,
    this.lat,
    this.lng,
    this.distanceKm,
    this.distanceTextFromApi = "",
    this.distanceMeters,
    this.services = const [],
  });

  // ---------------------------
  // Helpers
  // ---------------------------

  bool get hasValidCoords =>
      lat != null &&
      lng != null &&
      lat!.isFinite &&
      lng!.isFinite &&
      lat!.abs() <= 90 &&
      lng!.abs() <= 180;

  /// Prefer meters -> API text -> km
  String get distanceText {
    final dm = distanceMeters;
    if (dm != null && dm.isFinite && dm > 0) {
      final km = dm / 1000.0;
      if (km < 1) return "${dm.round()} م";
      return "${km.toStringAsFixed(km < 10 ? 1 : 0)} كم";
    }

    final apiText = distanceTextFromApi.trim();
    if (apiText.isNotEmpty) return apiText;

    final dk = distanceKm;
    if (dk != null && dk.isFinite && dk > 0) {
      if (dk < 1) return "${(dk * 1000).round()} م";
      return "${dk.toStringAsFixed(dk < 10 ? 1 : 0)} كم";
    }

    return "";
  }

  double? get computedDistanceKm {
    final dm = distanceMeters;
    if (dm != null && dm.isFinite && dm > 0) return dm / 1000.0;

    final dk = distanceKm;
    if (dk != null && dk.isFinite && dk > 0) return dk;

    return null;
  }

  Uri? get googleMapsUri {
    if (!hasValidCoords) return null;
    return Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng");
  }

  CenterModel copyWith({
    String? id,
    String? name,
    double? rating,
    String? imageUrl,
    String? address,
    double? lat,
    double? lng,
    double? distanceKm,
    String? distanceTextFromApi,
    double? distanceMeters,
    List<String>? services,
  }) {
    return CenterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      distanceKm: distanceKm ?? this.distanceKm,
      distanceTextFromApi: distanceTextFromApi ?? this.distanceTextFromApi,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      services: services ?? this.services,
    );
  }

  // ---------------------------
  // Parsing utilities
  // ---------------------------

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static String _toStringSafe(dynamic v) => (v ?? "").toString();

  static List<String> _toStringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    if (v is String && v.trim().isNotEmpty) {
      // allow "a,b,c"
      return v
          .split(",")
          .map((e) => e.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  static double _clampRating(double value) {
    if (!value.isFinite) return 0.0;
    if (value < 0) return 0.0;
    if (value > 5) return 5.0;
    return value;
  }

  static String _pickFirstNonEmptyString(List<dynamic> candidates) {
    for (final c in candidates) {
      final s = _toStringSafe(c).trim();
      if (s.isNotEmpty) return s;
    }
    return "";
  }

  // ---------------------------
  // Factory
  // ---------------------------

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    // -------- id --------
    final rawId = _pickFirstNonEmptyString([json["_id"], json["id"]]);
    final id = rawId.isNotEmpty ? rawId : "";

    // -------- name/address --------
    final name = _toStringSafe(json["name"]).trim();
    final address = _pickFirstNonEmptyString([
      json["address"],
      json["fullAddress"],
      json["locationName"],
      json["city"],
      json["governorate"],
    ]).trim();

    // -------- image --------
    final imageUrl = _pickFirstNonEmptyString([
      json["imageUrl"],
      json["image"],
      json["logo"],
      json["photo"],
      json["cover"],
    ]).trim();

    // -------- rating --------
    final rating = _clampRating(_toDouble(json["rating"]) ?? 0.0);

    // -------- coords (support many shapes) --------
    double? lat = _toDouble(json["lat"]) ?? _toDouble(json["latitude"]);
    double? lng = _toDouble(json["lng"]) ??
        _toDouble(json["longitude"]) ??
        _toDouble(json["lon"]);

    // location object support
    if ((lat == null || lng == null) && json["location"] is Map) {
      final loc = json["location"] as Map;

      // location: { lat, lng } or { latitude, longitude }
      lat ??= _toDouble(loc["lat"]) ?? _toDouble(loc["latitude"]);
      lng ??= _toDouble(loc["lng"]) ??
          _toDouble(loc["longitude"]) ??
          _toDouble(loc["lon"]);

      // GeoJSON: { coordinates: [lng, lat] }
      final coords = loc["coordinates"];
      if ((lat == null || lng == null) &&
          coords is List &&
          coords.length >= 2) {
        lng ??= _toDouble(coords[0]);
        lat ??= _toDouble(coords[1]);
      }
    }

    // sanity check: remove invalid coords
    if (lat != null && (!lat.isFinite || lat.abs() > 90)) lat = null;
    if (lng != null && (!lng.isFinite || lng.abs() > 180)) lng = null;

    // -------- distance --------
    // Prefer distanceMeters, else try "distance" heuristics, else distanceKm
    double? distanceMeters = _toDouble(json["distanceMeters"]);

    if (distanceMeters == null) {
      final dAny = _toDouble(json["distance"]);
      if (dAny != null && dAny.isFinite && dAny > 0) {
        // heuristic: if it's < 500 assume km, else meters
        distanceMeters = dAny < 500 ? dAny * 1000.0 : dAny;
      }
    }

    final distanceKm = _toDouble(json["distanceKm"]) ??
        ((distanceMeters != null &&
                distanceMeters.isFinite &&
                distanceMeters > 0)
            ? (distanceMeters / 1000.0)
            : null);

    final distanceTextFromApi = _pickFirstNonEmptyString(
        [json["distanceText"], json["distanceTextAr"]]);

    // -------- services --------
    final services = _toStringList(json["services"]).isNotEmpty
        ? _toStringList(json["services"])
        : _toStringList(json["types"]);

    return CenterModel(
      id: id,
      name: name,
      rating: rating,
      imageUrl: imageUrl,
      address: address,
      lat: lat,
      lng: lng,
      distanceKm: distanceKm,
      distanceTextFromApi: distanceTextFromApi,
      distanceMeters: distanceMeters,
      services: services,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "rating": rating,
      "imageUrl": imageUrl,
      "address": address,
      "lat": lat,
      "lng": lng,
      "distanceKm": distanceKm,
      "distanceText": distanceTextFromApi,
      "distanceMeters": distanceMeters,
      "services": services,
    };
  }

  // ---------------------------
  // Equality
  // ---------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CenterModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
