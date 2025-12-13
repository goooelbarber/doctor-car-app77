// 📁 lib/models/car_model_name.dart

class CarModelName {
  final String model;

  CarModelName({required this.model});

  factory CarModelName.fromJson(Map<String, dynamic> json) {
    return CarModelName(
      model: json["model"],
    );
  }
}
