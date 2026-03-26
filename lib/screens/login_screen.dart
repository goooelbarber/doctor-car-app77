// PATH: lib/screens/login_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'driver/incoming_request_screen.dart';
import 'home_screen.dart';
import 'role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // =========================
  // COLORS - Keep background style
  // =========================
  static const Color _bgStart = Color(0xFF090B12);
  static const Color _bgEnd = Color(0xFF05070D);

  static const Color _panel = Color(0xFF18232B);
  static const Color _panelTop = Color(0xFF8EA1A9);

  static const Color _accent = Color.fromARGB(255, 8, 89, 143);
  static const Color _accentDark = Color.fromARGB(255, 33, 129, 194);
  static const Color _accentSoft = Color.fromARGB(255, 94, 176, 217);
  static const Color _accentGlow = Color(0xFF8FD3FF);

  static const Color _text = Color(0xFFF4F6F8);
  static const Color _muted = Color(0xFFB7C1C7);
  static const Color _hint = Color(0xFF93A1A8);
  static const Color _line = Color(0xFFDCE4E8);
  static const Color _lime = Color.fromARGB(255, 25, 180, 232);
  static const Color _success = Color(0xFF7DD3AE);

  // =========================
  // Controllers
  // =========================
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  final LocalAuthentication _auth = LocalAuthentication();

  // =========================
  // Animations
  // =========================
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  // =========================
  // State
  // =========================
  bool _obscureText = true;
  bool _isLoading = false;

  bool _rememberMe = true;
  bool _biometricEnabled = false;
  bool _deviceSupportsBiometric = false;

  String? _selectedRole;
  bool _roleChecked = false;

  // =========================
  // Pref keys
  // =========================
  static const String _kIsLoggedInKey = 'isLoggedIn';
  static const String _kTokenKey = 'token';
  static const String _kUserIdKey = 'userId';
  static const String _kUserEmailKey = 'userEmail';
  static const String _kUserNameKey = 'userName';
  static const String _kSelectedRoleKey = 'selectedRole';
  static const String _kBiometricKey = 'biometric';
  static const String _kForceLoginOnceKey = 'forceLoginOnce';

  static const String _kRememberedEmailKey = 'rememberedEmail';
  static const String _kRememberMeKey = 'rememberMe';

  static const String kGoogleWebClientId =
      "261907163300-cngtqbjih04t2c5k66vfqd2tduqvt2oc.apps.googleusercontent.com";

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _fadeIn = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, .03),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadRoleOrRedirect();
    if (!mounted) return;

    await _loadRememberedEmail();

    final prefs = await SharedPreferences.getInstance();
    final forceLogin = prefs.getBool(_kForceLoginOnceKey) ?? false;

    if (forceLogin) {
      await prefs.setBool(_kForceLoginOnceKey, false);
    } else {
      await _autoRedirectIfAlreadyLoggedIn();
    }

    await _initBiometric();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ======================================================
  // ROLE CHECK
  // ======================================================
  Future<void> _loadRoleOrRedirect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedRole = prefs.getString(_kSelectedRoleKey);

      if (!mounted) return;

      if (_selectedRole == null || _selectedRole!.isEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          (route) => false,
        );
        return;
      }

      setState(() => _roleChecked = true);
    } catch (_) {
      if (mounted) setState(() => _roleChecked = true);
    }
  }

  Future<void> _changeRole() async {
    if (_isLoading) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_kIsLoggedInKey, false);
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserIdKey);
    await prefs.remove(_kUserEmailKey);
    await prefs.remove(_kUserNameKey);

    await prefs.remove(_kSelectedRoleKey);
    await prefs.remove(_kForceLoginOnceKey);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  // ======================================================
  // AUTO REDIRECT
  // ======================================================
  Future<void> _autoRedirectIfAlreadyLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_kIsLoggedInKey) ?? false;
      final token = prefs.getString(_kTokenKey) ?? "";
      final role = prefs.getString(_kSelectedRoleKey) ?? "";
      final userId = prefs.getString(_kUserIdKey) ?? "";

      if (!mounted) return;

      if (isLoggedIn &&
          token.isNotEmpty &&
          role.isNotEmpty &&
          userId.isNotEmpty) {
        await _goAfterLogin(role);
      }
    } catch (_) {}
  }

  // ======================================================
  // BIOMETRIC
  // ======================================================
  Future<void> _initBiometric() async {
    if (kIsWeb) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _biometricEnabled = prefs.getBool(_kBiometricKey) ?? false;

      final hasToken = (prefs.getString(_kTokenKey) ?? "").isNotEmpty;
      _deviceSupportsBiometric = await _auth.canCheckBiometrics;

      if (mounted) {
        setState(() {
          _biometricEnabled = _biometricEnabled && hasToken;
        });
      }
    } catch (_) {}
  }

  Future<void> _biometricLogin() async {
    if (kIsWeb || _isLoading) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey) ?? "";
    final role = prefs.getString(_kSelectedRoleKey) ?? "";

    if (token.isEmpty || role.isEmpty) {
      _showMessage("لا يوجد جلسة محفوظة للبصمة، سجل دخول مرة أولاً");
      return;
    }

    final success = await _auth.authenticate(
      localizedReason: 'سجل الدخول باستخدام Face ID / Fingerprint',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (!success) return;

    if (!mounted) return;
    await _goAfterLogin(role);
  }

  // ======================================================
  // ROLE RESOLVER
  // ======================================================
  String _resolveRoleToUse({
    required String selectedRole,
    dynamic serverUserObj,
  }) {
    final s = selectedRole.toLowerCase().trim();

    if (s == "driver" || s == "technician" || s == "mechanic") return "driver";
    if (s == "rider" || s == "user" || s == "client") return "rider";

    final fromServer =
        (serverUserObj is Map ? serverUserObj["role"]?.toString() : null) ?? "";
    final fs = fromServer.toLowerCase().trim();
    if (_isTechnicianRole(fs)) return "driver";
    return "rider";
  }

  // ======================================================
  // AUTH: EMAIL/PASSWORD
  // ======================================================
  Future<void> _login() async {
    if (_isLoading) return;

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
      final prefs = await SharedPreferences.getInstance();
      final selectedRole = prefs.getString(_kSelectedRoleKey);

      if (selectedRole == null || selectedRole.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          (route) => false,
        );
        return;
      }

      final res = await ApiService.login(email, password);

      if (res['token'] != null) {
        final token = (res['token'] ?? "").toString();

        final userObj = res['user'];
        final idFromUser =
            (userObj is Map ? (userObj['_id'] ?? userObj['id']) : null)
                ?.toString();
        final idFromRoot = (res['userId'] ?? res['id'] ?? "").toString();

        final finalId = (idFromUser != null && idFromUser.isNotEmpty)
            ? idFromUser
            : idFromRoot;

        final name =
            (userObj is Map ? (userObj['name'] ?? userObj['username']) : null)
                    ?.toString() ??
                "User";

        final roleToUse = _resolveRoleToUse(
          selectedRole: selectedRole,
          serverUserObj: userObj,
        );

        await prefs.setBool(_kIsLoggedInKey, true);
        await prefs.setString(_kTokenKey, token);
        await prefs.setString(_kUserIdKey, finalId);
        await prefs.setString(_kUserEmailKey, email);
        await prefs.setString(_kUserNameKey, name);
        await prefs.setString(_kSelectedRoleKey, roleToUse);

        await prefs.setBool(_kForceLoginOnceKey, false);

        if (!kIsWeb) {
          await prefs.setBool(_kBiometricKey, true);
        }

        await _saveRememberedEmail();

        if (!mounted) return;
        await _goAfterLogin(roleToUse);
      } else {
        _showMessage(res['message']?.toString() ?? "فشل تسجيل الدخول");
      }
    } catch (_) {
      _showMessage("تعذر الاتصال بالسيرفر");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ======================================================
  // AUTH: GOOGLE
  // ======================================================
  Future<void> _loginWithGoogle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedRole = prefs.getString(_kSelectedRoleKey);

      if (selectedRole == null || selectedRole.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          (route) => false,
        );
        return;
      }

      final googleSignIn = GoogleSignIn(
        scopes: const ["email", "profile", "openid"],
        clientId: kIsWeb ? kGoogleWebClientId : null,
        serverClientId: !kIsWeb ? kGoogleWebClientId : null,
      );

      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) return;

      final auth = await account.authentication;
      if (auth.idToken == null) {
        _showMessage("تعذر الحصول على Google Token");
        return;
      }

      final res =
          await ApiService.googleLogin(auth.idToken!, role: selectedRole);

      if (res['token'] != null) {
        final token = (res['token'] ?? "").toString();

        final userObj = res['user'];
        final idFromUser =
            (userObj is Map ? (userObj['_id'] ?? userObj['id']) : null)
                ?.toString();
        final idFromRoot = (res['userId'] ?? res['id'] ?? "").toString();

        final finalId = (idFromUser != null && idFromUser.isNotEmpty)
            ? idFromUser
            : idFromRoot;

        final name =
            (userObj is Map ? (userObj['name'] ?? userObj['username']) : null)
                    ?.toString() ??
                (account.displayName ?? "User");

        final email = (userObj is Map ? userObj['email'] : null)?.toString() ??
            account.email;

        final roleToUse = _resolveRoleToUse(
          selectedRole: selectedRole,
          serverUserObj: userObj,
        );

        await prefs.setBool(_kIsLoggedInKey, true);
        await prefs.setString(_kTokenKey, token);
        await prefs.setString(_kUserIdKey, finalId);
        await prefs.setString(_kUserNameKey, name);
        await prefs.setString(_kUserEmailKey, email);
        await prefs.setString(_kSelectedRoleKey, roleToUse);

        await prefs.setBool(_kForceLoginOnceKey, false);

        if (!kIsWeb) {
          await prefs.setBool(_kBiometricKey, true);
        }

        await _saveRememberedEmail();

        if (!mounted) return;
        await _goAfterLogin(roleToUse);
      } else {
        _showMessage(res['message']?.toString() ?? "Google login failed");
      }
    } catch (_) {
      _showMessage("Google login failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ======================================================
  // NAVIGATION
  // ======================================================
  Future<void> _goAfterLogin(String role) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey) ?? "";
    final userId = prefs.getString(_kUserIdKey) ?? "";

    if (!mounted) return;

    final Widget next = _isTechnicianRole(role)
        ? IncomingRequestScreen(
            technicianToken: token,
            technicianId: userId,
          )
        : const HomeScreen();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => next),
      (route) => false,
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================
  bool _isTechnicianRole(String role) {
    final r = role.toLowerCase().trim();
    return r == "driver" ||
        r == "technician" ||
        r == "mechanic" ||
        r == "service_provider";
  }

  String _roleLabel(String? role) {
    final r = (role ?? "").toLowerCase();
    if (_isTechnicianRole(r)) return "فني";
    return "راكب";
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF162029),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _emailController.text = prefs.getString(_kRememberedEmailKey) ?? "";
    _rememberMe = prefs.getBool(_kRememberMeKey) ?? true;
    if (mounted) setState(() {});
  }

  Future<void> _saveRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString(_kRememberedEmailKey, _emailController.text.trim());
    } else {
      await prefs.remove(_kRememberedEmailKey);
    }
    await prefs.setBool(_kRememberMeKey, _rememberMe);
  }

  double _passwordStrength() {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    if (p.length >= 12) return 1;
    if (p.length >= 8) return 0.75;
    if (p.length >= 6) return 0.5;
    return 0.25;
  }

  String _strengthLabel() {
    final v = _passwordStrength();
    if (v >= 1) return "قوية جدًا";
    if (v >= 0.75) return "قوية";
    if (v >= 0.5) return "متوسطة";
    if (v > 0) return "ضعيفة";
    return "";
  }

  Color _strengthColor() {
    final v = _passwordStrength();
    if (v >= 1) return _success;
    if (v >= 0.75) return _lime;
    if (v >= 0.5) return const Color(0xFFE6C66F);
    if (v > 0) return const Color(0xFFE88989);
    return _muted;
  }

  bool get _isTechnicianSelected => _isTechnicianRole(_selectedRole ?? "");

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    if (!_roleChecked) {
      return const Scaffold(
        backgroundColor: _bgStart,
        body: Center(
          child: CircularProgressIndicator(color: _accent),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            _background(),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideIn,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 16,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Column(
                          children: [
                            _topRoleBar(),
                            const SizedBox(height: 18),
                            _heroTitle(),
                            const SizedBox(height: 18),
                            _loginPanel(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _background() {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgStart, _bgEnd],
              ),
            ),
          ),
        ),
        Positioned(
          top: 90,
          right: -35,
          child: _sideGlow(
            width: 120,
            height: 260,
            color: _accent.withOpacity(.85),
            angle: .35,
          ),
        ),
        Positioned(
          top: 300,
          left: -35,
          child: _sideGlow(
            width: 120,
            height: 260,
            color: _accent.withOpacity(.85),
            angle: -.35,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _ReferenceBackgroundPainter()),
        ),
      ],
    );
  }

  Widget _sideGlow({
    required double width,
    required double height,
    required Color color,
    required double angle,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color,
              color.withOpacity(.75),
              color.withOpacity(.15),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.18),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _topRoleBar() {
    final roleLabel = _roleLabel(_selectedRole);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(.09)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _accentSoft.withOpacity(.90),
                        _accent.withOpacity(.95),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(.20),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isTechnicianSelected
                        ? Icons.car_repair_rounded
                        : Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "الدور الحالي: $roleLabel",
                    style: const TextStyle(
                      color: _text,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: _isLoading ? null : _changeRole,
          style: TextButton.styleFrom(
            foregroundColor: _text,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          child: const Text(
            "تغيير الدور",
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroTitle() {
    return ScaleTransition(
      scale: _logoScale,
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _accentSoft,
                  _accent,
                  _accentDark,
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(.14),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(.30),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: _accentGlow.withOpacity(.10),
                  blurRadius: 60,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(
              _isTechnicianSelected
                  ? Icons.build_circle_rounded
                  : Icons.directions_car_filled_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "تسجيل الدخول",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isTechnicianSelected
                ? "دخول سريع وآمن لإدارة الطلبات ومتابعة العمل باحترافية"
                : "أكمل رحلتك بأمان مع تجربة دخول سريعة وسلسة",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD0D5D9),
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginPanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: _panel.withOpacity(.92),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: Colors.white.withOpacity(.07)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.35),
                blurRadius: 35,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              _panelHeader(),
              const SizedBox(height: 18),
              const Text(
                "LOGIN",
                style: TextStyle(
                  color: _lime,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "أدخل بيانات الحساب للمتابعة",
                style: TextStyle(
                  color: _muted.withOpacity(.88),
                  fontSize: 13.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              _field(
                _emailController,
                Icons.person_outline_rounded,
                "Email",
              ),
              const SizedBox(height: 14),
              _passwordField(),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pushNamed(context, '/forgot-password'),
                  style: TextButton.styleFrom(
                    foregroundColor: _muted,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    "?Forgot Password",
                    style: TextStyle(
                      color: _muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _strengthBar(),
              const SizedBox(height: 14),
              _rememberBiometricRow(),
              const SizedBox(height: 18),
              _loginButton(),
              const SizedBox(height: 16),
              _orDivider(),
              const SizedBox(height: 16),
              _googleButton(),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _social(FontAwesomeIcons.facebookF),
                  const SizedBox(width: 12),
                  _social(FontAwesomeIcons.apple),
                  const SizedBox(width: 12),
                  _social(FontAwesomeIcons.twitter),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "بالاستمرار أنت توافق على الشروط وسياسة الخصوصية",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _hint,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _panelTop.withOpacity(.16),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.06)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.07),
            Colors.white.withOpacity(.03),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_accentSoft, _accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(.18),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "دخول آمن وسريع",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.2,
                fontWeight: FontWeight.w800,
                letterSpacing: .3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _strengthBar() {
    final strength = _passwordStrength();
    final strengthColor = _strengthColor();

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: strength,
              minHeight: 7,
              backgroundColor: Colors.white.withOpacity(.10),
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _strengthLabel(),
          style: TextStyle(
            color: strength == 0 ? _muted : strengthColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _rememberBiometricRow() {
    return Row(
      children: [
        InkWell(
          onTap: _isLoading
              ? null
              : () => setState(() => _rememberMe = !_rememberMe),
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _rememberMe ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _rememberMe ? _accent : Colors.white24,
                  ),
                  boxShadow: _rememberMe
                      ? [
                          BoxShadow(
                            color: _accent.withOpacity(.20),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: _rememberMe
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              const Text(
                "تذكرني",
                style: TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (!kIsWeb && _deviceSupportsBiometric && _biometricEnabled)
          InkWell(
            onTap: _isLoading ? null : _biometricLogin,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(.08)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.fingerprint, color: _accentSoft, size: 20),
                  SizedBox(width: 6),
                  Text(
                    "بصمة",
                    style: TextStyle(
                      color: _text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_accentSoft, _accent, _accentDark],
          ),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(.22),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _isLoading ? null : _login,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(.10))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "أو",
            style: TextStyle(
              color: _muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(.10))),
      ],
    );
  }

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _loginWithGoogle,
        icon: const Icon(FontAwesomeIcons.google, size: 18),
        label: const Text(
          "تسجيل بواسطة Google",
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _text,
          backgroundColor: Colors.white.withOpacity(.03),
          side: BorderSide(color: Colors.white.withOpacity(.14)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, IconData i, String hint) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.emailAddress,
      textAlign: TextAlign.left,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
      style: const TextStyle(
        color: _text,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: _accent,
      decoration: _input(i, hint),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      obscureText: _obscureText,
      textAlign: TextAlign.left,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _login(),
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        color: _text,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: _accent,
      decoration: _input(Icons.lock_outline_rounded, "Password").copyWith(
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscureText = !_obscureText),
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _muted,
          ),
        ),
      ),
    );
  }

  InputDecoration _input(IconData icon, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(.03),
      hintText: hint,
      hintStyle: const TextStyle(
        color: _hint,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: _text.withOpacity(.88), size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(.10),
          width: 1.2,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: _accentSoft, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _line, width: 1.2),
      ),
    );
  }

  Widget _social(IconData icon) {
    return InkWell(
      onTap: () => _showMessage("سيتم تفعيلها قريبًا"),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(.05),
          border: Border.all(color: Colors.white.withOpacity(.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.10),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: _text, size: 18),
      ),
    );
  }
}

class _ReferenceBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    glow.color = const Color(0xFF7CCBFF).withOpacity(.06);
    canvas.drawCircle(Offset(size.width * .25, size.height * .18), 160, glow);

    glow.color = Colors.white.withOpacity(.025);
    canvas.drawCircle(Offset(size.width * .72, size.height * .50), 220, glow);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(.02)
      ..strokeWidth = 1;

    const spacing = 26.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
