import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../data/products/products_data.dart';
import 'product_details_page.dart';

class ProductListPage extends StatefulWidget {
  final int? categoryId;
  final int? modelId;
  final int? brandId;

  const ProductListPage({
    super.key,
    this.categoryId,
    this.modelId,
    this.brandId,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String searchText = "";
  RangeValues priceRange = const RangeValues(50, 500);

  @override
  Widget build(BuildContext context) {
    // ------------------------------
    // FILTER PRODUCTS
    // ------------------------------
    List<ProductModel> filtered = allProducts.where((p) {
      bool matchesCategory =
          widget.categoryId == null || p.categoryId == widget.categoryId;
      bool matchesModel =
          widget.modelId == null || p.carModelId == widget.modelId;
      bool matchesBrand = widget.brandId == null || p.brandId == widget.brandId;
      bool matchesSearch =
          p.name.toLowerCase().contains(searchText.toLowerCase());

      bool matchesPrice =
          p.price >= priceRange.start && p.price <= priceRange.end;

      return matchesCategory &&
          matchesBrand &&
          matchesModel &&
          matchesSearch &&
          matchesPrice;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "قطع الغيار",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // ------------------------------
      // BODY
      // ------------------------------
      body: Column(
        children: [
          const SizedBox(height: 10),
          _searchBar(),
          _filters(), // <-- NEW filters
          const SizedBox(height: 10),

          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      "لا توجد نتائج",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (_, i) {
                      return _productCard(filtered[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // SEARCH BAR
  // ------------------------------
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "ابحث عن القطعة…",
                  border: InputBorder.none,
                ),
                onChanged: (txt) {
                  setState(() => searchText = txt);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // FILTER BAR
  // ------------------------------
  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.filter_alt, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "تصفية النتائج",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // --- price range ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("السعر"),
                RangeSlider(
                  values: priceRange,
                  min: 0,
                  max: 1000,
                  activeColor: Colors.blue,
                  onChanged: (v) {
                    setState(() => priceRange = v);
                  },
                ),
                Text(
                  "من ${priceRange.start.toInt()} ريال • إلى ${priceRange.end.toInt()} ريال",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // PRODUCT CARD (PRO)
  // ------------------------------
  Widget _productCard(ProductModel p) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: p),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  p.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${p.price} ريال",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        p.inStock ? Icons.check_circle : Icons.cancel,
                        color: p.inStock ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        p.inStock ? "متوفر" : "غير متوفر",
                        style: TextStyle(
                          color: p.inStock ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
