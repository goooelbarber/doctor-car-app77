import 'package:flutter/material.dart';
import 'package:doctor_car_app/services/wishlist_service.dart';
import 'package:doctor_car_app/models/product_model.dart';

class FavButton extends StatefulWidget {
  final ProductModel product;
  final double size;

  const FavButton({super.key, required this.product, this.size = 26});

  @override
  State<FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<FavButton> {
  @override
  Widget build(BuildContext context) {
    final bool isFav = WishlistService.isInWishlist(widget.product.id);

    return GestureDetector(
      onTap: () {
        if (isFav) {
          WishlistService.remove(widget.product);
        } else {
          WishlistService.add(widget.product);
        }
        setState(() {});
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFav),
          size: widget.size,
          color: isFav ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}
