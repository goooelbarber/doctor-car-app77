import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_details_screen.dart';

class SupplementaryServicesScreen extends StatefulWidget {
  const SupplementaryServicesScreen({super.key});

  @override
  State<SupplementaryServicesScreen> createState() =>
      _SupplementaryServicesScreenState();
}

class _SupplementaryServicesScreenState
    extends State<SupplementaryServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  // -----------------------------------
  // 🔥 CATEGORIES
  // -----------------------------------
  final List<String> categories = [
    "الكل",
    "ميكانيكا",
    "كهرباء",
    "إطارات",
    "فحص",
    "تنظيف",
  ];

  String selectedCategory = "الكل";

  // -----------------------------------
  // 🔥 ALL SERVICES — PRO VERSION
  // -----------------------------------
  final List<Map<String, dynamic>> allServices = [
    {
      "name": "تغيير زيت",
      "icon": Icons.oil_barrel_rounded,
      "type": "ميكانيكا",
      "price": 120,
      "rating": 4.7,
      "time": "10 دقائق",
      "popular": true,
      "desc": "تغيير زيت مع فحص سريع للمحرك.",
    },
    {
      "name": "فحص كهرباء",
      "icon": Icons.bolt,
      "type": "كهرباء",
      "price": 90,
      "rating": 4.3,
      "time": "15 دقيقة",
      "popular": false,
      "desc": "تشخيص كهربائي كامل.",
    },
    {
      "name": "بنشر / كاوتش",
      "icon": Icons.tire_repair,
      "type": "إطارات",
      "price": 60,
      "rating": 4.8,
      "time": "7 دقائق",
      "popular": true,
      "desc": "إصلاح إطار مع تعبئة هواء.",
    },
    {
      "name": "ميكانيكي عام",
      "icon": Icons.build,
      "type": "ميكانيكا",
      "price": 150,
      "rating": 4.9,
      "time": "20 دقيقة",
      "popular": true,
      "desc": "خدمة ميكانيكا عند موقع العميل.",
    },
    {
      "name": "تنظيف السيارة",
      "icon": Icons.local_car_wash,
      "type": "تنظيف",
      "price": 75,
      "rating": 4.1,
      "time": "20 دقيقة",
      "popular": false,
      "desc": "غسيل خارجي + داخلي.",
    },
    {
      "name": "فحص كمبيوتر",
      "icon": Icons.memory,
      "type": "فحص",
      "price": 130,
      "rating": 4.6,
      "time": "8 دقائق",
      "popular": true,
      "desc": "فحص كمبيوتر كامل.",
    },
    {
      "name": "فلتر هواء",
      "icon": Icons.filter_alt,
      "type": "ميكانيكا",
      "price": 50,
      "rating": 4.0,
      "time": "5 دقائق",
      "popular": false,
      "desc": "تغيير فلتر الهواء.",
    },
    {
      "name": "بطارية — تغيير / شحن",
      "icon": Icons.battery_full,
      "type": "كهرباء",
      "price": 180,
      "rating": 4.7,
      "time": "12 دقيقة",
      "popular": true,
      "desc": "فحص + تركيب بطارية.",
    },
  ];

  List<Map<String, dynamic>> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = List<Map<String, dynamic>>.from(allServices);
  }

  // -----------------------------------
  // 🔍 SEARCH
  // -----------------------------------
  void _search(String text) {
    setState(() {
      filtered = allServices.where((service) {
        final matchName = service["name"].toString().contains(text);
        final matchType = service["type"].toString().contains(text);

        final matchCat = selectedCategory == "الكل"
            ? true
            : service["type"] == selectedCategory;

        return (matchName || matchType) && matchCat;
      }).toList();
    });
  }

  // -----------------------------------
  // 🔘 FILTER CATEGORY
  // -----------------------------------
  void _filterCategory(String cat) {
    setState(() {
      selectedCategory = cat;
      filtered = allServices.where((service) {
        if (cat == "الكل") return true;
        return service["type"] == cat;
      }).toList();
    });
  }

  // -----------------------------------
  // OPEN DETAILS PAGE
  // -----------------------------------
  void _openDetails(Map<String, dynamic> service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsScreen(service: service),
      ),
    );
  }

  // -----------------------------------
  //   UI
  // -----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text("الخدمات الإضافية", style: GoogleFonts.cairo()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -----------------------------------
            // SEARCH BAR
            // -----------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.06),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: "ابحث عن خدمة...",
                  hintStyle: GoogleFonts.cairo(color: Colors.grey),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Colors.redAccent),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // -----------------------------------
            // CATEGORIES
            // -----------------------------------
            SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isActive = cat == selectedCategory;

                  return GestureDetector(
                    onTap: () => _filterCategory(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.redAccent : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isActive
                                ? Colors.redAccent
                                : Colors.grey.shade400),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: GoogleFonts.cairo(
                            color: isActive ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // -----------------------------------
            // SERVICES GRID
            // -----------------------------------
            Expanded(
              child: GridView.builder(
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 170,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final s = filtered[index];

                  return GestureDetector(
                    onTap: () => _openDetails(s),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.08),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(s["icon"], size: 50, color: Colors.redAccent),
                          const SizedBox(height: 10),
                          Text(
                            s["name"],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${s['price']} جنيه",
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star,
                                  size: 16, color: Colors.amber.shade700),
                              Text(
                                "${s['rating']}",
                                style: GoogleFonts.cairo(
                                    fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
