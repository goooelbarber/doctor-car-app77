import 'package:doctor_car_app/screens/screens/services/help_now_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// 🎯 استيراد الشاشات الأساسية
import 'package:doctor_car_app/screens/splash_screen.dart';
import 'package:doctor_car_app/screens/login_screen.dart';
import 'screens/home_screen.dart';
// ignore: unused_import

// 📦 مزود اللغة (Locale Provider)
import 'providers/locale_provider.dart';

// 💡 الثوابت والألوان
const Color kPrimaryColor = Color(0xFF0D47A1);

class DoctorCarApp extends StatelessWidget {
  const DoctorCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Doctor Car App',
            debugShowCheckedModeBanner: false,

            // 🌍 اللغة
            locale: localeProvider.appLocale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // 🎨 الثيم والتصميم
            theme: ThemeData(
              primaryColor: kPrimaryColor,
              scaffoldBackgroundColor: const Color(0xFFF4F7F9),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              fontFamily: 'Cairo',
              useMaterial3: true,
            ),

            // 🎯 نقطة البداية
            initialRoute: '/splash',

            // 🗺️ تعريف المسارات
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/help-now': (context) => const HelpNowScreen(),
            },
          );
        },
      ),
    );
  }
}
