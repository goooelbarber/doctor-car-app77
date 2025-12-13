import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// DATA
import '../../data/brands/brands_data.dart';
import '../../data/products/products_data.dart';

// MODELS
import '../../models/product_model.dart';

// PAGES
import '../search/search_page.dart';
import '../brands/models_page.dart';
import '../products/product_details_page.dart';
import '../products/product_list_page.dart';
import '../cart/cart_page.dart';
import '../orders/orders_page.dart';
import '../more/more_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ------------------------------------------------------------
// ULTRA LUXURY HOME PAGE
// ------------------------------------------------------------
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int bottomIndex = 0;
  final PageController bannerCtrl = PageController(viewportFraction: 0.90);

  @override
  void initState() {
    super.initState();
    _autoSlideBanner();
  }

  void _autoSlideBanner() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      if (bannerCtrl.hasClients) {
        bannerCtrl.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }

      _autoSlideBanner();
    });
  }

  // GOLD THEME
  LinearGradient get goldGradient => const LinearGradient(
        colors: [Color(0xffEAC770), Color(0xffC6932B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  Color get darkBg => const Color(0xff0B0D15);

  // ------------------------------------------------------------
  // BUILD UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      floatingActionButton: _floatingCartButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _bottomNav(),
      body: CustomScrollView(
        slivers: [
          _header(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _searchBar(),
                const SizedBox(height: 20),
                _luxuryIntroCard(),
                const SizedBox(height: 20),
                _bannerSlider(),
                _title("الأقسام الفاخرة"),
                _categories(),
                _title("ماركات السيارات"),
                _brands(),
                _title("الأكثر رواجاً"),
                _productSlider(allProducts.take(6).toList()),
                _title("مقترحات خاصة لك"),
                _productSlider(allProducts.reversed.take(6).toList()),
                const SizedBox(height: 120),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------
  SliverAppBar _header() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 130,
      backgroundColor: darkBg,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(bottom: 14, left: 16),
        title: ShaderMask(
          shaderCallback: (bounds) => goldGradient.createShader(bounds),
          child: Text(
            "Doctor Car Shop",
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: goldGradient.withOpacity(0.25),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH BAR (Glassmorphism)
  // ------------------------------------------------------------
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    "ابحث عن قطعة، ماركة، موديل…",
                    style: GoogleFonts.cairo(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LUXURY INTRO CARD
  // ------------------------------------------------------------
  Widget _luxuryIntroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(.6),
              Colors.black.withOpacity(.3),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(.2),
              blurRadius: 25,
              spreadRadius: -5,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.withOpacity(.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "مرحباً بك في متجر السيارات الفاخر",
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "قطع أصلية • جودة عالية • شحن سريع",
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BANNER SLIDER
  // ------------------------------------------------------------
  Widget _bannerSlider() {
    final items = [
      "assets/images/offer3.png",
      "assets/images/offer2.png",
      "assets/images/offer1.png",
    ];

    return SizedBox(
      height: 190,
      child: PageView.builder(
        controller: bannerCtrl,
        itemCount: items.length,
        itemBuilder: (_, i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: DecorationImage(
                image: NetworkImage(items[i]),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.45),
                  blurRadius: 18,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------
  Widget _title(String txt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        txt,
        style: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORIES
  // ------------------------------------------------------------
  Widget _categories() {
    final List<Map<String, dynamic>> cats = [
      {"icon": Icons.tire_repair, "txt": "جنوط", "id": 1},
      {"icon": Icons.battery_6_bar, "txt": "بطاريات", "id": 2},
      {"icon": Icons.handyman, "txt": "قطع غيار", "id": 3},
      {"icon": Icons.oil_barrel, "txt": "زيوت", "id": 4},
      {"icon": Icons.oil_barrel, "txt": "زيوت", "id": 4},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final IconData icon = cats[i]["icon"] as IconData;
          final String txt = cats[i]["txt"] as String;
          final int id = cats[i]["id"] as int;

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductListPage(categoryId: id),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: goldGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(.3),
                        blurRadius: 18,
                      )
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.black87,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  txt,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.2,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // BRANDS
  // ------------------------------------------------------------
  Widget _brands() {
    final brands = CarBrandData.brands;

    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        itemBuilder: (_, i) {
          final String name = brands[i]["name"]!;
          final String logo = brands[i]["logo"]!;

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ModelsPage(
                  brandId: i + 1,
                  brandName: name,
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 110,
              decoration: BoxDecoration(
                gradient: goldGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.3),
                    blurRadius: 12,
                  )
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        logo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCT SLIDER
  // ------------------------------------------------------------
  Widget _productSlider(List<ProductModel> list) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (_, i) {
          final ProductModel p = list[i];

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsPage(product: p),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(.06),
                border: Border.all(color: Colors.white24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.5),
                    blurRadius: 25,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        p.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(.8),
                            Colors.black.withOpacity(.3),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                goldGradient.createShader(bounds),
                            child: Text(
                              "${p.price} ريال",
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // FLOAT CART BUTTON (PREMIUM CENTER DOCK)
  // ------------------------------------------------------------
  Widget _floatingCartButton() {
    return SizedBox(
      height: 70,
      width: 70,
      child: FloatingActionButton(
        elevation: 12,
        splashColor: Colors.amber.withOpacity(.3),
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartPage()),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => goldGradient.createShader(bounds),
          child: const Icon(Icons.shopping_cart, size: 30, color: Colors.white),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PREMIUM BOTTOM NAVIGATION (LUXURY STYLE)
  // ------------------------------------------------------------
  Widget _bottomNav() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xffEAC770),
          unselectedItemColor: Colors.white54,
          showUnselectedLabels: false,
          currentIndex: bottomIndex,
          onTap: (i) {
            setState(() => bottomIndex = i);
            if (i == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersPage()),
              );
            } else if (i == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MorePage()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 28), label: ""),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt, size: 26), label: ""),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu, size: 28), label: ""),
          ],
        ),
      ),
    );
  }
}
