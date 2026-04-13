import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static String _clean(String url) {
    var v = url.trim();
    if (v.endsWith("/")) {
      v = v.substring(0, v.length - 1);
    }
    return v;
  }

  static String? _getEnv(String key) {
    final value = dotenv.env[key];
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool get isProduction =>
      (_getEnv("NODE_ENV") ?? "").toLowerCase() == "production";

  static bool get forceAndroidEmulator =>
      (_getEnv("FORCE_ANDROID_EMULATOR") ?? "0") == "1";

  static bool get debugLogs => (_getEnv("DEBUG_LOGS") ?? "1") == "1";

  static String get apiPrefix => (_getEnv("API_PREFIX") ?? "/api").trim();

  // ignore: unused_element
  static String get _webFallbackBase => "http://localhost:5555";

  // IP اللاب الحقيقي على الواي فاي حسب ipconfig
  static String get _realDeviceFallbackBase => "http://192.168.1.20:5555";

  static bool _looksLocalhostHost(String host) {
    final h = host.toLowerCase().trim();
    return h == "localhost" || h == "127.0.0.1" || h == "0.0.0.0";
  }

  static String get _rawBase {
    return _getEnv("API_BASE_URL") ??
        _getEnv("BASE_URL") ??
        _realDeviceFallbackBase;
  }

  static Uri _parseBaseUri() {
    try {
      return Uri.parse(_rawBase);
    } catch (_) {
      return Uri.parse(_realDeviceFallbackBase);
    }
  }

  static String _join(String a, String b) {
    final aa = a.endsWith("/") ? a.substring(0, a.length - 1) : a;
    final bb = b.startsWith("/") ? b : "/$b";
    return "$aa$bb";
  }

  static String get baseUrl {
    final parsed = _parseBaseUri();

    if (kIsWeb) {
      final finalUrl = _clean(parsed.toString());
      if (debugLogs) debugPrint("🌍 WEB baseUrl => $finalUrl");
      return finalUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (forceAndroidEmulator) {
        final u = Uri(
          scheme: parsed.scheme.isNotEmpty ? parsed.scheme : "http",
          host: "10.0.2.2",
          port: parsed.hasPort ? parsed.port : 5555,
        );
        final finalUrl = _clean(u.toString());
        if (debugLogs) debugPrint("🤖 ANDROID EMULATOR baseUrl => $finalUrl");
        return finalUrl;
      }

      // لو env فيه localhost أو 127.0.0.1 أو 0.0.0.0 على موبايل حقيقي
      // أو لو فيه IP الـ vEthernet القديم 172.21.128.1
      // نحوله تلقائيًا لـ IP الواي فاي الصحيح
      if (_looksLocalhostHost(parsed.host) || parsed.host == "172.21.128.1") {
        final fixed = Uri.parse(_realDeviceFallbackBase);
        final finalUrl = _clean(fixed.toString());

        if (debugLogs) {
          debugPrint(
            "⚠️ BASE_URL غير مناسب للموبايل الحقيقي.\n"
            "⚠️ تم التحويل تلقائيًا إلى IP الواي فاي الصحيح.\n"
            "⚠️ current => ${_clean(parsed.toString())}\n"
            "✅ using   => $finalUrl",
          );
        }
        return finalUrl;
      }

      final finalUrl = _clean(parsed.toString());
      if (debugLogs) debugPrint("📱 ANDROID DEVICE baseUrl => $finalUrl");
      return finalUrl;
    }

    final finalUrl = _clean(parsed.toString());
    if (debugLogs) debugPrint("🖥️ OTHER PLATFORM baseUrl => $finalUrl");
    return finalUrl;
  }

  static String get apiBase => _join(baseUrl, apiPrefix);

  static String get socketUrl {
    final socketOverride = _getEnv("SOCKET_URL");

    if (socketOverride != null) {
      final cleaned = _clean(socketOverride);

      // لو SOCKET_URL متساب على IP غلط للموبايل الحقيقي
      if (!kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android &&
          (cleaned.contains("172.21.128.1") ||
              cleaned.contains("localhost") ||
              cleaned.contains("127.0.0.1") ||
              cleaned.contains("0.0.0.0"))) {
        final fixed = _realDeviceFallbackBase;
        if (debugLogs) {
          debugPrint(
              "⚠️ socketUrl override غير مناسب، تم استبداله بـ => $fixed");
        }
        return fixed;
      }

      if (debugLogs) debugPrint("🔌 socketUrl override => $cleaned");
      return cleaned;
    }

    final url = baseUrl;
    if (debugLogs) debugPrint("🔌 socketUrl => $url");
    return url;
  }

  static const Duration requestTimeout = Duration(seconds: 30);

  static Map<String, String> jsonHeaders({String? token}) => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

  static String get userLogin => "$apiBase/users/login";
  static String get technicianLogin => "$apiBase/technicians/login";

  static String get orders => "$apiBase/orders";
  static String get createOrder => "$apiBase/orders";
  static String orderById(String id) => "$apiBase/orders/$id";
  static String cancelOrder(String id) => "$apiBase/orders/$id/cancel";

  static String get technicians => "$apiBase/technicians";

  static String get centers => "$apiBase/centers";

  static String nearbyCenters({
    required double lat,
    required double lng,
    int limit = 20,
    int maxDistanceMeters = 50000,
    String? governorate,
    String? city,
  }) {
    final l = limit.clamp(1, 50);
    final md = maxDistanceMeters.clamp(1000, 200000);

    final qp = <String, String>{
      "lat": lat.toString(),
      "lng": lng.toString(),
      "limit": l.toString(),
      "maxDistance": md.toString(),
    };

    if (governorate != null && governorate.trim().isNotEmpty) {
      qp["governorate"] = governorate.trim();
    }
    if (city != null && city.trim().isNotEmpty) {
      qp["city"] = city.trim();
    }

    return Uri.parse("$apiBase/centers/nearby")
        .replace(queryParameters: qp)
        .toString();
  }

  static String get support => "$apiBase/support";
  static String get supportChats => "$apiBase/support/chats";
  static String supportMessages(String chatId) =>
      "$apiBase/support/chats/$chatId/messages";

  static String get payments => "$apiBase/payments";

  static String get feedback => "$apiBase/feedback";

  static String mapsAutocomplete(String input, {String lang = "ar"}) {
    final qp = {"input": input.trim(), "lang": lang};
    return Uri.parse("$apiBase/maps/autocomplete")
        .replace(queryParameters: qp)
        .toString();
  }

  static String mapsPlaceDetails(String placeId, {String lang = "ar"}) {
    final qp = {"placeId": placeId.trim(), "lang": lang};
    return Uri.parse("$apiBase/maps/place-details")
        .replace(queryParameters: qp)
        .toString();
  }

  static String mapsReverseGeocode({
    required double lat,
    required double lng,
    String lang = "ar",
  }) {
    final qp = {"lat": "$lat", "lng": "$lng", "lang": lang};
    return Uri.parse("$apiBase/maps/reverse-geocode")
        .replace(queryParameters: qp)
        .toString();
  }

  static String mapsDirections({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final qp = {
      "fromLat": "$fromLat",
      "fromLng": "$fromLng",
      "toLat": "$toLat",
      "toLng": "$toLng",
    };

    return Uri.parse("$apiBase/maps/directions")
        .replace(queryParameters: qp)
        .toString();
  }
}
