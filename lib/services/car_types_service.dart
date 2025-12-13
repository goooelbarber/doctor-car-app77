// 📁 lib/services/car_types_service.dart

import 'dart:convert';
import 'package:doctor_car_app/models/car_brand.dart';
import 'package:doctor_car_app/models/car_model_name.dart';
import 'package:http/http.dart' as http;

class CarTypesService {
  static const String base = "http://10.0.2.2:5000/api/car-types";

  // 🟦 1) Get Brands
  static Future<List<CarBrand>> getBrands() async {
    final res = await http.get(Uri.parse("$base/brands"));
    final List data = jsonDecode(res.body);
    return data.map((e) => CarBrand.fromJson(e)).toList();
  }

  // 🟦 2) Get Models by Brand
  static Future<List<CarModelName>> getModels(String brand) async {
    final res = await http.get(Uri.parse("$base/models/$brand"));
    final List data = jsonDecode(res.body);
    return data.map((e) => CarModelName.fromJson(e)).toList();
  }

  // 🟦 3) Get Years by Brand + Model
  static Future<List<int>> getYears(String brand, String model) async {
    final res = await http.get(Uri.parse("$base/years/$brand/$model"));
    final List data = jsonDecode(res.body);
    return data.map((e) => int.parse(e.toString())).toList();
  }
}
