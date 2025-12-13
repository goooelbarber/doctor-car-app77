// =======================
// main.dart  (الكامل)
// =======================

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html; // ← نستخدمه فقط على الويب

import 'dart:async';
import 'package:doctor_car_app/screens/auth/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:easy_localization/easy_localization.dart';

import 'package:doctor_car_app/screens/splash_screen.dart';
import 'package:doctor_car_app/screens/login_screen.dart';
import 'package:doctor_car_app/screens/SignUp_Screen.dart';
import 'package:doctor_car_app/screens/home_screen.dart';
import 'package:doctor_car_app/screens/road_services_screen.dart';
import 'package:doctor_car_app/screens/vehicles/vehicle_screen.dart';
import 'package:doctor_car_app/screens/smart_accident_screen.dart';
import 'package:doctor_car_app/screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // تحميل Google Maps للويب فقط
  if (kIsWeb) {
    await _loadGoogleMapsJS();
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      child: const DoctorCarApp(),
    ),
  );
}

/// تحميل Google Maps JS للويب فقط
Future<void> _loadGoogleMapsJS() async {
  final Completer<void> completer = Completer();

  final script = html.ScriptElement()
    ..src =
        "https://maps.googleapis.com/maps/api/js?key=AIzaSyD9BGSScE-DU9nbdFgIbJV4fbNspNdPg_M&libraries=places"
    ..async = true;

  script.onLoad.listen((event) {
    if (kDebugMode) {
      print("✅ Google Maps JS Loaded Successfully");
    }
    completer.complete();
  });

  script.onError.listen((event) {
    if (kDebugMode) {
      print("❌ Failed to Load Google Maps JS");
    }
    completer.complete();
  });

  html.document.head!.append(script);

  return completer.future;
}

// ======================
// تطبيق DoctorCarApp
// ======================
class DoctorCarApp extends StatelessWidget {
  const DoctorCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Car',

      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        fontFamily: 'Cairo',
      ),

      // الترجمة
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      home: const SplashScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/road': (context) => const RoadServicesScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/vehicle': (context) => const VehiclesScreen(),
        "/smart-accident": (context) => const SmartAccidentScreen(),
        "/settings": (context) => const SettingsScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
      },
    );
  }
}
