import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
// DOCTOR CAR SHOP - ULTRA PRO (NEON GREEN THEME)
// ------------------------------------------------------------
class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int bottomIndex = 0;

  final PageController bannerCtrl = PageController(viewportFraction: 0.92);
  Timer? _bannerTimer;
  int _bannerIndex = 0;

  // ✅ Banner items (Assets) — تم إصلاحها
  final List<String> _banners = const [
    "assets/images/offer3.png",
    "assets/images/offer2.png",
    "assets/images/offer1.png",
  ];

  // ================== BRAND TOKENS ==================
  static const Color _bg1 = Color(0xff0B1220);
  // ignore: unused_field
  static const Color _bg2 = Color(0xff081837);
  static const Color _bg3 = Color(0xff06101C);

  // ✅ نفس الهوية اللي ماشيين عليها
  static const Color _brand = Color.fromARGB(255, 17, 103, 189);

  Color get _brand2 =>
      Color.lerp(_brand, const Color.fromARGB(255, 6, 48, 131), 0.22)!;
  Color get _brand3 => Color.lerp(_brand, Colors.white, 0.18)!;

  Color get _stroke => Colors.white.withOpacity(.10);
  Color get _textMain => Colors.white;
  Color get _textSub => Colors.white.withOpacity(.75);

  LinearGradient get _screenBg => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromARGB(255, 19, 51, 116),
          Color.lerp(_bg1, _brand2, 0.07)!,
          _bg3,
        ],
      );

  /// ✅ أخضر → أبيض (زي ما طلبت)
  LinearGradient get _greenWhite => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          _brand.withOpacity(.92),
          Color.lerp(_brand, Colors.white, .62)!,
          Colors.white,
        ],
        stops: const [0.0, 0.56, 1.0],
      );

  /// Glass gradient
  LinearGradient get _glass => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(.09),
          Colors.white.withOpacity(.06),
          Colors.white.withOpacity(.04),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  List<BoxShadow> get _shadowSm => [
        BoxShadow(
          color: const Color.fromARGB(255, 13, 89, 175).withOpacity(.22),
          blurRadius: 16,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get _greenGlow => [
        BoxShadow(
          color: _brand.withOpacity(.22),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: const Color.fromARGB(255, 14, 70, 139).withOpacity(.22),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  // ================== INIT ==================
  @override
  void initState() {
    super.initState();
    _startBannerAutoSlide();
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (!bannerCtrl.hasClients) return;
      if (_banners.isEmpty) return;

      _bannerIndex = (_bannerIndex + 1) % _banners.length;
      bannerCtrl.animateToPage(
        _bannerIndex,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    bannerCtrl.dispose();
    super.dispose();
  }

  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // ✅ clamp text scale to avoid overflow
    final mq = MediaQuery.of(context);
    final scale = mq.textScaler.scale(1.0);
    final clamped = scale.clamp(1.0, 1.12);
    final fixedMq = mq.copyWith(textScaler: TextScaler.linear(clamped));

    return MediaQuery(
      data: fixedMq,
      child: Scaffold(
        backgroundColor: _bg1,
        floatingActionButton: _floatingCartButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _bottomNav(),
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: _screenBg)),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _header(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
                      _searchBar(),
                      const SizedBox(height: 16),
                      _introCard(),
                      const SizedBox(height: 16),
                      _bannerSlider(),
                      const SizedBox(height: 10),
                      _sectionTitle("الأقسام"),
                      _categories(),
                      _sectionTitle("ماركات السيارات"),
                      _brands(),
                      _sectionTitle("الأكثر رواجاً"),
                      _productSlider(allProducts.take(6).toList()),
                      _sectionTitle("مقترحات خاصة لك"),
                      _productSlider(allProducts.reversed.take(6).toList()),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER (PRO)
  // ------------------------------------------------------------
  SliverAppBar _header() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 132,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: _greenWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black.withOpacity(.08)),
              ),
              child: const Icon(Icons.storefront_rounded,
                  size: 16, color: Colors.black),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                "Doctor Car Shop",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _bg3,
                Color.lerp(_bg3, _brand2, 0.12)!,
                Colors.transparent,
              ],
              stops: const [0.0, 0.78, 1.0],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(.06),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _iconBtn(
            icon: Icons.shopping_cart_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _tap(onTap),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(.10)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH BAR (GLASS)
  // ------------------------------------------------------------
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: InkWell(
            onTap: () => _tap(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            }),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                gradient: _glass,
                border: Border.all(color: _stroke),
                borderRadius: BorderRadius.circular(18),
                boxShadow: _shadowSm,
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: _brand3, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "ابحث عن قطعة، ماركة، موديل…",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: _textSub,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: _brand.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _brand.withOpacity(.22)),
                    ),
                    child: Text(
                      "بحث",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
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
  // INTRO CARD (GREEN-WHITE)
  // ------------------------------------------------------------
  Widget _introCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 138,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: _greenGlow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Container(decoration: BoxDecoration(gradient: _greenWhite)),
              Positioned(
                right: -40,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.22),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -35,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(.06),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "متجر Doctor Car",
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "قطع أصلية • جودة عالية • شحن سريع",
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(.72),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.black.withOpacity(.10)),
                          ),
                          child: Text(
                            "خصومات اليوم",
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.local_offer_rounded,
                            color: Colors.black.withOpacity(.75), size: 18),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BANNER SLIDER (ASSETS) + INDICATORS
  // ------------------------------------------------------------
  Widget _bannerSlider() {
    if (_banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: bannerCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, i) {
              final active = i == _bannerIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: active ? _greenGlow : _shadowSm,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        _banners[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white.withOpacity(.06),
                          child: Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.white.withOpacity(.65), size: 46),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(.40),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 14,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(.12)),
                          ),
                          child: Text(
                            "شوف العرض",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _bannerIndex == i ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    _bannerIndex == i ? _brand : Colors.white.withOpacity(.22),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------
  Widget _sectionTitle(String txt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 26,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              txt,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORIES (NEON CIRCLES)
  // ------------------------------------------------------------
  Widget _categories() {
    final List<Map<String, dynamic>> cats = [
      {"icon": Icons.tire_repair, "txt": "جنوط", "id": 1},
      {"icon": Icons.battery_6_bar, "txt": "بطاريات", "id": 2},
      {"icon": Icons.handyman, "txt": "قطع غيار", "id": 3},
      {"icon": Icons.oil_barrel, "txt": "زيوت", "id": 4},
      {"icon": Icons.local_car_wash, "txt": "تنظيف", "id": 5},
    ];

    return SizedBox(
      height: 116,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final IconData icon = cats[i]["icon"] as IconData;
          final String txt = cats[i]["txt"] as String;
          final int id = cats[i]["id"] as int;

          return InkWell(
            onTap: () => _tap(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProductListPage(categoryId: id)),
              );
            }),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: _greenWhite,
                      shape: BoxShape.circle,
                      boxShadow: _greenGlow,
                    ),
                    child: Icon(icon, color: Colors.black, size: 32),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 78,
                    child: Text(
                      txt,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // BRANDS (GLASS CARDS)
  // ------------------------------------------------------------
  Widget _brands() {
    final brands = CarBrandData.brands;

    return SizedBox(
      height: 150,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        itemBuilder: (_, i) {
          final String name = brands[i]["name"]!;
          final String logo = brands[i]["logo"]!;

          return InkWell(
            onTap: () => _tap(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ModelsPage(
                    brandId: i + 1,
                    brandName: name,
                  ),
                ),
              );
            }),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: _glass,
                border: Border.all(color: _stroke),
                boxShadow: _shadowSm,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        logo,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_not_supported,
                          color: Colors.white.withOpacity(.65),
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 13.2,
                      ),
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
  // PRODUCT SLIDER (PRO GLASS)
  // ------------------------------------------------------------
  Widget _productSlider(List<ProductModel> list) {
    return SizedBox(
      height: 270,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (_, i) {
          final ProductModel p = list[i];

          return InkWell(
            onTap: () => _tap(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProductDetailsPage(product: p)),
              );
            }),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              width: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: _glass,
                border: Border.all(color: _stroke),
                boxShadow: _shadowSm,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            p.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white.withOpacity(.05),
                              child: Center(
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.white.withOpacity(.65),
                                    size: 44),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(.55),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _brand.withOpacity(.18),
                                borderRadius: BorderRadius.circular(999),
                                border:
                                    Border.all(color: _brand.withOpacity(.22)),
                              ),
                              child: Text(
                                "PRO",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
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
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${p.price} ريال",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.5,
                                    color: _brand3,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: _greenWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.black.withOpacity(.08)),
                                ),
                                child: const Icon(Icons.add_rounded,
                                    color: Colors.black, size: 18),
                              ),
                            ],
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
  // FLOAT CART BUTTON (CENTER)
  // ------------------------------------------------------------
  Widget _floatingCartButton() {
    return SizedBox(
      height: 70,
      width: 70,
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.transparent,
        onPressed: () => _tap(() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          );
        }),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: _greenWhite,
            shape: BoxShape.circle,
            boxShadow: _greenGlow,
            border: Border.all(color: Colors.black.withOpacity(.10)),
          ),
          child: const Icon(Icons.shopping_cart_rounded,
              size: 30, color: Colors.black),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAV (PREMIUM)
  // ------------------------------------------------------------
  Widget _bottomNav() {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: Colors.white.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.45),
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BottomAppBar(
          color: Colors.transparent,
          notchMargin: 10,
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.home_rounded,
                index: 0,
                onTap: () => setState(() => bottomIndex = 0),
              ),
              _navItem(
                icon: Icons.list_alt_rounded,
                index: 1,
                onTap: () {
                  setState(() => bottomIndex = 1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersPage()),
                  );
                },
              ),
              const SizedBox(width: 52), // مكان زر الكارت
              _navItem(
                icon: Icons.favorite_border_rounded,
                index: 2,
                onTap: () {
                  // لو عندك Favorites لاحقاً
                  _tap(() {});
                },
              ),
              _navItem(
                icon: Icons.menu_rounded,
                index: 3,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MorePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required int index,
    required VoidCallback onTap,
  }) {
    final active = bottomIndex == index;
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 28,
          color: active ? _brand3 : Colors.white.withOpacity(.60),
        ),
      ),
    );
  }
}
