// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import '../../pages/home/home_page.dart';
import '../../pages/products/product_details_page.dart';
import '../../pages/products/product_list_page.dart';
import '../../pages/search/search_page.dart';
import '../../pages/cart/cart_page.dart';
import '../../pages/profile/profile_page.dart';
import '../navigation/bottom_nav.dart';
import '../../models/product_model.dart';

class AppRouter {
  static const String main = "/main";
  static const String home = "/home";
  static const String products = "/products";
  static const String details = "/details";
  static const String search = "/search";
  static const String cart = "/cart";
  static const String profile = "/profile";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const BottomNav());

      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case products:
        return MaterialPageRoute(builder: (_) => const ProductListPage());

      case details:
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => ProductDetailsPage(product: product),
        );

      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());

      case cart:
        return MaterialPageRoute(builder: (_) => const CartPage());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
        );
    }
  }
}
