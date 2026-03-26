// screens/services/supplementary_services_screen.dart
// DOCTOR CAR DARK BLUE + GLASS VERSION
// ignore_for_file: unused_import, unnecessary_import

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
    extends State<SupplementaryServicesScreen> {
  // ===== THEME =====
  static const Color _bg1 = Color(0xFF081A36);
  static const Color _bg2 = Color(0xFF0B2348);
  static const Color _bg3 = Color(0xFF040D1D);

  // ✅ Brand Dark Blue
  static const Color _brand = Color(0xFF1B4F9C);

  Color get _brand2 => Color.lerp(_brand, const Color(0xFF040D1D), 0.22)!;
  // ignore: unused_element
  Color get _brand3 => Color.lerp(_brand, Colors.white, 0.12)!;

  LinearGradient get _screenBgGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _bg1,
          Color.lerp(_bg1, _brand2, .08)!,
          _bg3,
        ],
      );

  /// ✅ Dark blue primary gradient
  LinearGradient get _bluePrimary => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF1B4F99),
          Color(0xFF245AA6),
          Color(0xFF153F78),
        ],
        stops: [0.0, 0.56, 1.0],
      );

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

  Color get _stroke => Colors.white.withOpacity(.12);

  List<BoxShadow> get _shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(.22),
          blurRadius: 16,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get _glow => [
        BoxShadow(
          color: _brand.withOpacity(.22),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(.22),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  // ===== STATE =====
  final TextEditingController _searchCtrl = TextEditingController();
  String _category = "الكل";
  _SortMode _sortMode = _SortMode.topRated;

  final List<String> categories = [
    "الكل",
    "ميكانيكا",
    "كهرباء",
    "إطارات",
    "عفشة",
    "فحص",
    "تنظيف",
    "طوارئ",
  ];

  final List<Map<String, dynamic>> services = [
    // ================= طوارئ =================
    {
      "name": "سطحة سيارات",
      "icon": Icons.local_shipping,
      "category": "طوارئ",
      "price": 350,
      "rating": 4.9,
      "time": "حسب المسافة",
      "desc": "نقل السيارة عند العطل",
    },
    {
      "name": "فتح سيارة",
      "icon": Icons.lock_open,
      "category": "طوارئ",
      "price": 120,
      "rating": 4.7,
      "time": "10 دقائق",
      "desc": "فتح السيارة بدون تلف",
    },
    {
      "name": "نفاد بنزين",
      "icon": Icons.local_gas_station,
      "category": "طوارئ",
      "price": 100,
      "rating": 4.6,
      "time": "10 دقائق",
      "desc": "توصيل وقود للطوارئ",
    },

    // ================= ميكانيكا =================
    {
      "name": "تغيير زيت",
      "icon": Icons.oil_barrel,
      "category": "ميكانيكا",
      "price": 120,
      "rating": 4.7,
      "time": "10 دقائق",
      "desc": "تغيير زيت + فحص المحرك",
    },
    {
      "name": "ميكانيكي عام",
      "icon": Icons.build,
      "category": "ميكانيكا",
      "price": 150,
      "rating": 4.8,
      "time": "20 دقيقة",
      "desc": "إصلاح أعطال ميكانيكية",
    },
    {
      "name": "تغيير فلتر هواء",
      "icon": Icons.filter_alt,
      "category": "ميكانيكا",
      "price": 60,
      "rating": 4.5,
      "time": "5 دقائق",
      "desc": "تغيير فلتر الهواء",
    },

    // ================= كهرباء =================
    {
      "name": "تغيير بطارية",
      "icon": Icons.battery_charging_full,
      "category": "كهرباء",
      "price": 180,
      "rating": 4.7,
      "time": "12 دقيقة",
      "desc": "فحص وتركيب بطارية",
    },
    {
      "name": "شحن بطارية",
      "icon": Icons.battery_full,
      "category": "كهرباء",
      "price": 90,
      "rating": 4.4,
      "time": "10 دقائق",
      "desc": "شحن البطارية",
    },
    {
      "name": "فحص كهرباء",
      "icon": Icons.bolt,
      "category": "كهرباء",
      "price": 100,
      "rating": 4.3,
      "time": "15 دقيقة",
      "desc": "تشخيص كهرباء السيارة",
    },

    // ================= إطارات =================
    {
      "name": "بنشر / كاوتش",
      "icon": Icons.tire_repair,
      "category": "إطارات",
      "price": 60,
      "rating": 4.8,
      "time": "7 دقائق",
      "desc": "إصلاح إطار",
    },
    {
      "name": "تغيير كاوتش",
      "icon": Icons.circle,
      "category": "إطارات",
      "price": 80,
      "rating": 4.6,
      "time": "10 دقائق",
      "desc": "تغيير الإطار",
    },

    // ================= عفشة =================
    {
      "name": "فحص عفشة",
      "icon": Icons.car_repair,
      "category": "عفشة",
      "price": 120,
      "rating": 4.8,
      "time": "20 دقيقة",
      "desc": "فحص كامل للعفشة",
    },
    {
      "name": "تغيير مساعد",
      "icon": Icons.settings,
      "category": "عفشة",
      "price": 300,
      "rating": 4.7,
      "time": "30 دقيقة",
      "desc": "تغيير مساعد أمامي أو خلفي",
    },
    {
      "name": "شد عفشة",
      "icon": Icons.tune,
      "category": "عفشة",
      "price": 150,
      "rating": 4.6,
      "time": "25 دقيقة",
      "desc": "شد وضبط العفشة",
    },

    // ================= فحص =================
    {
      "name": "فحص كمبيوتر",
      "icon": Icons.memory,
      "category": "فحص",
      "price": 130,
      "rating": 4.6,
      "time": "8 دقائق",
      "desc": "تشخيص أعطال ECU",
    },

    // ================= تنظيف =================
    {
      "name": "غسيل السيارة",
      "icon": Icons.local_car_wash,
      "category": "تنظيف",
      "price": 90,
      "rating": 4.2,
      "time": "20 دقيقة",
      "desc": "غسيل داخلي وخارجي",
    },
  ];

  Map<String, dynamic> _safeService(Map<String, dynamic> s) => {
        ...s,
        "type": s["type"] ?? s["name"],
      };

  void _tap(VoidCallback fn) {
    HapticFeedback.selectionClick();
    fn();
  }

  List<Map<String, dynamic>> get _filtered {
    final search = _searchCtrl.text.trim().toLowerCase();

    final base = services.where((s) {
      final name = s["name"].toString().toLowerCase();
      final cat = s["category"].toString().toLowerCase();
      final matchSearch =
          search.isEmpty || name.contains(search) || cat.contains(search);
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
    await Future.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = mq.textScaler.scale(1.0);
    final clamped = scale.clamp(1.0, 1.12);
    final fixedMq = mq.copyWith(textScaler: TextScaler.linear(clamped));

    final filtered = _filtered;

    return MediaQuery(
      data: fixedMq,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _bg1,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              Container(decoration: BoxDecoration(gradient: _screenBgGradient)),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: _searchBar(),
                    ),
                    _categoriesRow(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: RefreshIndicator(
                        color: _brand,
                        onRefresh: _refresh,
                        child: filtered.isEmpty
                            ? _emptyState()
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                itemCount: filtered.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: 210,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                                itemBuilder: (_, i) {
                                  final s = filtered[i];
                                  return _serviceCard(s);
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
      ),
    );
  }

  // ================= AppBar =================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: _bluePrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(.10)),
            ),
            child: const Icon(
              Icons.extension_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "الخدمات الإضافية",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _bg3,
              Color.lerp(_bg3, _brand2, 0.10)!,
              Colors.transparent,
            ],
            stops: const [0.0, 0.80, 1.0],
          ),
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

  // ================= Search =================
  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
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
                borderSide:
                    BorderSide(color: _brand.withOpacity(.75), width: 1.4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= Categories =================
  Widget _categoriesRow() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final c = categories[i];
          final active = c == _category;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _tap(() => setState(() => _category = c)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                gradient: active ? _bluePrimary : null,
                color: active ? null : Colors.white.withOpacity(.06),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active ? Colors.white.withOpacity(.10) : _stroke,
                ),
                boxShadow: active ? _glow : null,
              ),
              child: Center(
                child: Text(
                  c,
                  style: GoogleFonts.cairo(
                    color: active ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= Service Card =================
  Widget _serviceCard(Map<String, dynamic> s) {
    final IconData icon = s["icon"] as IconData;
    final String name = s["name"].toString();
    final String cat = s["category"].toString();
    final num price = s["price"] as num;
    final num rating = s["rating"] as num;
    final String time = s["time"].toString();

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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: _shadowSm,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: _glass,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + rating badge
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: _bluePrimary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(.10),
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      const Spacer(),
                      _badge(
                        icon: Icons.star_rounded,
                        text: rating.toStringAsFixed(1),
                        bg: _brand.withOpacity(.16),
                        fg: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    cat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.2,
                    ),
                  ),
                  const Spacer(),

                  Row(
                    children: [
                      Expanded(
                        child: _badge(
                          icon: Icons.payments_rounded,
                          text: "$price ج.م",
                          bg: Colors.white.withOpacity(.06),
                          fg: Colors.white.withOpacity(.90),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _badge(
                          icon: Icons.timer_rounded,
                          text: time,
                          bg: Colors.white.withOpacity(.06),
                          fg: Colors.white.withOpacity(.90),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String text,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: fg,
                fontWeight: FontWeight.w900,
                fontSize: 12.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= Empty =================
  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: _glass,
            border: Border.all(color: _stroke),
            boxShadow: _shadowSm,
          ),
          child: Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: _bluePrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 12),
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

  // ================= Sort Sheet =================
  void _showSortSheet() {
    _tap(() {});
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.28,
          maxChildSize: 0.62,
          builder: (context, scrollCtrl) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(26)),
              child: Container(
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
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  children: [
                    Center(
                      child: Container(
                        width: 54,
                        height: 6,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Text(
                      "ترتيب الخدمات",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _sortTile(
                      title: "الأعلى تقييمًا",
                      sub: "يعرض الأفضل أولًا",
                      selected: _sortMode == _SortMode.topRated,
                      onTap: () {
                        setState(() => _sortMode = _SortMode.topRated);
                        Navigator.pop(context);
                      },
                    ),
                    _sortTile(
                      title: "الأقل سعرًا",
                      sub: "يعرض الأرخص أولًا",
                      selected: _sortMode == _SortMode.lowestPrice,
                      onTap: () {
                        setState(() => _sortMode = _SortMode.lowestPrice);
                        Navigator.pop(context);
                      },
                    ),
                    _sortTile(
                      title: "الأسرع",
                      sub: "يعرض الأسرع زمنًا",
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
      },
    );
  }

  Widget _sortTile({
    required String title,
    required String sub,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () => _tap(onTap),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: selected ? _bluePrimary : _glass,
          border: Border.all(
            color: selected ? Colors.white.withOpacity(.10) : _stroke,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(.10)
                    : Colors.white.withOpacity(.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? Colors.white.withOpacity(.10)
                      : Colors.white.withOpacity(.10),
                ),
              ),
              child: Icon(
                selected ? Icons.check_rounded : Icons.tune_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.6,
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
}
