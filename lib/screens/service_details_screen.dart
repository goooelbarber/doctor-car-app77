// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'map_picker_screen.dart';
import 'searching_technician_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final LinearGradient _gold = const LinearGradient(
    colors: [Color(0xffE8C87A), Color(0xffB68A32)],
  );

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 10, 23),
      appBar: _buildAppBar(s),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            children: [
              const SizedBox(height: 18),
              _serviceIcon(s),
              const SizedBox(height: 14),
              _serviceTitle(s),
              const SizedBox(height: 8),
              _ratingTimeRow(s),
              const SizedBox(height: 22),
              _glassSection(
                title: "وصف الخدمة",
                icon: Icons.description,
                child: Text(
                  s["desc"],
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _glassSection(
                title: "السعر",
                icon: Icons.payments,
                child: Text(
                  "${s['price']} جنيه",
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomButton(s),
    );
  }

  // ---------------- APP BAR ----------------

  AppBar _buildAppBar(Map s) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: ShaderMask(
        shaderCallback: (b) => _gold.createShader(b),
        child: Text(
          s["name"],
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.redAccent,
          ),
          onPressed: () => setState(() => isFavorite = !isFavorite),
        ),
      ],
    );
  }

  // ---------------- ICON ----------------

  Widget _serviceIcon(Map s) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _gold,
        boxShadow: [
          BoxShadow(color: Colors.amber.withOpacity(.4), blurRadius: 25),
        ],
      ),
      child: Icon(s["icon"], size: 70, color: Colors.black),
    );
  }

  Widget _serviceTitle(Map s) {
    return Text(
      s["name"],
      style: GoogleFonts.cairo(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _ratingTimeRow(Map s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, color: Colors.amber),
        const SizedBox(width: 4),
        Text("${s['rating']}", style: GoogleFonts.cairo(color: Colors.white)),
        const SizedBox(width: 18),
        const Icon(Icons.timer, color: Colors.white54),
        const SizedBox(width: 4),
        Text(s["time"], style: GoogleFonts.cairo(color: Colors.white70)),
      ],
    );
  }

  Widget _glassSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.06),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(title,
                        style: GoogleFonts.cairo(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- FINAL FLOW BUTTON ----------------

  Widget _bottomButton(Map s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 1, 10, 23),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(.08))),
      ),
      child: SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.location_on, color: Colors.black),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () async {
            /// 1️⃣ اختار الموقع
            final location = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MapPickerScreen(
                  selectedService: s["name"],
                ),
              ),
            );

            if (location == null) return;

            /// 2️⃣ البحث عن الفني
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchingTechnicianScreen(
                  userId: "user_001",
                  serviceType: s["name"],
                  lat: location.latitude,
                  lng: location.longitude,
                  orderId: DateTime.now().millisecondsSinceEpoch.toString(),
                  selectedServices: [],
                  address: '',
                ),
              ),
            );
          },
          label: Text(
            "تحديد الموقع وبدء الطلب",
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
