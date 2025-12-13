class CarModel {
  final int id;
  final int brandId;
  final String modelName;
  final List<int> years;

  CarModel({
    required this.id,
    required this.brandId,
    required this.modelName,
    required this.years,
  });

  get imageUrl => null;

  get model => null;

  get mileage => null;

  String? get vin => null;

  String? get plateNumber => null;

  get lastService => null;

  get nextOilChange => null;

  get lastOilChange => null;

  get brandName => null;

  static fromJson(e) {}
}
