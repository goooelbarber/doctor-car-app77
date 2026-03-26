// PATH: lib/screens/role_selection_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_routes.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  static const String _kIsLoggedInKey = 'isLoggedIn';
  static const String _kTokenKey = 'token';
  static const String _kUserIdKey = 'userId';
  static const String _kSelectedRoleKey = 'selectedRole';
  static const String _kForceLoginOnceKey = 'forceLoginOnce';

  // =========================
  // Premium Dark Automotive Theme
  // =========================
  static const Color _bgTop = Color(0xFF06162E);
  static const Color _bgMid = Color(0xFF0A2245);
  static const Color _bgBottom = Color(0xFF030A16);

  static const Color _primaryBlue = Color(0xFF1B4F9C);
  static const Color _primaryBlue2 = Color(0xFF143F7C);
  static const Color _primaryBlue3 = Color(0xFF2D66BD);
  static const Color _cyanGlow = Color(0xFF5EA9FF);
  static const Color _electric = Color(0xFF79C3FF);

  static const Color _white = Color(0xFFF7F9FC);
  static const Color _muted = Color(0xFFC9D6EA);
  static const Color _muted2 = Color(0xFF90A8CB);
  static const Color _success = Color(0xFF74D2A7);

  String? selectedRole;
  bool _saving = false;
  String? _pressedRole;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slide = Tween<double>(begin: 22, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scale = Tween<double>(begin: .975, end: 1).animate(
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

    final oldRole = prefs.getString(_kSelectedRoleKey);
    final wasLoggedIn = prefs.getBool(_kIsLoggedInKey) ?? false;

    if (wasLoggedIn && oldRole != null && oldRole != selectedRole) {
      await prefs.setBool(_kIsLoggedInKey, false);
      await prefs.remove(_kTokenKey);
      await prefs.remove(_kUserIdKey);
    }

    await prefs.setString(_kSelectedRoleKey, selectedRole!);
    await prefs.setBool(_kForceLoginOnceKey, true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      AppRoutes.fadeScale(const LoginScreen()),
    );

    if (mounted) {
      setState(() => _saving = false);
    }
  }

  void _select(String role) {
    if (_saving) return;
    HapticFeedback.selectionClick();
    setState(() => selectedRole = role);
  }

  String get _selectedDescription {
    switch (selectedRole) {
      case 'driver':
        return 'وضع الفني يتيح لك استقبال الطلبات، إدارة الحالات، ومتابعة العمل باحترافية.';
      case 'rider':
        return 'وضع العميل يمنحك تجربة سريعة وسلسة لطلب الخدمة ومتابعتها خطوة بخطوة.';
      default:
        return 'اختر الوضع المناسب لطريقة استخدامك للتطبيق لتجربة أكثر دقة وراحة.';
    }
  }

  IconData get _selectedIcon {
    switch (selectedRole) {
      case 'driver':
        return Icons.build_circle_outlined;
      case 'rider':
        return Icons.route_rounded;
      default:
        return Icons.tune_rounded;
    }
  }

  String get _selectedTitle {
    switch (selectedRole) {
      case 'driver':
        return 'تم اختيار وضع الفني';
      case 'rider':
        return 'تم اختيار وضع العميل';
      default:
        return 'لم يتم اختيار وضع بعد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return Opacity(
                    opacity: _fade.value,
                    child: Transform.translate(
                      offset: Offset(0, _slide.value),
                      child: Transform.scale(
                        scale: _scale.value,
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(18, 18, 18, 8),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 2),
                                    _buildLogoSection(),
                                    const SizedBox(height: 30),
                                    _buildTitleSection(),
                                    const SizedBox(height: 26),
                                    _buildMainRoleCard(),
                                    const SizedBox(height: 18),
                                    _buildSecondaryRoleCard(),
                                    const SizedBox(height: 22),
                                    _buildSelectionInfo(),
                                    const SizedBox(height: 18),
                                    _buildDividerText(),
                                    const SizedBox(height: 16),
                                    _buildTermsText(),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                              child: _buildBottomButton(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgTop, _bgMid, _bgBottom],
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -30,
          child: _glowBlob(260, _primaryBlue.withOpacity(.18)),
        ),
        Positioned(
          top: 90,
          right: -60,
          child: _glowBlob(220, _cyanGlow.withOpacity(.08)),
        ),
        Positioned(
          bottom: -70,
          left: -50,
          child: _glowBlob(240, _primaryBlue2.withOpacity(.16)),
        ),
        Positioned(
          bottom: 90,
          right: -40,
          child: _glowBlob(180, _primaryBlue3.withOpacity(.12)),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _BackgroundPainter(),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.82),
                radius: 1.22,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(.16),
                  Colors.black.withOpacity(.34),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glowBlob(double size, Color color) {
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 72, sigmaY: 72),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFEAF1FB),
                Color(0xFFBDD2F0),
              ],
            ).createShader(bounds);
          },
          child: const Text(
            "DOCTOR\nCAR",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              height: .92,
              fontSize: 31,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.25,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 72,
          height: 4.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: const LinearGradient(
              colors: [_primaryBlue3, Colors.white, _primaryBlue3],
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryBlue.withOpacity(.30),
                blurRadius: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        const Text(
          'اختر وضع الاستخدام المناسب',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Color(0x55284A84),
                blurRadius: 14,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'واجهة مصممة لتمنحك أفضل تجربة حسب دورك داخل التطبيق',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _muted.withOpacity(.88),
            fontSize: 13.6,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildMainRoleCard() {
    final bool active = selectedRole == "rider";
    final bool pressed = _pressedRole == "rider";

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedRole = "rider"),
      onTapCancel: () => setState(() => _pressedRole = null),
      onTapUp: (_) => setState(() => _pressedRole = null),
      child: AnimatedScale(
        scale: pressed ? .985 : 1,
        duration: const Duration(milliseconds: 120),
        child: InkWell(
          borderRadius: BorderRadius.circular(34),
          onTap: () => _select("rider"),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: active
                    ? const [
                        Color(0xFF1E549F),
                        Color(0xFF174281),
                        Color(0xFF0D2A58),
                      ]
                    : const [
                        Color(0xFF173E79),
                        Color(0xFF123564),
                        Color(0xFF0B2447),
                      ],
              ),
              border: Border.all(
                color: active
                    ? Colors.white.withOpacity(.22)
                    : Colors.white.withOpacity(.10),
                width: active ? 1.45 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(active ? .26 : .15),
                  blurRadius: active ? 28 : 18,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(34),
                      child: CustomPaint(
                        painter: _RiderCardPainter(active: active),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child:
                        _SelectionBadge(active: active, key: ValueKey(active)),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 8,
                  child: _GlassArrowCircle(
                    glow: active ? .24 : .14,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 28),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 54,
                                        height: 54,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(.22),
                                              Colors.white.withOpacity(.08),
                                            ],
                                          ),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(.18),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _cyanGlow.withOpacity(
                                                active ? .22 : .10,
                                              ),
                                              blurRadius: 18,
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white
                                                    .withOpacity(.08),
                                              ),
                                            ),
                                            Icon(
                                              Icons.route_rounded,
                                              color:
                                                  Colors.white.withOpacity(.96),
                                              size: 26,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          "العميل",
                                          style: TextStyle(
                                            color: _white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "الاختيار المثالي لطلب الخدمة بسرعة، متابعة الحالة بسهولة، والوصول لتجربة أكثر سلاسة ووضوحًا.",
                              style: TextStyle(
                                color: _white.withOpacity(.88),
                                fontSize: 13.4,
                                height: 1.42,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _MiniPill(
                                  icon: Icons.flash_on_rounded,
                                  text: "طلب سريع",
                                ),
                                _MiniPill(
                                  icon: Icons.my_location_rounded,
                                  text: "متابعة فورية",
                                ),
                                _MiniPill(
                                  icon: Icons.verified_user_outlined,
                                  text: "تجربة واضحة",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryRoleCard() {
    final bool active = selectedRole == "driver";
    final bool pressed = _pressedRole == "driver";

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedRole = "driver"),
      onTapCancel: () => setState(() => _pressedRole = null),
      onTapUp: (_) => setState(() => _pressedRole = null),
      child: AnimatedScale(
        scale: pressed ? .99 : 1,
        duration: const Duration(milliseconds: 120),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _select("driver"),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: active
                    ? const [
                        Color(0xFF1A4B8D),
                        Color(0xFF12386E),
                        Color(0xFF0B2446),
                      ]
                    : const [
                        Color(0xFF143764),
                        Color(0xFF0D294D),
                        Color(0xFF081D38),
                      ],
              ),
              border: Border.all(
                color: active
                    ? Colors.white.withOpacity(.19)
                    : Colors.white.withOpacity(.10),
                width: active ? 1.25 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue2.withOpacity(active ? .24 : .14),
                  blurRadius: active ? 22 : 14,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CustomPaint(
                        painter: _DriverCardPainter(active: active),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _HexIconBox(active: active),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "الفني",
                                  style: TextStyle(
                                    color: _white.withOpacity(.98),
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: _SelectionBadge(
                                  active: active,
                                  compact: true,
                                  key: ValueKey(active),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "مناسب لإدارة الطلبات، استقبال المهام، والعمل بكفاءة داخل التطبيق.",
                            style: TextStyle(
                              color: _white.withOpacity(.84),
                              fontSize: 12.8,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _GlassArrowCircle(
                      size: 42,
                      iconSize: 22,
                      glow: active ? .22 : .10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionInfo() {
    final bool hasSelection = selectedRole != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasSelection
              ? _primaryBlue.withOpacity(.26)
              : Colors.white.withOpacity(.08),
        ),
        boxShadow: hasSelection
            ? [
                BoxShadow(
                  color: _primaryBlue.withOpacity(.10),
                  blurRadius: 20,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(.12),
                  Colors.white.withOpacity(.05),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(.10)),
            ),
            child: Icon(
              _selectedIcon,
              color: hasSelection ? _electric : _muted2,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTitle,
                  style: TextStyle(
                    color: _white.withOpacity(.96),
                    fontSize: 13.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedDescription,
                  style: TextStyle(
                    color: _white.withOpacity(.84),
                    fontSize: 12.6,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (hasSelection)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _success.withOpacity(.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: _success.withOpacity(.26),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 15,
                    color: _success,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'جاهز',
                    style: TextStyle(
                      color: _success,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDividerText() {
    return Column(
      children: [
        Text(
          'يمكنك تغيير وضع الاستخدام لاحقًا من داخل التطبيق',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _white.withOpacity(.88),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 180,
          height: 1.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _softLine.withOpacity(.75),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lock_rounded,
          color: _muted2.withOpacity(.90),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'بالاستمرار، أنت توافق على الشروط وسياسة الخصوصية، ويمكنك تعديل الدور لاحقًا بدون تعقيد.',
            style: TextStyle(
              color: _muted2.withOpacity(.90),
              fontSize: 11.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    final bool enabled = selectedRole != null;
    final bool rider = selectedRole == "rider";

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(.08),
            ),
          ),
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: enabled
                      ? rider
                          ? const [
                              Color(0xFF143F7C),
                              Color(0xFF1A4E95),
                              Color(0xFF10386B),
                            ]
                          : const [
                              Color(0xFF1B4F99),
                              Color(0xFF275FB1),
                              Color(0xFF153F78),
                            ]
                      : [
                          Colors.white.withOpacity(.12),
                          Colors.white.withOpacity(.08),
                        ],
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: _primaryBlue.withOpacity(.30),
                          blurRadius: 24,
                          offset: const Offset(0, 14),
                        ),
                      ]
                    : [],
              ),
              child: ElevatedButton(
                onPressed: enabled && !_saving ? _continue : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: _white.withOpacity(.55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'تأكيد الاختيار',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.2,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white.withOpacity(.95),
                            size: 22,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const Color _softLine = Color(0xFF86A8DB);

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withOpacity(.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white.withOpacity(.92),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(.92),
              fontSize: 11.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassArrowCircle extends StatelessWidget {
  final double size;
  final double iconSize;
  final double glow;

  const _GlassArrowCircle({
    this.size = 44,
    this.iconSize = 24,
    this.glow = .18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(.18),
            Colors.white.withOpacity(.06),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(.14),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5EA9FF).withOpacity(glow),
            blurRadius: 14,
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white.withOpacity(.94),
        size: iconSize,
      ),
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  final bool active;
  final bool compact;

  const _SelectionBadge({
    super.key,
    required this.active,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF7BD0A7).withOpacity(.12)
            : Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: active
              ? const Color(0xFF7BD0A7).withOpacity(.28)
              : Colors.white.withOpacity(.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: compact ? 16 : 17,
            color: active
                ? const Color(0xFF7BD0A7)
                : Colors.white.withOpacity(.72),
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'محدد' : 'اختر',
            style: TextStyle(
              color: active
                  ? const Color(0xFF95E1BC)
                  : Colors.white.withOpacity(.84),
              fontSize: compact ? 11.2 : 11.6,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HexIconBox extends StatelessWidget {
  final bool active;

  const _HexIconBox({
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HexagonClipper(),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: active
                ? [
                    Colors.white.withOpacity(.22),
                    Colors.white.withOpacity(.08),
                  ]
                : [
                    Colors.white.withOpacity(.14),
                    Colors.white.withOpacity(.05),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4D9BFF).withOpacity(active ? .18 : .08),
              blurRadius: 14,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _InnerHexPainter(),
              ),
            ),
            Icon(
              Icons.build_rounded,
              color: Colors.white.withOpacity(.95),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderCardPainter extends CustomPainter {
  final bool active;

  const _RiderCardPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 2.2 : 1.8
      ..color = Colors.white.withOpacity(active ? .20 : .12);

    final path = Path()
      ..moveTo(size.width * .62, size.height * .24)
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .18,
        size.width * .85,
        size.height * .34,
      )
      ..quadraticBezierTo(
        size.width * .92,
        size.height * .52,
        size.width * .76,
        size.height * .67,
      )
      ..quadraticBezierTo(
        size.width * .64,
        size.height * .78,
        size.width * .88,
        size.height * .88,
      );

    canvas.drawPath(path, routePaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF91C8FF).withOpacity(active ? .34 : .20);

    canvas.drawCircle(
      Offset(size.width * .62, size.height * .24),
      4.5,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * .88, size.height * .88),
      5.3,
      dotPaint,
    );

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(.08);

    canvas.drawCircle(
      Offset(size.width * .82, size.height * .26),
      38,
      ringPaint,
    );
    canvas.drawCircle(
      Offset(size.width * .86, size.height * .72),
      24,
      ringPaint,
    );

    final shimmer = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white.withOpacity(.09),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(size.width * .48, 0, size.width * .52, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(size.width * .52, 0, size.width * .48, size.height),
      shimmer,
    );
  }

  @override
  bool shouldRepaint(covariant _RiderCardPainter oldDelegate) {
    return oldDelegate.active != active;
  }
}

class _DriverCardPainter extends CustomPainter {
  final bool active;

  const _DriverCardPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withOpacity(active ? .12 : .08)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..color = const Color(0xFF8DBBFF).withOpacity(active ? .08 : .05)
      ..style = PaintingStyle.fill;

    final hex1 = _hexPath(
      center: Offset(size.width * .80, size.height * .34),
      radius: 24,
    );
    final hex2 = _hexPath(
      center: Offset(size.width * .92, size.height * .68),
      radius: 18,
    );

    canvas.drawPath(hex1, fill);
    canvas.drawPath(hex1, line);
    canvas.drawPath(hex2, fill);
    canvas.drawPath(hex2, line);

    final connector = Paint()
      ..color = Colors.white.withOpacity(.09)
      ..strokeWidth = 1.2;

    canvas.drawLine(
      Offset(size.width * .83, size.height * .48),
      Offset(size.width * .89, size.height * .58),
      connector,
    );

    final diag = Paint()
      ..color = Colors.white.withOpacity(.05)
      ..strokeWidth = 1;

    for (double x = size.width * .56; x < size.width; x += 18) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - 28, size.height),
        diag,
      );
    }
  }

  Path _hexPath({
    required Offset center,
    required double radius,
  }) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3 * i) - math.pi / 6;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _DriverCardPainter oldDelegate) {
    return oldDelegate.active != active;
  }
}

class _InnerHexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(.08);

    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * .25, 0);
    path.lineTo(w * .75, 0);
    path.lineTo(w, h * .5);
    path.lineTo(w * .75, h);
    path.lineTo(w * .25, h);
    path.lineTo(0, h * .5);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF5D7FB3).withOpacity(.18);

    final center = Offset(size.width / 2, size.height * .47);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * .56),
      math.pi,
      math.pi,
      false,
      arcPaint,
    );

    final arcPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = Colors.white.withOpacity(.05);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * .64),
      math.pi,
      math.pi,
      false,
      arcPaint2,
    );

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(.020)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 44) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    for (double x = 0; x < size.width; x += 42) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint..color = Colors.white.withOpacity(.012),
      );
    }

    final dotPaint = Paint()..color = const Color(0xFFAFC3E2).withOpacity(.09);

    for (int i = 0; i < 16; i++) {
      final dx = (size.width / 15) * i + (i.isEven ? 8 : -4);
      final dy = 90 + (i % 5) * 88.0;
      canvas.drawCircle(Offset(dx, dy), 1.45, dotPaint);
    }

    final diagonalPaint = Paint()
      ..color = Colors.white.withOpacity(.015)
      ..strokeWidth = 1;

    for (double x = -size.width; x < size.width * 1.5; x += 48) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 130, size.height),
        diagonalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
