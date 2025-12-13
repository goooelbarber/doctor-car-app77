// ignore_for_file: use_build_context_synchronously

import 'package:doctor_car_app/screens/select_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoadServicesSelectionScreen extends StatefulWidget {
  const RoadServicesSelectionScreen({super.key, required String initial});

  @override
  State<RoadServicesSelectionScreen> createState() =>
      _RoadServicesSelectionScreenState();
}

class _RoadServicesSelectionScreenState
    extends State<RoadServicesSelectionScreen> with TickerProviderStateMixin {
  final Set<String> _selected = {};

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final List<Map<String, dynamic>> services = [
    {"key": "tow", "title": "ونــش", "image": "assets/images/tow_truck.png"},
    {
      "key": "battery",
      "title": "بطــارية",
      "image": "assets/images/battery.png"
    },
    {"key": "fuel", "title": "بنــزين", "image": "assets/images/fuel.png"},
    {"key": "tire", "title": "الكــاوتش", "image": "assets/images/tire.png"},
    {"key": "ride", "title": "سيارة ركاب", "image": "assets/images/car.png"},
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  void _confirmOrder() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى اختيار خدمة أولاً"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectLocationScreen(
          serviceType: _selected.join(", "),
          userId: "68fe4505493ae17aa81d605b",
          selectedServices: _selected.toList(),
        ),
      ),
    );
  }

  /// ✨ ELEMENT: SERVICE BOX
  Widget _serviceCard(Map<String, dynamic> s, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: selected
            ? LinearGradient(
                colors: [
                  Colors.amber.shade600,
                  Colors.amber.shade300,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Colors.white, Color(0xFFF3F3F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: selected ? Colors.amber.withOpacity(0.4) : Colors.black12,
            blurRadius: selected ? 18 : 10,
            spreadRadius: selected ? 2 : 1,
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            if (selected) {
              _selected.remove(s["key"]);
            } else {
              _selected.add(s["key"]);
            }
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// ICON
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.black.withOpacity(.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: selected ? Colors.white54 : Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Image.asset(
                s["image"],
                width: 55,
                height: 55,
              ),
            ),

            const SizedBox(height: 10),

            /// TEXT
            Text(
              s["title"],
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: selected ? Colors.black : Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? Colors.black : Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      /// =================== APPBAR ===================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Text(
          "اختر الخدمة",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.amber,
          ),
        ),
        centerTitle: true,
      ),

      /// =================== BODY ===================
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// TITLE
                Text(
                  "ما نوع المساعدة التي تحتاجها؟",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 15),

                /// GOLD DIVIDER
                Container(
                  height: 3,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                /// SERVICES GRID
                Expanded(
                  child: GridView.builder(
                    itemCount: services.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemBuilder: (context, i) {
                      final s = services[i];
                      final selected = _selected.contains(s["key"]);
                      return _serviceCard(s, selected);
                    },
                  ),
                ),

                const SizedBox(height: 10),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.amber,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "متــابعة",
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
