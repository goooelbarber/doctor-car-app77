import 'package:doctor_car_app/models/product_model.dart';

class WishlistService {
  static final List<ProductModel> _wishlist = [];

  /// إضافة منتج إلى المفضلة
  static void add(ProductModel product) {
    if (!_wishlist.any((p) => p.id == product.id)) {
      _wishlist.add(product);
    }
  }

  /// إزالة منتج من المفضلة
  static void remove(ProductModel product) {
    _wishlist.removeWhere((p) => p.id == product.id);
  }

  /// التحقق إن كان المنتج موجود في المفضلة
  static bool isInWishlist(int id) {
    return _wishlist.any((p) => p.id == id);
  }

  /// جلب جميع عناصر المفضلة
  static List<ProductModel> getWishlist() {
    return List.unmodifiable(_wishlist);
  }
}
