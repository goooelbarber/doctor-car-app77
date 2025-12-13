// 📁 lib/models/car_brand.dart

class CarBrand {
  final String id;
  final String name;
  final String country;

  CarBrand({required this.id, required this.name, required this.country});

  factory CarBrand.fromJson(Map<String, dynamic> json) {
    return CarBrand(
      id: json["id"],
      name: json["name"],
      country: json["country"],
    );
  }
}
