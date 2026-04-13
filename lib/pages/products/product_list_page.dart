import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../data/products/products_data.dart';
import '../../data/categories/categories_data.dart';
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
  RangeValues priceRange = const RangeValues(0, 5000);
  bool showInStockOnly = false;
  bool showCompatibleOnly = true;
  String sortMode = "recommended";

  // ignore: unused_field
  static const Color _bg = Color(0xFF07111B);
  static const Color _bg3 = Color(0xFF040A12);
  static const Color _surface2 = Color(0xFF132235);

  static const Color _brand = Color(0xFF1565C0);
  static const Color _brandSoft = Color(0xFF8FD3FF);

  static const Color _textMain = Color(0xFFF5F7FB);
  static const Color _textSub = Color(0xFFB8C5D4);
  static const Color _textHint = Color(0xFF8EA1B5);
  static const Color _success = Color(0xFF7DD3AE);
  static const Color _danger = Color(0xFFFF7B7B);
  static const Color _warning = Color(0xFFFFC857);

  int? selectedCategoryId;

  Color get _stroke => Colors.white.withOpacity(.08);
  Color get _softStroke => Colors.white.withOpacity(.05);

  LinearGradient get _screenBg => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A1830),
          Color(0xFF091321),
          Color(0xFF050B14),
        ],
      );

  LinearGradient get _cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(.09),
          Colors.white.withOpacity(.04),
          Colors.white.withOpacity(.02),
        ],
      );

  LinearGradient get _buttonGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2A8CFF),
          Color(0xFF0C5FB8),
        ],
      );

  List<BoxShadow> get _softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.26),
          blurRadius: 20,
          offset: const Offset(0, 12),
        ),
      ];

  List<BoxShadow> get _blueGlow => [
        BoxShadow(
          color: _brandSoft.withOpacity(.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: _brand.withOpacity(.16),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.categoryId;
  }

  List<ProductModel> get _allCompatibleProducts {
    return allProducts.where((p) {
      final matchesBrand =
          widget.brandId == null || p.brandId == widget.brandId;
      final matchesModel =
          widget.modelId == null || p.carModelId == widget.modelId;
      return matchesBrand && matchesModel;
    }).toList();
  }

  List<int> get _availableCategoryIds {
    final ids =
        _allCompatibleProducts.map((e) => e.categoryId).toSet().toList();
    ids.sort();
    return ids;
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

  String _searchableProductText(ProductModel p) {
    return [
      _safeText(p.name),
      _safeText(p.oemNumber),
      _safeText(p.description),
      _getCategoryName(p.categoryId),
    ].join(" ").toLowerCase();
  }

  bool _looksLikeRealProductImage(String url) {
    final lower = url.toLowerCase().trim();
    if (lower.isEmpty) return false;
    if (lower.contains("placeholder")) return false;
    if (lower.contains("random")) return false;
    if (lower.contains("dummy")) return false;
    if (lower.contains("unsplash")) return false;
    if (lower.contains("pexels")) return false;
    return true;
  }

  int _recommendationScore(ProductModel p) {
    int score = 0;

    if (widget.brandId != null && p.brandId == widget.brandId) score += 3;
    if (widget.modelId != null && p.carModelId == widget.modelId) score += 5;
    if (selectedCategoryId != null && p.categoryId == selectedCategoryId) {
      score += 2;
    }
    if (p.inStock) score += 2;
    if (_looksLikeRealProductImage(_safeText(p.imageUrl))) score += 1;

    return score;
  }

  List<ProductModel> get _filteredProducts {
    final query = searchText.trim().toLowerCase();

    final filtered = allProducts.where((p) {
      final matchesBrand =
          widget.brandId == null || p.brandId == widget.brandId;
      final matchesModel =
          widget.modelId == null || p.carModelId == widget.modelId;

      final matchesCompatibility =
          showCompatibleOnly ? (matchesBrand && matchesModel) : true;

      final matchesCategory =
          selectedCategoryId == null || p.categoryId == selectedCategoryId;

      final matchesSearch =
          query.isEmpty || _searchableProductText(p).contains(query);

      final matchesPrice =
          p.price >= priceRange.start && p.price <= priceRange.end;

      final matchesStock = !showInStockOnly || p.inStock;

      return matchesCompatibility &&
          matchesCategory &&
          matchesSearch &&
          matchesPrice &&
          matchesStock;
    }).toList();

    switch (sortMode) {
      case "price_low":
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case "price_high":
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case "name":
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "stock":
        filtered.sort((a, b) {
          if (a.inStock == b.inStock) return a.name.compareTo(b.name);
          return a.inStock ? -1 : 1;
        });
        break;
      case "recommended":
      default:
        filtered.sort((a, b) {
          final s1 = _recommendationScore(a);
          final s2 = _recommendationScore(b);
          if (s1 != s2) return s2.compareTo(s1);
          if (a.inStock != b.inStock) return a.inStock ? -1 : 1;
          return a.price.compareTo(b.price);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;
    final categoryIds = _availableCategoryIds;
    final hasVehicleContext = widget.brandId != null || widget.modelId != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg3,
        body: Stack(
          children: [
            _backgroundDecor(),
            SafeArea(
              child: Column(
                children: [
                  _header(),
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              _vehicleFocusBanner(
                                  filtered.length, hasVehicleContext),
                              const SizedBox(height: 14),
                              _searchBar(),
                              const SizedBox(height: 14),
                              if (categoryIds.isNotEmpty)
                                _categoryTabs(categoryIds),
                              const SizedBox(height: 12),
                              _resultSummary(filtered.length),
                              const SizedBox(height: 12),
                              _filtersPanel(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        filtered.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: _emptyState(),
                              )
                            : SliverPadding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverGrid.builder(
                                  itemCount: filtered.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.62,
                                  ),
                                  itemBuilder: (_, i) {
                                    return _productCard(filtered[i]);
                                  },
                                ),
                              ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 28),
                        ),
                      ],
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

  Widget _backgroundDecor() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(gradient: _screenBg),
          ),
        ),
        Positioned(
          top: -110,
          right: -70,
          child: _glowOrb(250, _brandSoft.withOpacity(.10)),
        ),
        Positioned(
          top: 260,
          left: -90,
          child: _glowOrb(210, _brand.withOpacity(.08)),
        ),
        Positioned(
          bottom: -100,
          right: -30,
          child: _glowOrb(210, _brandSoft.withOpacity(.08)),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ProductsBackgroundPainter(
                lineColor: Colors.white.withOpacity(.022),
                glowColor: _brandSoft.withOpacity(.05),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glowOrb(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 54, sigmaY: 54),
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

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Row(
        children: [
          _iconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "قطع الغيار المتوافقة",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _textMain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _iconBtn(
            icon: Icons.filter_alt_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _softStroke),
        ),
        child: Icon(icon, color: _textMain, size: 21),
      ),
    );
  }

  Widget _vehicleFocusBanner(int count, bool hasVehicleContext) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _cardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _stroke),
          boxShadow: _softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: _buttonGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasVehicleContext
                        ? "تم تجهيز القطع حسب السيارة المحددة"
                        : "تصفح قطع الغيار حسب القسم أو البحث",
                    style: GoogleFonts.cairo(
                      color: _textMain,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasVehicleContext
                        ? "اعرض القطع المتوافقة فقط لتجربة أوضح وأسرع للعميل"
                        : "يمكنك التصفية حسب القسم والسعر والتوفر للوصول للقطعة المناسبة",
                    style: GoogleFonts.cairo(
                      color: _textSub,
                      fontSize: 12.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _success.withOpacity(.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _success.withOpacity(.24)),
              ),
              child: Text(
                "$count منتج",
                style: GoogleFonts.cairo(
                  color: _success,
                  fontSize: 11.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: _cardGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _stroke),
              boxShadow: _softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: _buttonGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    style: GoogleFonts.cairo(
                      color: _textMain,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: "ابحث باسم القطعة أو رقم OEM",
                      hintStyle: GoogleFonts.cairo(
                        color: _textHint,
                        fontWeight: FontWeight.w700,
                      ),
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
        ),
      ),
    );
  }

  Widget _categoryTabs(List<int> categoryIds) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        reverse: true,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _categoryChip(
              title: "كل الأقسام",
              active: selectedCategoryId == null,
              onTap: () => setState(() => selectedCategoryId = null),
            );
          }

          final id = categoryIds[i - 1];
          return _categoryChip(
            title: _getCategoryName(id),
            active: selectedCategoryId == id,
            onTap: () => setState(() => selectedCategoryId = id),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: categoryIds.length + 1,
      ),
    );
  }

  Widget _categoryChip({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? _buttonGradient : null,
          color: active ? null : Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? Colors.white.withOpacity(.08) : _softStroke,
          ),
          boxShadow: active ? _blueGlow : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 11.8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _resultSummary(int count) {
    final selectedCategoryName = selectedCategoryId == null
        ? "كل الأقسام"
        : _getCategoryName(selectedCategoryId!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: _cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _softStroke),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: _buttonGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "تم العثور على $count قطعة",
                    style: GoogleFonts.cairo(
                      color: _textMain,
                      fontSize: 14.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    selectedCategoryName,
                    style: GoogleFonts.cairo(
                      color: _textHint,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "عرض منظم",
              style: GoogleFonts.cairo(
                color: _brandSoft,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtersPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _cardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _stroke),
          boxShadow: _softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: _buttonGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.filter_alt_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "تصفية وفرز المنتجات",
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _textMain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chipButton(
                  active: showInStockOnly,
                  title: "المتوفر فقط",
                  onTap: () {
                    setState(() => showInStockOnly = !showInStockOnly);
                  },
                ),
                _chipButton(
                  active: showCompatibleOnly,
                  title: "المتوافق فقط",
                  onTap: () {
                    setState(() => showCompatibleOnly = !showCompatibleOnly);
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              "نطاق السعر",
              style: GoogleFonts.cairo(
                color: _textSub,
                fontWeight: FontWeight.w800,
                fontSize: 13.2,
              ),
            ),
            RangeSlider(
              values: priceRange,
              min: 0,
              max: 5000,
              divisions: 50,
              activeColor: _brandSoft,
              inactiveColor: Colors.white.withOpacity(.10),
              labels: RangeLabels(
                "${priceRange.start.toInt()}",
                "${priceRange.end.toInt()}",
              ),
              onChanged: (v) {
                setState(() => priceRange = v);
              },
            ),
            Text(
              "من ${priceRange.start.toInt()} ريال إلى ${priceRange.end.toInt()} ريال",
              style: GoogleFonts.cairo(
                color: _textHint,
                fontSize: 12.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "الترتيب",
              style: GoogleFonts.cairo(
                color: _textSub,
                fontWeight: FontWeight.w800,
                fontSize: 13.2,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _sortChip("موصى به", "recommended"),
                _sortChip("المتوفر أولاً", "stock"),
                _sortChip("السعر: الأقل", "price_low"),
                _sortChip("السعر: الأعلى", "price_high"),
                _sortChip("الاسم", "name"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipButton({
    required bool active,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? _success.withOpacity(.12)
              : Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? _success.withOpacity(.24) : _softStroke,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.cairo(
            color: active ? _success : _textSub,
            fontSize: 11.8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _sortChip(String title, String value) {
    final active = sortMode == value;
    return InkWell(
      onTap: () {
        setState(() => sortMode = value);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? _buttonGradient : null,
          color: active ? null : Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? Colors.white.withOpacity(.08) : _softStroke,
          ),
          boxShadow: active ? _blueGlow : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 12.2,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _productCard(ProductModel p) {
    final isCompatible =
        (widget.brandId == null || p.brandId == widget.brandId) &&
            (widget.modelId == null || p.carModelId == widget.modelId);

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
          gradient: _cardGradient,
          borderRadius: BorderRadius.circular(24),
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
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(.56),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isCompatible
                              ? _brandSoft.withOpacity(.14)
                              : _warning.withOpacity(.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isCompatible
                                ? _brandSoft.withOpacity(.30)
                                : _warning.withOpacity(.28),
                          ),
                        ),
                        child: Text(
                          isCompatible ? "متوافق" : "عام",
                          style: GoogleFonts.cairo(
                            color: isCompatible ? _brandSoft : _warning,
                            fontSize: 10.8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
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
                              ? _success.withOpacity(.12)
                              : _danger.withOpacity(.10),
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
                            fontSize: 10.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.38),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(.10),
                          ),
                        ),
                        child: Text(
                          "OEM: ${_safeText(p.oemNumber, fallback: "غير متوفر")}",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 10.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.8,
                        color: _textMain,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getCategoryName(p.categoryId),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: _textHint,
                        fontSize: 11.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${p.price.toStringAsFixed(0)} ريال",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 14.2,
                              color: _brandSoft,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: _buttonGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: _blueGlow,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
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
  }

  Widget _productImage(ProductModel p) {
    final image = _safeText(p.imageUrl);

    if (_looksLikeRealProductImage(image)) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _productPlaceholder(),
      );
    }

    return _productPlaceholder();
  }

  Widget _productPlaceholder() {
    return Container(
      color: _surface2,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: _buttonGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.precision_manufacturing_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "صورة المنتج غير متاحة",
              style: GoogleFonts.cairo(
                color: _textSub,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: _cardGradient,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _stroke),
            boxShadow: _softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: _buttonGradient,
                  shape: BoxShape.circle,
                  boxShadow: _blueGlow,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "لا توجد نتائج مطابقة",
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "جرّب تعديل كلمات البحث أو توسيع نطاق السعر أو تغيير القسم المختار.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: _textSub,
                  fontSize: 13,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductsBackgroundPainter extends CustomPainter {
  final Color lineColor;
  final Color glowColor;

  const _ProductsBackgroundPainter({
    required this.lineColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path1 = Path()
      ..moveTo(0, size.height * .16)
      ..quadraticBezierTo(
        size.width * .24,
        size.height * .07,
        size.width * .55,
        size.height * .16,
      )
      ..quadraticBezierTo(
        size.width * .82,
        size.height * .24,
        size.width,
        size.height * .15,
      );

    final path2 = Path()
      ..moveTo(0, size.height * .54)
      ..quadraticBezierTo(
        size.width * .22,
        size.height * .46,
        size.width * .50,
        size.height * .58,
      )
      ..quadraticBezierTo(
        size.width * .80,
        size.height * .66,
        size.width,
        size.height * .56,
      );

    final path3 = Path()
      ..moveTo(0, size.height * .88)
      ..quadraticBezierTo(
        size.width * .22,
        size.height * .82,
        size.width * .48,
        size.height * .90,
      )
      ..quadraticBezierTo(
        size.width * .76,
        size.height * .99,
        size.width,
        size.height * .90,
      );

    canvas.drawPath(path1, glowPaint);
    canvas.drawPath(path2, linePaint);
    canvas.drawPath(path3, linePaint);

    final dotPaint = Paint()..color = glowColor.withOpacity(.9);
    for (double x = 18; x < size.width; x += 58) {
      canvas.drawCircle(Offset(x, size.height * .22), 1.2, dotPaint);
    }
    for (double x = 8; x < size.width; x += 62) {
      canvas.drawCircle(Offset(x, size.height * .74), 1.1, dotPaint);
    }

    final diagonalPaint = Paint()
      ..color = Colors.white.withOpacity(.014)
      ..strokeWidth = 1;

    for (double x = -40; x < size.width + 80; x += 30) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 80, size.height),
        diagonalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
