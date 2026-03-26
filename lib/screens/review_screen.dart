// PATH: lib/screens/review_screen.dart
// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import 'home_screen.dart';

class ReviewScreen extends StatefulWidget {
  final String orderId;
  final bool useNamedHomeRoute;
  final String homeRouteName;

  const ReviewScreen({
    super.key,
    required this.orderId,
    this.useNamedHomeRoute = false,
    this.homeRouteName = '/home',
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with TickerProviderStateMixin {
  // ================== THEME ==================
  static const Color _bg = Color(0xFF0B1220);

  Color get _surface => const Color(0xFF10233E);
  Color get _surface2 => const Color(0xFF17345F);
  Color get _surface3 => const Color(0xFF0D2140);

  Color get _primary => AppTheme.accent;
  // ignore: unused_element
  Color get _primaryDark => AppTheme.accentDark;
  Color get _primarySoft => AppTheme.accentSoft;
  Color get _textMain => AppTheme.textLight;
  Color get _textSub => AppTheme.muted;
  // ignore: unused_element
  Color get _danger => AppTheme.danger;
  // ignore: unused_element
  Color get _success => const Color(0xFF22C55E);
  Color get _star => const Color(0xFFFFC107);
  Color get _border => Colors.white.withOpacity(.10);

  LinearGradient get _pageGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF081A36),
          Color(0xFF122B50),
          Color(0xFF040D1D),
        ],
      );

  LinearGradient get _headerGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1D4F99),
          Color(0xFF163F7E),
          Color(0xFF0E2D60),
        ],
      );

  LinearGradient get _primaryGradient => AppTheme.ctaAquaGradient;

  List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.24),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get _strongGlow => [
        BoxShadow(
          color: _primary.withOpacity(.18),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(.20),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  // ================== STATE ==================
  double overallRating = 0;
  double techRating = 0;
  double speedRating = 0;
  double priceRating = 0;

  bool isSending = false;

  final TextEditingController commentController = TextEditingController();

  final List<String> tags = const [
    "خدمة سريعة",
    "سعر مناسب",
    "فريق محترف",
    "التعامل ممتاز",
    "الفني محترف",
    "التواصل ممتاز",
    "جودة عالية",
    "التزام بالمواعيد",
    "تأخير",
    "السعر مرتفع",
    "غير مرضي",
    "أحتاج تحسين",
  ];

  final Set<String> selectedTags = {};
  bool _submittedOnce = false;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  // ================== HELPERS ==================
  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _surface2,
        behavior: SnackBarBehavior.floating,
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  double _calcProgress() {
    double p = 0;
    if (overallRating > 0) p += 0.50;
    if (techRating > 0) p += 0.15;
    if (speedRating > 0) p += 0.15;
    if (priceRating > 0) p += 0.10;
    if (commentController.text.trim().isNotEmpty || selectedTags.isNotEmpty) {
      p += 0.10;
    }
    return p.clamp(0.0, 1.0);
  }

  String _ratingLabel(double v) {
    if (v >= 5) return "ممتاز";
    if (v >= 4) return "جيد جدًا";
    if (v >= 3) return "جيد";
    if (v >= 2) return "مقبول";
    if (v >= 1) return "ضعيف";
    return "اختر تقييم";
  }

  String _ratingDescription(double v) {
    if (v >= 5) return "تجربة ممتازة جدًا";
    if (v >= 4) return "تجربة مرضية جدًا";
    if (v >= 3) return "تجربة جيدة بشكل عام";
    if (v >= 2) return "هناك بعض الملاحظات";
    if (v >= 1) return "نحتاج تحسين الخدمة";
    return "ابدأ بتحديد تقييمك العام";
  }

  Future<void> submitReview() async {
    if (isSending || _submittedOnce) return;

    if (overallRating == 0) {
      _snack("من فضلك اختر التقييم العام");
      return;
    }

    _submittedOnce = true;
    HapticFeedback.mediumImpact();
    setState(() => isSending = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => isSending = false);

    _showSuccessSheet();
  }

  void _goHome() {
    if (!mounted) return;

    Navigator.of(context).pop();

    if (widget.useNamedHomeRoute) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        widget.homeRouteName,
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(22)),
    bool withGlow = false,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: borderRadius,
        border: Border.all(color: _border),
        boxShadow: withGlow ? _strongGlow : _cardShadow,
      ),
      child: child,
    );
  }

  Widget _iconBadge(
    IconData icon, {
    double size = 48,
    double iconSize = 22,
    bool light = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: light
            ? LinearGradient(
                colors: [
                  Colors.white.withOpacity(.22),
                  Colors.white.withOpacity(.14),
                ],
              )
            : _primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (light ? Colors.white : _primary).withOpacity(.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String value,
    required String label,
    bool darkCard = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: darkCard ? Colors.white.withOpacity(.10) : _surface2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: darkCard ? Colors.white.withOpacity(.12) : _border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: darkCard
                  ? Colors.white.withOpacity(.12)
                  : _primary.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(.80),
                    fontSize: 11.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    final progress = _calcProgress();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: _pageGradient)),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _headerCard(),
                    const SizedBox(height: 16),
                    _progressCard(progress),
                    const SizedBox(height: 18),
                    _mainQuestion(),
                    const SizedBox(height: 12),
                    _bigStars(),
                    const SizedBox(height: 18),
                    _summaryCard(),
                    const SizedBox(height: 18),
                    _subRatingsCard(),
                    const SizedBox(height: 24),
                    _writeOpinionTitle(),
                    const SizedBox(height: 10),
                    _commentBox(),
                    const SizedBox(height: 14),
                    _tags(),
                    const SizedBox(height: 26),
                    _submitButton(),
                  ],
                ),
              ),
            ),
            if (isSending) _loading(),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        gradient: _headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _strongGlow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "قيّم تجربتك",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "رأيك يساعدنا على تحسين الخدمة باستمرار",
                      style: GoogleFonts.cairo(
                        color: Colors.white.withOpacity(.82),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              _iconBadge(
                Icons.rate_review_rounded,
                size: 46,
                iconSize: 20,
                light: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  icon: Icons.confirmation_number_outlined,
                  value: widget.orderId,
                  label: "رقم الطلب",
                  darkCard: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  icon: Icons.star_rate_rounded,
                  value: overallRating == 0
                      ? "--"
                      : overallRating.toStringAsFixed(1),
                  label: "التقييم الحالي",
                  darkCard: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressCard(double progress) {
    final percent = (progress * 100).round();

    return _card(
      withGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: _primaryGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "$percent%",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "اكتمال التقييم",
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 10),
              _iconBadge(Icons.fact_check_rounded, size: 46, iconSize: 21),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(_primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "أضف تقييمًا وتعليقًا مختصرًا لزيادة فائدة المراجعة.",
            style: GoogleFonts.cairo(
              color: _textSub,
              fontWeight: FontWeight.w700,
              fontSize: 12.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainQuestion() {
    return Column(
      children: [
        Text(
          "ما هو تقييمك للخدمة؟",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _textMain,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _ratingDescription(overallRating),
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _textSub,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _bigStars() {
    return Column(
      children: [
        _stars(
          value: overallRating,
          size: 42,
          onTap: (v) {
            setState(() {
              overallRating = v;
            });
          },
          allowClear: true,
          showBorderForUnselected: true,
        ),
        const SizedBox(height: 8),
        Text(
          _ratingLabel(overallRating),
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    final displayed = overallRating == 0 ? 4.0 : overallRating;

    return _card(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    displayed.toStringAsFixed(1),
                    style: GoogleFonts.cairo(
                      color: _primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: Text(
                      "من 5 نقاط",
                      style: GoogleFonts.cairo(
                        color: _textSub,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    _barRow(
                      5,
                      overallRating == 0
                          ? 0.82
                          : (overallRating / 5).clamp(0.0, 1.0),
                    ),
                    const SizedBox(height: 10),
                    _barRow(
                      4,
                      overallRating == 0
                          ? 0.62
                          : ((overallRating - 1) / 4).clamp(0.0, 1.0),
                    ),
                    const SizedBox(height: 10),
                    _barRow(
                      3,
                      overallRating == 0
                          ? 0.78
                          : ((overallRating - 2) / 3).clamp(0.0, 1.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "تقييمك بيساعدنا نطوّر التجربة بشكل أفضل",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: _textMain,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _barRow(int label, double value) {
    return Row(
      children: [
        Text(
          "$label",
          style: GoogleFonts.cairo(
            color: _textSub,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(_primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _subRatingsCard() {
    return _card(
      child: Column(
        children: [
          _subRatingRow(
            title: "احترافية الفني",
            value: techRating,
            icon: Icons.engineering_rounded,
            onChanged: (v) {
              setState(() {
                techRating = v;
              });
            },
          ),
          const SizedBox(height: 12),
          _subRatingRow(
            title: "سرعة الوصول",
            value: speedRating,
            icon: Icons.flash_on_rounded,
            onChanged: (v) {
              setState(() {
                speedRating = v;
              });
            },
          ),
          const SizedBox(height: 12),
          _subRatingRow(
            title: "السعر",
            value: priceRating,
            icon: Icons.payments_rounded,
            onChanged: (v) {
              setState(() {
                priceRating = v;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _subRatingRow({
    required String title,
    required double value,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          _iconBadge(icon, size: 40, iconSize: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                color: _textMain,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          _stars(
            value: value,
            size: 24,
            onTap: onChanged,
            allowClear: true,
            showBorderForUnselected: false,
          ),
        ],
      ),
    );
  }

  Widget _writeOpinionTitle() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        "اكتب رأيك",
        style: GoogleFonts.cairo(
          color: _textMain,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _commentBox() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: commentController,
        onChanged: (_) => setState(() {}),
        maxLines: 4,
        style: GoogleFonts.cairo(
          color: _textMain,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText:
              "شاركنا تفاصيل تجربتك هنا... ما الذي أعجبك؟ وكيف يمكننا التحسن؟",
          hintStyle: GoogleFonts.cairo(
            color: _textSub.withOpacity(.75),
            fontWeight: FontWeight.w700,
            fontSize: 14,
            height: 1.45,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primary, width: 1.2),
          ),
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _tags() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: tags.map((t) {
        final active = selectedTags.contains(t);

        return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              active ? selectedTags.remove(t) : selectedTags.add(t);
            });
          },
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: active ? _primary.withOpacity(.18) : _surface3,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: active ? _primary.withOpacity(.70) : _border,
              ),
            ),
            child: Text(
              t,
              style: GoogleFonts.cairo(
                color: _textMain,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _submitButton() {
    final disabled = isSending || overallRating == 0;

    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: disabled
              ? LinearGradient(
                  colors: [
                    Colors.white.withOpacity(.08),
                    Colors.white.withOpacity(.04),
                  ],
                )
              : _primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: disabled ? [] : _strongGlow,
        ),
        child: ElevatedButton(
          onPressed: disabled ? null : submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            isSending ? "جاري الإرسال..." : "إرسال التقييم",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _stars({
    required double value,
    required double size,
    required ValueChanged<double> onTap,
    bool allowClear = false,
    bool showBorderForUnselected = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1.0;
        final isFilled = value >= starValue;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            if (allowClear && value == starValue) {
              onTap(0);
            } else {
              onTap(starValue);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 150),
              scale: isFilled ? 1.08 : 1.0,
              child: Icon(
                isFilled
                    ? Icons.star_rounded
                    : (showBorderForUnselected
                        ? Icons.star_border_rounded
                        : Icons.star_rounded),
                size: size,
                color: isFilled
                    ? _star
                    : (showBorderForUnselected
                        ? Colors.white54
                        : Colors.white24),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _loading() {
    return Container(
      color: Colors.black.withOpacity(.35),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: _cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _primary),
              const SizedBox(height: 12),
              Text(
                "جاري إرسال التقييم...",
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _border),
              boxShadow: _cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _primarySoft,
                  child: Icon(
                    Icons.check_circle,
                    color: _primary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "شكرًا لتقييمك 🙏",
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "تم إرسال التقييم بنجاح",
                  style: GoogleFonts.cairo(
                    color: _textSub,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: InkWell(
                    onTap: _goHome,
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: _primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          "تم",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
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
      },
    );
  }
}
