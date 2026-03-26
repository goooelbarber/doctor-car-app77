// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  // ✅ Pref keys
  static const String _kIsLoggedInKey = 'isLoggedIn';
  static const String _kTokenKey = 'token';
  static const String _kUserNameKey = 'userName';
  static const String _kUserEmailKey = 'userEmail';
  static const String _kSelectedRoleKey = 'selectedRole'; // rider|driver
  static const String _kBiometricKey = 'biometric';

  // ✅ Google Web Client ID (يجب أن يطابق GOOGLE_CLIENT_ID في السيرفر)
  static const String kGoogleWebClientId =
      "261907163300-cngtqbjih04t2c5k66vfqd2tduqvt2oc.apps.googleusercontent.com";

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _scale = Tween<double>(begin: .98, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ======================================================
  // REGISTER
  // ======================================================
  Future<void> _register() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final selectedRole = prefs.getString(_kSelectedRoleKey);
      if (selectedRole == null || selectedRole.trim().isEmpty) {
        _showSnack("اختر (راكب/سائق) أولاً");
        return;
      }

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final res =
          await ApiService.register(name, email, password, selectedRole);

      final hasToken =
          res['token'] != null && (res['token'] as String).isNotEmpty;
      final isSuccess = res['success'] == true || hasToken;

      if (isSuccess) {
        await prefs.setBool(_kIsLoggedInKey, true);

        if (hasToken) {
          await prefs.setString(_kTokenKey, res['token']);
        }

        await prefs.setString(_kUserNameKey, name);
        await prefs.setString(_kUserEmailKey, email);

        final serverRole = res['user']?['role'];
        final roleToSave = (serverRole is String && serverRole.isNotEmpty)
            ? serverRole
            : selectedRole;

        await prefs.setString(_kSelectedRoleKey, roleToSave);

        await prefs.setBool(_kBiometricKey, true);

        _showSnack("تم إنشاء الحساب بنجاح ✅");
        _goAfterRegister(roleToSave);
      } else {
        _showSnack(res['message']?.toString() ?? "حدث خطأ أثناء التسجيل");
      }
    } catch (_) {
      _showSnack("خطأ في الاتصال بالسيرفر ⚠️");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ======================================================
  // GOOGLE SIGNUP/LOGIN (REAL)
  // ======================================================
  Future<void> _signupWithGoogle() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedRole = prefs.getString(_kSelectedRoleKey);
      if (selectedRole == null || selectedRole.trim().isEmpty) {
        _showSnack("اختر (راكب/سائق) أولاً");
        return;
      }

      // ✅ مهم: استخدم serverClientId فقط (Web Client ID)
      // ولا تضع clientId هنا (خصوصًا على Android/iOS)
      final googleSignIn = GoogleSignIn(
        scopes: const ["email", "profile"],
        serverClientId: kGoogleWebClientId,
      );

      // ✅ حل مشاكل جلسة قديمة / حساب غير صحيح
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final account = await googleSignIn.signIn();
      if (account == null) {
        _showSnack("تم إلغاء تسجيل الدخول");
        return;
      }

      final auth = await account.authentication;

      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        _showSnack("فشل الحصول على Google idToken");
        return;
      }

      // Debug (آمن): لا تطبع التوكن كله
      log("Google email: ${account.email}");
      log("idToken(head): ${idToken.substring(0, 18)}... tail: ...${idToken.substring(idToken.length - 12)}");

      final res = await ApiService.googleLogin(idToken, role: selectedRole);

      if (res["success"] == true && res["token"] != null) {
        await prefs.setBool(_kIsLoggedInKey, true);
        await prefs.setString(_kTokenKey, res["token"]);

        await prefs.setString(
          _kUserEmailKey,
          (res["user"]?["email"] ?? account.email).toString(),
        );

        await prefs.setString(
          _kUserNameKey,
          (res["user"]?["name"] ??
                  (account.displayName ?? account.email.split("@")[0]))
              .toString(),
        );

        final serverRole = res["user"]?["role"];
        final roleToSave = (serverRole is String && serverRole.isNotEmpty)
            ? serverRole
            : selectedRole;

        await prefs.setString(_kSelectedRoleKey, roleToSave);
        await prefs.setBool(_kBiometricKey, true);

        _showSnack("تم تسجيل الدخول عبر Google ✅");
        _goAfterRegister(roleToSave);
      } else {
        _showSnack(res["message"]?.toString() ?? "فشل تسجيل الدخول بجوجل");
      }
    } catch (e) {
      log("GOOGLE SIGNIN ERROR: $e");
      _showSnack("حدث خطأ أثناء تسجيل الدخول بجوجل");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goAfterRegister(String role) {
    Navigator.pushReplacementNamed(context, '/home');
  }

  // ======================================================
  // VALIDATION + HELPERS
  // ======================================================
  bool _isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

  double _passwordStrength() {
    final p = _passwordController.text;
    if (p.length >= 12) return 1;
    if (p.length >= 8) return .7;
    if (p.length >= 6) return .5;
    if (p.isNotEmpty) return .25;
    return 0;
  }

  String _strengthLabel() {
    final v = _passwordStrength();
    if (v >= 1) return "قوية جدًا";
    if (v >= .7) return "قوية";
    if (v >= .5) return "متوسطة";
    if (v > 0) return "ضعيفة";
    return "";
  }

  void _showSnack(String msg) {
    if (!mounted) return;
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
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: _glassCard(),
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

  Widget _glassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.10),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(.18)),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                color: Colors.black.withOpacity(.25),
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 30,
                        color: Colors.amber.withOpacity(.35),
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    color: Color(0xFF0B1B2B),
                    size: 44,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "إنشاء حساب جديد",
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "أدخل بياناتك لبدء الاستخدام",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                _inputField(
                  controller: _nameController,
                  icon: Icons.person,
                  hint: "الاسم الكامل",
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "الاسم مطلوب" : null,
                ),
                const SizedBox(height: 12),
                _inputField(
                  controller: _emailController,
                  icon: Icons.email,
                  hint: "البريد الإلكتروني",
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final s = (v ?? "").trim();
                    if (s.isEmpty) return "البريد مطلوب";
                    if (!_isValidEmail(s)) return "بريد غير صحيح";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _passwordInput(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _passwordStrength(),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(20),
                        backgroundColor: Colors.white24,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _strengthLabel(),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: const Color(0xFF0B1B2B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF0B1B2B),
                            ),
                          )
                        : const Text(
                            "تسجيل الحساب",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(.25)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child:
                          Text("أو", style: TextStyle(color: Colors.white70)),
                    ),
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(.25)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signupWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 30),
                    label: const Text(
                      "التسجيل بواسطة Google",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(.30)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      backgroundColor: Colors.white.withOpacity(.06),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    "لديك حساب؟ تسجيل الدخول",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordInput() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      onChanged: (_) => setState(() {}),
      validator: (v) {
        final s = (v ?? "").trim();
        if (s.isEmpty) return "كلمة المرور مطلوبة";
        if (s.length < 6) return "كلمة المرور قصيرة";
        return null;
      },
      style: const TextStyle(color: Colors.white),
      textAlign: TextAlign.right,
      decoration: _inputDecoration(
        icon: Icons.lock,
        hint: "كلمة المرور",
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      textAlign: TextAlign.right,
      decoration: _inputDecoration(icon: icon, hint: hint),
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(.12),
      prefixIcon: Icon(icon, color: Colors.white),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.amber, width: 1.3),
      ),
    );
  }

  Widget _background() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff051937), Color(0xff003d73), Color(0xff001b3a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
}
