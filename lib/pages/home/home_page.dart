import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// DATA
import '../../data/brands/brands_data.dart';
import '../../data/products/products_data.dart';
import '../../data/categories/categories_data.dart';

// MODELS
import '../../models/product_model.dart';

// PAGES
import '../search/search_page.dart';
import '../brands/brands_page.dart';
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

class _HomePageState extends State<HomePage> {
  int bottomIndex = 0;

  final PageController bannerCtrl = PageController(viewportFraction: 0.92);
  Timer? _bannerTimer;
  int _bannerIndex = 0;

  final List<String> _banners = const [
    "assets/images/offer1.png",
    "assets/images/offer2.png",
    "assets/images/offer3.png",
  ];

  static const String _productPlaceholderAsset =
      "assets/images/placeholder_part.png";
  static const String _brandPlaceholderAsset =
      "assets/images/placeholder_brand.png";
  static const String _heroCarAsset = "assets/images/home/hero_car.png";

  static const Color _bg = Color(0xFF07111B);
  static const Color _bg2 = Color(0xFF0A1727);
  static const Color _bg3 = Color(0xFF040B13);

  static const Color _primary = Color(0xFF1677FF);
  static const Color _primaryDark = Color(0xFF0E5FC2);
  static const Color _accent = Color(0xFF8ED2FF);

  static const Color _textMain = Color(0xFFF4F7FB);
  static const Color _textSub = Color(0xFFC5D1DD);
  static const Color _textHint = Color(0xFF8FA3B7);

  static const Color _success = Color(0xFF42D392);
  static const Color _danger = Color(0xFFFF7B7B);
  static const Color _warning = Color(0xFFFFC857);

  Color get _stroke => Colors.white.withOpacity(.08);
  Color get _softStroke => Colors.white.withOpacity(.05);

  LinearGradient get _screenGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0B1627),
          Color(0xFF081320),
          Color(0xFF050C15),
        ],
      );

  LinearGradient get _primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF34A4FF),
          Color(0xFF1565C0),
        ],
      );

  LinearGradient get _heroGradient => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF173B63),
          Color(0xFF102742),
          Color(0xFF091522),
        ],
      );

  LinearGradient get _glassGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(.10),
          Colors.white.withOpacity(.05),
          Colors.white.withOpacity(.03),
        ],
      );

  List<BoxShadow> get _softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.28),
          blurRadius: 22,
          offset: const Offset(0, 12),
        ),
      ];

  List<BoxShadow> get _blueGlow => [
        BoxShadow(
          color: _primary.withOpacity(.20),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: _accent.withOpacity(.09),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _startBannerAutoSlide();
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !bannerCtrl.hasClients || _banners.isEmpty) return;

      _bannerIndex = (_bannerIndex + 1) % _banners.length;
      bannerCtrl.animateToPage(
        _bannerIndex,
        duration: const Duration(milliseconds: 650),
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

  bool _hasRealProductImage(String url) {
    final lower = url.toLowerCase().trim();
    if (lower.isEmpty) return false;
    if (lower.contains("placeholder")) return false;
    if (lower.contains("random")) return false;
    if (lower.contains("dummy")) return false;
    if (lower.contains("unsplash")) return false;
    if (lower.contains("pexels")) return false;
    return true;
  }

  String _safeText(dynamic value, {String fallback = ""}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _getCategoryName(int id) {
    try {
      return categories.firstWhere((c) => c.id == id).name;
    } catch (_) {
      return "قسم";
    }
  }

  List<ProductModel> get _inStockProducts {
    final list = allProducts.where((p) => p.inStock).toList();
    list.sort((a, b) => a.price.compareTo(b.price));
    return list;
  }

  List<ProductModel> get _featuredProducts {
    final products = [..._inStockProducts];
    products.sort((a, b) {
      final aScore =
          (_hasRealProductImage(a.imageUrl) ? 2 : 0) + (a.inStock ? 2 : 0);
      final bScore =
          (_hasRealProductImage(b.imageUrl) ? 2 : 0) + (b.inStock ? 2 : 0);
      if (aScore != bScore) return bScore.compareTo(aScore);
      return a.price.compareTo(b.price);
    });
    return products.take(6).toList();
  }

  List<ProductModel> get _recommendedProducts {
    final products = [...allProducts];
    products.sort((a, b) {
      if (a.inStock != b.inStock) return a.inStock ? -1 : 1;
      final aReal = _hasRealProductImage(a.imageUrl) ? 1 : 0;
      final bReal = _hasRealProductImage(b.imageUrl) ? 1 : 0;
      if (aReal != bReal) return bReal.compareTo(aReal);
      return a.price.compareTo(b.price);
    });
    return products.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg3,
        floatingActionButton: _floatingCartButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _bottomNav(),
        body: Stack(
          children: [
            _backgroundDecor(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _header(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
                      _searchBar(),
                      const SizedBox(height: 18),
                      _heroSection(),
                      const SizedBox(height: 18),
                      _mainActionsSection(),
                      const SizedBox(height: 18),
                      _serviceHighlights(),
                      const SizedBox(height: 18),
                      _sectionTitle(
                        "العروض الحالية",
                        subtitle: "أفضل العروض والخدمات المميزة",
                        actionText: "عرض الكل",
                      ),
                      _bannerSlider(),
                      _sectionTitle(
                        "التسوق حسب القسم",
                        subtitle: "ابدأ بالقسم المناسب للقطعة",
                        actionText: "استكشف",
                      ),
                      _categoriesSection(),
                      _sectionTitle(
                        "اختر حسب الماركة",
                        subtitle: "حدد الشركة المصنعة أولاً",
                        actionText: "كل الماركات",
                      ),
                      _brands(),
                      _sectionTitle(
                        "منتجات جاهزة للطلب",
                        subtitle: "منتجات متوفرة الآن",
                        actionText: "عرض الكل",
                      ),
                      _productSlider(_featuredProducts),
                      _sectionTitle(
                        "ترشيحات مميزة",
                        subtitle: "اختيارات مقترحة لسهولة الوصول",
                        actionText: "المزيد",
                      ),
                      _productGrid(_recommendedProducts),
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

  Widget _backgroundDecor() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(gradient: _screenGradient),
          ),
        ),
        Positioned(
          top: -90,
          right: -60,
          child: _glowOrb(220, _accent.withOpacity(.11)),
        ),
        Positioned(
          top: 260,
          left: -80,
          child: _glowOrb(180, _primary.withOpacity(.08)),
        ),
        Positioned(
          bottom: -120,
          right: -30,
          child: _glowOrb(220, _primaryDark.withOpacity(.10)),
        ),
      ],
    );
  }

  Widget _glowOrb(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 56, sigmaY: 56),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  SliverAppBar _header() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 118,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(bottom: 14, right: 16, left: 16),
        title: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: _primaryGradient,
                border: Border.all(color: Colors.white.withOpacity(.10)),
                boxShadow: _blueGlow,
              ),
              child: const Icon(
                Icons.car_repair_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Doctor Car",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: _textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "Auto Parts Store",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: _textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
                _bg.withOpacity(.98),
                _bg2.withOpacity(.90),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: _headerButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _headerButton(
            icon: Icons.shopping_bag_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _tap(onTap),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _softStroke),
          ),
          child: Icon(icon, color: _textMain, size: 22),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: InkWell(
            onTap: () => _tap(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            }),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: _glassGradient,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _stroke),
                boxShadow: _softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "ابحث عن قطعة، رقم OEM، ماركة أو موديل...",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: _textSub,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.tune_rounded,
                    color: _accent,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: _heroGradient,
          border: Border.all(color: Colors.white.withOpacity(.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.32),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: _accent.withOpacity(.08),
              blurRadius: 20,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.04),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withOpacity(.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(.10),
                            ),
                          ),
                          child: Text(
                            "SMART AUTO EXPERIENCE",
                            style: GoogleFonts.cairo(
                              color: _accent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "اختار سيارتك\nووصل للقطعة المناسبة",
                          style: GoogleFonts.cairo(
                            color: _textMain,
                            fontSize: 25,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "رحلة شراء أوضح للعميل: ابدأ بالماركة والموديل ثم شاهد فقط القطع المناسبة والمتوفرة.",
                          style: GoogleFonts.cairo(
                            color: _textSub,
                            fontSize: 13,
                            height: 1.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _heroActionButton(
                              title: "ابدأ باختيار السيارة",
                              icon: Icons.directions_car_filled_rounded,
                              filled: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BrandsPage(),
                                  ),
                                );
                              },
                            ),
                            _heroActionButton(
                              title: "تصفح المنتجات",
                              icon: Icons.inventory_2_rounded,
                              filled: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductListPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 104,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(.12),
                          Colors.white.withOpacity(.04),
                        ],
                      ),
                      border: Border.all(color: Colors.white.withOpacity(.08)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        _heroCarAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: _primaryGradient,
                                  boxShadow: _blueGlow,
                                ),
                                child: const Icon(
                                  Icons.directions_car_filled_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "SMART\nMATCH",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color: _accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroActionButton({
    required String title,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          gradient: filled ? _primaryGradient : null,
          color: filled ? null : Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: filled
                ? Colors.white.withOpacity(.08)
                : Colors.white.withOpacity(.10),
          ),
          boxShadow: filled ? _blueGlow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _mainActionCard(
              icon: Icons.directions_car_filled_rounded,
              title: "اختيار السيارة",
              subtitle: "ابدأ بالماركة والموديل",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BrandsPage()),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _mainActionCard(
              icon: Icons.grid_view_rounded,
              title: "الأقسام",
              subtitle: "تصفح حسب نوع القطعة",
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _mainActionCard(
              icon: Icons.shopping_bag_rounded,
              title: "كل المنتجات",
              subtitle: "عرض سريع ومباشر",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductListPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          gradient: _glassGradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _stroke),
          boxShadow: _softShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: _primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _blueGlow,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: _textMain,
                fontWeight: FontWeight.w900,
                fontSize: 12.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: _textHint,
                fontWeight: FontWeight.w700,
                fontSize: 10.8,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceHighlights() {
    final items = [
      {
        "icon": Icons.verified_user_rounded,
        "title": "توافق أدق",
        "sub": "مطابقة أوضح",
      },
      {
        "icon": Icons.image_search_rounded,
        "title": "صور قطع",
        "sub": "عرض أوضح",
      },
      {
        "icon": Icons.local_shipping_rounded,
        "title": "طلب أسرع",
        "sub": "خطوات أسهل",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          items.length,
          (i) {
            final item = items[i];
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(left: i == items.length - 1 ? 0 : 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  gradient: _glassGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _softStroke),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: _primaryGradient,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        item["icon"] as IconData,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item["title"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: _textMain,
                        fontSize: 12.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item["sub"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: _textHint,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title, {
    String? subtitle,
    String? actionText,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: _primaryGradient,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _textMain,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null)
            Text(
              actionText,
              style: GoogleFonts.cairo(
                color: _accent,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }

  Widget _bannerSlider() {
    if (_banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: bannerCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, i) {
              final active = i == _bannerIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: active ? _blueGlow : _softShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        _banners[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white.withOpacity(.05),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: Colors.white.withOpacity(.65),
                              size: 46,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(.58),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 14,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: _primaryGradient,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "عرض خاص",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        left: 16,
                        bottom: 16,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "أفضل عروض قطع الغيار والخدمات الأكثر طلبًا لسيارتك",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.13),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(.16),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _bannerIndex == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    _bannerIndex == i ? _accent : Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoriesSection() {
    final cats = categories;

    return SizedBox(
      height: 126,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final c = cats[i];
          final icon = _iconForCategory(c.name);

          return InkWell(
            onTap: () => _tap(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListPage(categoryId: c.id),
                ),
              );
            }),
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              width: 98,
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: _primaryGradient,
                      boxShadow: _blueGlow,
                      border: Border.all(
                        color: Colors.white.withOpacity(.10),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 92,
                    child: Text(
                      c.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: _textMain,
                        fontWeight: FontWeight.w800,
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

  IconData _iconForCategory(String name) {
    final text = name.trim().toLowerCase();

    if (text.contains('زيت')) return Icons.oil_barrel_rounded;
    if (text.contains('فلتر')) return Icons.filter_alt_rounded;
    if (text.contains('فرامل')) return Icons.car_repair_rounded;
    if (text.contains('بطاري')) return Icons.battery_charging_full_rounded;
    if (text.contains('كهرب')) return Icons.electrical_services_rounded;
    if (text.contains('تعليق')) return Icons.settings_input_component_rounded;
    if (text.contains('إطار') || text.contains('اطار')) {
      return Icons.tire_repair_rounded;
    }
    if (text.contains('محرك')) return Icons.precision_manufacturing_rounded;

    return Icons.category_rounded;
  }

  Widget _brands() {
    final brands = CarBrandData.brands;

    return SizedBox(
      height: 166,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        itemBuilder: (_, i) {
          final brand = brands[i];
          final int brandId = brand["id"] as int;
          final String name = brand["name"] as String;
          final String logo = brand["logo"] as String;

          return InkWell(
            onTap: () => _tap(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ModelsPage(
                    brandId: brandId,
                    brandName: name,
                  ),
                ),
              );
            }),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              margin: const EdgeInsets.only(left: 14),
              width: 132,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: _glassGradient,
                border: Border.all(color: _stroke),
                boxShadow: _softShadow,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.network(
                        logo,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          _brandPlaceholderAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: _primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.directions_car_filled_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "لا يوجد شعار",
                                style: GoogleFonts.cairo(
                                  color: _textHint,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        color: _textMain,
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

  Widget _productSlider(List<ProductModel> list) {
    return SizedBox(
      height: 318,
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
                  builder: (_) => ProductDetailsPage(product: p),
                ),
              );
            }),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              margin: const EdgeInsets.only(left: 14),
              width: 206,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: _glassGradient,
                border: Border.all(color: _stroke),
                boxShadow: _softShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _productImage(p),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(.35),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _warning.withOpacity(.16),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: _warning.withOpacity(.25),
                                ),
                              ),
                              child: Text(
                                "الأكثر طلبًا",
                                style: GoogleFonts.cairo(
                                  color: _warning,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10.5,
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
                              color: _textMain,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _safeText(p.oemNumber, fallback: "OEM غير متوفر"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 11.6,
                              color: _textHint,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _success.withOpacity(.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  p.inStock ? "متوفر" : "غير متوفر",
                                  style: GoogleFonts.cairo(
                                    color: p.inStock ? _success : _danger,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${p.price.toStringAsFixed(0)} ريال",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: _accent,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              gradient: _primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                "عرض التفاصيل",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
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

  Widget _productGrid(List<ProductModel> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: .67,
        ),
        itemBuilder: (_, i) {
          final p = list[i];
          return InkWell(
            onTap: () => _tap(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsPage(product: p),
                ),
              );
            }),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: _glassGradient,
                border: Border.all(color: _stroke),
                boxShadow: _softShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _productImage(p),
                          Positioned(
                            left: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: p.inStock
                                    ? _success.withOpacity(.14)
                                    : _danger.withOpacity(.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: p.inStock
                                      ? _success.withOpacity(.24)
                                      : _danger.withOpacity(.24),
                                ),
                              ),
                              child: Text(
                                p.inStock ? "متوفر" : "غير متوفر",
                                style: GoogleFonts.cairo(
                                  color: p.inStock ? _success : _danger,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: _textMain,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getCategoryName(p.categoryId),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: _textHint,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${p.price.toStringAsFixed(0)} ريال",
                            style: GoogleFonts.cairo(
                              color: _accent,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: _primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                "عرض التفاصيل",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
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

  Widget _productImage(ProductModel p) {
    if (_hasRealProductImage(p.imageUrl)) {
      return Image.network(
        p.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _productPlaceholder(showLabel: true);
        },
        errorBuilder: (_, __, ___) => _productPlaceholder(showLabel: true),
      );
    }
    return _productPlaceholder(showLabel: true);
  }

  Widget _productPlaceholder({bool showLabel = false}) {
    return Container(
      color: Colors.white.withOpacity(.04),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Image.asset(
              _productPlaceholderAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: _primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
          ),
          if (showLabel)
            Positioned(
              right: 10,
              left: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "صورة القطعة غير مضافة بعد",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _floatingCartButton() {
    return SizedBox(
      height: 72,
      width: 72,
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
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _primaryGradient,
            boxShadow: _blueGlow,
            border: Border.all(color: Colors.white.withOpacity(.10)),
          ),
          child: const Icon(
            Icons.shopping_cart_rounded,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.45),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                label: "الرئيسية",
                onTap: () => setState(() => bottomIndex = 0),
              ),
              _navItem(
                icon: Icons.receipt_long_rounded,
                index: 1,
                label: "الطلبات",
                onTap: () {
                  setState(() => bottomIndex = 1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersPage()),
                  );
                },
              ),
              const SizedBox(width: 56),
              _navItem(
                icon: Icons.favorite_border_rounded,
                index: 2,
                label: "المفضلة",
                onTap: () => setState(() => bottomIndex = 2),
              ),
              _navItem(
                icon: Icons.menu_rounded,
                index: 3,
                label: "المزيد",
                onTap: () {
                  setState(() => bottomIndex = 3);
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
    required String label,
    required VoidCallback onTap,
  }) {
    final active = bottomIndex == index;
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 60,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: active ? _accent : Colors.white.withOpacity(.55),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: active ? _accent : Colors.white.withOpacity(.45),
                fontSize: 10.6,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
