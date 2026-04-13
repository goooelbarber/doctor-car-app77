// PATH: lib/screens/home_screen.dart

import 'dart:async';
import 'dart:convert';
// ignore: unused_import
import 'dart:io';
// ignore: unused_import
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
// ignore: unused_import
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
// ignore: unused_import
import '../features/photo_diagnosis/photo_preview_screen.dart';
import '../pages/home/home_page.dart';
import '../services/support_chat_service.dart';

// ignore: unused_import
import 'orders/orders_screen.dart';
import 'support_chat_screen.dart';
import '../maintenance_services_screen.dart';

import 'obd/obd_scan_screen.dart';

import 'about/about_us_screen.dart';
import 'account_settings_screen.dart';
import 'contact_screen.dart';
import 'road_services_screen.dart';
import 'smart_accident_screen.dart';

part 'home/home_models.dart';
part 'home/home_strings.dart';
part 'home/home_theme.dart';
part 'home/home_location.dart';
part 'home/home_smart_hub.dart';
part 'home/home_widgets.dart';
part 'home/home_how_card.dart';
part 'home/home_center_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isArabic = true;
  bool _isDarkMode = true;
  bool _prefsLoaded = false;

  bool _showAllCentersInHome = true;

  Position? _myPos;
  String? _locationError;

  Position? _cachedPos;
  DateTime? _cachedPosAt;

  static const List<int> _radiusOptionsKm = [5, 10, 20, 50];
  int _selectedRadiusKm = 20;

  double get _maxRadiusMeters => _selectedRadiusKm * 1000.0;
  // ignore: unused_field
  static const int _centersLimit = 50;

  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _timer;

  int _navIndex = 0;

  static const Color _primary = Color(0xFF7CCBFF);
  // ignore: unused_field
  static const Color _accent = Color(0xFF5BB8F6);

  final List<String> banners = const [
    "assets/images/v.png",
    "assets/images/vv.png",
    "assets/images/vvv.png",
    "assets/images/4444.png",
  ];

  final List<OfferItem> offers = const [
    OfferItem(
      title: "خصم 25% على الصيانة",
      image: "assets/offers/1.png",
      distance: "12 كم",
      until: "صالح حتى 31-01-2026",
    ),
    OfferItem(
      title: "خصم 8% على الزجاج المحلي",
      image: "assets/offers/2.png",
      distance: "15 كم",
      until: "صالح حتى 15-01-2026",
    ),
    OfferItem(
      title: "خصم 20% على السطحة",
      image: "assets/offers/3.png",
      distance: "9 كم",
      until: "صالح حتى 01-02-2026",
    ),
  ];

  late Future<List<CenterItem>> _centersFuture;

  @override
  void initState() {
    super.initState();

    _centersFuture = Future.value(<CenterItem>[]);
    _loadPrefs();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (banners.isEmpty) return;

      _currentBanner = (_currentBanner + 1) % banners.length;
      _bannerController.animateToPage(
        _currentBanner,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return Scaffold(
        backgroundColor: const Color(0xFF090B12),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Doctor Car",
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final bottomSpacer = 90 + bottomSafe;

    final mq = MediaQuery.of(context);
    final clampedScaler = mq.textScaler.clamp(
      minScaleFactor: 0.95,
      maxScaleFactor: 1.10,
    );

    return MediaQuery(
      data: mq.copyWith(textScaler: clampedScaler),
      child: Directionality(
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: _buildAppBar(),
          endDrawer: _buildDrawer(),
          bottomNavigationBar: _buildBottomNavCurvedWithCall(),
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: _primary,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: _bannerSlider()),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: _buildQuickActionGrid()),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 22)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: _sectionTitle(
                        _isArabic
                            ? "المراكز القريبة وكل المراكز"
                            : "Nearby & all centers",
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: _radiusSelector()),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: _myLocationCard()),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: _centersList()),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: _howToUseDoctorCar()),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: _whyDoctorCar()),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: _customerService()),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: bottomSpacer)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
