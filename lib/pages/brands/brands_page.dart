import 'package:doctor_car_app/data/brands/brands_data.dart';
import 'package:flutter/material.dart';
import 'models_page.dart';

class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final filteredBrands = CarBrandData.brands.where((brand) {
      final name = brand["name"]!.toLowerCase();
      return name.contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      // -----------------------
      // AppBar
      // -----------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Brands",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // -----------------------
      // Body
      // -----------------------
      body: Column(
        children: [
          const SizedBox(height: 10),

          // -----------------------
          // Search Bar
          // -----------------------
          Padding(
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
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search brands…",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() => searchText = value);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // -----------------------
          // Brands Grid (2 columns)
          // -----------------------
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredBrands.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final brand = filteredBrands[index];

                return _brandCard(
                  context,
                  brandId: brand["id"] as int,
                  name: brand["name"]!,
                  logoUrl: brand["logo"]!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BRAND CARD (Improved + Fixed brandId)
  // =====================================================
  Widget _brandCard(BuildContext context,
      {required int brandId, required String name, required String logoUrl}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModelsPage(
              brandId: brandId,
              brandName: name,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.network(
                  logoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.error, size: 40, color: Colors.red),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
