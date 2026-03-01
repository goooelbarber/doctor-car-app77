// PATH: lib/screens/tracking/completed_screen.dart
// inDrive ULTRA Completed Screen

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../payment_screen.dart';

class CompletedScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String serviceType;

  const CompletedScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.serviceType,
  });

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  static const Color _bg = Color(0xFF0B1220);
  static const Color _card = Color(0xFF121B2E);
  static const Color _green = Color(0xFF22C55E);
  static const Color _danger = Color(0xFFFF4D4D);

  bool _loading = false;

  double _pulse = 0;
  Timer? _pulseTimer;

  @override
  void initState() {
    super.initState();

    _pulseTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!mounted) return;
      setState(() {
        _pulse += 0.02;
        if (_pulse >= 1) _pulse = 0;
      });
    });
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  void _goToPayment() {
    if (_loading) return;

    setState(() => _loading = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            orderId: widget.orderId,
            amount: widget.amount,
            serviceType: widget.serviceType,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          _backgroundGlow(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Animated Success Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130 + (_pulse * 40),
                        height: 130 + (_pulse * 40),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _green.withOpacity(0.15 * (1 - _pulse)),
                        ),
                      ),
                      const Icon(
                        Icons.check_circle,
                        size: 100,
                        color: _green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    "تم إنهاء الخدمة بنجاح",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Service Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _card.withOpacity(.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.serviceType,
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "${widget.amount.toStringAsFixed(2)} E£",
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _goToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              "الدفع الآن",
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundGlow() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          color: Colors.black.withOpacity(0.25),
        ),
      ),
    );
  }
}
