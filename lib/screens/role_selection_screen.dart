// PATH: lib/screens/role_selection_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doctor_car_app/core/app_routes.dart';
import 'package:doctor_car_app/screens/login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  // =========================
  // Pref keys (لازم تطابق LoginScreen)
  // =========================
  static const String _kIsLoggedInKey = 'isLoggedIn';
  static const String _kTokenKey = 'token';
  static const String _kUserIdKey = 'userId';
  static const String _kSelectedRoleKey = 'selectedRole'; // rider|driver

  // ✅ NEW: Flag لمنع auto-redirect في LoginScreen مرة واحدة
  static const String _kForceLoginOnceKey = 'forceLoginOnce';

  // =========================
  // ✅ Brand palette (نفس لون Splash)
  // =========================
  static const Color _bg0 = Color(0xFF060A10);
  static const Color _bg1 = Color(0xFF070E14);
  static const Color _bg2 = Color(0xFF0A1418);

  static const Color _lime = Color(0xFFB8FF2C);
  static const Color _lime2 = Color(0xFF7CFF00);
  // ignore: unused_field
  static const Color _limeDeep = Color(0xFF2D6B00);

  String? selectedRole;
  bool _saving = false;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  // UI states for micro-interactions
  String? _pressedRole; // for press animation

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: .98, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _loadSavedRole();
  }

  Future<void> _loadSavedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final r = prefs.getString(_kSelectedRoleKey);
      if (!mounted) return;
      if (r != null && r.isNotEmpty) {
        setState(() => selectedRole = r);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (selectedRole == null || _saving) return;

    setState(() => _saving = true);
    HapticFeedback.lightImpact();

    final prefs = await SharedPreferences.getInstance();

    // ✅ لو كان عامل login قبل كده وغيّر الدور → امسح session القديم لتجنب اللخبطة
    final oldRole = prefs.getString(_kSelectedRoleKey);
    final wasLoggedIn = prefs.getBool(_kIsLoggedInKey) ?? false;

    if (wasLoggedIn && oldRole != null && oldRole != selectedRole) {
      await prefs.setBool(_kIsLoggedInKey, false);
      await prefs.remove(_kTokenKey);
      await prefs.remove(_kUserIdKey);
    }

    // ✅ خزّن الدور المختار
    await prefs.setString(_kSelectedRoleKey, selectedRole!);

    // ✅ أهم سطر: امنع LoginScreen من عمل auto redirect مرة واحدة
    await prefs.setBool(_kForceLoginOnceKey, true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      AppRoutes.fadeScale(const LoginScreen()),
    );

    if (mounted) setState(() => _saving = false);
  }

  void _select(String role) {
    if (_saving) return;
    HapticFeedback.selectionClick();
    setState(() => selectedRole = role);
  }

  // =========================
  // Premium UI helpers
  // =========================
  String get _continueLabel {
    if (selectedRole == null) return "اختر دورك للمتابعة";
    if (selectedRole == "rider") return "متابعة كـ راكب";
    return "متابعة كـ فني";
  }

  String get _subtitle {
    if (selectedRole == null)
      return "اختر الدور المناسب، ويمكنك تغييره لاحقًا.";
    if (selectedRole == "rider") return "وضع الراكب: اطلب خدمة بسرعة وراحة.";
    return "وضع الفني: استقبل الطلبات وابدأ العمل فورًا.";
  }

  IconData get _selectedIcon {
    if (selectedRole == "driver") return Icons.handyman_rounded;
    return Icons.person_rounded;
  }

  // --- Background ---
  Widget _background() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _bg0,
                _bg1,
                _bg2,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Blobs (✅ lime بدل amber/cyan)
        Positioned(
          top: -130,
          left: -90,
          child: _blurBlob(size: 280, color: _lime.withOpacity(.18)),
        ),
        Positioned(
          bottom: -160,
          right: -90,
          child: _blurBlob(size: 340, color: _lime2.withOpacity(.14)),
        ),
        Positioned(
          top: 140,
          right: -70,
          child: _blurBlob(size: 210, color: Colors.white.withOpacity(.10)),
        ),

        // Subtle vignette
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(.26),
              ],
              radius: 1.1,
              center: const Alignment(0, -0.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _blurBlob({required double size, required Color color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size),
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(.16)),
            boxShadow: [
              BoxShadow(
                blurRadius: 38,
                color: Colors.black.withOpacity(.30),
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _premiumHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(.10),
            border: Border.all(color: Colors.white.withOpacity(.16)),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                color: Colors.black.withOpacity(.18),
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(Icons.directions_car_filled,
              color: Colors.white.withOpacity(.95)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Doctor Car",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(.96),
                  letterSpacing: .2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "اختر وضع الاستخدام للبدء",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(.70),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.20),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(.14)),
          ),
          child: Text(
            "Step 1/2",
            style: TextStyle(
              color: Colors.white.withOpacity(.80),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        )
      ],
    );
  }

  Widget _roleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required List<String> bullets,
  }) {
    final bool isActive = selectedRole == role;
    final bool isPressed = _pressedRole == role;

    // ✅ lime بدل amber
    final Color borderColor =
        isActive ? _lime.withOpacity(.82) : Colors.white.withOpacity(.14);

    final Color bg = isActive
        ? Colors.white.withOpacity(.16)
        : Colors.white.withOpacity(.10);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedRole = role),
      onTapCancel: () => setState(() => _pressedRole = null),
      onTapUp: (_) => setState(() => _pressedRole = null),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _select(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: bg,
            border: Border.all(color: borderColor, width: isActive ? 1.6 : 1.0),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  blurRadius: 26,
                  color: _lime.withOpacity(.16),
                  offset: const Offset(0, 14),
                ),
            ],
          ),
          child: AnimatedScale(
            scale: isPressed ? .99 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Column(
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          // ✅ lime gradient بدل amber
                          colors: isActive
                              ? const [_lime, _lime2]
                              : [
                                  Colors.white.withOpacity(.14),
                                  Colors.white.withOpacity(.06),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color:
                            isActive ? const Color(0xFF07110B) : Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white.withOpacity(.96),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.22),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(.14),
                                  ),
                                ),
                                child: Text(
                                  badge,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.78),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: Colors.white.withOpacity(.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isActive
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        key: ValueKey(isActive),
                        color: isActive ? _lime2 : Colors.white38,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _bullets(bullets),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bullets(List<String> items) {
    return Column(
      children: items
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withOpacity(.78),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _selectionHint() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Container(
        key: ValueKey(selectedRole ?? "none"),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(.12)),
        ),
        child: Row(
          children: [
            Icon(_selectedIcon, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(.80),
                  fontSize: 12.8,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerNote() {
    return Row(
      children: [
        Icon(Icons.lock_outline,
            color: Colors.white.withOpacity(.55), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "بالاستمرار أنت توافق على الشروط وسياسة الخصوصية. ويمكن تغيير الدور لاحقًا.",
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.white.withOpacity(.60),
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                        child: _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _premiumHeader(),
                              const SizedBox(height: 18),
                              _roleCard(
                                role: "rider",
                                title: "راكب",
                                subtitle:
                                    "اطلب ميكانيكي أو خدمة طريق بسهولة وفي أسرع وقت.",
                                icon: Icons.person_rounded,
                                badge: "طلب سريع",
                                bullets: const [
                                  "طلب خدمة خلال ثوانٍ",
                                  "تتبع حالة الطلب لحظة بلحظة",
                                  "دعم فوري داخل التطبيق",
                                ],
                              ),
                              const SizedBox(height: 14),
                              _roleCard(
                                role: "driver",
                                title: "سائق / فني",
                                subtitle:
                                    "استقبل الطلبات، حدّد موقعك، وابدأ العمل فورًا.",
                                icon: Icons.handyman_rounded,
                                badge: "وضع العمل",
                                bullets: const [
                                  "استقبال الطلبات فورًا",
                                  "خرائط + موقع مباشر",
                                  "شات مع العميل بعد القبول",
                                ],
                              ),
                              const SizedBox(height: 14),
                              _selectionHint(),
                              const SizedBox(height: 12),
                              _footerNote(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom CTA
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.10),
                              border: Border.all(
                                  color: Colors.white.withOpacity(.14)),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: (selectedRole == null || _saving)
                                    ? null
                                    : _continue,
                                style: ElevatedButton.styleFrom(
                                  // ✅ lime بدل amber
                                  backgroundColor: _lime,
                                  disabledBackgroundColor:
                                      Colors.white.withOpacity(.20),
                                  foregroundColor: const Color(0xFF07110B),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: _saving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.3,
                                          color: Color(0xFF07110B),
                                        ),
                                      )
                                    : Text(
                                        _continueLabel,
                                        style: const TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w900,
                                        ),
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
            ),
          ),
        ],
      ),
    );
  }
}
