import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // ✅ kIsWeb
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctor_car_app/services/api_service.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ⚠️ local_auth لا يعمل على Web
  final LocalAuthentication _auth = LocalAuthentication();

  late AnimationController _logoController;

  bool _obscureText = true;
  bool _isLoading = false;
  bool _rememberMe = true;
  bool _biometricEnabled = false;
  bool _deviceSupportsBiometric = false;

  // ======================================================
  // INIT
  // ======================================================

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _loadRememberedEmail();
    _initBiometric(); // ✅ الآن آمن
  }

  @override
  void dispose() {
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ======================================================
  // BIOMETRIC (FIXED FOR WEB)
  // ======================================================

  Future<void> _initBiometric() async {
    if (kIsWeb) {
      // ❌ Web لا يدعم FaceID / Fingerprint
      _biometricEnabled = false;
      _deviceSupportsBiometric = false;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool('biometric') ?? false;
    _deviceSupportsBiometric = await _auth.canCheckBiometrics;
    setState(() {});
  }

  Future<void> _biometricLogin() async {
    if (kIsWeb) return;

    try {
      final success = await _auth.authenticate(
        localizedReason: 'سجل الدخول باستخدام Face ID / Fingerprint',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (_) {
      _showMessage("فشل التحقق بالبصمة");
    }
  }

  // ======================================================
  // LOCAL STORAGE
  // ======================================================

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _emailController.text = prefs.getString("rememberedEmail") ?? "";
    _rememberMe = prefs.getBool("rememberMe") ?? true;
    setState(() {});
  }

  Future<void> _saveRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString("rememberedEmail", _emailController.text.trim());
    } else {
      await prefs.remove("rememberedEmail");
    }
    await prefs.setBool("rememberMe", _rememberMe);
  }

  // ======================================================
  // LOGIN
  // ======================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_isValidEmail(email)) {
      _showMessage("أدخل بريد إلكتروني صحيح");
      return;
    }

    if (password.length < 6) {
      _showMessage("كلمة المرور قصيرة");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.login(email, password);

      if (res.containsKey('token')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if (!kIsWeb) {
          await prefs.setBool('biometric', true);
        }

        await prefs.setString('token', res['token']);
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', res['user']?['name'] ?? "User");

        await _saveRememberedEmail();

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage(res['message'] ?? "فشل تسجيل الدخول");
      }
    } catch (_) {
      _showMessage("تعذر الاتصال بالسيرفر");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ======================================================
  // HELPERS
  // ======================================================

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

  double _passwordStrength() {
    final p = _passwordController.text;
    if (p.length >= 10) return 1;
    if (p.length >= 6) return .6;
    if (p.isNotEmpty) return .3;
    return 0;
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ======================================================
  // UI
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          _background(),
          Center(
            child: Container(
              width: width * .9,
              padding: const EdgeInsets.all(22),
              decoration: _glass(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _logoController,
                        curve: Curves.easeOutBack,
                      ),
                      child: const Icon(
                        Icons.directions_car_filled,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 25),

                    _field(_emailController, Icons.email, "البريد الإلكتروني"),
                    const SizedBox(height: 14),

                    _passwordField(),
                    LinearProgressIndicator(
                      value: _passwordStrength(),
                      backgroundColor: Colors.white24,
                      color: Colors.greenAccent,
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: Colors.amber,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? true),
                        ),
                        const Text("تذكرني",
                            style: TextStyle(color: Colors.white)),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/forgot-password'),
                          child: const Text(
                            "نسيت كلمة المرور؟",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    // ✅ يظهر فقط على Mobile
                    if (!kIsWeb &&
                        _deviceSupportsBiometric &&
                        _biometricEnabled)
                      IconButton(
                        icon: const Icon(Icons.fingerprint,
                            size: 40, color: Colors.white),
                        onPressed: _biometricLogin,
                      ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text("أو سجل بواسطة",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _social(FontAwesomeIcons.google, Colors.red),
                        const SizedBox(width: 16),
                        _social(FontAwesomeIcons.facebook, Colors.blue),
                        const SizedBox(width: 16),
                        _social(FontAwesomeIcons.apple, Colors.black),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ======================================================
  // WIDGETS
  // ======================================================

  Widget _background() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff051937), Color(0xff003d73)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );

  BoxDecoration _glass() => BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
      );

  Widget _field(TextEditingController c, IconData i, String hint) {
    return TextField(
      controller: c,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white),
      decoration: _input(i, hint),
    );
  }

  Widget _passwordField() => TextField(
        controller: _passwordController,
        obscureText: _obscureText,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.right,
        onChanged: (_) => setState(() {}),
        decoration: _input(Icons.lock, "كلمة المرور").copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
      );

  InputDecoration _input(IconData icon, String hint) => InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(.15),
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget _social(IconData icon, Color c) => CircleAvatar(
        radius: 22,
        backgroundColor: c,
        child: Icon(icon, color: Colors.white, size: 20),
      );
}
