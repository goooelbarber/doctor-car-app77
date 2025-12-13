// 📁 lib/services/car_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';

class CarService {
  static const baseUrl = "https://your-backend.com/api/cars";

  static Future<List> getCars(String userId) async {
    final res = await http.get(Uri.parse("$baseUrl/$userId"));
    final List data = jsonDecode(res.body);
    return data.map((e) => CarModel.fromJson(e)).toList();
  }

  static Future<CarModel?> addCar(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (res.statusCode == 200) {
      return CarModel.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<bool> deleteCar(String id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    return res.statusCode == 200;
  }
}
