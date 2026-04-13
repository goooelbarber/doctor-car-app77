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

  const ProductModel({
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

  bool get hasRealImage {
    final lower = imageUrl.trim().toLowerCase();
    if (lower.isEmpty) return false;
    if (lower.contains('placeholder')) return false;
    if (lower.contains('dummy')) return false;
    if (lower.contains('random')) return false;
    if (lower.contains('unsplash')) return false;
    if (lower.contains('pexels')) return false;
    return true;
  }

  String get stockLabel => inStock ? 'متوفر' : 'غير متوفر';

  String get displayOemNumber =>
      oemNumber.trim().isEmpty ? 'غير متوفر' : oemNumber.trim();
}
