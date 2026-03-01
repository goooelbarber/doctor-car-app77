// PATH: lib/screens/home/home_location.dart
part of '../home_screen.dart';

extension _HomePrefsAndLocation on _HomeScreenState {
  // ================== Prefs ==================
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final savedRadius = prefs.getInt("nearbyRadiusKm");
    final radius = (_HomeScreenState._radiusOptionsKm.contains(savedRadius))
        ? savedRadius!
        : _selectedRadiusKm;

    // ignore: invalid_use_of_protected_member
    setState(() {
      _isArabic = prefs.getBool("isArabic") ?? true;
      _isDarkMode = prefs.getBool("isDarkMode") ?? false;
      _selectedRadiusKm = radius;
      _prefsLoaded = true;
    });

    await _refresh();
  }

  Future<void> _toggleLanguage() async {
    HapticFeedback.selectionClick();
    // ignore: invalid_use_of_protected_member
    setState(() => _isArabic = !_isArabic);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isArabic", _isArabic);
  }

  Future<void> _toggleTheme() async {
    HapticFeedback.selectionClick();
    // ignore: invalid_use_of_protected_member
    setState(() => _isDarkMode = !_isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", _isDarkMode);
  }

  Future<void> _setRadiusKm(int km) async {
    if (km == _selectedRadiusKm) return;
    HapticFeedback.selectionClick();
    // ignore: invalid_use_of_protected_member
    setState(() => _selectedRadiusKm = km);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("nearbyRadiusKm", km);

    await _refresh();
  }

  void _goto(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            _isDarkMode ? const Color(0xff0B1220) : const Color(0xff111827),
      ),
    );
  }

  // ================== Location Cache ==================
  // ⚠️ مفيش fields هنا — المتغيرات موجودة في _HomeScreenState:
  // Position? _cachedPos;
  // DateTime? _cachedPosAt;

  bool get _hasFreshCachedPos {
    if (_cachedPos == null || _cachedPosAt == null) return false;
    final age = DateTime.now().difference(_cachedPosAt!);
    return age.inSeconds <= 45; // cache لمدة 45 ثانية
  }

  void _setCachedPos(Position p) {
    _cachedPos = p;
    _cachedPosAt = DateTime.now();
    _myPos = p;
    // ignore: invalid_use_of_protected_member
    if (mounted) setState(() {});
  }

  // ================== LOCATION (geolocator) ==================
  Future<Position> _getAccurateLocation({bool force = false}) async {
    // ✅ استخدم cache لو موجودة وحديثة
    if (!force && _hasFreshCachedPos) return _cachedPos!;

    // ✅ على الويب مفيش serviceEnabled بنفس الطريقة
    if (!kIsWeb) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("LOCATION_SERVICE_DISABLED");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("LOCATION_PERMISSION_DENIED");
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("LOCATION_PERMISSION_DENIED_FOREVER");
    }

    // ✅ last known سريع
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && !force) {
        _setCachedPos(last);
      }
    } catch (_) {}

    // ✅ current
    try {
      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: kIsWeb ? LocationAccuracy.low : LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );

      _setCachedPos(current);
      return current;
    } on TimeoutException {
      throw Exception("LOCATION_TIMEOUT");
    } catch (e) {
      throw Exception("LOCATION_FAILED:$e");
    }
  }

  // ================== Google Maps Nearby (Fallback) ==================
  Future<void> _openGoogleMapsNearby() async {
    try {
      final pos = await _getAccurateLocation();
      final lat = pos.latitude;
      final lng = pos.longitude;

      final url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=%D9%85%D8%B1%D9%83%D8%B2%20%D8%B5%D9%8A%D8%A7%D9%86%D8%A9&center=$lat,$lng",
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _snack(
          _isArabic ? "تعذر فتح خرائط Google" : "Couldn't open Google Maps",
        );
      }
    } catch (_) {
      _snack(_isArabic ? "تعذر تحديد موقعك" : "Couldn't get your location");
    }
  }

  // ================== Manual fallback (from your JSON) ==================
  List<CenterItem> _manualCentersFallback() {
    final raw = <Map<String, dynamic>>[
      {
        "id": "manual-1",
        "name": "مركز م/ عصام غنايم لصيانة و فحص السيارات",
        "lat": 31.4165,
        "lng": 31.8133,
        "address": "دمياط - ميدان الشهابية",
        "phone": "01007976535",
        "rating": 4.6,
        "image": "",
        "source": "manual",
      },
      {
        "id": "manual-2",
        "name": "مركز الوطنية لخدمات وصيانة السيارات",
        "lat": 31.418,
        "lng": 31.815,
        "address": "دمياط الجديدة",
        "phone": "01000332305",
        "rating": 3.9,
        "image": "",
        "source": "manual",
      },
      {
        "id": "manual-3",
        "name": "Tecno Car / Shokry Shata",
        "lat": 31.42,
        "lng": 31.81,
        "address": "ثان دمياط",
        "phone": "01002271477",
        "rating": 4.6,
        "image": "",
        "source": "manual",
      },
    ];

    return raw.map((e) => CenterItem.fromJson(e)).toList();
  }

  // ================== NETWORK: Centers Nearby ==================
  Future<List<CenterItem>> _fetchCentersNearMe() async {
    _locationError = null;

    Position pos;
    try {
      pos = await _getAccurateLocation();
    } catch (e) {
      _locationError = _mapLocationError(e.toString());
      return <CenterItem>[];
    }

    final uri = Uri.parse(
      ApiConfig.nearbyCenters(
        lat: pos.latitude,
        lng: pos.longitude,
        limit: _HomeScreenState._centersLimit,
        maxDistanceMeters: _maxRadiusMeters.toInt(),
      ),
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        return await _manualWithDistances(pos);
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! List) {
        return await _manualWithDistances(pos);
      }

      final List<CenterItem> centers = [];

      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;

        final center = CenterItem.fromJson(item);
        if (!center.hasCoords) continue;

        final double d =
            (center.distanceMeters != null && center.distanceMeters! > 0)
                ? center.distanceMeters!
                : Geolocator.distanceBetween(
                    pos.latitude,
                    pos.longitude,
                    center.lat!,
                    center.lng!,
                  );

        if (d > _maxRadiusMeters) continue;

        centers.add(center.copyWith(distanceMeters: d));
      }

      if (centers.isEmpty) {
        return await _manualWithDistances(pos);
      }

      centers.sort(
        (a, b) => (a.distanceMeters ?? double.infinity)
            .compareTo(b.distanceMeters ?? double.infinity),
      );

      return centers;
    } catch (_) {
      return await _manualWithDistances(pos);
    }
  }

  Future<List<CenterItem>> _manualWithDistances(Position pos) async {
    final manual = _manualCentersFallback();
    final filtered = <CenterItem>[];

    for (final c in manual) {
      if (!c.hasCoords) continue;
      final d = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        c.lat!,
        c.lng!,
      );

      if (d > _maxRadiusMeters) continue;
      filtered.add(c.copyWith(distanceMeters: d));
    }

    filtered.sort(
      (a, b) => (a.distanceMeters ?? double.infinity)
          .compareTo(b.distanceMeters ?? double.infinity),
    );

    if (filtered.isEmpty) {
      _locationError = _isArabic
          ? "لا توجد مراكز ضمن النطاق الحالي."
          : "No centers within the selected range.";
    }

    return filtered;
  }

  String _mapLocationError(String msg) {
    if (msg.contains("LOCATION_SERVICE_DISABLED")) {
      return _isArabic
          ? "خدمة الموقع مقفولة.. فعّل GPS ثم جرّب تاني ✅"
          : "Location services are OFF. Enable GPS then try again ✅";
    }
    if (msg.contains("LOCATION_PERMISSION_DENIED_FOREVER")) {
      return _isArabic
          ? "صلاحية الموقع مرفوضة نهائيًا.. فعّلها من الإعدادات ✅"
          : "Location permission denied forever. Enable it from settings ✅";
    }
    if (msg.contains("LOCATION_PERMISSION_DENIED")) {
      return trKey("needLocation");
    }
    if (msg.contains("LOCATION_TIMEOUT")) {
      return _isArabic
          ? "أخذ تحديد الموقع وقت طويل.. فعّل Location وحاول مرة أخرى ✅"
          : "Location timed out. Enable Location and try again ✅";
    }
    if (msg.contains("LOCATION_FAILED")) {
      return trKey("needLocation");
    }
    return trKey("loadFail");
  }

  Future<void> _refresh() async {
    HapticFeedback.selectionClick();
    // ignore: invalid_use_of_protected_member
    setState(() {
      _centersFuture = _fetchCentersNearMe();
    });
    await _centersFuture;
  }
}
