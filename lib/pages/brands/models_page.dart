import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/cars/car_models_data.dart';
import '../products/product_list_page.dart';

class ModelsPage extends StatefulWidget {
  final String brandName;
  final int brandId;

  const ModelsPage({
    super.key,
    required this.brandName,
    required this.brandId,
  });

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  String searchText = "";

  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _card = Colors.white;
  static const Color _brand = Color(0xFF1565C0);
  static const Color _brandSoft = Color(0xFFE8F2FF);
  static const Color _textMain = Color(0xFF111827);
  static const Color _textSub = Color(0xFF6B7280);
  static const Color _stroke = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    // ✅ أهم تعديل: فلترة بالـ ID
    final models = carModels.where((m) => m.brandId == widget.brandId).toList();

    final filteredModels = models.where((model) {
      return model.modelName.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _bg,
          centerTitle: true,
          title: Text(
            "موديلات ${widget.brandName}",
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
            const SizedBox(height: 10),
            _infoBanner(filteredModels.length),
            const SizedBox(height: 12),
            _searchBar(),
            const SizedBox(height: 14),
            Expanded(
              child: filteredModels.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredModels.length,
                      itemBuilder: (context, index) {
                        final model = filteredModels[index];

                        return _modelCard(
                          modelName: model.modelName,
                          years: "${model.years.first} - ${model.years.last}",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductListPage(
                                  brandId: widget.brandId,
                                  modelId: model.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _brandSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.precision_manufacturing_rounded,
                color: _brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "اختر الموديل لعرض قطع الغيار المتوافقة فقط",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.2,
                  color: _textMain,
                ),
              ),
            ),
            Text(
              "$count موديل",
              style: GoogleFonts.cairo(
                color: _brand,
                fontWeight: FontWeight.w900,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _stroke),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: _textSub),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "ابحث عن الموديل...",
                  hintStyle: GoogleFonts.cairo(
                    color: _textSub,
                    fontWeight: FontWeight.w700,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() => searchText = val);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _modelCard({
    required String modelName,
    required String years,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: _brandSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.directions_car_filled,
                size: 36,
                color: _brand,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modelName,
                    style: GoogleFonts.cairo(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "سنوات: $years",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: _textSub,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: _brand,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "عرض القطع",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        "لا يوجد موديلات",
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: _textSub,
        ),
      ),
    );
  }
}
