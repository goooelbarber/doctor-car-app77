import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/brands/brands_data.dart';
import 'models_page.dart';

class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  String searchText = "";

  static const Color _bg = Color(0xFF09121F);
  // ignore: unused_field
  static const Color _bg2 = Color(0xFF0D1726);
  static const Color _surface = Color(0xFF101C2C);
  // ignore: unused_field
  static const Color _surface2 = Color(0xFF132338);

  static const Color _primary = Color(0xFF1E88E5);
  static const Color _primary2 = Color(0xFF42A5F5);
  static const Color _accent = Color(0xFF8FD3FF);

  static const Color _textMain = Color(0xFFF4F7FB);
  static const Color _textSub = Color(0xFFB8C5D4);
  static const Color _textHint = Color(0xFF8B9AAF);

  static const Color _success = Color(0xFF30C77B);
  static const Color _warning = Color(0xFFFFB84D);

  Color get _stroke => Colors.white.withOpacity(.08);
  Color get _softStroke => Colors.white.withOpacity(.05);

  LinearGradient get _screenGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0C1727),
          Color(0xFF0A1422),
          Color(0xFF070D17),
        ],
      );

  LinearGradient get _primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF35A4FF),
          Color(0xFF1565C0),
        ],
      );

  LinearGradient get _cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(.10),
          Colors.white.withOpacity(.05),
          Colors.white.withOpacity(.03),
        ],
      );

  List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.24),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  List<BoxShadow> get _glowShadow => [
        BoxShadow(
          color: _primary.withOpacity(.22),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: _accent.withOpacity(.10),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];

  List<Map<String, dynamic>> get _filteredBrands {
    final query = searchText.trim().toLowerCase();

    if (query.isEmpty) return CarBrandData.brands;

    return CarBrandData.brands.where((brand) {
      final name = (brand["name"] ?? "").toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBrands = _filteredBrands;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            _backgroundDecor(),
            SafeArea(
              child: Column(
                children: [
                  _topBar(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              _heroSection(filteredBrands.length),
                              const SizedBox(height: 18),
                              _searchBar(),
                              const SizedBox(height: 18),
                              _quickStats(filteredBrands.length),
                              const SizedBox(height: 22),
                              _sectionHeader(
                                title: "اختر الماركة",
                                subtitle:
                                    "ابدأ من الشركة المصنعة للوصول للموديلات المناسبة",
                              ),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                        filteredBrands.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: _emptyState(),
                              )
                            : SliverPadding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: .78,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final brand = filteredBrands[index];
                                      return _brandCard(
                                        context,
                                        index: index,
                                        brandId: brand["id"] as int,
                                        name: brand["name"] as String,
                                        logoUrl: brand["logo"] as String,
                                      );
                                    },
                                    childCount: filteredBrands.length,
                                  ),
                                ),
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
            decoration: BoxDecoration(gradient: _screenGradient),
          ),
        ),
        Positioned(
          top: -100,
          right: -50,
          child: _glowOrb(220, _primary2.withOpacity(.12)),
        ),
        Positioned(
          top: 240,
          left: -80,
          child: _glowOrb(190, _accent.withOpacity(.07)),
        ),
        Positioned(
          bottom: -120,
          right: -40,
          child: _glowOrb(220, _primary.withOpacity(.10)),
        ),
      ],
    );
  }

  Widget _glowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          _circleAction(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "اختيار نوع السيارة",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                color: _textMain,
                fontSize: 22,
              ),
            ),
          ),
          _circleAction(
            icon: Icons.tune_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _circleAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _softStroke),
        ),
        child: Icon(
          icon,
          color: _textMain,
          size: 24,
        ),
      ),
    );
  }

  Widget _heroSection(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFF143055),
              const Color(0xFF0F233A),
              _surface,
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.28),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: _primary.withOpacity(.12),
              blurRadius: 18,
            ),
          ],
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
                  color: Colors.white.withOpacity(.05),
                ),
              ),
            ),
            Positioned(
              bottom: -25,
              right: -10,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withOpacity(.08),
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
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(.10),
                            ),
                          ),
                          child: Text(
                            "SMART CAR SELECTOR",
                            style: GoogleFonts.cairo(
                              color: _accent,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                              letterSpacing: .4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "اختر الماركة أولاً\nوابدأ رحلتك بشكل احترافي",
                          style: GoogleFonts.cairo(
                            color: _textMain,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "بعد اختيار الشركة المصنعة، نعرض لك الموديلات ثم القطع المتوافقة فقط لتجربة أوضح وأسرع.",
                          style: GoogleFonts.cairo(
                            color: _textSub,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.8,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _miniBadge(
                              icon: Icons.verified_rounded,
                              text: "$count ماركة",
                              color: _success,
                            ),
                            const SizedBox(width: 10),
                            _miniBadge(
                              icon: Icons.auto_awesome_rounded,
                              text: "واجهة احترافية",
                              color: _warning,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 88,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
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
                    child: Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _primaryGradient,
                          boxShadow: _glowShadow,
                        ),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: Colors.white,
                          size: 28,
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
    );
  }

  Widget _miniBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: _cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _stroke),
          boxShadow: _cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: _primaryGradient,
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
                textDirection: TextDirection.ltr,
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: "ابحث عن الماركة مثل Toyota أو BMW",
                  hintStyle: GoogleFonts.cairo(
                    color: _textHint,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => searchText = value);
                },
              ),
            ),
            if (searchText.isNotEmpty)
              InkWell(
                onTap: () => setState(() => searchText = ""),
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quickStats(int count) {
    final items = [
      {
        "icon": Icons.approval_rounded,
        "title": "$count شركة",
        "sub": "ماركات متاحة",
      },
      {
        "icon": Icons.speed_rounded,
        "title": "اختيار أسرع",
        "sub": "وصول للموديل",
      },
      {
        "icon": Icons.precision_manufacturing_rounded,
        "title": "مطابقة أدق",
        "sub": "للقطع المناسبة",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          items.length,
          (index) {
            final item = items[index];
            return Expanded(
              child: Container(
                margin:
                    EdgeInsets.only(left: index == items.length - 1 ? 0 : 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  gradient: _cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _softStroke),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: _primaryGradient,
                        borderRadius: BorderRadius.circular(14),
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
                        fontWeight: FontWeight.w900,
                        fontSize: 12.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item["sub"] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: _textHint,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
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

  Widget _sectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 28,
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
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: _textHint,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandCard(
    BuildContext context, {
    required int index,
    required int brandId,
    required String name,
    required String logoUrl,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .94, end: 1),
      duration: Duration(milliseconds: 250 + (index * 40)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InkWell(
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
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: _cardGradient,
            border: Border.all(color: _stroke),
            boxShadow: _cardShadow,
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.04),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(.04)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _accent.withOpacity(.18),
                              ),
                            ),
                            child: Text(
                              "Brand",
                              style: GoogleFonts.cairo(
                                color: _accent,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Image.network(
                              logoUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return _logoLoading();
                              },
                              errorBuilder: (_, __, ___) {
                                return _logoFallback();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: _primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: _glowShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900,
                            fontSize: 14.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation(_primary2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "جاري تحميل الشعار",
          style: GoogleFonts.cairo(
            color: _textHint,
            fontWeight: FontWeight.w700,
            fontSize: 11.2,
          ),
        ),
      ],
    );
  }

  Widget _logoFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: _primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: _glowShadow,
          ),
          child: const Icon(
            Icons.directions_car_filled_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "تعذر تحميل الشعار",
          style: GoogleFonts.cairo(
            fontSize: 11.4,
            fontWeight: FontWeight.w800,
            color: _textSub,
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: _cardGradient,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _stroke),
            boxShadow: _cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  gradient: _primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: _glowShadow,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "لا توجد ماركة مطابقة",
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "جرّب كتابة اسم الماركة بشكل مختلف مثل Toyota أو BMW أو Mercedes.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: _textSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
