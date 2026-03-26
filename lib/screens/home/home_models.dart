// PATH: lib/screens/home/home_models.dart
part of '../home_screen.dart';

// =======================
// Models
// =======================
class OfferItem {
  final String title;
  final String image;
  final String distance;
  final String until;

  const OfferItem({
    required this.title,
    required this.image,
    required this.distance,
    required this.until,
  });
}

// -----------------------
// Review model (PRO)
// -----------------------
class ReviewItem {
  final String name;
  final double rating;
  final String comment;
  final DateTime? date;

  const ReviewItem({
    required this.name,
    required this.rating,
    required this.comment,
    this.date,
  });

  static double _num(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return null;

    // unix timestamp support
    final asInt = int.tryParse(s);
    if (asInt != null) {
      // if seconds -> *1000
      final ms = asInt < 1000000000000 ? asInt * 1000 : asInt;
      return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
    }

    return DateTime.tryParse(s);
  }

  factory ReviewItem.fromJson(Map<String, dynamic> j) {
    final name =
        (j["name"] ?? j["userName"] ?? j["user"] ?? "User").toString().trim();

    return ReviewItem(
      name: name.isEmpty ? "User" : name,
      rating: _num(j["rating"], fallback: 0).clamp(0, 5).toDouble(),
      comment:
          (j["comment"] ?? j["text"] ?? j["review"] ?? "").toString().trim(),
      date: _date(j["date"] ?? j["createdAt"] ?? j["time"]),
    );
  }

  /// مثال: "2026-02-14"
  String get dateShort {
    final d = date;
    if (d == null) return "";
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }
}

// -----------------------
// Center model (ULTRA PRO)
// -----------------------
class CenterItem {
  final String id;
  final String name;
  final double rating;

  /// main image: asset OR url
  final String image;

  final double? lat;
  final double? lng;

  /// distance in meters (server or local)
  final double? distanceMeters;

  /// optional
  final String? phone;
  final String? address;

  /// open state
  final bool? openNow;

  /// e.g. "10:00 - 22:00"
  final String? openHours;

  /// extra media / gallery
  final List<String> gallery;

  /// services list
  final List<String> services;

  /// tags / specialties
  final List<String> tags;

  /// reviews preview
  final List<ReviewItem> reviews;

  /// meta (اختياري جدًا)
  final String? governorate;
  final String? city;
  final String? source;
  final List<String> types;

  const CenterItem({
    required this.id,
    required this.name,
    required this.rating,
    required this.image,
    this.lat,
    this.lng,
    this.distanceMeters,
    this.phone,
    this.address,
    this.openNow,
    this.openHours,
    this.gallery = const [],
    this.services = const [],
    this.tags = const [],
    this.reviews = const [],
    this.governorate,
    this.city,
    this.source,
    this.types = const [],
  });

  bool get hasCoords => lat != null && lng != null;

  /// أفضل صورة نعرضها: image لو موجود وإلا أول صورة في gallery
  String get bestImage {
    final img = image.trim();
    if (img.isNotEmpty) return img;
    if (gallery.isNotEmpty) return gallery.first;
    return "";
  }

  /// Initials fallback للـ Avatar
  String get initials {
    final n = name.trim();
    if (n.isEmpty) return "C";
    final parts =
        n.split(RegExp(r"\s+")).where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return "C";
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    final a = parts.first.characters.take(1).toString();
    final b = parts[1].characters.take(1).toString();
    return (a + b).toUpperCase();
  }

  String get distanceText {
    if (distanceMeters == null) return "";
    final km = distanceMeters! / 1000.0;
    if (km < 1) return "${distanceMeters!.round()} م";
    return "${km.toStringAsFixed(km < 10 ? 1 : 0)} كم";
  }

  CenterItem copyWith({
    String? id,
    String? name,
    double? rating,
    String? image,
    double? lat,
    double? lng,
    double? distanceMeters,
    String? phone,
    String? address,
    bool? openNow,
    String? openHours,
    List<String>? gallery,
    List<String>? services,
    List<String>? tags,
    List<ReviewItem>? reviews,
    String? governorate,
    String? city,
    String? source,
    List<String>? types,
  }) {
    return CenterItem(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      image: image ?? this.image,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      openNow: openNow ?? this.openNow,
      openHours: openHours ?? this.openHours,
      gallery: gallery ?? this.gallery,
      services: services ?? this.services,
      tags: tags ?? this.tags,
      reviews: reviews ?? this.reviews,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      source: source ?? this.source,
      types: types ?? this.types,
    );
  }

  // ---------- parsing helpers ----------
  static double _num(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static bool? _bool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    final s = v.toString().toLowerCase().trim();
    if (s == "true" || s == "1" || s == "yes") return true;
    if (s == "false" || s == "0" || s == "no") return false;
    return null;
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return null;
    return s;
  }

  static List<String> _stringList(dynamic v) {
    if (v == null) return const [];
    if (v is List) {
      return v
          .map((e) => e?.toString().trim() ?? "")
          .where((s) => s.isNotEmpty && s.toLowerCase() != "null")
          .toList();
    }
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return const [];
    if (s.contains(",")) {
      return s
          .split(",")
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [s];
  }

  static List<ReviewItem> _reviewList(dynamic v) {
    if (v == null) return const [];
    if (v is List) {
      final out = <ReviewItem>[];
      for (final x in v) {
        if (x is Map) {
          out.add(ReviewItem.fromJson(Map<String, dynamic>.from(x)));
        } else if (x is Map<String, dynamic>) {
          out.add(ReviewItem.fromJson(x));
        }
      }
      return out;
    }
    return const [];
  }

  static String _genId({
    required String name,
    required double? lat,
    required double? lng,
  }) {
    final base = "${name.trim()}|${lat ?? ""}|${lng ?? ""}";
    return base.hashCode.toString();
  }

  factory CenterItem.fromJson(Map<String, dynamic> j) {
    double? lat;
    double? lng;

    // 1) direct lat/lng
    if (j["lat"] != null && j["lng"] != null) {
      lat = _num(j["lat"]);
      lng = _num(j["lng"]);
    } else if (j["latitude"] != null && j["longitude"] != null) {
      lat = _num(j["latitude"]);
      lng = _num(j["longitude"]);
    } else if (j["location"] is Map) {
      // 2) GeoJSON
      final loc = Map<String, dynamic>.from(j["location"] as Map);
      if (loc["coordinates"] is List &&
          (loc["coordinates"] as List).length >= 2) {
        final coords = loc["coordinates"] as List;
        lng = _num(coords[0]);
        lat = _num(coords[1]);
      }
    } else if (j["coords"] is Map) {
      // 3) coords object
      final c = Map<String, dynamic>.from(j["coords"] as Map);
      lat = c["lat"] != null ? _num(c["lat"]) : lat;
      lng = c["lng"] != null ? _num(c["lng"]) : lng;
    }

    // distance meters
    double? distMeters;
    if (j["distanceMeters"] != null) {
      distMeters = _num(j["distanceMeters"]);
    } else if (j["distance_meters"] != null) {
      distMeters = _num(j["distance_meters"]);
    } else if (j["distance"] != null) {
      final d = _num(j["distance"]);
      distMeters = d > 1000 ? d : (d * 1000);
    } else if (j["distanceKm"] != null) {
      distMeters = _num(j["distanceKm"]) * 1000.0;
    }

    final gallery = _stringList(
      j["gallery"] ??
          j["images"] ??
          j["photos"] ??
          j["media"] ??
          j["imageUrls"],
    );

    final name = (j["name"] ?? j["title"] ?? "").toString().trim();

    final id = (j["_id"] ?? j["id"])?.toString().trim();
    final safeId = (id == null || id.isEmpty)
        ? _genId(name: name, lat: lat, lng: lng)
        : id;

    // phone keys
    final phone = _str(j["phone"] ??
        j["phoneNumber"] ??
        j["mobile"] ??
        j["tel"] ??
        j["contactPhone"]);

    // address keys
    final address = _str(
        j["address"] ?? j["locationText"] ?? j["area"] ?? j["fullAddress"]);

    // open status / hours
    final openNow = _bool(j["openNow"] ?? j["isOpen"] ?? j["open"]);
    final openHours = _str(
        j["openHours"] ?? j["hours"] ?? j["workingHours"] ?? j["schedule"]);

    final services = _stringList(j["services"] ?? j["serviceList"]);
    final tags = _stringList(j["tags"] ?? j["specialties"] ?? j["categories"]);
    final reviews = _reviewList(j["reviews"] ?? j["ratings"] ?? j["comments"]);

    final types = _stringList(j["types"]);
    final governorate = _str(j["governorate"]);
    final city = _str(j["city"]);
    final source = _str(j["source"]);

    final image = (j["imageUrl"] ??
            j["image"] ??
            j["logo"] ??
            (gallery.isNotEmpty ? gallery.first : ""))
        .toString()
        .trim();

    return CenterItem(
      id: safeId,
      name: name,
      rating: _num(j["rating"], fallback: 0).clamp(0, 5).toDouble(),
      image: image,
      lat: lat,
      lng: lng,
      distanceMeters: distMeters,
      phone: phone,
      address: address,
      openNow: openNow,
      openHours: openHours,
      gallery: gallery,
      services: services,
      tags: tags,
      reviews: reviews,
      governorate: governorate,
      city: city,
      source: source,
      types: types,
    );
  }
}
