// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback, rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/google_places_service.dart';
import 'vehicles/vehicle_screen.dart';

/// ✅ Result model
class PickedLocation {
  final double lat;
  final double lng;
  final String address;

  const PickedLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  LatLng get latLng => LatLng(lat, lng);
}

class SelectLocationScreen extends StatefulWidget {
  final String serviceType;
  final String userId;
  final List<String> selectedServices;

  const SelectLocationScreen({
    super.key,
    required this.serviceType,
    required this.userId,
    required this.selectedServices,
  });

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen>
    with TickerProviderStateMixin {
  // ======================
  // THEME (DoctorCar)
  // ======================
  static const Color _bg = Color(0xFF0B1220);
  static const Color _bg2 = Color(0xFF081837);
  static const Color _bg3 = Color(0xFF0A2038);

  static const Color _card = Color(0xFF121B2E);
  static const Color _card2 = Color(0xFF0F1A30);

  static const Color _brand = Color(0xFFA8F12A);
  // ignore: unused_field
  static const Color _danger = Color(0xFFFF4D4D);

  GoogleMapController? _map;
  bool _mapReady = false;

  LatLng _selected = const LatLng(31.4175, 31.8153);

  /// ✅ Use unified key name + backward compat
  String get _googleApiKey =>
      (dotenv.env['GOOGLE_MAPS_API_KEY'] ?? dotenv.env['GOOGLE_MAPS_KEY'] ?? '')
          .trim();

  late final GooglePlacesService _places =
      GooglePlacesService(_googleApiKey, debugLog: true);

  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  // ✅ Places session token (Uber style)
  String _sessionToken = '';
  Timer? _sessionResetTimer;

  List<Map<String, dynamic>> _results = [];
  bool _showResults = false;

  late final AnimationController _pinAnim;
  late final AnimationController _pulseAnim;
  late final AnimationController _bgCtrl;

  String _currentAddress = "جارِ تحديد الموقع…";
  bool _reverseLoading = false;

  String? _mapStyle;

  Timer? _reverseDebounce;
  DateTime _lastReverseReq = DateTime.fromMillisecondsSinceEpoch(0);

  String? _lastResolvedAddress;
  LatLng? _lastResolvedLatLng;

  CameraPosition? _lastCameraPosition;

  static const double _bottomUiPadding = 240;

  // ============================================================
  // ✅ NEW: Vehicle gate
  // ============================================================
  bool _vehicleGateDone = false;
  dynamic _selectedVehicle;

  @override
  void initState() {
    super.initState();

    _search.addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    _pinAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      lowerBound: 0,
      upperBound: 10,
    )..repeat(reverse: true);

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);

    _loadMapStyle();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureVehicleSelected();
      if (!mounted) return;
      if (!_vehicleGateDone) return;
      await _initMyLocation();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _reverseDebounce?.cancel();
    _sessionResetTimer?.cancel();

    _pinAnim.dispose();
    _pulseAnim.dispose();
    _bgCtrl.dispose();
    _search.dispose();
    super.dispose();
  }

  // ======================
  // Vehicle selector gate
  // ======================
  Future<void> _ensureVehicleSelected() async {
    if (_vehicleGateDone) return;

    final vehicle = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VehiclesScreen(selectMode: true),
      ),
    );

    if (!mounted) return;
    if (vehicle == null) {
      Navigator.pop(context, null);
      return;
    }

    setState(() {
      _selectedVehicle = vehicle;
      _vehicleGateDone = true;
    });
  }

  String _vehicleLabel() {
    final v = _selectedVehicle;
    if (v is Map) {
      final brand = (v["brand"] ?? "").toString().trim();
      final model = (v["model"] ?? "").toString().trim();
      final plate = (v["plateNumber"] ?? "").toString().trim();

      final parts = <String>[];
      if (brand.isNotEmpty) parts.add(brand);
      if (model.isNotEmpty) parts.add(model);
      if (plate.isNotEmpty) parts.add("($plate)");

      if (parts.isNotEmpty) return parts.join(" ");
    }
    return "مركبة مختارة";
  }

  // ======================
  // Helpers UI
  // ======================
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(.92),
        content: Text(
          msg,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  LinearGradient get _ctaGradient => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.lerp(_brand, Colors.white, 0.20)!,
          _brand,
          Color.lerp(_brand, _bg, 0.18)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  String _coordsAddress(LatLng p) {
    return "الموقع المحدد: ${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}";
  }

  bool _isNearLastResolved(LatLng p, {double meters = 15}) {
    if (_lastResolvedLatLng == null) return false;

    final d = Geolocator.distanceBetween(
      _lastResolvedLatLng!.latitude,
      _lastResolvedLatLng!.longitude,
      p.latitude,
      p.longitude,
    );
    return d < meters;
  }

  // ======================
  // Assets
  // ======================
  Future<void> _loadMapStyle() async {
    try {
      final style =
          await rootBundle.loadString('assets/map_styles/uber_dark.json');
      _mapStyle = style;

      if (_map != null) {
        try {
          await _map!.setMapStyle(_mapStyle);
        } catch (_) {}
      }
    } catch (_) {
      _mapStyle = null;
    }
  }

  // ======================
  // Location Permission
  // ======================
  Future<bool> _ensureLocationPermission() async {
    if (!kIsWeb) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _snack("فعّل GPS أولًا");
        return false;
      }
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.deniedForever) {
      _snack("إذن الموقع مرفوض نهائيًا.. افتح الإعدادات وفعّل الإذن");
      return false;
    }

    if (perm == LocationPermission.denied) {
      _snack("تم رفض صلاحية الموقع");
      return false;
    }

    return true;
  }

  Future<void> _initMyLocation() async {
    try {
      final ok = await _ensureLocationPermission();
      if (!ok) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final me = LatLng(pos.latitude, pos.longitude);

      if (!mounted) return;
      setState(() {
        _selected = me;
        _currentAddress = _coordsAddress(me);
      });

      _animateTo(me, zoom: 16.7);
      _scheduleReverseGeocode(me);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentAddress = _coordsAddress(_selected);
      });
    }
  }

  // ======================
  // Map callbacks
  // ======================
  void _onMapCreated(GoogleMapController c) async {
    _map = c;

    try {
      if (_mapStyle != null) {
        await _map!.setMapStyle(_mapStyle);
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _mapReady = true);

    _animateTo(_selected, zoom: 16.7);
    _scheduleReverseGeocode(_selected);
  }

  void _animateTo(LatLng target, {double zoom = 16.7}) {
    if (_map == null) return;
    _map!.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  void _onCameraMove(CameraPosition pos) {
    if (!_mapReady) return;
    _lastCameraPosition = pos;
  }

  void _onCameraIdle() {
    if (!_mapReady) return;

    final cam = _lastCameraPosition;
    if (cam == null) return;

    setState(() {
      _selected = cam.target;
      _currentAddress = _coordsAddress(cam.target);
    });

    _scheduleReverseGeocode(_selected);
  }

  // ============================================================
  // SEARCH (Uber-like session + bias)
  // ============================================================
  void _ensureSessionToken() {
    if (_sessionToken.isEmpty) {
      _sessionToken = DateTime.now().microsecondsSinceEpoch.toString();
    }
    _sessionResetTimer?.cancel();
    _sessionResetTimer = Timer(const Duration(seconds: 3), () {
      _sessionToken = '';
    });
  }

  Future<void> _onSearchChanged(String value) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final q = value.trim();
      if (q.isEmpty) {
        if (!mounted) return;
        setState(() {
          _results = [];
          _showResults = false;
        });
        return;
      }

      if (_googleApiKey.isEmpty) {
        _snack("GOOGLE_MAPS_API_KEY غير موجود في .env");
        return;
      }

      _ensureSessionToken();

      final items = await _places.autocomplete(
        q,
        sessionToken: _sessionToken,
        locationBias: LatLngBias(_selected.latitude, _selected.longitude),
        radiusMeters: 50000,
      );

      if (!mounted) return;
      setState(() {
        _results = items;
        _showResults = items.isNotEmpty;
      });
    });
  }

  Future<void> _onSelectPlace(Map<String, dynamic> item) async {
    final placeId = (item["place_id"] ?? "").toString();
    if (placeId.isEmpty) return;

    final details =
        await _places.getPlaceLatLng(placeId, sessionToken: _sessionToken);
    if (details == null) return;

    _sessionToken = '';

    final point = LatLng(details.lat, details.lng);

    if (!mounted) return;
    setState(() {
      _selected = point;
      _currentAddress =
          details.address.isNotEmpty ? details.address : _coordsAddress(point);
      _search.text = details.name;
      _showResults = false;
      _lastResolvedLatLng = point;
      _lastResolvedAddress = _currentAddress;
    });

    HapticFeedback.selectionClick();
    _animateTo(point, zoom: 16.9);
    _scheduleReverseGeocode(point);
  }

  // ============================================================
  // Reverse Geocoding
  // ============================================================
  void _scheduleReverseGeocode(LatLng p) {
    _reverseDebounce?.cancel();
    _reverseDebounce = Timer(const Duration(milliseconds: 420), () {
      _reverseGeocode(p);
    });
  }

  Future<void> _reverseGeocode(LatLng p) async {
    final now = DateTime.now();
    if (now.difference(_lastReverseReq).inMilliseconds < 650) return;
    _lastReverseReq = now;

    if (_lastResolvedAddress != null &&
        _lastResolvedAddress!.trim().isNotEmpty &&
        _isNearLastResolved(p)) {
      if (!mounted) return;
      setState(() {
        _currentAddress = _lastResolvedAddress!;
        _reverseLoading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _reverseLoading = true;
      _currentAddress = _coordsAddress(p);
    });

    try {
      // ✅ Web/Flutter direct geocoding كان عامل REQUEST_DENIED
      // لذلك نخلي العنوان fallback آمن بالإحداثيات
      await Future.delayed(const Duration(milliseconds: 120));

      final addr = _coordsAddress(p);

      if (!mounted) return;
      setState(() {
        _currentAddress = addr;
        _lastResolvedLatLng = p;
        _lastResolvedAddress = addr;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentAddress = _coordsAddress(p);
      });
    } finally {
      if (mounted) {
        setState(() => _reverseLoading = false);
      }
    }
  }

  // ============================================================
  // UI ACTIONS
  // ============================================================
  Future<void> _goToMyLocation() async {
    HapticFeedback.mediumImpact();
    await _initMyLocation();
  }

  void _confirm() {
    final addr = (_currentAddress.trim().isEmpty)
        ? _coordsAddress(_selected)
        : _currentAddress.trim();

    HapticFeedback.heavyImpact();
    Navigator.pop(
      context,
      PickedLocation(
        lat: _selected.latitude,
        lng: _selected.longitude,
        address: addr,
      ),
    );
  }

  // ======================
  // Background glow
  // ======================
  Widget _proBackground() {
    return AnimatedBuilder(
      animation: _bgCtrl,
      builder: (_, __) {
        final t = _bgCtrl.value;
        final dx = lerpDouble(-0.18, 0.18, t)!;
        final dy = lerpDouble(0.10, -0.06, t)!;

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_bg, _bg2, _bg3],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Align(
              alignment: Alignment(dx, -0.90),
              child: _glowBlob(size: 320, opacity: 0.16),
            ),
            Align(
              alignment: Alignment(-0.90, dy),
              child: _glowBlob(size: 380, opacity: 0.12),
            ),
            Align(
              alignment: Alignment(0.95, 0.30 - dy),
              child: _glowBlob(size: 300, opacity: 0.10),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                    Colors.black.withOpacity(0.20),
                  ],
                  stops: const [0.0, 0.58, 1.0],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _glowBlob({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _brand.withOpacity(opacity),
            _brand.withOpacity(opacity * 0.35),
            Colors.transparent,
          ],
          stops: const [0.0, 0.50, 1.0],
        ),
      ),
    );
  }

  // ======================
  // Uber-ish center pin
  // ======================
  Widget _uberCenterPin() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pinAnim, _pulseAnim]),
      builder: (_, __) {
        final t = _pulseAnim.value;
        final pulseSize = 18 + (t * 26);
        final pulseOpacity = (1 - t).clamp(0.0, 1.0) * 0.22;

        return Center(
          child: Transform.translate(
            offset: Offset(0, -_pinAnim.value - 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: pulseSize,
                  height: pulseSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _brand.withOpacity(pulseOpacity),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 20,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _brand.withOpacity(0.18),
                      ),
                      child: const Icon(
                        Icons.place_rounded,
                        color: _brand,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ======================
  // BUILD
  // ======================
  @override
  Widget build(BuildContext context) {
    final mapPadding = EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 98,
      bottom: _bottomUiPadding,
    );

    if (!_vehicleGateDone) {
      return Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            _proBackground(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: _brand,
                    strokeWidth: 2.6,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "اختيار المركبة أولاً…",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _proBackground(),
          Listener(
            onPointerDown: (_) {
              if (_showResults) {
                setState(() => _showResults = false);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: GoogleMap(
                padding: mapPadding,
                initialCameraPosition:
                    CameraPosition(target: _selected, zoom: 15),
                onMapCreated: _onMapCreated,
                onCameraMove: _onCameraMove,
                onCameraIdle: _onCameraIdle,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                buildingsEnabled: true,
                indoorViewEnabled: true,
                trafficEnabled: false,
                mapType: MapType.normal,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(child: _uberCenterPin()),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _topGlassBar(),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _searchBox(),
                ),
                if (_showResults) _resultsBox(),
              ],
            ),
          ),
          Positioned(
            right: 14,
            bottom: 265,
            child: _pillAction(
              icon: Icons.my_location,
              label: "موقعي",
              onTap: _goToMyLocation,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _bottomGlassSheet(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topGlassBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.30),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _brand.withOpacity(.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: _brand.withOpacity(.22)),
                ),
                child: const Icon(Icons.place_rounded, color: _brand, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "تحديد موقع الخدمة",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.25),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  widget.serviceType,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _card.withOpacity(.78),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: _search,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: _onSearchChanged,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            cursorColor: _brand,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "ابحث عن مدينة أو شارع…",
              hintStyle: GoogleFonts.cairo(
                color: Colors.white54,
                fontWeight: FontWeight.w700,
              ),
              prefixIcon:
                  Icon(Icons.search, color: Colors.white.withOpacity(.70)),
              suffixIcon: _search.text.trim().isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(.75),
                      ),
                      onPressed: () {
                        setState(() {
                          _search.clear();
                          _results = [];
                          _showResults = false;
                        });
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultsBox() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _card2.withOpacity(.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _results.length,
        separatorBuilder: (_, __) =>
            Divider(color: Colors.white.withOpacity(.06), height: 1),
        itemBuilder: (_, i) {
          final item = _results[i];
          final desc = (item["description"] ?? "").toString();

          return ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _brand.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _brand.withOpacity(.20)),
              ),
              child: const Icon(Icons.place, color: _brand, size: 18),
            ),
            title: Text(
              desc,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _onSelectPlace(item),
          );
        },
      ),
    );
  }

  Widget _pillAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withOpacity(.35),
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomGlassSheet() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: _card.withOpacity(.88),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _brand.withOpacity(.14),
                        shape: BoxShape.circle,
                        border: Border.all(color: _brand.withOpacity(.22)),
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: _brand,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _vehicleLabel(),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        _vehicleGateDone = false;
                        setState(() {});
                        await _ensureVehicleSelected();
                        if (!mounted) return;
                        if (_vehicleGateDone) {
                          setState(() {});
                        }
                      },
                      child: Text(
                        "تغيير",
                        style: GoogleFonts.cairo(
                          color: _brand,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _brand.withOpacity(.14),
                      shape: BoxShape.circle,
                      border: Border.all(color: _brand.withOpacity(.22)),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: _brand,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currentAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_selected.latitude.toStringAsFixed(5)}, ${_selected.longitude.toStringAsFixed(5)}",
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_reverseLoading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: _brand,
                      ),
                    )
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _brand.withOpacity(0.28),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedOpacity(
                          opacity: _reverseLoading ? 0.45 : 1,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            decoration: BoxDecoration(gradient: _ctaGradient),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _reverseLoading ? null : _confirm,
                            child: Center(
                              child: Text(
                                "تأكيد الموقع",
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "اسحب الخريطة لتحديد مكانك بدقة",
                style: GoogleFonts.cairo(
                  color: Colors.white54,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
