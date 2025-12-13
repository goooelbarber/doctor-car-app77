import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int selectedImage = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),

      // ============= BUY BUTTON FIXED =============
      bottomNavigationBar: _bottomBuyBar(product),

      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _imageGallery(product),
                    const SizedBox(height: 20),
                    _titleAndPrice(product),
                    const SizedBox(height: 16),
                    _ratingStars(),
                    const SizedBox(height: 20),
                    _stockStatus(product),
                    const SizedBox(height: 22),
                    _sectionTitle("Description"),
                    _description(product),
                    const SizedBox(height: 20),
                    _sectionTitle("OEM Number"),
                    _oemBox(product),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- HEADER -----------------
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 22),
          ),
          const Spacer(),
          Text(
            "Product Details",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Icon(Icons.favorite_border, size: 24),
        ],
      ),
    );
  }

  // ----------------- IMAGE SLIDER -----------------
  Widget _imageGallery(ProductModel product) {
    final images = [
      product.imageUrl,
      product.imageUrl,
      product.imageUrl, // لو عندك صور متعددة هتضيفها هنا
    ];

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => selectedImage = i),
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // SMALL DOTS INDICATOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.all(4),
              width: selectedImage == i ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: selectedImage == i ? Colors.blue : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------- TITLE + PRICE -----------------
  Widget _titleAndPrice(ProductModel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p.name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            "${p.price} ريال",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xff3A55FF),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- RATING -----------------
  Widget _ratingStars() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(
          5,
          (i) => const Icon(Icons.star, color: Colors.orange, size: 22),
        ),
      ),
    );
  }

  // ----------------- STOCK -----------------
  Widget _stockStatus(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            product.inStock ? Icons.check_circle : Icons.cancel,
            size: 26,
            color: product.inStock ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Text(
            product.inStock ? "Available in stock" : "Not available",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: product.inStock ? Colors.green : Colors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- SECTION TITLE -----------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ----------------- DESCRIPTION -----------------
  Widget _description(ProductModel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        p.description,
        textAlign: TextAlign.start,
        style: GoogleFonts.poppins(
          fontSize: 14,
          height: 1.5,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  // ----------------- OEM BOX -----------------
  Widget _oemBox(ProductModel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.settings, size: 28, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              "OEM: ${p.oemNumber}",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  // ----------------- BOTTOM BUY BAR -----------------
  Widget _bottomBuyBar(ProductModel p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3A55FF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Add to Cart",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xff3A55FF), width: 2),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: Color(0xff3A55FF)),
          )
        ],
      ),
    );
  }
}
