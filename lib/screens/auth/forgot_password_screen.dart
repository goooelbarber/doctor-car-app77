import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // =========================
  // COLORS - Baby Blue Theme
  // =========================
  static const Color _bgStart = Color(0xFF090B12);
  static const Color _bgEnd = Color(0xFF05070D);

  static const Color _panel = Color(0xFF1A252D);
  static const Color _accent = Color(0xFF7CCBFF);
  static const Color _accentSoft = Color(0xFFCFEFFF);
  static const Color _accentDark = Color(0xFF5BB8F6);
  static const Color _accentGlow = Color(0xFF9AD9FF);

  static const Color _text = Color(0xFFF4F6F8);
  static const Color _muted = Color(0xFFD0D5D9);
  static const Color _hint = Color(0xFF93A1A8);
  static const Color _line = Color(0xFFDCE4E8);
  static const Color _successBg = Color(0xFF1B2730);

  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  bool _isLoading = false;

  late final AnimationController _iconCtrl;
  late final Animation<double> _iconScale;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();

    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _iconScale = CurvedAnimation(
      parent: _iconCtrl,
      curve: Curves.easeOutBack,
    );

    _fadeIn = CurvedAnimation(
      parent: _iconCtrl,
      curve: Curves.easeOutCubic,
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, .03),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _iconCtrl,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

  Future<void> _submit() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage("يرجى إدخال البريد الإلكتروني");
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage("يرجى إدخال بريد إلكتروني صحيح");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.forgotPassword(email);

      if (!mounted) return;
      _showSuccessDialog(email);
    } catch (_) {
      _showMessage("حدث خطأ، حاول مرة أخرى");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _successBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          title: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accentSoft, _accent, _accentDark],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(.14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(.30),
                      blurRadius: 22,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: Colors.black,
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "تم الإرسال بنجاح",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            "تم إرسال رابط إعادة تعيين كلمة المرور إلى:\n$email\n\nيرجى التحقق من بريدك الإلكتروني.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 14.2,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [_accentSoft, _accent, _accentDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: Text(
                        "حسنًا",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 500;

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
                        vertical: 18,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: _glass(),
                              child: Column(
                                children: [
                                  _topBar(),
                                  const SizedBox(height: 12),
                                  ScaleTransition(
                                    scale: _iconScale,
                                    child: Container(
                                      width: 100,
                                      height: 100,
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
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _accent.withOpacity(.28),
                                            blurRadius: 28,
                                            spreadRadius: 2,
                                          ),
                                          BoxShadow(
                                            color: _accentGlow.withOpacity(.10),
                                            blurRadius: 50,
                                            spreadRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.lock_reset_rounded,
                                        color: Colors.black,
                                        size: 42,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    "نسيت كلمة المرور؟",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: _text,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "لا تقلق، أدخل بريدك الإلكتروني\nوسنرسل لك رابط إعادة التعيين",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _emailField(),
                                  const SizedBox(height: 24),
                                  _submitButton(),
                                  const SizedBox(height: 14),
                                  TextButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      size: 18,
                                      color: _muted,
                                    ),
                                    label: const Text(
                                      "العودة لتسجيل الدخول",
                                      style: TextStyle(
                                        color: _muted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "تأكد من كتابة البريد الإلكتروني المرتبط بحسابك",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.45),
                                      fontSize: isWide ? 12.5 : 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }

  // ================= UI =================

  Widget _topBar() {
    return Row(
      children: [
        IconButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white.withOpacity(.08)),
            ),
          ),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _text,
            size: 18,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: const Text(
            "استعادة الحساب",
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
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
          top: 110,
          right: -35,
          child: _sideGlow(
            width: 120,
            height: 260,
            color: _accent.withOpacity(.82),
            angle: .35,
          ),
        ),
        Positioned(
          top: 340,
          left: -35,
          child: _sideGlow(
            width: 120,
            height: 260,
            color: _accent.withOpacity(.82),
            angle: -.35,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _ForgotBackgroundPainter()),
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
              color.withOpacity(.70),
              color.withOpacity(.12),
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

  BoxDecoration _glass() => BoxDecoration(
        color: _panel.withOpacity(.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      );

  Widget _emailField() {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submit(),
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: _text,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: _accent,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(.03),
        hintText: "البريد الإلكتروني",
        hintStyle: const TextStyle(
          color: _hint,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: _text.withOpacity(.88),
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(.10),
            width: 1.2,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: _accent, width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _line, width: 1.2),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
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
            onTap: _isLoading ? null : _submit,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "إرسال رابط التعيين",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
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
}

class _ForgotBackgroundPainter extends CustomPainter {
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
