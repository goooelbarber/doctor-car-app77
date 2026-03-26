import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../service_details_screen.dart';

class ServicesHistoryScreen extends StatefulWidget {
  const ServicesHistoryScreen({super.key});

  @override
  State<ServicesHistoryScreen> createState() => _ServicesHistoryScreenState();
}

class _ServicesHistoryScreenState extends State<ServicesHistoryScreen> {
  static const Color _bg = Color.fromARGB(255, 1, 10, 23);

  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = "الكل";

  LinearGradient get _gold => const LinearGradient(
        colors: [Color(0xffE8C87A), Color(0xffB68A32)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  List<ServiceModel> get _filteredServices {
    return _services.where((s) {
      final matchSearch = s.title.contains(_searchCtrl.text.trim());
      final matchFilter = _filter == "الكل" || s.status == _filter;
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _searchBar(),
            _filterTabs(),
            Expanded(
              child: _filteredServices.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredServices.length,
                      itemBuilder: (context, index) {
                        return _serviceCard(context, _filteredServices[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- APP BAR ----------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: ShaderMask(
        shaderCallback: (b) => _gold.createShader(b),
        child: Text(
          "Service History",
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ---------------- SEARCH ----------------

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.cairo(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search service...",
          hintStyle: GoogleFonts.cairo(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withOpacity(.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---------------- FILTER ----------------

  Widget _filterTabs() {
    final tabs = ["الكل", "مكتمل", "ملغي"];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((t) {
          final active = _filter == t;
          return GestureDetector(
            onTap: () => setState(() => _filter = t),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                gradient: active ? _gold : null,
                color: active ? null : Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                t,
                style: GoogleFonts.cairo(
                  color: active ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------- CARD ----------------

  Widget _serviceCard(BuildContext context, ServiceModel s) {
    final bool isDone = s.status == "مكتمل";

    return InkWell(
      onTap: () => _openDetails(context, s),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(.15)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.amber,
                        child: Icon(s.icon, color: Colors.black),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.title,
                                style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(s.date,
                                style: GoogleFonts.cairo(
                                    color: Colors.white60, fontSize: 13)),
                            Text("Order #${s.id}",
                                style: GoogleFonts.cairo(
                                    color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${s.price} EGP",
                              style: GoogleFonts.cairo(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          _statusChip(isDone),
                        ],
                      )
                    ],
                  ),

                  const Divider(color: Colors.white12),

                  // EXTRA DETAILS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _info("⏱", s.duration),
                      _info("⭐", s.rating.toString()),
                      _info("📍", "Location"),
                      _info("🧾", "Invoice"),
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

  Widget _info(String icon, String text) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(text,
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // ---------------- HELPERS ----------------

  void _openDetails(BuildContext context, ServiceModel s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsScreen(
          service: {
            "name": s.title,
            "price": s.price,
            "icon": s.icon,
            "rating": s.rating,
            "time": s.duration,
            "desc": s.details,
            "type": s.title,
          },
        ),
      ),
    );
  }

  Widget _statusChip(bool isDone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDone
            ? Colors.greenAccent.withOpacity(.15)
            : Colors.redAccent.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDone ? "Completed" : "Cancelled",
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDone ? Colors.greenAccent : Colors.redAccent,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        "No previous services 🚗",
        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 18),
      ),
    );
  }
}

// ---------------- MODEL ----------------

class ServiceModel {
  final int id;
  final String title;
  final String date;
  final String status;
  final double price;
  final IconData icon;
  final String duration;
  final double rating;
  final String details;

  ServiceModel({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.price,
    required this.icon,
    required this.duration,
    required this.rating,
    required this.details,
  });
}

// ---------------- DATA ----------------

final List<ServiceModel> _services = [
  ServiceModel(
    id: 1023,
    title: "Car Towing",
    date: "12 March 2025 · 4:30 PM",
    status: "مكتمل",
    price: 350,
    icon: Icons.local_shipping,
    duration: "30 min",
    rating: 4.6,
    details: "Full towing service with professional driver",
  ),
  ServiceModel(
    id: 1024,
    title: "Battery Replacement",
    date: "5 March 2025 · 1:10 PM",
    status: "مكتمل",
    price: 220,
    icon: Icons.battery_charging_full,
    duration: "20 min",
    rating: 4.8,
    details: "Battery replacement and system check",
  ),
  ServiceModel(
    id: 1025,
    title: "Accident Report",
    date: "20 February 2025 · 11:00 AM",
    status: "ملغي",
    price: 0,
    icon: Icons.car_crash,
    duration: "-",
    rating: 0,
    details: "Accident report was cancelled",
  ),
];
