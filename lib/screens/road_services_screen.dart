// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';
import 'package:doctor_car_app/screens/smart_accident_screen.dart';
import 'package:doctor_car_app/screens/supplementary_services_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'select_location_screen.dart';

class RoadServicesScreen extends StatefulWidget {
  const RoadServicesScreen({super.key});

  @override
  State<RoadServicesScreen> createState() => _RoadServicesScreenState();
}

class _RoadServicesScreenState extends State<RoadServicesScreen>
    with TickerProviderStateMixin {
  String? selected;

  final services = [
    {
      "key": "tow",
      "name": "خدمة ونش",
      "img": "assets/images/tow_truck.png",
    },
    {
      "key": "battery",
      "name": "خدمة بطارية",
      "img": "assets/images/battery.png",
    },
    {
      "key": "fuel",
      "name": "خدمة بنزين",
      "img": "assets/images/fuel.png",
    },
    {
      "key": "tire",
      "name": "خدمة الكاوتش",
      "img": "assets/images/tire.png",
    },
    {
      "key": "ride",
      "name": "سيارة ركاب",
      "img": "assets/images/car.png",
    },

    // -----------------------------
    // NEW services added inside Road
    // -----------------------------
    {
      "key": "more",
      "name": "الخدمات الإضافية",
      "img": "assets/images/more_service.png",
    },
    {
      "key": "accident",
      "name": "تبليغ عن حادث",
      "img": "assets/images/accident_service.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          "🚘 خدمات الطريق",
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff0D1B2A),
                  Color(0xff1B263B),
                  Color(0xff415A77),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.only(top: 120, left: 16, right: 16),
            child: Column(
              children: [
                Text(
                  "اختر خدمتك المطلوبة",
                  style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    itemCount: services.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.88,
                    ),
                    itemBuilder: (_, index) {
                      final item = services[index];
                      final isSel = selected == item['key'];

                      return GestureDetector(
                        onTap: () => setState(() => selected = item['key']),
                        onDoubleTap: () {
                          // ---------- Auto Open ----------
                          if (item["key"] == "more") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SupplementaryServicesScreen(),
                              ),
                            );
                          } else if (item["key"] == "accident") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SmartAccidentScreen(),
                              ),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSel
                                  ? Colors.amber
                                  : Colors.white.withOpacity(0.2),
                              width: isSel ? 3 : 1.3,
                            ),
                            color: Colors.white.withOpacity(0.08),
                            boxShadow: [
                              if (isSel)
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.4),
                                  blurRadius: 25,
                                  offset: const Offset(0, 5),
                                ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    item['img']!,
                                    width: 210,
                                    height: 150,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item['name']!,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),

          // Request button
          Positioned(
            bottom: 25,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: selected == null
                  ? null
                  : () {
                      if (selected == "more") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SupplementaryServicesScreen(),
                          ),
                        );
                        return;
                      }

                      if (selected == "accident") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SmartAccidentScreen(),
                          ),
                        );
                        return;
                      }

                      // Default Road services → needs a location
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SelectLocationScreen(
                            serviceType: selected!,
                            userId: "68fe4505493ae17aa81d605b",
                            selectedServices: [selected!],
                          ),
                        ),
                      );
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: selected == null
                      ? Colors.grey.shade500
                      : Colors.amber.shade600,
                  boxShadow: [
                    if (selected != null)
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.45),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    selected == "more"
                        ? "عرض الخدمات الإضافية"
                        : selected == "accident"
                            ? "فتح نظام الحوادث الذكي"
                            : "🚗 طلب الخدمة الآن",
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
