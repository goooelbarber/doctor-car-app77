// PATH: lib/screens/tracking/tracking_screen.dart
// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback, rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/socket_service.dart';
import '../payment_screen.dart';

enum TrackingCameraMode { driverOnly, fitBoth }

class TrackingScreen extends StatefulWidget {
  final String orderId;
  final String userId;
  final String baseUrl;
  final String serviceType;
  final bool fakeMode;

  final double userLat;
  final double userLng;

  const TrackingScreen({
    super.key,
    required this.orderId,
    required this.userId,
    required this.baseUrl,
    required this.serviceType,
    required this.userLat,
    required this.userLng,
    this.fakeMode = false,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  static const Color _brand = Color(0xFF4B3BFF);
  static const Color _routeOuter = Color(0xFF291CFF);
  static const Color _routeInner = Color(0xFF4B3BFF);
  static const Color _routeGlow = Color(0xFF8A82FF);
  static const Color _routePassed = Color(0xFF95A1B7);

  static const Color _bg1 = Color(0xFF08111F);
  static const Color _bg2 = Color(0xFF081837);
  static const Color _bg3 = Color(0xFF0A2038);

  static const Color _sheet = Color(0xFF111A2C);
  static const Color _sheet2 = Color(0xFF0F1830);

  static const Color _danger = Color(0xFF3B82F6);
  static const Color _accentGreen = Color(0xFF22C55E);

  static const double _followTilt = 58;
  static const double _driverOnlyLeadMeters = 90;
  static const double _snapToRouteMaxDistanceMeters = 55;
  static const double _fakeCurveMaxOffsetMeters = 140;

  final SocketService socketService = SocketService();
  final Dio _dio = Dio();

  bool socketConnected = false;
  bool _mapReady = false;
  bool _routeFetchFailed = false;
  bool _programmaticCameraMove = false;
  bool _trafficEnabled = false;

  GoogleMapController? _map;

  late LatLng userLocation;
  LatLng driverLocation = const LatLng(31.4182, 31.8152);
  LatLng? _targetDriver;

  bool _follow = true;
  TrackingCameraMode _cameraMode = TrackingCameraMode.fitBoth;
  DateTime _lastCamMove = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastManualMapGesture = DateTime.fromMillisecondsSinceEpoch(0);

  double _bearing = 0.0;
  double _displayBearing = 0.0;

  List<LatLng> _routePoints = [];
  List<LatLng> _passedRoutePoints = [];
  List<LatLng> _remainingRoutePoints = [];

  DateTime _lastRouteFetch = DateTime.fromMillisecondsSinceEpoch(0);
  final List<LatLng> _trailPoints = [];
  DateTime _lastTrailAdd = DateTime.fromMillisecondsSinceEpoch(0);

  double speedMs = 0;
  double distanceToUser = 0;
  int etaMin = 3;
  bool _hasDirectionsEta = false;

  LatLng? _lastMetricsPos;
  DateTime? _lastMetricsAt;

  double _arrivalDistanceMeters = 40;
  int _arrivalStableSeconds = 6;

  int _arrivalStableCounter = 0;
  bool _arrived = false;
  bool _arrivalHapticDone = false;
  bool _arrivalZoomDone = false;

  double _pulse = 0.0;
  Timer? _pulseTimer;
  Timer? _smoothTimer;
  Timer? _metricsTimer;
  Timer? _routeRefreshTimer;
  Timer? _fakeMoveTimer;
  Timer? _flowTimer;

  int _flowTick = 0;
  List<LatLng> _routeSampled = [];
  int _flowEveryN = 6;

  BitmapDescriptor? _carIcon;
  BitmapDescriptor? _userIcon;
  String? _mapStyle;

  int _routeRefreshSeconds = 6;
  int _cameraThrottleMs = 260;
  int _followResumeDelayMs = 3500;

  int _trailMaxPoints = 160;
  int _trailMinAddMs = 700;
  double _trailMinMoveMeters = 8;

  double _routeMinMoveMeters = 18;
  LatLng? _lastRouteOrigin;
  CancelToken? _routeCancel;

  late final bool _effectiveFake;

  int _fakeRouteIndex = 0;
  bool _fakeRouteInitialized = false;
  bool _isFetchingRoute = false;

  MapType _currentMapType = MapType.normal;

  // ignore: unused_field
  int _driverRouteIndex = 0;
  double _routeProgress = 0.0;

  @override
  void initState() {
    super.initState();

    userLocation = LatLng(widget.userLat, widget.userLng);
    _effectiveFake = widget.fakeMode || widget.orderId.trim().isEmpty;
    _currentMapType = MapType.normal;

    _loadEnvKnobs();
    _loadAssets();

    if (!_effectiveFake) {
      _initSocket();
    }

    _pulseTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!mounted) return;
      setState(() {
        _pulse += 0.03;
        if (_pulse >= 1.0) _pulse = 0.0;
      });
    });

    _metricsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateMetrics();
      _maybeMoveCamera();
      _handleArrivalLogic();
    });

    _smoothTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      _tickSmoothMovement();
    });

    _routeRefreshTimer =
        Timer.periodic(Duration(seconds: _routeRefreshSeconds), (_) {
      if (!mounted) return;
      _maybeFetchRoute(force: false);
    });

    _flowTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      if (_routeSampled.length < 2) return;
      setState(() => _flowTick++);
    });

    if (_effectiveFake) {
      _fakeMoveTimer = Timer.periodic(const Duration(milliseconds: 650), (_) {
        if (!mounted || _arrived) return;
        _tickFakeMovement();
      });
    }

    _trailPoints.add(driverLocation);
    _lastMetricsPos = driverLocation;
    _lastMetricsAt = DateTime.now();
  }

  void _loadEnvKnobs() {
    final r = int.tryParse(dotenv.env["ROUTE_REFRESH_SECONDS"] ?? "");
    final c = int.tryParse(dotenv.env["CAMERA_THROTTLE_MS"] ?? "");
    final aDist = double.tryParse(dotenv.env["ARRIVAL_DISTANCE_METERS"] ?? "");
    final aStable = int.tryParse(dotenv.env["ARRIVAL_STABLE_SECONDS"] ?? "");

    final trailMax = int.tryParse(dotenv.env["TRAIL_MAX_POINTS"] ?? "");
    final trailMs = int.tryParse(dotenv.env["TRAIL_MIN_ADD_MS"] ?? "");
    final trailMove =
        double.tryParse(dotenv.env["TRAIL_MIN_MOVE_METERS"] ?? "");

    final flowEvery = int.tryParse(dotenv.env["ROUTE_FLOW_EVERY_N"] ?? "");
    final routeMinMove =
        double.tryParse(dotenv.env["ROUTE_MIN_MOVE_METERS"] ?? "");

    final followResume =
        int.tryParse(dotenv.env["FOLLOW_RESUME_DELAY_MS"] ?? "");

    if (r != null && r >= 3 && r <= 60) _routeRefreshSeconds = r;
    if (c != null && c >= 100 && c <= 1500) _cameraThrottleMs = c;
    if (followResume != null && followResume >= 1000 && followResume <= 15000) {
      _followResumeDelayMs = followResume;
    }

    if (aDist != null && aDist >= 10 && aDist <= 200) {
      _arrivalDistanceMeters = aDist;
    }
    if (aStable != null && aStable >= 2 && aStable <= 20) {
      _arrivalStableSeconds = aStable;
    }

    if (trailMax != null && trailMax >= 40 && trailMax <= 600) {
      _trailMaxPoints = trailMax;
    }
    if (trailMs != null && trailMs >= 200 && trailMs <= 5000) {
      _trailMinAddMs = trailMs;
    }
    if (trailMove != null && trailMove >= 2 && trailMove <= 100) {
      _trailMinMoveMeters = trailMove;
    }

    if (flowEvery != null && flowEvery >= 3 && flowEvery <= 20) {
      _flowEveryN = flowEvery;
    }

    if (routeMinMove != null && routeMinMove >= 5 && routeMinMove <= 150) {
      _routeMinMoveMeters = routeMinMove;
    }
  }

  void _initSocket() {
    socketService.initUser(userId: widget.userId);

    socketService.onConnectionChanged((connected) {
      if (!mounted) return;
      setState(() => socketConnected = connected);
      if (connected) {
        socketService.joinOrderRoom(widget.orderId);
      }
    });

    socketService.joinOrderRoom(widget.orderId);

    socketService.onTechnicianLocation((lat, lng) {
      if (!mounted) return;
      _feedDriverLocation(LatLng(lat, lng));
    });
  }

  void _feedDriverLocation(LatLng next) {
    final snapped = _routePoints.length >= 2 ? _snapToRouteIfClose(next) : next;
    _targetDriver = snapped;
    _bearing = _computeBearing(driverLocation, snapped);
    _displayBearing = _smoothAngle(_displayBearing, _bearing, 0.22);
    _maybeAddTrailPoint(snapped);
    _updateRouteProgress(snapped);
    _maybeFetchRoute(force: false);
  }

  void _tickFakeMovement() {
    if (_routePoints.length < 2) {
      _maybeFetchRoute(force: true);

      final next = _moveTowards(driverLocation, userLocation, metersStep: 7);
      _targetDriver = next;
      _bearing = _computeBearing(driverLocation, next);
      _displayBearing = _smoothAngle(_displayBearing, _bearing, 0.22);
      _maybeAddTrailPoint(next);
      return;
    }

    if (!_fakeRouteInitialized) {
      _fakeRouteInitialized = true;
      _fakeRouteIndex = _nearestRouteIndex(driverLocation, _routePoints);

      driverLocation = _routePoints[_fakeRouteIndex];
      _targetDriver = driverLocation;
      _updateRouteProgress(driverLocation);

      _trailPoints
        ..clear()
        ..add(driverLocation);

      if (mounted) setState(() {});
      return;
    }

    final step = _stepCountFromDistance(distanceToUser);

    if (_fakeRouteIndex < _routePoints.length - 1) {
      _fakeRouteIndex =
          (_fakeRouteIndex + step).clamp(0, _routePoints.length - 1);
      final next = _routePoints[_fakeRouteIndex];
      _targetDriver = next;
      _bearing = _computeBearing(driverLocation, next);
      _displayBearing = _smoothAngle(_displayBearing, _bearing, 0.22);
      _maybeAddTrailPoint(next);
      _updateRouteProgress(next);
    } else {
      _targetDriver = userLocation;
      _bearing = _computeBearing(driverLocation, userLocation);
      _displayBearing = _smoothAngle(_displayBearing, _bearing, 0.22);
      _maybeAddTrailPoint(userLocation);
      _updateRouteProgress(userLocation);
    }
  }

  int _stepCountFromDistance(double meters) {
    if (meters > 3000) return 7;
    if (meters > 1500) return 6;
    if (meters > 800) return 5;
    if (meters > 300) return 4;
    if (meters > 120) return 3;
    return 2;
  }

  int _nearestRouteIndex(LatLng pos, List<LatLng> pts) {
    if (pts.isEmpty) return 0;
    int best = 0;
    double bestDist = double.infinity;

    for (int i = 0; i < pts.length; i++) {
      final d = _distanceBetween(pos, pts[i]);
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  void _maybeAddTrailPoint(LatLng next) {
    final now = DateTime.now();
    if (now.difference(_lastTrailAdd).inMilliseconds < _trailMinAddMs) return;

    final last = _trailPoints.isNotEmpty ? _trailPoints.last : driverLocation;
    final moved = _distanceBetween(last, next);
    if (moved < _trailMinMoveMeters) return;

    _lastTrailAdd = now;
    _trailPoints.add(next);

    if (_trailPoints.length > _trailMaxPoints) {
      _trailPoints.removeRange(0, _trailPoints.length - _trailMaxPoints);
    }
  }

  Future<void> _loadAssets() async {
    await Future.wait([
      _loadMarkerIcons(),
      _loadMapStyle(),
    ]);
  }

  Future<void> _loadMapStyle() async {
    try {
      final style =
          await rootBundle.loadString("assets/map_styles/uber_dark.json");

      if (!mounted) return;
      setState(() {
        _mapStyle = style;
      });

      if (_map != null && !kIsWeb && _currentMapType == MapType.normal) {
        try {
          await _map!.setMapStyle(_mapStyle);
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _loadMarkerIcons() async {
    try {
      final car = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        "assets/icons/car_top.png",
      );

      final pin = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        "assets/icons/user_pin.png",
      );

      if (!mounted) return;
      setState(() {
        _carIcon = car;
        _userIcon = pin;
      });
    } catch (_) {}
  }

  Future<void> _toggleMapType() async {
    final next =
        _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;

    setState(() {
      _currentMapType = next;
    });

    if (_map != null && !kIsWeb) {
      try {
        if (_currentMapType == MapType.normal && _mapStyle != null) {
          await _map!.setMapStyle(_mapStyle);
        } else {
          await _map!.setMapStyle(null);
        }
      } catch (_) {}
    }
  }

  void _tickSmoothMovement() {
    if (_targetDriver == null) return;

    const t = 0.22;
    final cur = driverLocation;
    final tar = _targetDriver!;

    LatLng newPos = LatLng(
      cur.latitude + (tar.latitude - cur.latitude) * t,
      cur.longitude + (tar.longitude - cur.longitude) * t,
    );

    if (_routePoints.length >= 2) {
      newPos = _snapToRouteIfClose(newPos);
    }

    final dist = _distanceBetween(newPos, tar);
    if (dist < 1.8) {
      driverLocation = tar;
      _targetDriver = null;
    } else {
      driverLocation = newPos;
    }

    _updateRouteProgress(driverLocation);
    _displayBearing = _smoothAngle(_displayBearing, _bearing, 0.18);

    if (mounted) setState(() {});
  }

  void _updateMetrics() {
    final now = DateTime.now();
    final prevPos = _lastMetricsPos ?? driverLocation;
    final prevAt = _lastMetricsAt ?? now;

    final dt = now.difference(prevAt).inMilliseconds / 1000.0;
    final moved = _distanceBetween(prevPos, driverLocation);

    if (dt > 0.0) {
      speedMs = _clamp(moved / dt, 0, 60);
    } else {
      speedMs = 0;
    }

    _lastMetricsPos = driverLocation;
    _lastMetricsAt = now;

    distanceToUser = _distanceBetween(driverLocation, userLocation);

    if (!_hasDirectionsEta) {
      final assumedSpeed = (speedMs >= 2.0) ? speedMs : 8.0;
      final seconds = distanceToUser / assumedSpeed;
      etaMin = (seconds / 60).ceil().clamp(1, 99);
    }

    if (mounted) setState(() {});
  }

  Future<void> _maybeMoveCamera() async {
    if (!_follow || !_mapReady || _map == null) return;

    final sinceGesture =
        DateTime.now().difference(_lastManualMapGesture).inMilliseconds;
    if (sinceGesture < _followResumeDelayMs) return;

    if (_arrived) {
      _doArrivalZoomOnce();
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastCamMove).inMilliseconds < _cameraThrottleMs) return;
    _lastCamMove = now;

    if (_cameraMode == TrackingCameraMode.fitBoth) {
      await _fitUserAndDriver(padding: 150);
      return;
    }

    final zoom = _zoomFromDistance(distanceToUser);
    final leadTarget =
        _pointFrom(driverLocation, _displayBearing, _driverOnlyLeadMeters);

    await _animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: leadTarget,
          zoom: zoom,
          tilt: zoom >= 16 ? _followTilt : 40,
          bearing: _displayBearing,
        ),
      ),
    );
  }

  Future<void> _animateCamera(CameraUpdate update) async {
    if (_map == null) return;
    _programmaticCameraMove = true;
    try {
      await _map!.animateCamera(update);
    } catch (_) {
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        _programmaticCameraMove = false;
      });
    }
  }

  Future<void> _fitUserAndDriver({double padding = 120}) async {
    if (_map == null) return;

    final bounds = _computeBounds([
      userLocation,
      driverLocation,
    ]);

    try {
      await _animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 220));
      try {
        await _animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
      } catch (_) {}
    }
  }

  Future<void> _fitRouteBounds({double padding = 90}) async {
    if (_map == null) return;

    final pts = <LatLng>[
      userLocation,
      driverLocation,
      ..._routePoints,
    ];

    final bounds = _computeBounds(pts);
    try {
      await _animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
    } catch (_) {}
  }

  LatLngBounds _computeBounds(List<LatLng> pts) {
    double minLat = pts.first.latitude;
    double maxLat = pts.first.latitude;
    double minLng = pts.first.longitude;
    double maxLng = pts.first.longitude;

    for (final p in pts) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    if ((maxLat - minLat).abs() < 0.0002) {
      maxLat += 0.0001;
      minLat -= 0.0001;
    }
    if ((maxLng - minLng).abs() < 0.0002) {
      maxLng += 0.0001;
      minLng -= 0.0001;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  double _zoomFromDistance(double meters) {
    if (meters <= 120) return 18.4;
    if (meters <= 250) return 17.8;
    if (meters <= 500) return 17.0;
    if (meters <= 1000) return 16.2;
    if (meters <= 2500) return 15.3;
    return 14.5;
  }

  void _handleArrivalLogic() {
    if (_arrived) return;

    if (distanceToUser <= _arrivalDistanceMeters) {
      _arrivalStableCounter++;
      if (_arrivalStableCounter >= _arrivalStableSeconds) {
        _arrived = true;
        _triggerArrivalHapticsOnce();
        _doArrivalZoomOnce();
        if (mounted) setState(() {});
      }
    } else {
      if (_arrivalStableCounter != 0) _arrivalStableCounter = 0;
    }
  }

  Future<void> _triggerArrivalHapticsOnce() async {
    if (_arrivalHapticDone) return;
    _arrivalHapticDone = true;

    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  void _doArrivalZoomOnce() {
    if (_arrivalZoomDone || _map == null) return;
    _arrivalZoomDone = true;
    _fitRouteBounds(padding: 150);
  }

  Future<void> _maybeFetchRoute({required bool force}) async {
    if (_isFetchingRoute) return;

    final now = DateTime.now();
    if (!force &&
        now.difference(_lastRouteFetch).inSeconds < _routeRefreshSeconds) {
      return;
    }

    if (!force && _lastRouteOrigin != null) {
      final moved = _distanceBetween(_lastRouteOrigin!, driverLocation);
      if (moved < _routeMinMoveMeters) return;
    }

    _lastRouteFetch = now;
    _lastRouteOrigin = driverLocation;

    final key =
        (dotenv.env["GOOGLE_DIRECTIONS_KEY"]?.trim().isNotEmpty ?? false)
            ? dotenv.env["GOOGLE_DIRECTIONS_KEY"]!.trim()
            : (dotenv.env["GOOGLE_MAPS_KEY"] ?? "").trim();

    if (key.isEmpty) {
      debugPrint("Directions key is empty -> fallback route");
      _useFallbackStraightRoute();
      return;
    }

    try {
      _isFetchingRoute = true;
      _routeFetchFailed = false;

      try {
        _routeCancel?.cancel("new-route-request");
      } catch (_) {}

      _routeCancel = CancelToken();

      final origin = "${driverLocation.latitude},${driverLocation.longitude}";
      final dest = "${userLocation.latitude},${userLocation.longitude}";

      final res = await _dio.get(
        "https://maps.googleapis.com/maps/api/directions/json",
        queryParameters: {
          "origin": origin,
          "destination": dest,
          "mode": "driving",
          "alternatives": "false",
          "departure_time": "now",
          "traffic_model": "best_guess",
          "key": key,
          "language": "ar",
          "region": "eg",
        },
        cancelToken: _routeCancel,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final data = res.data;
      if (data is! Map) {
        debugPrint("Directions invalid response type");
        _useFallbackStraightRoute();
        return;
      }

      final status = (data["status"] ?? "").toString();
      if (status != "OK") {
        debugPrint("Directions API status: $status");
        debugPrint("Directions API response: $data");
        _useFallbackStraightRoute();
        return;
      }

      final routes = data["routes"];
      if (routes is! List || routes.isEmpty) {
        debugPrint("Directions routes empty");
        _useFallbackStraightRoute();
        return;
      }

      final route0 = routes.first;
      final decoded = _decodeDetailedRoutePoints(route0);

      if (decoded.length < 2) {
        debugPrint("Decoded route < 2 points");
        _useFallbackStraightRoute();
        return;
      }

      final legs = route0["legs"];
      if (legs is List && legs.isNotEmpty) {
        final leg0 = legs.first;
        final durTraffic = leg0["duration_in_traffic"]?["value"];
        final durVal = leg0["duration"]?["value"];
        final distVal = leg0["distance"]?["value"];

        if (durTraffic is num) {
          etaMin = (durTraffic.toDouble() / 60).ceil().clamp(1, 99);
          _hasDirectionsEta = true;
        } else if (durVal is num) {
          etaMin = (durVal.toDouble() / 60).ceil().clamp(1, 99);
          _hasDirectionsEta = true;
        } else {
          _hasDirectionsEta = false;
        }

        if (distVal is num) {
          distanceToUser = distVal.toDouble();
        }
      }

      if (!mounted) return;
      setState(() {
        _routePoints = _dedupeAdjacentPoints(decoded);
        _routeFetchFailed = false;

        if (_effectiveFake) {
          if (!_fakeRouteInitialized) {
            _fakeRouteIndex = _nearestRouteIndex(driverLocation, _routePoints);
            driverLocation = _routePoints[_fakeRouteIndex];
            _targetDriver = driverLocation;

            _trailPoints
              ..clear()
              ..add(driverLocation);

            _fakeRouteInitialized = true;
          } else {
            _fakeRouteIndex = _nearestRouteIndex(driverLocation, _routePoints);
          }
        } else {
          driverLocation = _snapToRouteIfClose(driverLocation);
        }

        _updateRouteProgress(driverLocation);
      });
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;
      debugPrint("Directions DioException: ${e.message}");
      _useFallbackStraightRoute();
    } catch (e) {
      debugPrint("Directions error: $e");
      _useFallbackStraightRoute();
    } finally {
      _isFetchingRoute = false;
    }
  }

  List<LatLng> _decodeDetailedRoutePoints(dynamic route0) {
    final detailed = <LatLng>[];

    final legs = route0["legs"];
    if (legs is List && legs.isNotEmpty) {
      for (final leg in legs) {
        final steps = leg["steps"];
        if (steps is! List || steps.isEmpty) continue;

        for (final step in steps) {
          final poly = step["polyline"]?["points"];
          if (poly is String && poly.isNotEmpty) {
            final pts = PolylinePoints().decodePolyline(poly);
            for (final p in pts) {
              detailed.add(LatLng(p.latitude, p.longitude));
            }
          }
        }
      }
    }

    if (detailed.length >= 2) {
      return _densifyRoute(detailed, maxGapMeters: 22);
    }

    final overview = route0["overview_polyline"]?["points"];
    if (overview is String && overview.isNotEmpty) {
      final pts = PolylinePoints().decodePolyline(overview);
      final decoded = pts.map((p) => LatLng(p.latitude, p.longitude)).toList();
      if (decoded.length >= 2) {
        return _densifyRoute(decoded, maxGapMeters: 24);
      }
    }

    return [];
  }

  void _useFallbackStraightRoute() {
    final fallback = _buildPremiumFakeRoute(driverLocation, userLocation);
    if (!mounted) return;

    setState(() {
      _routeFetchFailed = true;
      _routePoints = fallback;
      _hasDirectionsEta = false;

      if (_effectiveFake && !_fakeRouteInitialized) {
        _fakeRouteIndex = _nearestRouteIndex(driverLocation, _routePoints);
        driverLocation = _routePoints[_fakeRouteIndex];
        _targetDriver = driverLocation;
        _fakeRouteInitialized = true;
      } else if (_routePoints.length >= 2) {
        driverLocation = _snapToRouteIfClose(driverLocation);
      }

      _updateRouteProgress(driverLocation);
    });
  }

  List<LatLng> _buildPremiumFakeRoute(LatLng from, LatLng to) {
    final straightMeters = _distanceBetween(from, to);
    if (straightMeters < 35) return [from, to];

    final bearing = _computeBearing(from, to);
    final mid = LatLng(
      (from.latitude + to.latitude) / 2,
      (from.longitude + to.longitude) / 2,
    );

    final curveStrength =
        _clamp(straightMeters * 0.12, 25, _fakeCurveMaxOffsetMeters);
    final curveBearing =
        (bearing + (from.latitude > to.latitude ? 78 : -78)) % 360;

    final control1 = _pointFrom(
      _moveTowards(from, mid, metersStep: straightMeters * 0.33),
      curveBearing,
      curveStrength,
    );

    final control2 = _pointFrom(
      _moveTowards(mid, to, metersStep: straightMeters * 0.33),
      (curveBearing + 18) % 360,
      curveStrength * 0.72,
    );

    final raw = <LatLng>[];
    const segments = 56;

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      raw.add(_cubicBezier(from, control1, control2, to, t));
    }

    return _densifyRoute(_dedupeAdjacentPoints(raw), maxGapMeters: 16);
  }

  LatLng _cubicBezier(
    LatLng p0,
    LatLng p1,
    LatLng p2,
    LatLng p3,
    double t,
  ) {
    final mt = 1 - t;
    final x = mt * mt * mt * p0.latitude +
        3 * mt * mt * t * p1.latitude +
        3 * mt * t * t * p2.latitude +
        t * t * t * p3.latitude;

    final y = mt * mt * mt * p0.longitude +
        3 * mt * mt * t * p1.longitude +
        3 * mt * t * t * p2.longitude +
        t * t * t * p3.longitude;

    return LatLng(x, y);
  }

  List<LatLng> _densifyRoute(List<LatLng> input, {double maxGapMeters = 20}) {
    if (input.length < 2) return input;

    final out = <LatLng>[input.first];

    for (int i = 0; i < input.length - 1; i++) {
      final a = input[i];
      final b = input[i + 1];
      final dist = _distanceBetween(a, b);

      if (dist <= maxGapMeters) {
        out.add(b);
        continue;
      }

      final extraPoints = (dist / maxGapMeters).floor();
      for (int j = 1; j <= extraPoints; j++) {
        final t = j / (extraPoints + 1);
        out.add(LatLng(
          a.latitude + (b.latitude - a.latitude) * t,
          a.longitude + (b.longitude - a.longitude) * t,
        ));
      }
      out.add(b);
    }

    return out;
  }

  List<LatLng> _dedupeAdjacentPoints(List<LatLng> input) {
    if (input.isEmpty) return [];
    final out = <LatLng>[input.first];

    for (int i = 1; i < input.length; i++) {
      if (_distanceBetween(out.last, input[i]) > 1.2) {
        out.add(input[i]);
      }
    }
    return out;
  }

  void _rebuildRouteSampled() {
    final base = _remainingRoutePoints.length >= 2
        ? _remainingRoutePoints
        : _routePoints;

    if (base.length < 2) {
      _routeSampled = [];
      _flowTick = 0;
      return;
    }

    final sampled = <LatLng>[];
    for (int i = 0; i < base.length; i += _flowEveryN) {
      sampled.add(base[i]);
    }

    if (sampled.length < 2) {
      sampled
        ..clear()
        ..addAll(base);
    }

    _routeSampled = sampled;
    _flowTick = 0;
  }

  void _updateRouteProgress(LatLng pos) {
    if (_routePoints.length < 2) {
      _passedRoutePoints = [];
      _remainingRoutePoints = [];
      _routeProgress = 0.0;
      _rebuildRouteSampled();
      return;
    }

    final snapped = _snapToRouteIfClose(pos);
    final idx = _nearestRouteIndex(snapped, _routePoints);
    _driverRouteIndex = idx;

    _passedRoutePoints = [
      ..._routePoints.take(idx + 1),
      snapped,
    ];

    _remainingRoutePoints = [
      snapped,
      ..._routePoints.skip(idx + 1),
    ];

    _routeProgress = idx / math.max(1, _routePoints.length - 1);
    _rebuildRouteSampled();
  }

  LatLng _snapToRoute(LatLng p) {
    if (_routePoints.length < 2) return p;

    double bestDist = double.infinity;
    LatLng bestPoint = _routePoints.first;

    for (int i = 0; i < _routePoints.length - 1; i++) {
      final a = _routePoints[i];
      final b = _routePoints[i + 1];
      final cand = _closestPointOnSegment(a, b, p);
      final d = _distanceBetween(cand, p);

      if (d < bestDist) {
        bestDist = d;
        bestPoint = cand;
      }
    }

    return bestPoint;
  }

  LatLng _snapToRouteIfClose(LatLng p) {
    final snapped = _snapToRoute(p);
    final d = _distanceBetween(p, snapped);
    if (d <= _snapToRouteMaxDistanceMeters) return snapped;
    return p;
  }

  LatLng _closestPointOnSegment(LatLng a, LatLng b, LatLng p) {
    final ax = a.latitude;
    final ay = a.longitude;
    final bx = b.latitude;
    final by = b.longitude;
    final px = p.latitude;
    final py = p.longitude;

    final abx = bx - ax;
    final aby = by - ay;
    final ab2 = abx * abx + aby * aby;

    if (ab2 == 0) return a;

    final apx = px - ax;
    final apy = py - ay;

    double t = (apx * abx + apy * aby) / ab2;
    t = t.clamp(0.0, 1.0);

    return LatLng(ax + abx * t, ay + aby * t);
  }

  @override
  Widget build(BuildContext context) {
    final mapPadding = EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 86,
      bottom: 305,
    );

    return Scaffold(
      backgroundColor: _bg1,
      body: Stack(
        children: [
          _backgroundGlow(),
          _buildMap(mapPadding),
          _buildTopDoctorBar(),
          _buildRightControls(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _backgroundGlow() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_bg1, _bg2, _bg3],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildMap(EdgeInsets padding) {
    return GoogleMap(
      padding: padding,
      initialCameraPosition: CameraPosition(target: userLocation, zoom: 14.8),
      onMapCreated: (c) async {
        _map = c;

        if (_mapStyle != null && !kIsWeb && _currentMapType == MapType.normal) {
          try {
            await c.setMapStyle(_mapStyle);
          } catch (_) {}
        }

        if (!mounted) return;
        setState(() => _mapReady = true);

        await _maybeFetchRoute(force: true);
        await Future.delayed(const Duration(milliseconds: 180));
        await _fitRouteBounds(padding: 150);
      },
      onCameraMoveStarted: () {
        if (_programmaticCameraMove) return;
        _lastManualMapGesture = DateTime.now();
        if (_follow) {
          setState(() => _follow = false);
        }
      },
      mapType: _currentMapType,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      buildingsEnabled: true,
      indoorViewEnabled: false,
      trafficEnabled: _trafficEnabled,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      minMaxZoomPreference: const MinMaxZoomPreference(3, 20),
      circles: _buildMapCircles(),
      polylines: _buildPolylines(),
      markers: {
        Marker(
          markerId: const MarkerId("user"),
          position: userLocation,
          anchor: const Offset(0.5, 1.0),
          zIndex: 5,
          icon: _userIcon ?? BitmapDescriptor.defaultMarker,
        ),
        Marker(
          markerId: const MarkerId("driver"),
          position: driverLocation,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          zIndex: 10,
          rotation: _displayBearing,
          icon: _carIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
        ),
      },
    );
  }

  Set<Polyline> _buildPolylines() {
    final set = <Polyline>{};

    final remaining = _remainingRoutePoints.length >= 2
        ? _remainingRoutePoints
        : _routePoints;

    if (_routePoints.length >= 2) {
      set.add(
        Polyline(
          polylineId: const PolylineId("routeBaseShadow"),
          points: _routePoints,
          width: 11,
          color: Colors.black.withOpacity(0.22),
          geodesic: true,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }

    if (remaining.length >= 2) {
      set.add(
        Polyline(
          polylineId: const PolylineId("routeGlow"),
          points: remaining,
          width: 26,
          color: _routeGlow.withOpacity(0.24),
          geodesic: true,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );

      set.add(
        Polyline(
          polylineId: const PolylineId("routeOuter"),
          points: remaining,
          width: 18,
          color: _routeOuter.withOpacity(0.98),
          geodesic: true,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );

      set.add(
        Polyline(
          polylineId: const PolylineId("routeInner"),
          points: remaining,
          width: 12,
          color: _routeInner,
          geodesic: true,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );

      set.add(
        Polyline(
          polylineId: const PolylineId("routeCore"),
          points: remaining,
          width: 5,
          color: Colors.white.withOpacity(0.24),
          geodesic: true,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }

    if (_passedRoutePoints.length >= 2) {
      set.add(
        Polyline(
          polylineId: const PolylineId("routePassed"),
          points: _passedRoutePoints,
          width: 8,
          color: _routePassed.withOpacity(0.58),
          geodesic: true,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          jointType: JointType.round,
          patterns: [
            PatternItem.dash(14),
            PatternItem.gap(10),
          ],
        ),
      );
    }

    if (_trailPoints.length >= 2) {
      set.add(
        Polyline(
          polylineId: const PolylineId("trail"),
          points: _trailPoints,
          width: 4,
          color: Colors.white.withOpacity(0.10),
          geodesic: true,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }

    return set;
  }

  Set<Circle> _buildMapCircles() {
    final all = <Circle>{};
    all.addAll(_buildDriverPulseCircles());
    all.addAll(_buildRouteFlowCircles());
    all.addAll(_buildDestinationCircles());
    return all;
  }

  Set<Circle> _buildDriverPulseCircles() {
    final r1 = 22 + (_pulse * 76);
    final r2 = 22 + (((_pulse + 0.5) % 1.0) * 76);

    double opacity(double t) => (1 - t).clamp(0.0, 1.0);
    final t2 = ((_pulse + 0.5) % 1.0);

    return {
      Circle(
        circleId: const CircleId("p1"),
        center: driverLocation,
        radius: r1,
        fillColor: _brand.withOpacity(0.10 * opacity(_pulse)),
        strokeColor: _brand.withOpacity(0.18 * opacity(_pulse)),
        strokeWidth: 1,
      ),
      Circle(
        circleId: const CircleId("p2"),
        center: driverLocation,
        radius: r2,
        fillColor: _brand.withOpacity(0.08 * opacity(t2)),
        strokeColor: _brand.withOpacity(0.16 * opacity(t2)),
        strokeWidth: 1,
      ),
    };
  }

  Set<Circle> _buildDestinationCircles() {
    return {
      Circle(
        circleId: const CircleId("destinationHalo"),
        center: userLocation,
        radius: 34,
        fillColor: _accentGreen.withOpacity(0.08),
        strokeColor: _accentGreen.withOpacity(0.22),
        strokeWidth: 1,
      ),
    };
  }

  Set<Circle> _buildRouteFlowCircles() {
    if (_routeSampled.length < 2) return {};

    const int kDots = 9;
    const int spacing = 4;

    final circles = <Circle>{};
    final n = _routeSampled.length;

    for (int i = 0; i < kDots; i++) {
      final idx = (_flowTick + i * spacing) % n;
      final p = _routeSampled[idx];

      final t = i / (kDots - 1);
      final alpha = (1.0 - t) * 0.42;
      final radius = 4.5 + i * 1.5;

      circles.add(
        Circle(
          circleId: CircleId("rf_$i"),
          center: p,
          radius: radius,
          fillColor: Colors.white.withOpacity(alpha),
          strokeColor: _routeGlow.withOpacity(alpha * 0.75),
          strokeWidth: 1,
        ),
      );
    }

    return circles;
  }

  Widget _buildTopDoctorBar() {
    final km = (distanceToUser / 1000);
    final statusText = _arrived ? "وصل الفني" : "قيد الطريق";
    final liveText =
        socketConnected ? "Live" : (_effectiveFake ? "Fake" : "Offline");

    final liveColor = socketConnected
        ? _accentGreen
        : (_effectiveFake ? Colors.orangeAccent : Colors.redAccent);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 12,
      right: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.34),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                _miniStat(
                  icon: Icons.place_rounded,
                  title: "الحالة",
                  value: statusText,
                ),
                const SizedBox(width: 8),
                _miniStat(
                  icon: Icons.route_rounded,
                  title: "المسافة",
                  value: "${km.toStringAsFixed(2)} كم",
                ),
                const SizedBox(width: 8),
                _miniStat(
                  icon: Icons.timer_rounded,
                  title: "ETA",
                  value: "$etaMin د",
                ),
                const Spacer(),
                _chip(icon: Icons.wifi, text: liveText, color: liveColor),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: _accentGreen, size: 18),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightControls() {
    return Positioned(
      right: 14,
      bottom: 310,
      child: Column(
        children: [
          _pillBtn(
            icon: _follow ? Icons.gps_fixed : Icons.gps_not_fixed,
            label: _follow ? "Follow" : "Free",
            onTap: () async {
              setState(() => _follow = !_follow);
              if (_follow) {
                _lastManualMapGesture = DateTime.fromMillisecondsSinceEpoch(0);
                await _fitRouteBounds(padding: 150);
              }
            },
          ),
          const SizedBox(height: 10),
          _pillBtn(
            icon: _cameraMode == TrackingCameraMode.fitBoth
                ? Icons.center_focus_strong
                : Icons.directions_car,
            label: _cameraMode == TrackingCameraMode.fitBoth
                ? "FitBoth"
                : "Driver",
            onTap: () {
              setState(() {
                _cameraMode = _cameraMode == TrackingCameraMode.fitBoth
                    ? TrackingCameraMode.driverOnly
                    : TrackingCameraMode.fitBoth;
              });
              _maybeMoveCamera();
            },
          ),
          const SizedBox(height: 10),
          _pillBtn(
            icon: Icons.fit_screen,
            label: "Fit",
            onTap: () => _fitRouteBounds(padding: 120),
          ),
          const SizedBox(height: 10),
          _pillBtn(
            icon: _currentMapType == MapType.normal
                ? Icons.satellite_alt
                : Icons.map,
            label: _currentMapType == MapType.normal ? "Satellite" : "Normal",
            onTap: _toggleMapType,
          ),
          const SizedBox(height: 10),
          _pillBtn(
            icon: _trafficEnabled ? Icons.traffic : Icons.traffic_outlined,
            label: _trafficEnabled ? "Traffic On" : "Traffic Off",
            onTap: () => setState(() => _trafficEnabled = !_trafficEnabled),
          ),
          const SizedBox(height: 10),
          _pillBtn(
            icon: Icons.refresh,
            label: "Route",
            onTap: () => _maybeFetchRoute(force: true),
          ),
        ],
      ),
    );
  }

  Widget _pillBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withOpacity(.38),
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.18,
      maxChildSize: 0.64,
      builder: (context, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: _sheet.withOpacity(.92),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white10),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _statusCard(),
                  const SizedBox(height: 12),
                  _progressCard(),
                  const SizedBox(height: 12),
                  _techCard(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _actionBtn(
                          icon: Icons.call,
                          label: "اتصال",
                          kind: _ActionKind.primary,
                          onTap: _callTechDemo,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionBtn(
                          icon: Icons.chat_bubble,
                          label: "محادثة",
                          kind: _ActionKind.secondary,
                          onTap: _chatDemo,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionBtn(
                          icon: Icons.share,
                          label: "مشاركة",
                          kind: _ActionKind.secondary,
                          onTap: _shareDemo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_routeFetchFailed)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Text(
                        "تعذر تحميل مسار Google Directions حاليًا، وتم استخدام مسار بديل ناعم مؤقت.",
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _maybeFetchRoute(force: true);
                            if (!mounted) return;
                            _toast("تم تحديث المسار");
                          },
                          icon: const Icon(Icons.route, color: _accentGreen),
                          label: Text(
                            "تحديث المسار",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _cancelOrder,
                          icon:
                              const Icon(Icons.cancel, color: Colors.redAccent),
                          label: Text(
                            "إلغاء",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PaymentScreen(orderId: widget.orderId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "إنهاء الخدمة (الدفع)",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statusCard() {
    final km = distanceToUser / 1000;
    final text = _arrived
        ? "✔ الفني وصل لموقعك الآن"
        : "🚗 الفني في الطريق — ${km.toStringAsFixed(2)} كم • ETA $etaMin د";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentGreen.withOpacity(.14),
              border: Border.all(color: _accentGreen.withOpacity(.18)),
            ),
            child: Icon(
              _arrived ? Icons.check_circle : Icons.directions_car,
              color: _accentGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard() {
    final percent = (_routeProgress * 100).clamp(0, 100).toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _sheet2.withOpacity(.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "تقدّم الرحلة",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _arrived ? 1 : _routeProgress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(_accentGreen),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _smallMetric("السرعة", "${speedMs.toStringAsFixed(1)} m/s"),
              const SizedBox(width: 8),
              _smallMetric("التقدّم", "${percent.toStringAsFixed(0)}%"),
              const SizedBox(width: 8),
              _smallMetric(
                "المتبقي",
                "${(distanceToUser / 1000).toStringAsFixed(2)} كم",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallMetric(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: Colors.white60,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _techCard() {
    final liveText = socketConnected
        ? "Live tracking"
        : (_effectiveFake ? "Fake mode" : "Offline");

    final liveColor = socketConnected
        ? _accentGreen
        : (_effectiveFake ? Colors.orangeAccent : Colors.redAccent);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _sheet2.withOpacity(.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentGreen.withOpacity(.14),
              border: Border.all(color: _accentGreen.withOpacity(.18)),
            ),
            child: const Icon(Icons.person, color: _accentGreen, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الفني المعين",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "الخدمة: ${widget.serviceType}",
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  liveText,
                  style: GoogleFonts.cairo(
                    color: liveColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                "4.9",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required _ActionKind kind,
    required VoidCallback onTap,
  }) {
    final bool primary = kind == _ActionKind.primary;

    return Material(
      color: primary ? _accentGreen : Colors.white10,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: primary ? Colors.black : Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: primary ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _sheet.withOpacity(.96),
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

  Future<void> _callTechDemo() async {
    const phone = "tel:+201000000000";
    final uri = Uri.parse(phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _toast("اربطي رقم الفني القادم من السيرفر");
    }
  }

  void _chatDemo() => _toast("اربطي شاشة المحادثة هنا");
  void _shareDemo() => _toast("اربطي مشاركة تفاصيل الطلب هنا");

  void _cancelOrder() {
    if (!_effectiveFake) {
      try {
        socketService.cancelOrder(widget.orderId);
      } catch (_) {}
      try {
        socketService.leaveOrderRoom(widget.orderId);
      } catch (_) {}
    }
    Navigator.pop(context);
  }

  double _distanceBetween(LatLng a, LatLng b) {
    const double r = 6371e3;
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return r * c;
  }

  double _clamp(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  double _computeBearing(LatLng from, LatLng to) {
    final lat1 = _degToRad(from.latitude);
    final lon1 = _degToRad(from.longitude);
    final lat2 = _degToRad(to.latitude);
    final lon2 = _degToRad(to.longitude);

    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    var brng = math.atan2(y, x);
    brng = _radToDeg(brng);
    brng = (brng + 360) % 360;

    return brng.isNaN ? 0.0 : brng;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
  double _radToDeg(double rad) => rad * (180.0 / math.pi);

  LatLng _moveTowards(LatLng from, LatLng to, {required double metersStep}) {
    final dist = _distanceBetween(from, to);
    if (dist <= metersStep || dist == 0) return to;

    final t = metersStep / dist;
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  double _smoothAngle(double current, double target, double t) {
    final diff = ((target - current + 540) % 360) - 180;
    return (current + diff * t + 360) % 360;
  }

  LatLng _pointFrom(LatLng start, double bearingDeg, double distanceMeters) {
    const earthRadius = 6378137.0;
    final bearing = _degToRad(bearingDeg);

    final lat1 = _degToRad(start.latitude);
    final lon1 = _degToRad(start.longitude);
    final angDist = distanceMeters / earthRadius;

    final lat2 = math.asin(
      math.sin(lat1) * math.cos(angDist) +
          math.cos(lat1) * math.sin(angDist) * math.cos(bearing),
    );

    final lon2 = lon1 +
        math.atan2(
          math.sin(bearing) * math.sin(angDist) * math.cos(lat1),
          math.cos(angDist) - math.sin(lat1) * math.sin(lat2),
        );

    return LatLng(_radToDeg(lat2), _radToDeg(lon2));
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _smoothTimer?.cancel();
    _metricsTimer?.cancel();
    _routeRefreshTimer?.cancel();
    _flowTimer?.cancel();
    _fakeMoveTimer?.cancel();

    try {
      _routeCancel?.cancel("dispose");
    } catch (_) {}

    try {
      _dio.close(force: true);
    } catch (_) {}

    if (!_effectiveFake) {
      try {
        socketService.leaveOrderRoom(widget.orderId);
      } catch (_) {}
    }

    try {
      _map?.dispose();
    } catch (_) {}

    super.dispose();
  }
}

enum _ActionKind { primary, secondary }
