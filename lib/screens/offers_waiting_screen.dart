// PATH: lib/screens/offers_waiting_screen.dart
// PRO VERSION - CLEAN & NO ERRORS

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'searching_technician_screen.dart';

class OffersWaitingScreen extends StatefulWidget {
  final String userId;
  final String serviceType;
  final LatLng pickup;
  final String address;
  final List<String> selectedServices;
  final double initialPrice;
  final bool autoAccept;

  const OffersWaitingScreen({
    super.key,
    required this.userId,
    required this.serviceType,
    required this.pickup,
    required this.address,
    required this.selectedServices,
    required this.initialPrice,
    required this.autoAccept,
  });

  @override
  State<OffersWaitingScreen> createState() => _OffersWaitingScreenState();
}

class _OffersWaitingScreenState extends State<OffersWaitingScreen> {
  static const int _totalSeconds = 92;

  double _price = 0;
  int _secs = 0;
  Timer? _timer;

  // ignore: unused_field
  late bool _autoAccept;
  bool _searching = false;

  late final String _tempOrderId =
      "ORDER_${DateTime.now().millisecondsSinceEpoch}";

  @override
  void initState() {
    super.initState();
    _price = widget.initialPrice;
    _autoAccept = widget.autoAccept;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() => _secs++);

      if (_secs >= _totalSeconds) {
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "انتهى وقت انتظار العروض",
              style: GoogleFonts.cairo(),
            ),
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLeft {
    final remain = (_totalSeconds - _secs).clamp(0, 9999);
    final m = (remain ~/ 60).toString().padLeft(2, '0');
    final s = (remain % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _incPrice() => setState(() => _price += 1);

  void _decPrice() => setState(() {
        if (_price > 1) _price -= 1;
      });

  void _startSearching() {
    setState(() => _searching = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SearchingTechnicianScreen(
            userId: widget.userId,
            serviceType: widget.serviceType,
            lat: widget.pickup.latitude,
            lng: widget.pickup.longitude,
            address: widget.address,
            selectedServices: widget.selectedServices,
            orderId: _tempOrderId,
            fakeMode: true,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: widget.pickup, zoom: 14),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId("pickup"),
                position: widget.pickup,
              ),
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "يعرض شركاء فنيين طلبك",
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _timeLeft,
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _stepBtn(Icons.add, _incPrice),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "${_price.toStringAsFixed(0)} ج.م",
                                    style: GoogleFonts.cairo(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _stepBtn(Icons.remove, _decPrice),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _searching ? null : _startSearching,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _searching
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "البحث عن فني",
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_searching)
                          Text(
                            "جارٍ البحث عن فني قريب...",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                      ],
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

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Icon(icon),
      ),
    );
  }
}
