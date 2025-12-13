import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ============================================================
  // 🌍 تحديد عنوان السيرفر حسب نوع الجهاز
  // ============================================================
  static String get baseUrl {
    const int port = 5001;
    const String localIP = "192.168.1.11"; // ← عدّله حسب شبكتك

    if (kIsWeb) return "http://localhost:$port/api";

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return kDebugMode
            ? "http://10.0.2.2:$port/api"
            : "http://$localIP:$port/api";
      case TargetPlatform.iOS:
        return "http://$localIP:$port/api";
      default:
        return "http://localhost:$port/api";
    }
  }

  // ============================================================
  // TOKEN HELPERS
  // ============================================================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ============================================================
  // 🔌 اختبار الاتصال
  // ============================================================
  static Future<void> checkConnection() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/"));
      debugPrint("SERVER: ${res.body}");
    } catch (e) {
      debugPrint("❌ Cannot connect: $e");
    }
  }

  // ============================================================
  // 🔐 تسجيل الدخول
  // ============================================================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
        }),
      );

      return res.statusCode == 200
          ? jsonDecode(res.body)
          : {"error": true, "message": "بيانات غير صحيحة"};
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // ============================================================
  // 🚘 جلب سيارات المستخدم
  // ============================================================
  static Future<List> getVehicles(String token) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/vehicles/my-vehicles"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (data is List) return data;
      if (data["vehicles"] != null) return data["vehicles"];

      return [];
    } catch (e) {
      debugPrint("❌ getVehicles error: $e");
      return [];
    }
  }

  // ============================================================
  // 🚘 إضافة مركبة
  // ============================================================
  static Future<Map<String, dynamic>> addVehicle(
    String token, {
    required String brand,
    required String model,
    required String fuel,
    required String condition,
    required String plateNumber,
    required String year,
    required String color,
    required String chassisNumber,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/vehicles"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "brand": brand,
          "model": model,
          "fuel": fuel,
          "condition": condition,
          "plateNumber": plateNumber,
          "year": year,
          "color": color,
          "chassisNumber": chassisNumber,
        }),
      );

      return res.statusCode == 201
          ? jsonDecode(res.body)
          : {"error": true, "message": "فشل إضافة المركبة"};
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // ============================================================
  // ✏ تعديل مركبة
  // ============================================================
  static Future<Map<String, dynamic>> updateVehicle(
    String token, {
    required String vehicleId,
    String? brand,
    String? model,
    String? fuel,
    String? condition,
    String? plateNumber,
    String? year,
    String? color,
    String? chassisNumber,
    required id,
  }) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/vehicles/$vehicleId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          if (brand != null) "brand": brand,
          if (model != null) "model": model,
          if (fuel != null) "fuel": fuel,
          if (condition != null) "condition": condition,
          if (plateNumber != null) "plateNumber": plateNumber,
          if (year != null) "year": year,
          if (color != null) "color": color,
          if (chassisNumber != null) "chassisNumber": chassisNumber,
        }),
      );

      return res.statusCode == 200
          ? jsonDecode(res.body)
          : {"error": true, "message": "فشل تعديل المركبة"};
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // ============================================================
  // ❌ حذف مركبة
  // ============================================================
  static Future<Map<String, dynamic>> deleteVehicle(
      String token, String id) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/vehicles/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      return res.statusCode == 200
          ? {"success": true}
          : {"error": true, "message": "فشل حذف المركبة"};
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // ============================================================
  // 🚘 الماركات – MODELS – YEARS
  // ============================================================

  /// 🟦 جلب الماركات
  static Future<List<String>> getCarBrands() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/car-types/brands"));

      if (res.statusCode == 200) {
        final List decoded = jsonDecode(res.body);
        return decoded.map((e) => e["name"].toString()).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// 🟩 جلب الموديلات
  static Future<List<String>> getModelsByBrand(String brand) async {
    try {
      final br = brand.toLowerCase().trim();
      final res = await http.get(Uri.parse("$baseUrl/car-types/models/$br"));

      if (res.statusCode == 200) {
        return List<String>.from(jsonDecode(res.body));
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// 🟧 جلب السنوات
  static Future<List<String>> getYears(String brand, String model) async {
    try {
      final res = await http.get(Uri.parse(
          "$baseUrl/car-types/years/${brand.toLowerCase()}/${model.toLowerCase()}"));

      if (res.statusCode == 200) {
        return List<String>.from(jsonDecode(res.body));
      }

      return [];
    } catch (e) {
      return [];
    }
  }

// ============================================================
// 🔧 إضافة عملية صيانة
// ============================================================
  static Future<Map<String, dynamic>> addMaintenance({
    required String vehicleId,
    required String type,
    required String km,
    required String cost,
    required String notes,
    required String date,
  }) async {
    try {
      final token = await getToken();

      final res = await http.post(
        Uri.parse("$baseUrl/maintenance/$vehicleId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "type": type,
          "km": km,
          "cost": cost,
          "notes": notes,
          "date": date,
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

// ============================================================
// 🟣 جلب سجل الصيانة لسيارة
// ============================================================
  static Future<List> getMaintenanceHistory(String vehicleId) async {
    try {
      final token = await getToken();

      final res = await http.get(
        Uri.parse("$baseUrl/maintenance/$vehicleId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      return jsonDecode(res.body);
    } catch (e) {
      return [];
    }
  }

  static Future register(
      String name, String email, String password, String s) async {}

  static Future deleteMaintenance(String id) async {}

  static Future<void> forgotPassword(String email) async {}
}
