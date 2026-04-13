import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../data/categories/categories_data.dart';
import '../cart/cart_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;

  static const String _placeholderPart = "assets/images/placeholder_part.png";

  static const Color _bg = Color(0xFF07111B);
  static const Color _bg2 = Color(0xFF0B1624);
  static const Color _surface = Color(0xFF101C2B);
  static const Color _surface2 = Color(0xFF132235);

  static const Color _brand = Color(0xFF1565C0);
  static const Color _brandDark = Color(0xFF0D4B96);
  static const Color _brandSoft = Color(0xFF8FD3FF);

  static const Color _textMain = Color(0xFFF5F7FB);
  static const Color _textSub = Color(0xFFB8C5D4);
  static const Color _textHint = Color(0xFF8EA1B5);
  static const Color _success = Color(0xFF7DD3AE);
  static const Color _danger = Color(0xFFFF7B7B);
  // ignore: unused_field
  static const Color _warning = Color(0xFFFFC857);

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
          blurRadius: 22,
          offset: const Offset(0, 12),
        ),
      ];

  List<BoxShadow> get _blueGlow => [
        BoxShadow(
          color: _brandSoft.withOpacity(.13),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: _brand.withOpacity(.16),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  String _safeText(dynamic value, {String fallback = ""}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String get _oem => _safeText(widget.product.oemNumber, fallback: "غير متوفر");

  String get _description => _safeText(
        widget.product.description,
        fallback: "لا يوجد وصف متاح لهذا المنتج حالياً.",
      );

  String get _categoryName {
    try {
      return categories
          .firstWhere((c) => c.id == widget.product.categoryId)
          .name;
    } catch (_) {
      return "قسم غير محدد";
    }
  }

  bool _hasImage(String url) {
    return url.trim().isNotEmpty;
  }

  bool _isAssetImage(String url) {
    return url.trim().startsWith("assets/");
  }

  Widget _buildProductImage(String imageUrl) {
    if (!_hasImage(imageUrl)) {
      return _imageFallback();
    }

    if (_isAssetImage(imageUrl)) {
      return Hero(
        tag: "product_${widget.product.id}_${widget.product.name}",
        child: Image.asset(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _imageFallback(),
        ),
      );
    }

    return Hero(
      tag: "product_${widget.product.id}_${widget.product.name}",
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _imageFallback(loading: true);
        },
        errorBuilder: (_, __, ___) => _imageFallback(),
      ),
    );
  }

  void _increaseQty() {
    setState(() => quantity++);
  }

  void _decreaseQty() {
    if (quantity > 1) {
      setState(() => quantity--);
    }
  }

  void _handleAddToCart() {
    if (!widget.product.inStock) return;

    // اربط هنا مزود السلة لو عندك Provider / Cubit / Firebase.
    // حاليًا بنمشي العميل الخطوات الطبيعية:
    // إضافة -> نجاح -> الذهاب للسلة أو متابعة التسوق

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: _bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _success.withOpacity(.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: _success.withOpacity(.25)),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: _success,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "تمت إضافة المنتج بنجاح",
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.product.name}\nالكمية: $quantity",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: _textSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(color: Colors.white.withOpacity(.14)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "متابعة التسوق",
                          style: GoogleFonts.cairo(
                            color: _textMain,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartPage(),
                            ),
                          );
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: _buttonGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _blueGlow,
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              "الذهاب للسلة",
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        bottomNavigationBar: _bottomActionBar(product),
        body: Stack(
          children: [
            _backgroundDecor(),
            SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _heroImage(product),
                          const SizedBox(height: 18),
                          _titlePriceSection(product),
                          const SizedBox(height: 14),
                          _statusRow(product),
                          const SizedBox(height: 18),
                          _quickInfoStrip(product),
                          const SizedBox(height: 20),
                          _sectionTitle("الوصف"),
                          _descriptionBox(),
                          const SizedBox(height: 20),
                          _sectionTitle("مواصفات القطعة"),
                          _specsGrid(product),
                          const SizedBox(height: 20),
                          _sectionTitle("معلومات المطابقة"),
                          _compatibilityCard(product),
                          const SizedBox(height: 24),
                        ],
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

  Widget _backgroundDecor() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(gradient: _screenBg),
          ),
        ),
        Positioned(
          top: -100,
          right: -70,
          child: _glowOrb(240, _brandSoft.withOpacity(.10)),
        ),
        Positioned(
          top: 260,
          left: -80,
          child: _glowOrb(190, _brand.withOpacity(.08)),
        ),
        Positioned(
          bottom: -90,
          right: -30,
          child: _glowOrb(200, _brandSoft.withOpacity(.08)),
        ),
      ],
    );
  }

  Widget _glowOrb(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 52, sigmaY: 52),
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

  Widget _header(BuildContext context) {
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
              "تفاصيل القطعة",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: _textMain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _iconBtn(
            icon: Icons.share_outlined,
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

  Widget _heroImage(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _surface2,
              _surface,
              Color(0xFF0E1826),
            ],
          ),
          border: Border.all(color: _stroke),
          boxShadow: _softShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brandSoft.withOpacity(.06),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brand.withOpacity(.06),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildProductImage(product.imageUrl),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _topBadge(
                product.inStock ? "جاهزة للطلب" : "نفدت مؤقتًا",
                product.inStock ? _success : _danger,
              ),
            ),
            Positioned(
              left: 16,
              top: 16,
              child: _topBadge(_categoryName, _brandSoft),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback({bool loading = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            gradient: _buttonGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _blueGlow,
          ),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.6,
                  ),
                )
              : Image.asset(
                  _placeholderPart,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.precision_manufacturing_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
        ),
        const SizedBox(height: 14),
        Text(
          loading ? "جاري تحميل الصورة..." : "صورة المنتج غير متاحة",
          style: GoogleFonts.cairo(
            color: _textSub,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _topBadge(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.28)),
      ),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: color,
          fontSize: 11.2,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _titlePriceSection(ProductModel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.name,
            style: GoogleFonts.cairo(
              fontSize: 23,
              height: 1.35,
              fontWeight: FontWeight.w900,
              color: _textMain,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: _buttonGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _blueGlow,
                ),
                child: Text(
                  "${p.price.toStringAsFixed(0)} ريال",
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "رقم OEM: $_oem",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: _textHint,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusRow(ProductModel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _metaCard(
              Icons.inventory_2_outlined,
              p.inStock ? "متوفر" : "غير متوفر",
              "الحالة",
              valueColor: p.inStock ? _success : _danger,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _metaCard(
              Icons.category_rounded,
              _categoryName,
              "القسم",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _metaCard(
              Icons.settings_suggest_rounded,
              _oem,
              "OEM",
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaCard(
    IconData icon,
    String value,
    String label, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        gradient: _cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _softStroke),
      ),
      child: Column(
        children: [
          Icon(icon, color: _brandSoft, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: valueColor ?? _textMain,
              fontSize: 12.8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
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
    );
  }

  Widget _quickInfoStrip(ProductModel p) {
    final items = [
      {
        "icon": Icons.car_repair_rounded,
        "txt": "مطابقة حسب السيارة",
      },
      {
        "icon": Icons.verified_outlined,
        "txt": "بيانات واضحة",
      },
      {
        "icon": Icons.local_shipping_outlined,
        "txt": p.inStock ? "جاهز للطلب" : "انتظار التوفر",
      },
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final item = items[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _softStroke),
            ),
            child: Row(
              children: [
                Icon(item["icon"] as IconData, color: _brandSoft, size: 18),
                const SizedBox(width: 8),
                Text(
                  item["txt"] as String,
                  style: GoogleFonts.cairo(
                    color: _textSub,
                    fontSize: 12.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: _buttonGradient,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _descriptionBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _cardGradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _softStroke),
          boxShadow: _softShadow,
        ),
        child: Text(
          _description,
          style: GoogleFonts.cairo(
            fontSize: 14,
            height: 1.9,
            color: _textSub,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _specsGrid(ProductModel p) {
    final specs = [
      {"title": "الحالة", "value": p.inStock ? "متوفر" : "غير متوفر"},
      {"title": "رقم OEM", "value": _oem},
      {"title": "القسم", "value": _categoryName},
      {"title": "النوع", "value": "قطعة غيار"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: specs.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.65,
        ),
        itemBuilder: (_, i) {
          final item = specs[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: _cardGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _softStroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item["title"] as String,
                  style: GoogleFonts.cairo(
                    color: _textHint,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["value"] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _compatibilityCard(ProductModel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _brand.withOpacity(.18),
              _brandDark.withOpacity(.10),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _brandSoft.withOpacity(.16)),
          boxShadow: _blueGlow,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _buttonGradient,
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "بيانات المطابقة",
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _textSub,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Brand ID: ${p.brandId}  •  Model ID: ${p.carModelId}",
                    style: GoogleFonts.cairo(
                      fontSize: 14.2,
                      fontWeight: FontWeight.w900,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "القسم: $_categoryName",
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _textSub,
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

  Widget _bottomActionBar(ProductModel p) {
    final total = p.price * quantity;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: _bg2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "الإجمالي: ${total.toStringAsFixed(0)} ريال",
                    style: GoogleFonts.cairo(
                      color: _textMain,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _softStroke),
                  ),
                  child: Row(
                    children: [
                      _qtyBtn(Icons.remove_rounded, _decreaseQty),
                      SizedBox(
                        width: 34,
                        child: Center(
                          child: Text(
                            "$quantity",
                            style: GoogleFonts.cairo(
                              color: _textMain,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      _qtyBtn(Icons.add_rounded, _increaseQty),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: p.inStock ? _handleAddToCart : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: p.inStock
                        ? _buttonGradient
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade700,
                              Colors.grey.shade800,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: p.inStock ? _blueGlow : null,
                  ),
                  child: Center(
                    child: Text(
                      p.inStock ? "أضف إلى السلة" : "غير متوفر حالياً",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _textMain, size: 18),
      ),
    );
  }
}
