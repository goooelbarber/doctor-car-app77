// lib/screens/role_selection_screen.dart
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
    with TickerProviderStateMixin {
  static const String _kIsLoggedInKey = 'isLoggedIn';
  static const String _kTokenKey = 'token';
  static const String _kUserIdKey = 'userId';
  static const String _kSelectedRoleKey = 'selectedRole';
  static const String _kForceLoginOnceKey = 'forceLoginOnce';

  static const Color _bgStart = Color(0xFF090B12);
  static const Color _bgMid = Color(0xFF07111A);
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
  static const Color _lime = Color.fromARGB(255, 25, 180, 232);
  static const Color _success = Color(0xFF7DD3AE);

  String? selectedRole;
  bool _saving = false;

  late final AnimationController _pageController;
  late final AnimationController _backgroundController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _bgEnd,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat();

    _fade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );

    _scale = Tween<double>(begin: .985, end: 1).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOutBack),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, .025),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
    );

    _loadSavedRole();
  }

  Future<void> _loadSavedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(_kSelectedRoleKey);
      if (!mounted) return;
      if (role != null && role.isNotEmpty) {
        setState(() => selectedRole = role);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    if (_saving) return;
    HapticFeedback.selectionClick();
    setState(() => selectedRole = role);
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

  String get _selectionTitle {
    switch (selectedRole) {
      case 'rider':
        return 'تم اختيار وضع العميل';
      case 'driver':
        return 'تم اختيار وضع الفني';
      default:
        return 'اختر الدور المناسب';
    }
  }

  String get _selectionDescription {
    switch (selectedRole) {
      case 'rider':
        return 'واجهة أسهل وأوضح لطلب الخدمة ومتابعة الحالة بسرعة.';
      case 'driver':
        return 'واجهة عملية للفني لاستقبال الطلبات وإدارة المهام بكفاءة.';
      default:
        return 'اختر الدور المناسب الآن ويمكنك تغييره لاحقًا من داخل التطبيق.';
    }
  }

  IconData get _selectionIcon {
    switch (selectedRole) {
      case 'rider':
        return Icons.person_outline_rounded;
      case 'driver':
        return Icons.handyman_rounded;
      default:
        return Icons.tune_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = selectedRole != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _backgroundController,
          builder: (_, __) {
            return Stack(
              children: [
                _buildBackground(),
                SafeArea(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _offset,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(20, 18, 20, 10),
                                child: Column(
                                  children: [
                                    _buildTopBar(),
                                    const SizedBox(height: 22),
                                    _buildHeroPanel(),
                                    const SizedBox(height: 18),
                                    _buildCustomerSpotlightCard(),
                                    const SizedBox(height: 14),
                                    _buildTechnicianCompactCard(),
                                    const SizedBox(height: 16),
                                    _buildSelectionInfo(),
                                    const SizedBox(height: 12),
                                    _buildHintText(),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                              child: _buildBottomButton(canContinue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_bgStart, _bgMid, _bgEnd],
                stops: [0.0, 0.44, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _glowBlob(
            320,
            const [
              Color(0x552181C2),
              Color(0x0008578F),
            ],
          ),
        ),
        Positioned(
          top: 240,
          left: -70,
          child: _glowBlob(
            230,
            const [
              Color(0x2208B4E8),
              Color(0x0008B4E8),
            ],
          ),
        ),
        Positioned(
          bottom: -100,
          right: -40,
          child: _glowBlob(
            230,
            const [
              Color(0x2219B4E8),
              Color(0x0019B4E8),
            ],
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _RoleBackgroundPainter(
              progress: _backgroundController.value,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, .82),
                radius: 1.22,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(.10),
                  Colors.black.withOpacity(.22),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glowBlob(double size, List<Color> colors) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doctor Car',
                style: TextStyle(
                  color: _text,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'اختر الدور المناسب للبدء',
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_accentDark, _accent],
            ),
            boxShadow: [
              BoxShadow(
                color: _accentGlow.withOpacity(.22),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(.10),
            ),
          ),
          child: const Icon(
            Icons.directions_car_filled_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            _panelTop.withOpacity(.14),
            _panel.withOpacity(.90),
            const Color(0xFF0F1720),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: _accentGlow.withOpacity(.08),
            blurRadius: 28,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _accentGlow.withOpacity(.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: _accentGlow.withOpacity(.22),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: _accentGlow,
                ),
                SizedBox(width: 6),
                Text(
                  'واجهة احترافية',
                  style: TextStyle(
                    color: _accentGlow,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'اختر طريقة استخدام التطبيق',
            style: TextStyle(
              color: _text,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تم تركيز التصميم على العميل بشكل أوضح، مع أيقونة هندسية مختلفة تمامًا عن الفني وشكل أنظف وأكثر احترافية.',
            style: TextStyle(
              color: _muted.withOpacity(.96),
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSpotlightCard() {
    final bool active = selectedRole == 'rider';

    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: () => _selectRole('rider'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: active
                ? const [
                    Color(0xFF143956),
                    Color(0xFF112E46),
                    Color(0xFF0C2131),
                  ]
                : const [
                    Color(0xFF121E27),
                    Color(0xFF101821),
                    Color(0xFF0B1218),
                  ],
          ),
          border: Border.all(
            color: active
                ? _accentGlow.withOpacity(.52)
                : Colors.white.withOpacity(.08),
            width: active ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: active
                  ? _accentGlow.withOpacity(.20)
                  : Colors.black.withOpacity(.16),
              blurRadius: active ? 30 : 18,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 410;

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CustomerPremiumIcon(active: active),
                      const Spacer(),
                      _buildSelector(active, highlight: _accentGlow),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'العميل',
                    style: TextStyle(
                      color: _text,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لطلب الخدمة ومتابعة الحالة بسهولة، بتجربة مرنة وسريعة وواضحة من أول استخدام.',
                    style: TextStyle(
                      color: _muted.withOpacity(.96),
                      fontSize: 14,
                      height: 1.7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _FeatureChip(
                        label: 'طلب سريع',
                        color: _accentGlow,
                      ),
                      _FeatureChip(
                        label: 'متابعة الحالة',
                        color: _accentSoft,
                      ),
                      _FeatureChip(
                        label: 'واجهة أوضح',
                        color: _accentGlow,
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'العميل',
                        style: TextStyle(
                          color: _text,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'لطلب الخدمة ومتابعة الحالة بسهولة، بتجربة مرنة وسريعة وواضحة من أول استخدام.',
                        style: TextStyle(
                          color: _muted.withOpacity(.96),
                          fontSize: 14,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _FeatureChip(
                            label: 'طلب سريع',
                            color: _accentGlow,
                          ),
                          _FeatureChip(
                            label: 'متابعة الحالة',
                            color: _accentSoft,
                          ),
                          _FeatureChip(
                            label: 'واجهة أوضح',
                            color: _accentGlow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Row(
                      children: [
                        _buildSelector(active, highlight: _accentGlow),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _CustomerPremiumIcon(active: active),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTechnicianCompactCard() {
    final bool active = selectedRole == 'driver';

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => _selectRole('driver'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: active
                ? const [
                    Color(0xFF18242C),
                    Color(0xFF131D24),
                    Color(0xFF0D141A),
                  ]
                : const [
                    Color(0xFF141C23),
                    Color(0xFF10161C),
                    Color(0xFF0B1015),
                  ],
          ),
          border: Border.all(
            color:
                active ? _lime.withOpacity(.42) : Colors.white.withOpacity(.08),
            width: active ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: active
                  ? _lime.withOpacity(.10)
                  : Colors.black.withOpacity(.14),
              blurRadius: active ? 24 : 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            _TechnicianMinimalIcon(active: active),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'الفني',
                          style: TextStyle(
                            color: _text,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _buildSelector(active, highlight: _lime),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لاستقبال الطلبات وإدارة المهام والتنقل بين الحالات بكفاءة داخل التطبيق.',
                    style: TextStyle(
                      color: _muted.withOpacity(.95),
                      fontSize: 13.3,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _FeatureChip(
                        label: 'استقبال الطلبات',
                        color: _lime,
                      ),
                      _FeatureChip(
                        label: 'إدارة المهام',
                        color: _accentSoft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector(bool active, {required Color highlight}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? highlight.withOpacity(.18) : Colors.transparent,
        border: Border.all(
          color: active ? highlight : Colors.white.withOpacity(.28),
          width: 1.4,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: highlight.withOpacity(.18),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Icon(
        active ? Icons.check_rounded : Icons.add_rounded,
        size: 18,
        color: active ? Colors.white : _muted,
      ),
    );
  }

  Widget _buildSelectionInfo() {
    final bool hasSelection = selectedRole != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(.05),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: hasSelection
                  ? _accentGlow.withOpacity(.10)
                  : Colors.white.withOpacity(.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasSelection
                    ? _accentGlow.withOpacity(.20)
                    : Colors.white.withOpacity(.08),
              ),
            ),
            child: Icon(
              _selectionIcon,
              color: hasSelection ? _accentGlow : _hint,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectionTitle,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectionDescription,
                  style: TextStyle(
                    color: _muted.withOpacity(.96),
                    fontSize: 12.8,
                    height: 1.5,
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
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _success.withOpacity(.28),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
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

  Widget _buildHintText() {
    return Text(
      'يمكنك تغيير وضع الاستخدام لاحقًا من داخل التطبيق.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _hint.withOpacity(.95),
        fontSize: 12.6,
        height: 1.6,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildBottomButton(bool canContinue) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(.05),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: canContinue
                  ? const [_accent, _accentDark]
                  : [
                      Colors.white.withOpacity(.12),
                      Colors.white.withOpacity(.08),
                    ],
            ),
            boxShadow: canContinue
                ? [
                    BoxShadow(
                      color: _accentGlow.withOpacity(.18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton(
            onPressed: canContinue && !_saving ? _continue : null,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: _muted,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'تأكيد الاختيار',
                        style: TextStyle(
                          fontSize: 16.8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withOpacity(.10),
        border: Border.all(
          color: color.withOpacity(.20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CustomerPremiumIcon extends StatefulWidget {
  const _CustomerPremiumIcon({required this.active});

  final bool active;

  @override
  State<_CustomerPremiumIcon> createState() => _CustomerPremiumIconState();
}

class _CustomerPremiumIconState extends State<_CustomerPremiumIcon>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulse = Tween<double>(begin: .98, end: 1.045).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color glow = widget.active ? const Color(0xFF8FD3FF) : Colors.white24;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (_, __) {
        return Transform.scale(
          scale: widget.active ? _pulse.value : 1,
          child: SizedBox(
            width: 126,
            height: 126,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 126,
                  height: 126,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    gradient: RadialGradient(
                      colors: [
                        glow.withOpacity(widget.active ? .26 : .08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: _rotateController.value * math.pi * 2,
                  child: SizedBox(
                    width: 118,
                    height: 118,
                    child: CustomPaint(
                      painter: _SquareOrbitPainter(
                        color: glow.withOpacity(widget.active ? .84 : .22),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 98,
                  height: 98,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.active
                          ? const [
                              Color(0xFF184565),
                              Color(0xFF11344D),
                              Color(0xFF0B2537),
                            ]
                          : [
                              Colors.white.withOpacity(.10),
                              Colors.white.withOpacity(.05),
                            ],
                    ),
                    border: Border.all(
                      color: widget.active
                          ? const Color(0x888FD3FF)
                          : Colors.white.withOpacity(.10),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: glow.withOpacity(widget.active ? .22 : .08),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 11,
                        left: 14,
                        right: 14,
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(.25),
                                Colors.white.withOpacity(.03),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white.withOpacity(.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(.05),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            color: widget.active
                                ? const Color(0xFF8FD3FF)
                                : Colors.white.withOpacity(.95),
                            size: 30,
                          ),
                          const SizedBox(height: 3),
                          Container(
                            width: 26,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              color: widget.active
                                  ? const Color(0xFF8FD3FF).withOpacity(.85)
                                  : Colors.white.withOpacity(.75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child:
                      _tinyDot(glow.withOpacity(widget.active ? .95 : .20), 8),
                ),
                Positioned(
                  bottom: 20,
                  left: 18,
                  child:
                      _tinyDot(glow.withOpacity(widget.active ? .72 : .16), 6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tinyDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.45),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _TechnicianMinimalIcon extends StatefulWidget {
  const _TechnicianMinimalIcon({required this.active});

  final bool active;

  @override
  State<_TechnicianMinimalIcon> createState() => _TechnicianMinimalIconState();
}

class _TechnicianMinimalIconState extends State<_TechnicianMinimalIcon>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: .99, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color core = widget.active ? const Color(0xFF25B4E8) : Colors.white70;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        return Transform.scale(
          scale: widget.active ? _pulse.value : 1,
          child: SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        core.withOpacity(widget.active ? .18 : .05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.active
                          ? const Color(0x5525B4E8)
                          : Colors.white.withOpacity(.10),
                      width: 1.2,
                    ),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: widget.active
                          ? const [
                              Color(0x3325B4E8),
                              Color(0x1225B4E8),
                            ]
                          : [
                              Colors.white.withOpacity(.08),
                              Colors.white.withOpacity(.03),
                            ],
                    ),
                    border: Border.all(
                      color: widget.active
                          ? const Color(0x6625B4E8)
                          : Colors.white.withOpacity(.10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: core.withOpacity(.16),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.handyman_rounded,
                    color: widget.active ? core : Colors.white.withOpacity(.94),
                    size: 23,
                  ),
                ),
                Positioned(
                  top: 9,
                  child: _dot(core.withOpacity(widget.active ? .90 : .20)),
                ),
                Positioned(
                  left: 9,
                  child: _dot(core.withOpacity(widget.active ? .70 : .16)),
                ),
                Positioned(
                  right: 9,
                  child: _dot(core.withOpacity(widget.active ? .70 : .16)),
                ),
                Positioned(
                  bottom: 9,
                  child: _dot(core.withOpacity(widget.active ? .55 : .14)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6.5,
      height: 6.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _SquareOrbitPainter extends CustomPainter {
  const _SquareOrbitPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      const Radius.circular(26),
    );

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color;

    final Path path = Path()..addRRect(rect);
    final metric = path.computeMetrics().first;
    final double length = metric.length;

    void drawSeg(double start, double sweep) {
      final Path extract =
          metric.extractPath(start * length, (start + sweep) * length);
      canvas.drawPath(extract, paint);
    }

    drawSeg(0.04, 0.12);
    drawSeg(0.29, 0.08);
    drawSeg(0.56, 0.10);
    drawSeg(0.82, 0.07);

    final Paint dotPaint = Paint()..color = color;
    canvas.drawCircle(
        Offset(size.width * .82, size.height * .32), 2.0, dotPaint);
    canvas.drawCircle(
      Offset(size.width * .22, size.height * .74),
      1.7,
      dotPaint..color = color.withOpacity(.65),
    );
  }

  @override
  bool shouldRepaint(covariant _SquareOrbitPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RoleBackgroundPainter extends CustomPainter {
  const _RoleBackgroundPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint softLine = Paint()
      ..color = Colors.white.withOpacity(.023)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;

    final Paint brightLine = Paint()
      ..color = const Color(0xFF8FD3FF).withOpacity(.055)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    final double shift = progress * 120;

    for (double x = -size.width; x < size.width * 2; x += 92) {
      canvas.drawLine(
        Offset(x - shift, -50),
        Offset(x + size.height * .52 - shift, size.height + 60),
        softLine,
      );
    }

    for (double x = -size.width + 30; x < size.width * 2; x += 180) {
      canvas.drawLine(
        Offset(x - shift * .65, -60),
        Offset(x + size.height * .52 - shift * .65, size.height + 80),
        brightLine,
      );
    }

    final Paint wave = Paint()
      ..color = const Color(0xFF8FD3FF).withOpacity(.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final Path topWave = Path()
      ..moveTo(0, size.height * .14)
      ..quadraticBezierTo(
        size.width * .24,
        size.height * .06,
        size.width * .52,
        size.height * .14,
      )
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .22,
        size.width,
        size.height * .12,
      );

    final Path bottomWave = Path()
      ..moveTo(0, size.height * .84)
      ..quadraticBezierTo(
        size.width * .18,
        size.height * .80,
        size.width * .38,
        size.height * .88,
      )
      ..quadraticBezierTo(
        size.width * .72,
        size.height * .97,
        size.width,
        size.height * .90,
      );

    canvas.drawPath(topWave, wave);
    canvas.drawPath(bottomWave, wave);

    final Paint dotPaint = Paint()
      ..color = const Color(0xFF8FD3FF).withOpacity(.08);

    for (double x = 18; x < size.width; x += 58) {
      canvas.drawCircle(Offset(x, size.height * .22), 1.3, dotPaint);
    }

    for (double x = 10; x < size.width; x += 62) {
      canvas.drawCircle(Offset(x, size.height * .72), 1.2, dotPaint);
    }

    final Paint ringPaint = Paint()
      ..color = const Color(0xFF8FD3FF).withOpacity(.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(
      Offset(size.width * .84, size.height * .18),
      34,
      ringPaint,
    );
    canvas.drawCircle(
      Offset(size.width * .16, size.height * .60),
      26,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoleBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
