import 'package:flutter/material.dart';

class FavoritesManager with ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  void toggleFavorite(Map<String, dynamic> service) {
    if (isFavorite(service)) {
      _favorites.removeWhere((item) => item["name"] == service["name"]);
    } else {
      _favorites.add(service);
    }
    notifyListeners();
  }

  bool isFavorite(Map<String, dynamic> service) {
    return _favorites.any((item) => item["name"] == service["name"]);
  }
}
