class ProductModel {
  final int id;
  final int brandId;
  final int carModelId;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String oemNumber;
  final bool inStock;

  ProductModel({
    required this.id,
    required this.brandId,
    required this.carModelId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.oemNumber,
    required this.inStock,
  });
}
