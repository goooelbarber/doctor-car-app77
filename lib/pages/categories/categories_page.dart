import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/categories/categories_data.dart';
import '../products/product_list_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _card = Colors.white;
  static const Color _brand = Color(0xFF1565C0);
  static const Color _brandSoft = Color(0xFFE8F2FF);
  static const Color _textMain = Color(0xFF111827);
  static const Color _textSub = Color(0xFF6B7280);
  static const Color _stroke = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final items = categories;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _bg,
          centerTitle: true,
          title: Text(
            "أقسام قطع الغيار",
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              color: _textMain,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: _textMain),
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            _infoBanner(),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return _categoryCard(
                    context: context,
                    categoryId: item.id,
                    categoryName: item.name,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _stroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _brandSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.category_rounded,
                color: _brand,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "اختر القسم المناسب لتصفح قطع الغيار بشكل أسرع وأسهل.",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.2,
                  color: _textMain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard({
    required BuildContext context,
    required int categoryId,
    required String categoryName,
  }) {
    final icon = _iconForCategory(categoryName);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListPage(categoryId: categoryId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _stroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _brandSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: _brand,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: _textMain,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "عرض المنتجات",
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: _textSub,
              ),
            ),
          ],
        ),
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
    if (text.contains('تعليق')) return Icons.car_repair_rounded;
    if (text.contains('إطار') || text.contains('اطار')) {
      return Icons.tire_repair_rounded;
    }
    if (text.contains('محرك')) return Icons.precision_manufacturing_rounded;

    return Icons.category_rounded;
  }
}
