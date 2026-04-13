import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = "";
  List<String> history = [
    "فلتر زيت",
    "بطارية",
    "فحمات فرامل",
  ];

  // =========================
  // COLORS
  // =========================
  static const Color _bg = Color(0xFF07111B);
  // ignore: unused_field
  static const Color _bg2 = Color(0xFF0B1624);

  // ignore: unused_field
  static const Color _brand = Color(0xFF1E6FD9);
  static const Color _brandSoft = Color(0xFF8FD3FF);

  static const Color _textMain = Color(0xFFF5F7FB);
  static const Color _textSub = Color(0xFFB8C5D4);
  static const Color _hint = Color(0xFF8EA1B5);

  LinearGradient get _gradient => const LinearGradient(
        colors: [Color(0xFF2A8CFF), Color(0xFF0C5FB8)],
      );

  Color get _stroke => Colors.white.withOpacity(.08);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            _background(),
            SafeArea(
              child: Column(
                children: [
                  _header(context),
                  const SizedBox(height: 10),
                  _searchBar(),
                  const SizedBox(height: 16),
                  if (query.isEmpty)
                    _suggestions()
                  else
                    Expanded(child: _results()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BACKGROUND =================
  Widget _background() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A1830),
                  Color(0xFF050B14),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: -100,
          right: -60,
          child: _glow(220),
        ),
      ],
    );
  }

  Widget _glow(double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _brandSoft.withOpacity(.08),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _iconBtn(Icons.arrow_back_ios_new, () {
            Navigator.pop(context);
          }),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "بحث",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: _textMain,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _iconBtn(Icons.tune_rounded, () {}),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _stroke),
        ),
        child: Icon(icon, color: _textMain),
      ),
    );
  }

  // ================= SEARCH BAR =================
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _stroke),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: _gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: GoogleFonts.cairo(color: _textMain),
                    decoration: InputDecoration(
                      hintText: "ابحث عن قطعة أو رقم OEM...",
                      hintStyle: GoogleFonts.cairo(color: _hint),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      setState(() => query = v);
                    },
                  ),
                ),
                if (query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() => query = "");
                    },
                    child: const Icon(Icons.close, color: Colors.white),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= SUGGESTIONS =================
  Widget _suggestions() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _sectionTitle("عمليات البحث الأخيرة"),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: history.map((e) {
              return GestureDetector(
                onTap: () {
                  setState(() => query = e);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _stroke),
                  ),
                  child: Text(
                    e,
                    style: GoogleFonts.cairo(
                      color: _textSub,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _sectionTitle("اقتراحات"),
          const SizedBox(height: 10),
          ...["فلتر هواء", "زيت محرك", "بطارية", "كشافات"].map((e) => ListTile(
                leading: const Icon(Icons.search, color: Colors.white70),
                title: Text(
                  e,
                  style: GoogleFonts.cairo(color: _textMain),
                ),
                onTap: () {
                  setState(() => query = e);
                },
              ))
        ],
      ),
    );
  }

  // ================= RESULTS =================
  Widget _results() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _stroke),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withOpacity(.05),
                ),
                child: const Icon(Icons.image, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "اسم المنتج",
                      style: GoogleFonts.cairo(
                        color: _textMain,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "150 ريال",
                      style: GoogleFonts.cairo(
                        color: _brandSoft,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.white54)
            ],
          ),
        );
      },
    );
  }

  // ================= TITLE =================
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        color: _textMain,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
