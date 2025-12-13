// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doctor_car_app/screens/login_screen.dart';
import 'package:doctor_car_app/screens/home_screen.dart';
import 'package:doctor_car_app/core/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _glow;
  late final Animation<Offset> _slide;

  static const Duration _splashDuration = Duration(seconds: 3);
  static const Duration _animationDuration = Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();

    HapticFeedback.lightImpact();
    _initAnimations();
    _handleNavigation();
  }

  // ================= Animations =================
  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _glow = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  // ================= Navigation =================
  Future<void> _handleNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await Future.delayed(_splashDuration);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      AppRoutes.fadeScale(
        isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF020024),
                Color(0xFF090979),
                Color(0xFF00D4FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              _buildContent(),
              _buildVersion(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Widgets =================
  Widget _buildContent() {
    return Center(
      child: FadeTransition(
        opacity: _fade,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: AnimatedBuilder(
                animation: _glow,
                builder: (_, __) {
                  return Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0F2027),
                          Color(0xFF203A43),
                          Color(0xFF2C5364),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(_glow.value),
                          blurRadius: 60,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Image.asset(
                        "assets/images/logo1.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 36),
            SlideTransition(
              position: _slide,
              child: const Column(
                children: [
                  Text(
                    "Doctor Car",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.4,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Smart Road Assistance",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: Colors.white24,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersion() {
    return const Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          "v1.0.0",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
