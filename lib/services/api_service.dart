import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class ApiService {
  // ============================================================
  // CONFIG
  // ============================================================

  static bool get forceAndroidEmulator =>
      (dotenv.env["FORCE_ANDROID_EMULATOR"] ?? "0") == "1";

  static bool get debugLogs => (dotenv.env["DEBUG_LOGS"] ?? "1") == "1";

  static String get apiPrefix => (dotenv.env["API_PREFIX"] ?? "/api").trim();

  static String get _baseUrlRaw => (dotenv.env["BASE_URL"] ?? "").trim();

  static int get defaultPort {
    final p = int.tryParse((dotenv.env["PORT"] ?? "5555").trim());
    return p ?? 5555;
  }

  static String get _webFallbackBase => "http://localhost:$defaultPort";

  // ده الـ IP الصحيح بتاع اللاب على شبكة الواي فاي الحالية
  static String get _realDeviceWifiBase => "http://192.168.1.20:$defaultPort";

  static bool _looksLocalhostHost(String host) {
    final h = host.toLowerCase().trim();
    return h == "localhost" || h == "127.0.0.1" || h == "0.0.0.0";
  }

  static bool _looksPrivateIpHost(String host) {
    final h = host.trim();
    return h.startsWith("192.168.") ||
        h.startsWith("10.") ||
        h.startsWith("172.16.") ||
        h.startsWith("172.17.") ||
        h.startsWith("172.18.") ||
        h.startsWith("172.19.") ||
        h.startsWith("172.20.") ||
        h.startsWith("172.21.") ||
        h.startsWith("172.22.") ||
        h.startsWith("172.23.") ||
        h.startsWith("172.24.") ||
        h.startsWith("172.25.") ||
        h.startsWith("172.26.") ||
        h.startsWith("172.27.") ||
        h.startsWith("172.28.") ||
        h.startsWith("172.29.") ||
        h.startsWith("172.30.") ||
        h.startsWith("172.31.");
  }

  static Uri _safeParseBase(String raw) {
    try {
      final parsed = Uri.parse(raw);
      if (parsed.scheme.isEmpty || parsed.host.isEmpty) {
        return Uri.parse(_webFallbackBase);
      }
      return parsed;
    } catch (_) {
      return Uri.parse(_webFallbackBase);
    }
  }

  static String _join(String a, String b) {
    final aa = a.endsWith("/") ? a.substring(0, a.length - 1) : a;
    final bb = b.startsWith("/") ? b : "/$b";
    return "$aa$bb";
  }

  static String _buildBase(Uri u) {
    final port = u.hasPort ? ":${u.port}" : "";
    return "${u.scheme}://${u.host}$port";
  }

  static void _warnInvalidDeviceBase(String finalUrl) {
    if (!debugLogs) return;
    debugPrint(
      "❌ BASE_URL غير صالح على جهاز حقيقي: $finalUrl\n"
      "لا تستخدم localhost / 127.0.0.1 / 0.0.0.0 على الموبايل.\n"
      "استخدم IP اللاب على نفس الواي فاي مثل: $_realDeviceWifiBase\n"
      "أو استخدم رابط public لو هتجرب من خارج الشبكة.",
    );
  }

  static String get baseUrl {
    final raw = _baseUrlRaw.isNotEmpty ? _baseUrlRaw : _webFallbackBase;
    final parsed = _safeParseBase(raw);

    if (kIsWeb) {
      final finalUrl = "http://localhost:$defaultPort$apiPrefix";
      if (debugLogs) debugPrint("🌐 WEB baseUrl (FORCED) => $finalUrl");
      return finalUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android &&
        forceAndroidEmulator) {
      final finalUrl = "http://10.0.2.2:$defaultPort$apiPrefix";
      if (debugLogs) debugPrint("🤖 ANDROID EMULATOR baseUrl => $finalUrl");
      return finalUrl;
    }

    // على الجهاز الحقيقي:
    // - لو BASE_URL في env هو localhost/127/0.0.0.0 => استخدم IP الواي فاي الصحيح
    // - لو BASE_URL موجود لكنه 172.21.x.x من vEthernet، فده غالبًا مش المناسب للموبايل الحقيقي
    //   وبرضه نبدله بـ IP الواي فاي
    // - غير كده استخدم BASE_URL كما هو
    String chosenBase;
    if (_looksLocalhostHost(parsed.host) || parsed.host.startsWith("172.21.")) {
      final invalidUrl = _join(_buildBase(parsed), apiPrefix);
      _warnInvalidDeviceBase(invalidUrl);
      chosenBase = _realDeviceWifiBase;
    } else {
      chosenBase = _buildBase(parsed);
    }

    final finalUrl = _join(chosenBase, apiPrefix);

    if (debugLogs) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint("📱 ANDROID DEVICE baseUrl => $finalUrl");
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        debugPrint("📱 IOS DEVICE baseUrl => $finalUrl");
      } else {
        debugPrint("🖥️ OTHER PLATFORM baseUrl => $finalUrl");
      }
    }

    return finalUrl;
  }

  static bool get isPublicBaseUrl {
    final raw = _baseUrlRaw.isNotEmpty ? _baseUrlRaw : _webFallbackBase;
    final parsed = _safeParseBase(raw);
    return !_looksLocalhostHost(parsed.host) &&
        !_looksPrivateIpHost(parsed.host);
  }

  // ============================================================
  // TIMEOUT
  // ============================================================

  static Duration get timeout {
    final s = int.tryParse((dotenv.env["HTTP_TIMEOUT_SECONDS"] ?? "30").trim());
    return Duration(seconds: (s ?? 30).clamp(5, 120));
  }

  // ============================================================
  // HEADERS
  // ============================================================

  static Map<String, String> _jsonHeaders() => const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      ..._jsonHeaders(),
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static Future<Map<String, String>> _multipartHeaders({
    bool auth = false,
  }) async {
    final token = auth ? await getToken() : null;
    return {
      "Accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // ============================================================
  // URL + DECODING
  // ============================================================

  static Uri _u(String path) {
    final pth = path.startsWith("/") ? path : "/$path";
    return Uri.parse("$baseUrl$pth");
  }

  static dynamic _decodeBody(http.Response res) {
    try {
      return jsonDecode(res.body);
    } catch (_) {
      final body = res.body;
      final preview = body.length > 500 ? body.substring(0, 500) : body;
      return {
        "error": true,
        "message": "رد غير JSON من السيرفر",
        "raw": preview,
      };
    }
  }

  static Map<String, dynamic> _normalizeError(
    http.Response res,
    dynamic decoded, {
    String fallback = "حدث خطأ",
  }) {
    String msg = fallback;

    if (decoded is Map) {
      if (decoded["message"] != null) {
        msg = decoded["message"].toString();
      } else if (decoded["error"] == true && decoded["raw"] != null) {
        msg = decoded["raw"].toString();
      }
    }

    return {
      "error": true,
      "success": false,
      "statusCode": res.statusCode,
      "message": msg,
    };
  }

  static String _errToMessage(Object e) {
    if (e is SocketException) {
      return "SocketException: ${e.message} (غالبًا السيرفر مش متاح من الجهاز الحالي أو الـ BASE_URL غلط)";
    }
    if (e is TimeoutException) {
      return "Timeout: السيرفر ما ردش خلال $timeout";
    }
    if (e is HttpException) {
      return "HttpException: ${e.message}";
    }
    return e.toString();
  }

  // ============================================================
  // LOGGING
  // ============================================================

  static void _logReq({
    required String tag,
    required Uri url,
    Map<String, String>? headers,
    Object? body,
  }) {
    if (!debugLogs) return;
    debugPrint("══════════════ $tag REQUEST ══════════════");
    debugPrint("✅ URL    => $url");
    if (headers != null) debugPrint("✅ HEADERS=> $headers");
    if (body != null) debugPrint("✅ BODY   => $body");
    debugPrint("══════════════════════════════════════════");
  }

  static void _logRes({
    required String tag,
    required int status,
    required String body,
    required int ms,
  }) {
    if (!debugLogs) return;
    debugPrint("══════════════ $tag RESPONSE ══════════════");
    debugPrint("✅ STATUS => $status");
    debugPrint("✅ TIME   => ${ms}ms");
    debugPrint("✅ RESP   => $body");
    debugPrint("══════════════════════════════════════════");
  }

  // ============================================================
  // TOKEN
  // ============================================================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ============================================================
  // INTERNAL HELPERS
  // ============================================================

  static Future<Map<String, dynamic>> _sendJson({
    required String tag,
    required String method,
    required String path,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool auth = false,
    bool retryOnce = true,
  }) async {
    final url = _u(path);
    final sw = Stopwatch()..start();

    try {
      final h = auth ? (await _authHeaders()) : (_jsonHeaders());
      final mergedHeaders = {...h, if (headers != null) ...headers};
      final bodyJson = body == null ? null : jsonEncode(body);

      _logReq(tag: tag, url: url, headers: mergedHeaders, body: bodyJson);

      late http.Response res;

      Future<http.Response> doCall() {
        switch (method.toUpperCase()) {
          case "GET":
            return http.get(url, headers: mergedHeaders);
          case "POST":
            return http.post(url, headers: mergedHeaders, body: bodyJson);
          case "PUT":
            return http.put(url, headers: mergedHeaders, body: bodyJson);
          case "DELETE":
            return http.delete(url, headers: mergedHeaders, body: bodyJson);
          default:
            throw UnsupportedError("Unsupported method: $method");
        }
      }

      res = await doCall().timeout(timeout);

      sw.stop();
      _logRes(
        tag: tag,
        status: res.statusCode,
        body: res.body,
        ms: sw.elapsedMilliseconds,
      );

      final decoded = _decodeBody(res);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (decoded is Map<String, dynamic>) return decoded;
        return {"success": true, "data": decoded};
      }

      if (res.statusCode == 401) {
        await clearToken();
      }

      return _normalizeError(res, decoded, fallback: "Request failed");
    } on TimeoutException catch (e) {
      sw.stop();

      if (debugLogs) debugPrint("❌ $tag TIMEOUT => ${_errToMessage(e)}");

      if (retryOnce) {
        if (debugLogs) debugPrint("🔁 $tag RETRY مرة واحدة...");
        await Future.delayed(const Duration(milliseconds: 350));
        return _sendJson(
          tag: tag,
          method: method,
          path: path,
          headers: headers,
          body: body,
          auth: auth,
          retryOnce: false,
        );
      }

      return {"error": true, "message": "السيرفر مش بيرد (Timeout)"};
    } catch (e, s) {
      sw.stop();

      if (debugLogs) {
        debugPrint("❌ $tag ERROR => ${_errToMessage(e)}");
        debugPrint(s.toString());
      }

      return {
        "error": true,
        "message": "تعذر الاتصال بالسيرفر: ${_errToMessage(e)}",
      };
    }
  }

  static Future<Map<String, dynamic>> _sendMultipart({
    required String tag,
    required String path,
    required List<_MultipartFileItem> files,
    Map<String, String>? fields,
    bool auth = true,
    bool retryOnce = true,
  }) async {
    final url = _u(path);
    final sw = Stopwatch()..start();

    try {
      final headers = await _multipartHeaders(auth: auth);

      _logReq(
        tag: tag,
        url: url,
        headers: headers,
        body: {
          "fields": fields ?? {},
          "files": files.map((e) => "${e.field}: ${e.path}").toList(),
        },
      );

      final request = http.MultipartRequest("POST", url);
      request.headers.addAll(headers);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      for (final file in files) {
        if (file.path.trim().isEmpty) continue;
        request.files.add(
          await http.MultipartFile.fromPath(
            file.field,
            file.path,
            filename: p.basename(file.path),
          ),
        );
      }

      final streamed = await request.send().timeout(timeout);
      final res = await http.Response.fromStream(streamed);

      sw.stop();
      _logRes(
        tag: tag,
        status: res.statusCode,
        body: res.body,
        ms: sw.elapsedMilliseconds,
      );

      final decoded = _decodeBody(res);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (decoded is Map<String, dynamic>) return decoded;
        return {"success": true, "data": decoded};
      }

      if (res.statusCode == 401) {
        await clearToken();
      }

      return _normalizeError(res, decoded,
          fallback: "Multipart request failed");
    } on TimeoutException catch (e) {
      sw.stop();

      if (debugLogs) debugPrint("❌ $tag TIMEOUT => ${_errToMessage(e)}");

      if (retryOnce) {
        if (debugLogs) debugPrint("🔁 $tag RETRY مرة واحدة...");
        await Future.delayed(const Duration(milliseconds: 350));
        return _sendMultipart(
          tag: tag,
          path: path,
          files: files,
          fields: fields,
          auth: auth,
          retryOnce: false,
        );
      }

      return {"error": true, "message": "السيرفر مش بيرد (Timeout)"};
    } catch (e, s) {
      sw.stop();

      if (debugLogs) {
        debugPrint("❌ $tag ERROR => ${_errToMessage(e)}");
        debugPrint(s.toString());
      }

      return {
        "error": true,
        "message": "تعذر رفع الملفات: ${_errToMessage(e)}",
      };
    }
  }

  // ============================================================
  // CONNECTION CHECK
  // ============================================================

  static Future<Map<String, dynamic>> checkConnection({bool retryOnce = true}) {
    return _sendJson(
      tag: "CHECK",
      method: "GET",
      path: "/health",
      auth: false,
      retryOnce: retryOnce,
    );
  }

  // ============================================================
  // AUTH
  // ============================================================

  static Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool retryOnce = true,
  }) async {
    final res = await _sendJson(
      tag: "LOGIN",
      method: "POST",
      path: "/users/login",
      body: {
        "email": email.trim(),
        "password": password.trim(),
      },
      auth: false,
      retryOnce: retryOnce,
    );

    final token = res["token"];
    if (token is String && token.isNotEmpty) {
      await saveToken(token);
    }
    return res;
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final res = await _sendJson(
      tag: "REGISTER",
      method: "POST",
      path: "/users/register",
      body: {
        "name": name.trim(),
        "email": email.trim(),
        "password": password.trim(),
        "role": role.trim(),
      },
      auth: false,
      retryOnce: true,
    );

    final token = res["token"];
    if (token is String && token.isNotEmpty) {
      await saveToken(token);
    }
    return res;
  }

  static Future<Map<String, dynamic>> googleLogin(
    String idToken, {
    String? role,
  }) async {
    final res = await _sendJson(
      tag: "GOOGLE_LOGIN",
      method: "POST",
      path: "/users/google",
      body: {
        "idToken": idToken,
        if (role != null && role.trim().isNotEmpty) "role": role.trim(),
      },
      auth: false,
      retryOnce: true,
    );

    final token = res["token"];
    if (token is String && token.isNotEmpty) {
      await saveToken(token);
    }
    return res;
  }

  // ============================================================
  // VEHICLES
  // ============================================================

  static Future<List> getVehicles() async {
    try {
      final headers = await _authHeaders();
      final url = _u("/vehicles/my-vehicles");

      _logReq(tag: "GET_VEHICLES", url: url, headers: headers);

      final res = await http.get(url, headers: headers).timeout(timeout);

      if (debugLogs) {
        debugPrint("✅ GET_VEHICLES STATUS => ${res.statusCode}");
        debugPrint("✅ GET_VEHICLES RESP   => ${res.body}");
      }

      final data = _decodeBody(res);

      if (res.statusCode == 200) {
        if (data is List) return data;
        if (data is Map && data["vehicles"] != null) return data["vehicles"];
      }

      return [];
    } catch (e) {
      if (debugLogs) debugPrint("❌ getVehicles error: ${_errToMessage(e)}");
      return [];
    }
  }

  static Future<Map<String, dynamic>> addVehicle({
    required String brand,
    required String model,
    required String fuel,
    required String condition,
    required String plateNumber,
    required String year,
    required String color,
    required String chassisNumber,
  }) {
    return _sendJson(
      tag: "ADD_VEHICLE",
      method: "POST",
      path: "/vehicles",
      auth: true,
      body: {
        "brand": brand,
        "model": model,
        "fuel": fuel,
        "condition": condition,
        "plateNumber": plateNumber,
        "year": year,
        "color": color,
        "chassisNumber": chassisNumber,
      },
      retryOnce: true,
    );
  }

  static Future<Map<String, dynamic>> updateVehicle({
    required String vehicleId,
    String? brand,
    String? model,
    String? fuel,
    String? condition,
    String? plateNumber,
    String? year,
    String? color,
    String? chassisNumber,
  }) {
    return _sendJson(
      tag: "UPDATE_VEHICLE",
      method: "PUT",
      path: "/vehicles/$vehicleId",
      auth: true,
      body: {
        if (brand != null) "brand": brand,
        if (model != null) "model": model,
        if (fuel != null) "fuel": fuel,
        if (condition != null) "condition": condition,
        if (plateNumber != null) "plateNumber": plateNumber,
        if (year != null) "year": year,
        if (color != null) "color": color,
        if (chassisNumber != null) "chassisNumber": chassisNumber,
      },
      retryOnce: true,
    );
  }

  static Future<Map<String, dynamic>> deleteVehicle(String id) {
    return _sendJson(
      tag: "DELETE_VEHICLE",
      method: "DELETE",
      path: "/vehicles/$id",
      auth: true,
      retryOnce: true,
    );
  }

  // ============================================================
  // CAR TYPES
  // ============================================================

  static Future<List<String>> getCarBrands() async {
    try {
      final url = _u("/car-types/brands");
      _logReq(tag: "CAR_BRANDS", url: url);

      final res = await http.get(url).timeout(timeout);

      if (debugLogs) {
        debugPrint("✅ CAR_BRANDS STATUS => ${res.statusCode}");
        debugPrint("✅ CAR_BRANDS RESP   => ${res.body}");
      }

      final decoded = _decodeBody(res);
      if (res.statusCode == 200 && decoded is List) {
        return decoded.map((e) => e["name"].toString()).toList();
      }
      return [];
    } catch (e) {
      if (debugLogs) debugPrint("❌ CAR_BRANDS ERROR => ${_errToMessage(e)}");
      return [];
    }
  }

  static Future<List<String>> getModelsByBrand(String brand) async {
    try {
      final br = brand.toLowerCase().trim();
      final url = _u("/car-types/models/$br");
      _logReq(tag: "CAR_MODELS", url: url);

      final res = await http.get(url).timeout(timeout);

      if (debugLogs) {
        debugPrint("✅ CAR_MODELS STATUS => ${res.statusCode}");
        debugPrint("✅ CAR_MODELS RESP   => ${res.body}");
      }

      final decoded = _decodeBody(res);
      if (res.statusCode == 200 && decoded is List) {
        return List<String>.from(decoded);
      }
      return [];
    } catch (e) {
      if (debugLogs) debugPrint("❌ CAR_MODELS ERROR => ${_errToMessage(e)}");
      return [];
    }
  }

  static Future<List<String>> getYears(String brand, String model) async {
    try {
      final url =
          _u("/car-types/years/${brand.toLowerCase()}/${model.toLowerCase()}");
      _logReq(tag: "CAR_YEARS", url: url);

      final res = await http.get(url).timeout(timeout);

      if (debugLogs) {
        debugPrint("✅ CAR_YEARS STATUS => ${res.statusCode}");
        debugPrint("✅ CAR_YEARS RESP   => ${res.body}");
      }

      final decoded = _decodeBody(res);
      if (res.statusCode == 200 && decoded is List) {
        return List<String>.from(decoded);
      }
      return [];
    } catch (e) {
      if (debugLogs) debugPrint("❌ CAR_YEARS ERROR => ${_errToMessage(e)}");
      return [];
    }
  }

  // ============================================================
  // MAINTENANCE
  // ============================================================

  static Future<Map<String, dynamic>> addMaintenance({
    required String vehicleId,
    required String type,
    required String km,
    required String cost,
    required String notes,
    required String date,
  }) {
    return _sendJson(
      tag: "ADD_MAINT",
      method: "POST",
      path: "/maintenance/$vehicleId",
      auth: true,
      body: {
        "type": type,
        "km": km,
        "cost": cost,
        "notes": notes,
        "date": date,
      },
      retryOnce: true,
    );
  }

  static Future<List> getMaintenanceHistory(String vehicleId) async {
    try {
      final headers = await _authHeaders();
      final url = _u("/maintenance/$vehicleId");

      _logReq(tag: "GET_MAINT", url: url, headers: headers);

      final res = await http.get(url, headers: headers).timeout(timeout);

      if (debugLogs) {
        debugPrint("✅ GET_MAINT STATUS => ${res.statusCode}");
        debugPrint("✅ GET_MAINT RESP   => ${res.body}");
      }

      final decoded = _decodeBody(res);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded["history"] is List) {
        return decoded["history"];
      }
      return [];
    } catch (e) {
      if (debugLogs) debugPrint("❌ GET_MAINT ERROR => ${_errToMessage(e)}");
      return [];
    }
  }

  static Future<Map<String, dynamic>> deleteMaintenance(String id) {
    return _sendJson(
      tag: "DEL_MAINT",
      method: "DELETE",
      path: "/maintenance/$id",
      auth: true,
      retryOnce: true,
    );
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  static Future<Map<String, dynamic>> forgotPassword(String email) {
    return _sendJson(
      tag: "FORGOT",
      method: "POST",
      path: "/users/forgot-password",
      auth: false,
      body: {"email": email.trim()},
      retryOnce: true,
    );
  }

  // ============================================================
  // ACCIDENT / EMERGENCY
  // ============================================================

  static Future<Map<String, dynamic>> uploadAccidentImages(
    List<String> imagePaths, {
    Map<String, String>? fields,
  }) async {
    final validPaths = imagePaths.where((e) => e.trim().isNotEmpty).toList();

    if (validPaths.isEmpty) {
      return {
        "error": true,
        "message": "لا توجد صور لرفعها",
      };
    }

    return _sendMultipart(
      tag: "UPLOAD_ACCIDENT_IMAGES",
      path: "/accidents/upload-images",
      auth: true,
      fields: fields,
      files: validPaths
          .map((path) => _MultipartFileItem(field: "images", path: path))
          .toList(),
    );
  }

  static Future<Map<String, dynamic>> uploadAccidentAudio(
    String audioPath, {
    Map<String, String>? fields,
  }) async {
    if (audioPath.trim().isEmpty) {
      return {
        "error": true,
        "message": "لا يوجد ملف صوتي لرفعه",
      };
    }

    return _sendMultipart(
      tag: "UPLOAD_ACCIDENT_AUDIO",
      path: "/accidents/upload-audio",
      auth: true,
      fields: fields,
      files: [
        _MultipartFileItem(field: "audio", path: audioPath),
      ],
    );
  }

  static Future<Map<String, dynamic>> createEmergencyAccident({
    required double lat,
    required double lng,
    String? address,
    String? notes,
    List<String>? imageUrls,
    String? audioUrl,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? status,
    String? serviceType,
    String? vehicleId,
  }) {
    return _sendJson(
      tag: "CREATE_EMERGENCY_ACCIDENT",
      method: "POST",
      path: "/accidents/emergency",
      auth: true,
      body: {
        "lat": lat,
        "lng": lng,
        if (address != null && address.trim().isNotEmpty) "address": address,
        if (notes != null && notes.trim().isNotEmpty) "notes": notes.trim(),
        if (imageUrls != null) "imageUrls": imageUrls,
        if (audioUrl != null && audioUrl.trim().isNotEmpty)
          "audioUrl": audioUrl,
        if (emergencyContactName != null &&
            emergencyContactName.trim().isNotEmpty)
          "emergencyContactName": emergencyContactName.trim(),
        if (emergencyContactPhone != null &&
            emergencyContactPhone.trim().isNotEmpty)
          "emergencyContactPhone": emergencyContactPhone.trim(),
        "status": status ?? "pending",
        if (serviceType != null && serviceType.trim().isNotEmpty)
          "serviceType": serviceType.trim(),
        if (vehicleId != null && vehicleId.trim().isNotEmpty)
          "vehicleId": vehicleId.trim(),
      },
      retryOnce: true,
    );
  }

  static Future<Map<String, dynamic>> sendEmergencyNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return _sendJson(
      tag: "SEND_EMERGENCY_NOTIFICATION",
      method: "POST",
      path: "/accidents/notify",
      auth: true,
      body: {
        "title": title,
        "body": body,
        if (data != null) "data": data,
      },
      retryOnce: true,
    );
  }

  static Future<Map<String, dynamic>> submitEmergencyCase({
    required double lat,
    required double lng,
    String? address,
    String? notes,
    List<String>? imagePaths,
    String? audioPath,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? serviceType,
    String? vehicleId,
  }) async {
    final List<String> uploadedImageUrls = [];
    String? uploadedAudioUrl;

    if (imagePaths != null && imagePaths.isNotEmpty) {
      final imgRes = await uploadAccidentImages(imagePaths);
      if (imgRes["error"] == true) return imgRes;

      final urls = _extractUploadedUrls(imgRes, keyCandidates: const [
        "urls",
        "imageUrls",
        "files",
      ]);
      uploadedImageUrls.addAll(urls);
    }

    if (audioPath != null && audioPath.trim().isNotEmpty) {
      final audioRes = await uploadAccidentAudio(audioPath);
      if (audioRes["error"] == true) return audioRes;

      uploadedAudioUrl =
          _extractSingleUploadedUrl(audioRes, keyCandidates: const [
        "url",
        "audioUrl",
        "file",
      ]);
    }

    return createEmergencyAccident(
      lat: lat,
      lng: lng,
      address: address,
      notes: notes,
      imageUrls: uploadedImageUrls,
      audioUrl: uploadedAudioUrl,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      serviceType: serviceType,
      vehicleId: vehicleId,
    );
  }

  static List<String> _extractUploadedUrls(
    Map<String, dynamic> res, {
    required List<String> keyCandidates,
  }) {
    for (final key in keyCandidates) {
      final value = res[key];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
    }

    final data = res["data"];
    if (data is Map<String, dynamic>) {
      for (final key in keyCandidates) {
        final value = data[key];
        if (value is List) {
          return value.map((e) => e.toString()).toList();
        }
      }
    }

    return [];
  }

  static String? _extractSingleUploadedUrl(
    Map<String, dynamic> res, {
    required List<String> keyCandidates,
  }) {
    for (final key in keyCandidates) {
      final value = res[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    final data = res["data"];
    if (data is Map<String, dynamic>) {
      for (final key in keyCandidates) {
        final value = data[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
    }

    return null;
  }
}

class _MultipartFileItem {
  final String field;
  final String path;

  const _MultipartFileItem({
    required this.field,
    required this.path,
  });
}

// flutter run -d RK8TC01A1WP
