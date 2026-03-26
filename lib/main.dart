import 'package:doctor_car_app/screens/ride_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Screens
import 'screens/auth/forgot_password_screen.dart';
import 'screens/driver/incoming_request_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/road_services_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/smart_accident_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/vehicles/vehicle_screen.dart';

// Services
import 'services/orders/orders_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e, st) {
    debugPrint("⚠️ dotenv load failed: $e");
    debugPrint("$st");
  }

  final mapsApiKey = (dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '').trim();
  final mapsKey = (dotenv.env['GOOGLE_MAPS_KEY'] ?? '').trim();
  final directionsKey = (dotenv.env['GOOGLE_DIRECTIONS_KEY'] ?? '').trim();
  final placesKey = (dotenv.env['GOOGLE_PLACES_KEY'] ?? '').trim();

  debugPrint("🔑 GOOGLE_MAPS_API_KEY loaded => ${mapsApiKey.isNotEmpty}");
  debugPrint("🔑 GOOGLE_MAPS_KEY loaded => ${mapsKey.isNotEmpty}");
  debugPrint("🔑 GOOGLE_DIRECTIONS_KEY loaded => ${directionsKey.isNotEmpty}");
  debugPrint("🔑 GOOGLE_PLACES_KEY loaded => ${placesKey.isNotEmpty}");

  if (mapsApiKey.isEmpty &&
      mapsKey.isEmpty &&
      directionsKey.isEmpty &&
      placesKey.isEmpty) {
    debugPrint(
      "⚠️ No Google Maps keys found in .env (Maps / Places / Geocoding / Directions may fail).",
    );
  }

  final ordersStore = OrdersStore();
  await ordersStore.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<OrdersStore>.value(value: ordersStore),
        ],
        child: const DoctorCarApp(),
      ),
    ),
  );
}

class DoctorCarApp extends StatelessWidget {
  const DoctorCarApp({super.key});

  static const Color brandPrimary = Color(0xFF1F4BA5);

  ThemeData _buildLightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: brandPrimary),
    );

    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      scaffoldBackgroundColor: const Color(0xffF5F6FA),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: const Color(0xff111827),
        ),
        iconTheme: const IconThemeData(color: Color(0xff111827)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandPrimary,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      scaffoldBackgroundColor: const Color(0xff0E1320),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Car',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (final l in supportedLocales) {
          if (l.languageCode == locale.languageCode) return l;
        }
        return supportedLocales.first;
      },
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/road': (_) => const RoadServicesScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/vehicle': (_) => const VehiclesScreen(),
        '/smart-accident': (_) => const SmartAccidentScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/role': (_) => const RoleSelectionScreen(),
        '/orders': (_) => const OrdersScreen(),

        // Route تجريبي فقط
        '/ride': (_) => const RideSelectionScreen(
              userId: "USER_ID_HERE",
              serviceType: "خدمة سريعة",
              fakeTracking: false,
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/driver-home') {
          final args = settings.arguments as Map<String, dynamic>?;

          final token = (args?['token'] ?? '').toString();
          final id = (args?['id'] ?? '').toString();

          return MaterialPageRoute(
            builder: (_) => IncomingRequestScreen(
              technicianToken: token,
              technicianId: id,
            ),
          );
        }
        return null;
      },
    );
  }
}
