// screens/services/supplementary_services_screen.dart
// DOCTOR CAR MINIMAL PREMIUM VERSION

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'service_details_screen.dart';

class SupplementaryServicesScreen extends StatefulWidget {
  const SupplementaryServicesScreen({super.key});

  @override
  State<SupplementaryServicesScreen> createState() =>
      _SupplementaryServicesScreenState();
}

enum _SortMode { topRated, lowestPrice, fastest }

class _SupplementaryServicesScreenState
    extends State<SupplementaryServicesScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bg1 = Color(0xFF081A36);
  static const Color _bg2 = Color(0xFF0B2348);
  static const Color _bg3 = Color(0xFF040D1D);

  static const Color _brand = Color(0xFF1B4F9C);
  static const Color _brandSoft = Color(0xFF7CC4F5);
  static const Color _text = Color(0xFFF2F6FB);
  static const Color _muted = Color(0xFFC9D6EA);
  static const Color _success = Color(0xFF36C690);
  static const Color _warning = Color(0xFFFFB84D);

  final TextEditingController _searchCtrl = TextEditingController();

  String _category = "الكل";
  _SortMode _sortMode = _SortMode.topRated;

  late final AnimationController _animCtrl;

  final List<String> categories = const [
    "الكل",
    "ميكانيكا",
    "كهرباء",
    "إطارات",
    "عفشة",
    "فحص",
    "تنظيف",
    "طوارئ",
  ];

  final List<Map<String, dynamic>> services = const [
    {
      "name": "سطحة سيارات",
      "icon": Icons.local_shipping_rounded,
      "category": "طوارئ",
      "price": 350,
      "rating": 4.9,
      "time": "حسب المسافة",
      "desc": "نقل السيارة عند العطل",
      "color": Color(0xFF4FA3FF),
    },
    {
      "name": "فتح سيارة",
      "icon": Icons.lock_open_rounded,
      "category": "طوارئ",
      "price": 120,
      "rating": 4.7,
      "time": "10 دقائق",
      "desc": "فتح السيارة بدون تلف",
      "color": Color(0xFF5E8CFF),
    },
    {
      "name": "نفاد بنزين",
      "icon": Icons.local_gas_station_rounded,
      "category": "طوارئ",
      "price": 100,
      "rating": 4.6,
      "time": "10 دقائق",
      "desc": "توصيل وقود للطوارئ",
      "color": Color(0xFFFFB84D),
    },
    {
      "name": "تغيير زيت",
      "icon": Icons.opacity_rounded,
      "category": "ميكانيكا",
      "price": 120,
      "rating": 4.7,
      "time": "10 دقائق",
      "desc": "تغيير زيت + فحص المحرك",
      "color": Color(0xFF49C2FF),
    },
    {
      "name": "ميكانيكي عام",
      "icon": Icons.build_rounded,
      "category": "ميكانيكا",
      "price": 150,
      "rating": 4.8,
      "time": "20 دقيقة",
      "desc": "إصلاح أعطال ميكانيكية",
      "color": Color(0xFF52D6B8),
    },
    {
      "name": "تغيير فلتر هواء",
      "icon": Icons.filter_alt_rounded,
      "category": "ميكانيكا",
      "price": 60,
      "rating": 4.5,
      "time": "5 دقائق",
      "desc": "تغيير فلتر الهواء",
      "color": Color(0xFF8A9EFF),
    },
    {
      "name": "تغيير بطارية",
      "icon": Icons.battery_charging_full_rounded,
      "category": "كهرباء",
      "price": 180,
      "rating": 4.7,
      "time": "12 دقيقة",
      "desc": "فحص وتركيب بطارية",
      "color": Color(0xFF7EE081),
    },
    {
      "name": "شحن بطارية",
      "icon": Icons.battery_full_rounded,
      "category": "كهرباء",
      "price": 90,
      "rating": 4.4,
      "time": "10 دقائق",
      "desc": "شحن البطارية",
      "color": Color(0xFF47D1A8),
    },
    {
      "name": "فحص كهرباء",
      "icon": Icons.bolt_rounded,
      "category": "كهرباء",
      "price": 100,
      "rating": 4.3,
      "time": "15 دقيقة",
      "desc": "تشخيص كهرباء السيارة",
      "color": Color(0xFFFFD15C),
    },
    {
      "name": "بنشر / كاوتش",
      "icon": Icons.tire_repair_rounded,
      "category": "إطارات",
      "price": 60,
      "rating": 4.8,
      "time": "7 دقائق",
      "desc": "إصلاح إطار",
      "color": Color(0xFFB88CFF),
    },
    {
      "name": "تغيير كاوتش",
      "icon": Icons.trip_origin_rounded,
      "category": "إطارات",
      "price": 80,
      "rating": 4.6,
      "time": "10 دقائق",
      "desc": "تغيير الإطار",
      "color": Color(0xFF8BB0FF),
    },
    {
      "name": "فحص عفشة",
      "icon": Icons.car_repair_rounded,
      "category": "عفشة",
      "price": 120,
      "rating": 4.8,
      "time": "20 دقيقة",
      "desc": "فحص كامل للعفشة",
      "color": Color(0xFF55C7FF),
    },
    {
      "name": "تغيير مساعد",
      "icon": Icons.settings_rounded,
      "category": "عفشة",
      "price": 300,
      "rating": 4.7,
      "time": "30 دقيقة",
      "desc": "تغيير مساعد أمامي أو خلفي",
      "color": Color(0xFF61C3A4),
    },
    {
      "name": "شد عفشة",
      "icon": Icons.tune_rounded,
      "category": "عفشة",
      "price": 150,
      "rating": 4.6,
      "time": "25 دقيقة",
      "desc": "شد وضبط العفشة",
      "color": Color(0xFF7FA3FF),
    },
    {
      "name": "فحص كمبيوتر",
      "icon": Icons.memory_rounded,
      "category": "فحص",
      "price": 130,
      "rating": 4.6,
      "time": "8 دقائق",
      "desc": "تشخيص أعطال ECU",
      "color": Color(0xFF78D5FF),
    },
    {
      "name": "غسيل السيارة",
      "icon": Icons.local_car_wash_rounded,
      "category": "تنظيف",
      "price": 90,
      "rating": 4.2,
      "time": "20 دقيقة",
      "desc": "غسيل داخلي وخارجي",
      "color": Color(0xFF57D8EA),
    },
  ];

  Map<String, dynamic> _safeService(Map<String, dynamic> s) => {
        ...s,
        "type": s["type"] ?? s["name"],
      };

  LinearGradient get _screenBgGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_bg1, _bg2, _bg3],
      );

  LinearGradient get _bluePrimary => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF1B4F99),
          Color(0xFF245AA6),
          Color(0xFF153F78),
        ],
      );

  LinearGradient get _cardGradient => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF17345F),
          Color(0xFF112A4E),
          Color(0xFF0C213E),
        ],
      );

  Color get _stroke => Colors.white.withOpacity(.10);

  List<BoxShadow> get _shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(.18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
  }

  List<Map<String, dynamic>> get _filtered {
    final search = _searchCtrl.text.trim().toLowerCase();

    final base = services.where((s) {
      final name = s["name"].toString().toLowerCase();
      final cat = s["category"].toString().toLowerCase();
      final desc = s["desc"].toString().toLowerCase();

      final matchSearch = search.isEmpty ||
          name.contains(search) ||
          cat.contains(search) ||
          desc.contains(search);

      final matchCat = _category == "الكل" || s["category"] == _category;
      return matchSearch && matchCat;
    }).toList();

    base.sort((a, b) {
      switch (_sortMode) {
        case _SortMode.topRated:
          return (b["rating"] as num).compareTo(a["rating"] as num);
        case _SortMode.lowestPrice:
          return (a["price"] as num).compareTo(b["price"] as num);
        case _SortMode.fastest:
          int parseMin(dynamic v) {
            final s = v.toString();
            final m = RegExp(r'(\d+)').firstMatch(s);
            if (m == null) return 9999;
            return int.tryParse(m.group(1)!) ?? 9999;
          }

          return parseMin(a["time"]).compareTo(parseMin(b["time"]));
      }
    });

    return base;
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg1,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: _screenBgGradient)),
            Positioned(
              top: -50,
              left: -20,
              child: _blurGlow(
                size: 170,
                color: _brandSoft.withOpacity(.06),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -10,
              child: _blurGlow(
                size: 150,
                color: _brand.withOpacity(.06),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Column(
                      children: [
                        _heroHeader(),
                        const SizedBox(height: 12),
                        _searchBar(),
                      ],
                    ),
                  ),
                  _categoriesRow(),
                  const SizedBox(height: 10),
                  _compactTopBar(filtered.length),
                  const SizedBox(height: 10),
                  Expanded(
                    child: RefreshIndicator(
                      color: _brand,
                      onRefresh: _refresh,
                      child: filtered.isEmpty
                          ? _emptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) {
                                final s = filtered[i];
                                return _serviceTile(s);
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
      title: Text(
        "الخدمات الإضافية",
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          tooltip: "ترتيب",
          onPressed: _showSortSheet,
          icon: Icon(Icons.tune_rounded, color: Colors.white.withOpacity(.92)),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _heroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: _cardGradient,
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: _shadowSm,
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (_, __) {
              return Transform.scale(
                scale: 1 + (_animCtrl.value * .03),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: _bluePrimary,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "اختر الخدمة بسرعة من قائمة مرتبة وواضحة.",
              style: GoogleFonts.cairo(
                color: _text,
                fontWeight: FontWeight.w800,
                fontSize: 14.2,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _shadowSm,
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        cursorColor: _brand,
        decoration: InputDecoration(
          hintText: "ابحث عن خدمة...",
          hintStyle: GoogleFonts.cairo(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchCtrl.text.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () => setState(() => _searchCtrl.clear()),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white54,
                  ),
                ),
          filled: true,
          fillColor: Colors.white.withOpacity(.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _stroke),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _stroke),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _brand.withOpacity(.75), width: 1.3),
          ),
        ),
      ),
    );
  }

  Widget _categoriesRow() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = categories[i];
          final active = c == _category;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _tap(() => setState(() => _category = c)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                gradient: active ? _bluePrimary : null,
                color: active ? null : Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active ? Colors.white.withOpacity(.10) : _stroke,
                ),
              ),
              child: Center(
                child: Text(
                  c,
                  style: GoogleFonts.cairo(
                    color: active ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _compactTopBar(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _miniStripItem(
              icon: Icons.grid_view_rounded,
              text: "$count خدمة",
              color: _brandSoft,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _miniStripItem(
              icon: _sortMode == _SortMode.topRated
                  ? Icons.star_rounded
                  : _sortMode == _SortMode.lowestPrice
                      ? Icons.payments_rounded
                      : Icons.timer_rounded,
              text: _sortMode == _SortMode.topRated
                  ? "الأعلى تقييمًا"
                  : _sortMode == _SortMode.lowestPrice
                      ? "الأقل سعرًا"
                      : "الأسرع",
              color: _warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStripItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: _text,
                fontWeight: FontWeight.w800,
                fontSize: 12.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceTile(Map<String, dynamic> s) {
    final IconData icon = s["icon"] as IconData;
    final String name = s["name"].toString();
    final String cat = s["category"].toString();
    final String desc = s["desc"].toString();
    final num price = s["price"] as num;
    final num rating = s["rating"] as num;
    final String time = s["time"].toString();
    final Color accent = s["color"] as Color? ?? _brandSoft;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        _tap(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailsScreen(service: _safeService(s)),
            ),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: _cardGradient,
          border: Border.all(color: Colors.white.withOpacity(.08)),
          boxShadow: _shadowSm,
        ),
        child: Row(
          children: [
            _premiumServiceIcon(icon: icon, accent: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ratingTag(rating: rating, accent: accent),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _smallPill(
                        icon: Icons.widgets_rounded,
                        text: cat,
                        color: _brandSoft,
                      ),
                      const SizedBox(width: 8),
                      _smallPill(
                        icon: Icons.timer_rounded,
                        text: time,
                        color: _warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _priceBox(price: price),
          ],
        ),
      ),
    );
  }

  Widget _premiumServiceIcon({
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(.28),
            accent.withOpacity(.10),
          ],
        ),
        border: Border.all(color: accent.withOpacity(.24)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
              ),
            ),
          ),
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _ratingTag({
    required num rating,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: accent),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallPill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBox({required num price}) {
    return Container(
      width: 74,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: _success.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _success.withOpacity(.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_rounded, size: 16, color: _success),
          const SizedBox(height: 4),
          Text(
            "$price",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          Text(
            "ج.م",
            style: GoogleFonts.cairo(
              color: _muted,
              fontWeight: FontWeight.w700,
              fontSize: 10.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: _cardGradient,
            border: Border.all(color: _stroke),
            boxShadow: _shadowSm,
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: _bluePrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "مفيش نتائج مطابقة",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "جرّب تغيّر التصنيف أو كلمات البحث.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => setState(() {
                  _category = "الكل";
                  _searchCtrl.clear();
                }),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  "إعادة ضبط",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSortSheet() {
    _tap(() {});
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_bg1, _bg2],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(.10)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                _sortTile(
                  title: "الأعلى تقييمًا",
                  icon: Icons.star_rounded,
                  selected: _sortMode == _SortMode.topRated,
                  onTap: () {
                    setState(() => _sortMode = _SortMode.topRated);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                _sortTile(
                  title: "الأقل سعرًا",
                  icon: Icons.payments_rounded,
                  selected: _sortMode == _SortMode.lowestPrice,
                  onTap: () {
                    setState(() => _sortMode = _SortMode.lowestPrice);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                _sortTile(
                  title: "الأسرع",
                  icon: Icons.timer_rounded,
                  selected: _sortMode == _SortMode.fastest,
                  onTap: () {
                    setState(() => _sortMode = _SortMode.fastest);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sortTile({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: selected ? _bluePrimary : _cardGradient,
          border: Border.all(
            color: selected ? Colors.white.withOpacity(.10) : _stroke,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _blurGlow({required double size, required Color color}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
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
}
