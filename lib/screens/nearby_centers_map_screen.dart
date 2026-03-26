import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

import '../config/api_config.dart';

class NearbyCentersMapScreen extends StatefulWidget {
  final bool isArabic;
  final bool isDarkMode;
  final int radiusKm;

  const NearbyCentersMapScreen({
    super.key,
    required this.isArabic,
    required this.isDarkMode,
    required this.radiusKm,
  });

  @override
  State<NearbyCentersMapScreen> createState() => _NearbyCentersMapScreenState();
}

class _NearbyCentersMapScreenState extends State<NearbyCentersMapScreen> {
  GoogleMapController? _map;
  Position? _pos;

  bool _loading = true;
  bool _listOpen = false;

  String? _error;

  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  // Store centers for list + tap actions
  final List<_CenterItem> _centers = [];

  String? _mapStyle;

  // UI helpers
  String tr(String ar, String en) => widget.isArabic ? ar : en;

  static const _fallbackCairo = LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _init();
  }

  Future<void> _loadMapStyle() async {
    if (!widget.isDarkMode) return;
    try {
      // نفس المسار اللي بتستخدمه في شاشات تانية
      _mapStyle =
          await rootBundle.loadString('assets/map_styles/uber_dark.json');
      if (_map != null) {
        await _map!.setMapStyle(_mapStyle);
      }
    } catch (_) {}
  }

  Future<Position> _getLocation() async {
    final service = await Geolocator.isLocationServiceEnabled();
    if (!service) throw Exception("SERVICE_OFF");

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) throw Exception("DENIED");
    if (perm == LocationPermission.deniedForever)
      throw Exception("DENIED_FOREVER");

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 12),
    );
  }

  Future<void> _init() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
      _markers.clear();
      _circles.clear();
      _centers.clear();
    });

    try {
      final p = await _getLocation();
      _pos = p;

      // دائرة نطاق البحث
      _circles.add(
        Circle(
          circleId: const CircleId("radius"),
          center: LatLng(p.latitude, p.longitude),
          radius: widget.radiusKm * 1000.0,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.12),
          strokeColor: Colors.blue,
        ),
      );

      // ✅ نجيب المراكز من API (وبنفلتر بالمسافة من السيرفر إن أمكن)
      final uri = Uri.parse(
        ApiConfig.nearbyCenters(
          lat: p.latitude,
          lng: p.longitude,
          limit: 200,
          maxDistanceMeters: widget.radiusKm * 1000,
        ),
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw Exception("API_${res.statusCode}");
      }

      final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;

      // يدعم لو السيرفر بيرجع List أو Map {centers:[...]}
      final List items = decoded is List
          ? decoded
          : (decoded is Map && decoded["centers"] is List)
              ? decoded["centers"]
              : (decoded is Map && decoded["data"] is List)
                  ? decoded["data"]
                  : [];

      if (items.isEmpty) {
        _error = tr(
          "لا يوجد مراكز داخل ${widget.radiusKm} كم",
          "No centers within ${widget.radiusKm} km",
        );
      }

      // ماركر لموقعك
      _markers.add(
        Marker(
          markerId: const MarkerId("me"),
          position: LatLng(p.latitude, p.longitude),
          infoWindow: InfoWindow(title: tr("موقعي", "My Location")),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );

      int added = 0;

      for (final raw in items) {
        if (raw is! Map) continue;
        // ignore: unnecessary_cast
        final item = Map<String, dynamic>.from(raw as Map);

        final lat = (item["lat"] ?? item["location"]?["lat"]) as num?;
        final lng = (item["lng"] ?? item["location"]?["lng"]) as num?;
        if (lat == null || lng == null) continue;

        final name = (item["name"] ?? item["title"] ?? "Center").toString();
        final id = (item["_id"] ?? item["id"] ?? name).toString();
        final phone = (item["phone"] ?? item["mobile"] ?? "").toString();
        final address =
            (item["address"] ?? item["locationText"] ?? "").toString();

        final distMeters = Geolocator.distanceBetween(
          p.latitude,
          p.longitude,
          lat.toDouble(),
          lng.toDouble(),
        );

        // فلترة محلية احتياطية (حتى لو السيرفر فلتر)
        if (distMeters > widget.radiusKm * 1000.0) continue;

        final center = _CenterItem(
          id: id,
          name: name,
          lat: lat.toDouble(),
          lng: lng.toDouble(),
          distanceMeters: distMeters,
          phone: phone,
          address: address,
        );

        _centers.add(center);

        _markers.add(
          Marker(
            markerId: MarkerId(id),
            position: LatLng(center.lat, center.lng),
            infoWindow: InfoWindow(
              title: center.name,
              snippet: tr(
                "${(center.distanceMeters / 1000).toStringAsFixed(1)} كم",
                "${(center.distanceMeters / 1000).toStringAsFixed(1)} km",
              ),
              onTap: () => _openCenterSheet(center),
            ),
            onTap: () => _openCenterSheet(center),
          ),
        );

        added++;
      }

      // sort by nearest
      _centers.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      if (added == 0) {
        _error = tr(
          "لا يوجد مراكز داخل ${widget.radiusKm} كم",
          "No centers within ${widget.radiusKm} km",
        );
      }

      if (!mounted) return;
      setState(() => _loading = false);

      // ظبط الكاميرا على نطاق النتائج
      _fitBounds();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _prettyError(e.toString());
      });
    }
  }

  String _prettyError(String raw) {
    if (raw.contains("SERVICE_OFF")) {
      return tr("فعّل GPS أولاً", "Please enable GPS");
    }
    if (raw.contains("DENIED_FOREVER")) {
      return tr("صلاحية الموقع مرفوضة نهائيًا من الإعدادات",
          "Location permission permanently denied");
    }
    if (raw.contains("DENIED")) {
      return tr("تم رفض صلاحية الموقع", "Location permission denied");
    }
    if (raw.contains("API_")) {
      return tr("خطأ في السيرفر: $raw", "Server error: $raw");
    }
    return tr("تعذر تحميل الخريطة: $raw", "Failed to load map: $raw");
  }

  void _fitBounds() {
    if (_map == null || _pos == null) return;

    final points = <LatLng>[
      LatLng(_pos!.latitude, _pos!.longitude),
      ..._centers.map((c) => LatLng(c.lat, c.lng)),
    ];

    if (points.length == 1) {
      _map!.animateCamera(CameraUpdate.newLatLngZoom(points.first, 13));
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _map!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  Future<void> _recenter() async {
    if (_pos == null) return;
    _map?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_pos!.latitude, _pos!.longitude),
        13,
      ),
    );
  }

  void _openCenterSheet(_CenterItem c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CenterDetailsSheet(
        isArabic: widget.isArabic,
        isDarkMode: widget.isDarkMode,
        center: c,
        onDirections: () {
          final url =
              "https://www.google.com/maps/dir/?api=1&destination=${c.lat},${c.lng}";
          // لو تحب أكتبلك launchUrl (url_launcher) ابعتهولك
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr("افتح: $url", "Open: $url"))),
          );
        },
        onFocus: () {
          Navigator.pop(context);
          _map?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(c.lat, c.lng), 15.5),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg =
        widget.isDarkMode ? const Color(0xff0E1320) : const Color(0xffF5F6FA);
    final surface = widget.isDarkMode ? const Color(0xff151A2E) : Colors.white;

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(
            tr("مراكز قريبة على الخريطة", "Nearby Centers Map"),
            style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _loading ? null : _init,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: _loading ? null : _recenter,
              icon: const Icon(Icons.my_location),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _fallbackCairo,
                      zoom: 11,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    markers: _markers,
                    circles: _circles,
                    onMapCreated: (c) async {
                      _map = c;
                      if (widget.isDarkMode && _mapStyle != null) {
                        await _map!.setMapStyle(_mapStyle);
                      }
                      // بعد الإنشاء نعمل fit لو فيه بيانات
                      _fitBounds();
                    },
                  ),

                  // ✅ List toggle (Uber-like)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: surface
                                .withOpacity(widget.isDarkMode ? .85 : .95),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                      Icons.store_mall_directory_outlined),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _error ??
                                          tr(
                                            "عدد المراكز: ${_centers.length}",
                                            "Centers: ${_centers.length}",
                                          ),
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _centers.isEmpty
                                        ? null
                                        : () => setState(
                                            () => _listOpen = !_listOpen),
                                    child: Text(
                                      _listOpen
                                          ? tr("إخفاء", "Hide")
                                          : tr("عرض", "Show"),
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ),
                              if (_listOpen && _centers.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 240),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: _centers.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 10),
                                    itemBuilder: (_, i) {
                                      final c = _centers[i];
                                      final km = (c.distanceMeters / 1000)
                                          .toStringAsFixed(1);
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.place,
                                            color: Colors.red),
                                        title: Text(
                                          c.name,
                                          style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.w900),
                                        ),
                                        subtitle: Text(
                                          tr("$km كم", "$km km"),
                                          style: GoogleFonts.cairo(),
                                        ),
                                        onTap: () {
                                          _map?.animateCamera(
                                            CameraUpdate.newLatLngZoom(
                                              LatLng(c.lat, c.lng),
                                              15.5,
                                            ),
                                          );
                                          _openCenterSheet(c);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CenterItem {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double distanceMeters;
  final String phone;
  final String address;

  _CenterItem({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.distanceMeters,
    required this.phone,
    required this.address,
  });
}

class _CenterDetailsSheet extends StatelessWidget {
  final bool isArabic;
  final bool isDarkMode;
  final _CenterItem center;
  final VoidCallback onDirections;
  final VoidCallback onFocus;

  const _CenterDetailsSheet({
    required this.isArabic,
    required this.isDarkMode,
    required this.center,
    required this.onDirections,
    required this.onFocus,
  });

  String tr(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final surface = isDarkMode ? const Color(0xff151A2E) : Colors.white;

    final km = (center.distanceMeters / 1000).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.store, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    center.name,
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr("المسافة: $km كم", "Distance: $km km"),
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
            ),
            if (center.address.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  center.address,
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onFocus,
                    icon: const Icon(Icons.center_focus_strong),
                    label: Text(tr("تركيز", "Focus"),
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDirections,
                    icon: const Icon(Icons.directions),
                    label: Text(tr("اتجاهات", "Directions"),
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
