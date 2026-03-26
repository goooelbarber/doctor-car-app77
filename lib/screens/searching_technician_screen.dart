// PATH: lib/screens/searching_technician_screen.dart
// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show HapticFeedback, rootBundle, Clipboard, ClipboardData;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../services/socket_service.dart';
import 'tracking/tracking_screen.dart';

enum SearchStatus {
  searching,
  contacting,
  list,
  assigned,
  timeout,
  canceled,
  failed,
  offline,
}

extension SearchStatusX on SearchStatus {
  bool get isError =>
      this == SearchStatus.timeout ||
      this == SearchStatus.failed ||
      this == SearchStatus.offline;
}

class SearchingTechnicianScreen extends StatefulWidget {
  final String userId;
  final String serviceType;
  final double lat;
  final double lng;
  final String address;
  final List<String> selectedServices;
  final String orderId;

  /// Fake mode
  final bool fakeMode;
  final int fakeAfterSeconds;
  final int fakeTechCount;

  /// Uber-like auto match
  final bool autoMatchBestTech;
  final int autoAssignAfterSeconds;

  /// Hide list (لو عايز تشوف ليست تحت)
  final bool hideTechList;

  const SearchingTechnicianScreen({
    super.key,
    required this.userId,
    required this.serviceType,
    required this.lat,
    required this.lng,
    required this.address,
    required this.selectedServices,
    required this.orderId,
    this.fakeMode = false,
    this.fakeAfterSeconds = 2,
    this.fakeTechCount = 8,
    this.autoMatchBestTech = true,
    this.autoAssignAfterSeconds = 2,
    this.hideTechList = true,
  });

  @override
  State<SearchingTechnicianScreen> createState() =>
      _SearchingTechnicianScreenState();
}

class _SearchingTechnicianScreenState extends State<SearchingTechnicianScreen>
    with TickerProviderStateMixin {
  // ======================
  // DoctorCar THEME
  // ======================
  static const Color _brand =
      Color.fromARGB(255, 32, 53, 147); // ✅ DoctorCar neon lime
  static const Color _bg1 = Color(0xFF0B1220);
  static const Color _bg2 = Color(0xFF081837);
  static const Color _bg3 = Color(0xFF0A2038);

  static const Color _card = Color(0xFF121B2E);
  // ignore: unused_field
  static const Color _card2 = Color(0xFF0F1A30);

  static const Color _danger = Color.fromARGB(255, 8, 195, 242);

  static const int _searchTimeoutSeconds = 45;

  static const List<String> _fakeNames = [
    "أحمد",
    "محمد",
    "علي",
    "محمود",
    "كريم",
    "يوسف",
    "حسام",
    "مصطفى",
  ];

  final SocketService _socket = SocketService();

  late final LatLng _userLocation;
  late final bool _effectiveFake;

  GoogleMapController? _map;
  String? _mapStyle;
  BitmapDescriptor? _carIcon;
  BitmapDescriptor? _userIcon;

  // ======================
  // UI / State
  // ======================
  bool _navigated = false;
  bool _finished = false;
  bool _canceling = false;

  SearchStatus _status = SearchStatus.searching;
  String? _statusMessage;

  bool _socketConnected = false;

  Timer? _secondsTimer;
  int _seconds = 0;

  Timer? _hardTimeoutTimer;

  // pulse animation
  late final AnimationController _pulseCtrl;

  // progress step animation
  late final AnimationController _stepCtrl;

  // ======================
  // Fake tech list + markers
  // ======================
  final List<_TechPreview> _fakeTechs = [];
  _TechPreview? _selectedTech;

  final Map<String, Marker> _techMarkers = {};

  Timer? _fakeFlowTimer;
  Timer? _autoAssignTimer;

  String? _assignedTechId;

  bool get _hasAssigned => _assignedTechId != null;

  // ======================
  // Gradients & Shadows
  // ======================
  // ignore: unused_element
  LinearGradient get _screenGradient => const LinearGradient(
        colors: [_bg1, _bg2, _bg3],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  LinearGradient get _greenToWhite => LinearGradient(
        colors: [_brand.withOpacity(.96), Colors.white],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  List<BoxShadow> get _glow => [
        BoxShadow(
          color: _brand.withOpacity(.28),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(.25),
          blurRadius: 26,
          offset: const Offset(0, 16),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _userLocation = LatLng(widget.lat, widget.lng);
    _effectiveFake = widget.fakeMode || widget.orderId.trim().isEmpty;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _stepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _loadAssets();
    _startSecondCounter();

    if (_effectiveFake) {
      _startFakeSearchFlow();
    } else {
      _connectSocketAndListen();
      _startHardTimeout();
      _watchOfflineFallback();
    }
  }

  // ======================
  // Assets
  // ======================
  Future<void> _loadAssets() async {
    await Future.wait([
      _loadMarkerIcons(),
      _loadMapStyle(),
    ]);
  }

  Future<void> _loadMapStyle() async {
    try {
      final s = await rootBundle.loadString("assets/map_styles/uber_dark.json");
      if (!mounted) return;
      _mapStyle = s;
      if (_map != null) await _map!.setMapStyle(_mapStyle);
      setState(() {});
    } catch (_) {
      // fallback handled in onMapCreated
    }
  }

  Future<void> _loadMarkerIcons() async {
    try {
      final car = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        "assets/icons/car_top.png",
      );

      final pin = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(70, 70)),
        "assets/icons/user_pin.png",
      );

      if (!mounted) return;
      setState(() {
        _carIcon = car;
        _userIcon = pin;
      });
    } catch (_) {}
  }

  // ======================
  // Timers
  // ======================
  void _startSecondCounter() {
    _secondsTimer?.cancel();
    _secondsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_finished) return;
      setState(() => _seconds++);
    });
  }

  void _startHardTimeout() {
    _hardTimeoutTimer?.cancel();
    _hardTimeoutTimer =
        Timer(const Duration(seconds: _searchTimeoutSeconds), () {
      if (!mounted || _finished || _navigated) return;
      _setStatus(
        SearchStatus.timeout,
        "لم يتم العثور على فني خلال الوقت المحدد، حاول مرة أخرى",
      );
    });
  }

  void _watchOfflineFallback() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || _finished) return;
      if (!_socketConnected) {
        _setStatus(SearchStatus.offline, "لا يوجد اتصال مباشر (Offline)");
      }
    });
  }

  // ======================
  // Status Helpers
  // ======================
  void _setStatus(SearchStatus s, [String? msg]) {
    if (!mounted || _finished) return;

    // في Fake: ممنوع ندخل في states سلبية
    if (_effectiveFake &&
        (s == SearchStatus.failed ||
            s == SearchStatus.offline ||
            s == SearchStatus.timeout)) {
      return;
    }

    setState(() {
      _status = s;
      final m = (msg ?? "").trim();
      _statusMessage = m.isEmpty ? null : m;
    });

    // animate step small pulse
    _stepCtrl
      ..stop()
      ..reset()
      ..forward();

    // في REAL: لما يتعمل assigned من السيرفر -> روح tracking
    if (!_effectiveFake && s == SearchStatus.assigned && !_navigated) {
      _finished = true;
      _navigated = true;
      _goToTracking();
    }
  }

  int get _stepIndex {
    switch (_status) {
      case SearchStatus.searching:
      case SearchStatus.contacting:
        return 0;
      case SearchStatus.list:
        return 1;
      case SearchStatus.assigned:
        return 2;
      default:
        return 0;
    }
  }

  String get _headerText {
    switch (_status) {
      case SearchStatus.assigned:
        return "✅ تم اختيار أفضل فني... جاري فتح التتبع";
      case SearchStatus.list:
        return "تم العثور على فنيين متاحين";
      case SearchStatus.contacting:
        return "جاري البحث عن فنيين متاحين...";
      case SearchStatus.timeout:
        return "لم يتم العثور على فني الآن";
      case SearchStatus.offline:
        return "Offline - لا يوجد اتصال مباشر";
      case SearchStatus.canceled:
        return "تم إلغاء الطلب";
      case SearchStatus.failed:
        return "حدث خطأ أثناء البحث";
      case SearchStatus.searching:
      // ignore: unreachable_switch_default
      default:
        return "جارٍ البحث عن فني قريب...";
    }
  }

  // ======================
  // Socket (REAL)
  // ======================
  void _connectSocketAndListen() {
    _socket.initUser(userId: widget.userId);

    _socket.onConnectionChanged((connected) {
      if (!mounted) return;
      setState(() => _socketConnected = connected);

      if (connected) {
        _setStatus(
          SearchStatus.contacting,
          "جاري التواصل مع الفنيين القريبين...",
        );
        _socket.joinOrderRoom(widget.orderId);

        // اختيار أفضل فني (لو السيرفر داعم)
        _socket.requestBestMatch(
          orderId: widget.orderId,
          lat: widget.lat,
          lng: widget.lng,
          serviceType: widget.serviceType,
          selectedServices: widget.selectedServices,
        );
      } else {
        if (!_finished && !_navigated) {
          _setStatus(SearchStatus.offline, "انقطع الاتصال (Offline)");
        }
      }
    });

    _socket.joinOrderRoom(widget.orderId);

    _socket.onOrderAccepted((data) {
      if (!mounted) return;
      _setStatus(SearchStatus.assigned, (data["message"] ?? "").toString());
    });

    _socket.onOrderStatusUpdated((status, data) {
      final msg = (data["message"] ?? "").toString();
      final s = _mapStringToStatus(status);
      _setStatus(s, msg);
    });

    _socket.onMatchStatus((data) {
      if (!mounted) return;
      final msg = (data["message"] ?? data["status"] ?? "").toString().trim();
      if (msg.isNotEmpty) _setStatus(_status, msg);
    });
  }

  SearchStatus _mapStringToStatus(String raw) {
    final s = raw.toLowerCase().trim();
    switch (s) {
      case "contacting":
        return SearchStatus.contacting;
      case "list":
        return SearchStatus.list;
      case "assigned":
        return SearchStatus.assigned;
      case "timeout":
        return SearchStatus.timeout;
      case "canceled":
        return SearchStatus.canceled;
      case "failed":
        return SearchStatus.failed;
      case "offline":
        return SearchStatus.offline;
      case "searching":
      default:
        return SearchStatus.searching;
    }
  }

  void _goToTracking() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TrackingScreen(
          orderId: widget.orderId,
          userId: widget.userId,
          baseUrl: ApiConfig.baseUrl,
          serviceType: widget.serviceType,
          userLat: widget.lat,
          userLng: widget.lng,
        ),
      ),
    );
  }

  // ======================
  // ✅ Fake Search Flow
  // ======================
  void _startFakeSearchFlow() {
    _setStatus(SearchStatus.contacting, "جاري البحث عن فنيين متاحين...");

    _fakeFlowTimer?.cancel();
    _fakeFlowTimer =
        Timer(Duration(seconds: widget.fakeAfterSeconds), () async {
      if (!mounted || _finished) return;

      _generateFakeAvailableTechs(count: widget.fakeTechCount);
      _buildTechMarkersFromList();

      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {}

      await _fitUserAndAllTechs();

      _setStatus(SearchStatus.list, "تم العثور على فنيين متاحين");

      if (widget.autoMatchBestTech) {
        _autoAssignTimer?.cancel();
        _autoAssignTimer =
            Timer(Duration(seconds: widget.autoAssignAfterSeconds), () async {
          if (!mounted || _finished) return;

          final best = _pickBestAvailableTech();
          if (best == null) {
            _setStatus(
                SearchStatus.timeout, "لا يوجد فني متاح الآن (تجربة فيك)");
            return;
          }

          await _assignAndNavigate(best);
        });
      }
    });
  }

  void _generateFakeAvailableTechs({required int count}) {
    final rnd = math.Random();
    _fakeTechs.clear();

    for (int i = 0; i < count; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final meters = 200 + rnd.nextInt(1400); // 0.2 -> 1.6km

      final dLat = (meters / 111000.0) * math.cos(angle);
      final dLng =
          (meters / (111000.0 * math.cos(_degToRad(_userLocation.latitude)))) *
              math.sin(angle);

      final pos =
          LatLng(_userLocation.latitude + dLat, _userLocation.longitude + dLng);

      final rating = 3.9 + rnd.nextDouble() * 1.1; // 3.9 -> 5.0
      final distKm = meters / 1000.0;

      _fakeTechs.add(_TechPreview(
        id: "FAKE_TECH_${i + 1}",
        name: _fakeNames[i % _fakeNames.length],
        rating: double.parse(rating.toStringAsFixed(1)),
        distanceKm: distKm,
        pos: pos,
        isOnline: true,
        isAvailable: true,
      ));
    }

    _fakeTechs.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    _selectedTech = _fakeTechs.isNotEmpty ? _fakeTechs.first : null;
  }

  _TechPreview? _pickBestAvailableTech() {
    if (_fakeTechs.isEmpty) return null;

    final candidates =
        _fakeTechs.where((t) => t.isOnline && t.isAvailable).toList();
    if (candidates.isEmpty) return null;

    double score(_TechPreview t) {
      final dist = t.distanceKm;
      final ratingPenalty = (5.0 - t.rating).clamp(0.0, 2.0);
      return (dist * 0.80) + (ratingPenalty * 0.20);
    }

    candidates.sort((a, b) => score(a).compareTo(score(b)));
    return candidates.first;
  }

  Future<void> _assignAndNavigate(_TechPreview tech) async {
    if (_finished || _navigated) return;

    setState(() {
      _assignedTechId = tech.id;
      _selectedTech = tech;
    });

    _refreshAllMarkers(highlightId: tech.id);

    _setStatus(SearchStatus.assigned, "✅ تم اختيار أفضل فني: ${tech.name}");

    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    _finished = true;
    _navigated = true;
    _goToTracking();
  }

  // ======================
  // Markers
  // ======================
  void _buildTechMarkersFromList() {
    _techMarkers.clear();

    for (final t in _fakeTechs) {
      _techMarkers[t.id] = _makeTechMarker(
        id: t.id,
        pos: t.pos,
        highlighted: (_selectedTech?.id == t.id) || (_assignedTechId == t.id),
      );
    }

    if (mounted) setState(() {});
  }

  void _refreshAllMarkers({String? highlightId}) {
    for (final t in _fakeTechs) {
      _techMarkers[t.id] = _makeTechMarker(
        id: t.id,
        pos: t.pos,
        highlighted: (highlightId != null && t.id == highlightId) ||
            (_selectedTech?.id == t.id),
      );
    }
    if (mounted) setState(() {});
  }

  Marker _makeTechMarker({
    required String id,
    required LatLng pos,
    required bool highlighted,
  }) {
    final hue =
        highlighted ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure;

    final icon = _carIcon ?? BitmapDescriptor.defaultMarkerWithHue(hue);

    return Marker(
      markerId: MarkerId(id),
      position: pos,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      rotation: 0,
      icon: icon,
      onTap: () {
        if (_hasAssigned) return;
        final t = _fakeTechs.firstWhere((e) => e.id == id);
        _onTechTapped(t);
      },
    );
  }

  Future<void> _onTechTapped(_TechPreview t) async {
    if (_hasAssigned) return;
    setState(() => _selectedTech = t);
    _refreshAllMarkers();

    if (_map != null) {
      try {
        await _map!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: t.pos,
              zoom: 16.8,
              tilt: 55,
              bearing: 0,
            ),
          ),
        );
      } catch (_) {}
    }
  }

  // ======================
  // Fit bounds
  // ======================
  Future<void> _fitUserAndAllTechs() async {
    if (_map == null) return;

    final pts = <LatLng>[_userLocation, ..._fakeTechs.map((e) => e.pos)];
    if (pts.length < 2) return;

    double minLat = pts.first.latitude, maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;

    for (final p in pts) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await _map!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 90));
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 250));
      try {
        await _map!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 90));
      } catch (_) {}
    }
  }

  // ======================
  // UI actions
  // ======================
  void _retry() {
    if (!mounted) return;

    _fakeFlowTimer?.cancel();
    _autoAssignTimer?.cancel();
    _hardTimeoutTimer?.cancel();

    HapticFeedback.lightImpact();

    setState(() {
      _finished = false;
      _navigated = false;
      _canceling = false;

      _seconds = 0;

      _status = SearchStatus.searching;
      _statusMessage = null;

      _fakeTechs.clear();
      _selectedTech = null;

      _techMarkers.clear();

      _assignedTechId = null;
    });

    if (_effectiveFake) {
      _startFakeSearchFlow();
    } else {
      _connectSocketAndListen();
      _startHardTimeout();
      _watchOfflineFallback();
    }
  }

  void _cancelOrder() {
    if (_canceling || _finished) return;
    setState(() => _canceling = true);

    if (!_effectiveFake) {
      try {
        _socket.cancelOrder(widget.orderId);
      } catch (_) {}
    }

    setState(() {
      _finished = true;
      _status = SearchStatus.canceled;
      _statusMessage = "تم إلغاء الطلب";
    });

    Navigator.pop(context);
  }

  Future<void> _contactSupportWhatsApp() async {
    final msg =
        "مشكلة في البحث عن فني ❗\nرقم الطلب: ${widget.orderId}\nالخدمة: ${widget.serviceType}\nالموقع: ${widget.address}\nالوقت: $_seconds ثانية\nالحالة: ${_status.name}";
    final uri = Uri.parse(
        "https://wa.me/201275649151?text=${Uri.encodeComponent(msg)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ======================
  // Build Map UI (NO POLYLINE)
  // ======================
  @override
  Widget build(BuildContext context) {
    final mapPadding = EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 10,
      bottom: widget.hideTechList ? 330 : 450,
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: _bg1,
        body: Stack(
          children: [
            _buildMap(mapPadding),
            _buildClose(),
            _buildTopStatusBar(),
            _buildBottomSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(EdgeInsets padding) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId("user"),
        position: _userLocation,
        anchor: const Offset(0.5, 1.0),
        icon: _userIcon ?? BitmapDescriptor.defaultMarker,
      ),
      ..._techMarkers.values,
    };

    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        return GoogleMap(
          padding: padding,
          initialCameraPosition:
              CameraPosition(target: _userLocation, zoom: 15),
          onMapCreated: (c) async {
            _map = c;
            try {
              await c.setMapStyle(_mapStyle ?? _fallbackDarkStyle);
            } catch (_) {}
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          buildingsEnabled: false,
          indoorViewEnabled: false,
          compassEnabled: false,
          circles: _buildPulseCircles(),
          markers: markers,
          polylines: const <Polyline>{},
        );
      },
    );
  }

  Set<Circle> _buildPulseCircles() {
    final t = _pulseCtrl.value; // 0..1
    final r1 = 55 + (t * 125);
    final r2 = 55 + (((t + .5) % 1) * 125);

    double op(double x) => (1 - x).clamp(0.0, 1.0);

    return {
      Circle(
        circleId: const CircleId("c1"),
        center: _userLocation,
        radius: r1,
        fillColor: _brand.withOpacity(0.10 * op(t)),
        strokeColor: _brand.withOpacity(0.25 * op(t)),
        strokeWidth: 1,
      ),
      Circle(
        circleId: const CircleId("c2"),
        center: _userLocation,
        radius: r2,
        fillColor: _brand.withOpacity(0.07 * op((t + .5) % 1)),
        strokeColor: _brand.withOpacity(0.20 * op((t + .5) % 1)),
        strokeWidth: 1,
      ),
    };
  }

  Widget _buildClose() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, right: 12),
          child: GestureDetector(
            onTap: _cancelOrder,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.35),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: _canceling
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ top small bar: time + copy orderId
  Widget _buildTopStatusBar() {
    final order = widget.orderId.trim();
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.28),
                  border: Border.all(color: Colors.white10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, color: _brand, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "$_seconds ث",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                    if (order.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: order));
                          HapticFeedback.selectionClick();
                          _snack("تم نسخ رقم الطلب");
                        },
                        child: Row(
                          children: [
                            Icon(Icons.copy, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              "نسخ الطلب",
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    final wifiColor = _socketConnected ? _brand : Colors.orangeAccent;
    final wifiText = _socketConnected ? "Live" : "Offline";
    final showRetry = _status.isError;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: _card.withOpacity(.88),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _steps(),

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _brand.withOpacity(.14),
                          border: Border.all(color: _brand.withOpacity(.14)),
                        ),
                        child: Icon(
                          _status == SearchStatus.assigned
                              ? Icons.verified_rounded
                              : Icons.handyman,
                          color: _brand,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _headerText,
                          style: GoogleFonts.cairo(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.25),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.wifi, color: wifiColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              wifiText,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "مدة البحث: $_seconds ثانية",
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (_selectedTech != null) ...[
                        _pill(
                          "${_selectedTech!.distanceKm.toStringAsFixed(2)} كم",
                          icon: Icons.route,
                        ),
                        const SizedBox(width: 8),
                        _pill(
                          "${_selectedTech!.rating.toStringAsFixed(1)}",
                          icon: Icons.star,
                        ),
                      ],
                    ],
                  ),

                  if ((_statusMessage ?? "").trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],

                  // Optional list
                  if (_effectiveFake &&
                      _status == SearchStatus.list &&
                      !widget.hideTechList) ...[
                    const SizedBox(height: 14),
                    _fakeTechList(),
                  ],

                  const SizedBox(height: 14),

                  if (showRetry) ...[
                    _primaryButton(
                      text: "إعادة المحاولة",
                      icon: Icons.refresh_rounded,
                      onTap: _retry,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _contactSupportWhatsApp,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: _brand.withOpacity(.35)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(Icons.support_agent, color: _brand),
                      label: Text(
                        "اتصال بالدعم",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _cancelOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "إلغاء الطلب",
                        style: GoogleFonts.cairo(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _steps() {
    final idx = _stepIndex;

    Widget dot(int i, String t) {
      final active = i <= idx;
      return Expanded(
        child: AnimatedBuilder(
          animation: _stepCtrl,
          builder: (_, __) {
            final pulse = (i == idx) ? (0.06 * _stepCtrl.value) : 0.0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.black.withOpacity(.18),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10 + (active ? 2 : 0),
                    height: 10 + (active ? 2 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? _brand : Colors.white24,
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: _brand.withOpacity(.35 + pulse),
                                blurRadius: 18,
                                spreadRadius: 1,
                              )
                            ]
                          : [],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t,
                    style: GoogleFonts.cairo(
                      color: active ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                    ),
                  )
                ],
              ),
            );
          },
        ),
      );
    }

    return Row(
      children: [
        dot(0, "بحث"),
        const SizedBox(width: 10),
        dot(1, "قائمة"),
        const SizedBox(width: 10),
        dot(2, "تتبع"),
      ],
    );
  }

  Widget _primaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _greenToWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: _glow,
            border: Border.all(color: _brand.withOpacity(.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black, size: 20),
              const SizedBox(width: 10),
              Text(
                text,
                style: GoogleFonts.cairo(
                  color: Colors.black,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fakeTechList() {
    if (_fakeTechs.isEmpty) {
      return Text("جاري تجهيز الفنيين...",
          style: GoogleFonts.cairo(color: Colors.white70));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: _fakeTechs.take(8).map((t) {
          final selected = _selectedTech?.id == t.id;

          return InkWell(
            onTap: () => _onTechTapped(t),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(.06)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _brand.withOpacity(.14),
                      border: Border.all(
                        color: selected ? _brand : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(Icons.person, color: _brand, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الفني ${t.name}",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: _brand, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              t.rating.toStringAsFixed(1),
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "${t.distanceKm.toStringAsFixed(2)} كم",
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _brand.withOpacity(.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _brand.withOpacity(.30)),
                      ),
                      child: Text(
                        "محدد",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _card.withOpacity(.96),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ======================
  // Math helpers
  // ======================
  double _degToRad(double deg) => deg * (math.pi / 180.0);

  // ======================
  // Fallback dark map style
  // ======================
  final String _fallbackDarkStyle = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#0b1220"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#9aa4b2"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#0b1220"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"road","stylers":[{"color":"#1b263b"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#b7c0cc"}]},
    {"featureType":"water","stylers":[{"color":"#070d18"}]}
  ]
  ''';

  @override
  void dispose() {
    _secondsTimer?.cancel();
    _hardTimeoutTimer?.cancel();
    _fakeFlowTimer?.cancel();
    _autoAssignTimer?.cancel();

    _pulseCtrl.dispose();
    _stepCtrl.dispose();

    if (!_effectiveFake) {
      try {
        _socket.dispose();
      } catch (_) {}
    }

    super.dispose();
  }
}

// ======================
// Models
// ======================
class _TechPreview {
  final String id;
  final String name;
  final double rating;
  final double distanceKm;
  final LatLng pos;

  final bool isOnline;
  final bool isAvailable;

  _TechPreview({
    required this.id,
    required this.name,
    required this.rating,
    required this.distanceKm,
    required this.pos,
    required this.isOnline,
    required this.isAvailable,
  });
}
