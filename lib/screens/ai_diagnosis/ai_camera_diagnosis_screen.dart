// PATH: lib/screens/ai_diagnosis/ai_camera_diagnosis_screen.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AiCameraDiagnosisScreen extends StatefulWidget {
  const AiCameraDiagnosisScreen({super.key});

  @override
  State<AiCameraDiagnosisScreen> createState() =>
      _AiCameraDiagnosisScreenState();
}

class _AiCameraDiagnosisScreenState extends State<AiCameraDiagnosisScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  bool _analyzing = false;
  double _progress = 0.75;
  final TextEditingController _problemController = TextEditingController();

  final List<Map<String, String>> _recentChecks = [
    {
      "title": "تسريب زيت المحرك",
      "time": "منذ يومين",
      "status": "تم الإصلاح",
    },
    {
      "title": "ضعف في البطارية",
      "time": "منذ 5 أيام",
      "status": "قيد المتابعة",
    },
  ];

  static const Color _bg0 = Color(0xFF0A2146);
  static const Color _bg1 = Color(0xFF0D356A);
  static const Color _bg2 = Color(0xFF071831);

  static const Color _topBarColor = Color(0xFF1588F4);
  static const Color _card = Color(0xFFD6D8DE);
  static const Color _cardInner = Color(0xFFCACCD3);
  static const Color _textDark = Color(0xFF0E1930);
  // ignore: unused_field
  static const Color _textLight = Colors.white;
  static const Color _blue = Color(0xFF24339D);
  static const Color _blueBtn1 = Color(0xFF1492FF);
  static const Color _blueBtn2 = Color(0xFF0B76DC);
  static const Color _blueBtn3 = Color(0xFF095EB6);
  static const Color _green = Color(0xFF2DBB66);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    HapticFeedback.mediumImpact();

    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (file == null) return;

    setState(() {
      _pickedImage = File(file.path);
      _analyzing = true;
      _progress = 0.15;
    });

    _fakeAnalyze();
  }

  Future<void> _pickFromGallery() async {
    HapticFeedback.selectionClick();

    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) return;

    setState(() {
      _pickedImage = File(file.path);
      _analyzing = true;
      _progress = 0.18;
    });

    _fakeAnalyze();
  }

  Future<void> _showProblemDialog() async {
    HapticFeedback.selectionClick();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFCFD3DB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "وصف العطل",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _problemController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "اكتب تفاصيل ما تشعر به في السيارة...",
                    filled: true,
                    fillColor: Colors.white.withOpacity(.75),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [_blueBtn1, _blueBtn2, _blueBtn3],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _analyzing = true;
                          _progress = 0.20;
                        });
                        _fakeAnalyze();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "بدء التحليل",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
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

  Future<void> _fakeAnalyze() async {
    for (final value in [0.28, 0.40, 0.57, 0.75]) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() => _progress = value);
    }

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    setState(() {
      _analyzing = false;
      _recentChecks.insert(0, {
        "title": _pickedImage != null
            ? "تم رفع صورة جديدة للفحص"
            : (_problemController.text.trim().isEmpty
                ? "تم إنشاء فحص جديد"
                : _problemController.text.trim()),
        "time": "الآن",
        "status": "جارٍ التحليل",
      });
    });
  }

  Widget _background() {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bg0, _bg1, _bg2],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: 90,
          left: -40,
          child: _glowBlob(180, const Color(0xFF6A3CFF).withOpacity(.18)),
        ),
        Positioned(
          bottom: 90,
          right: -50,
          child: _glowBlob(220, const Color(0xFF2A8CFF).withOpacity(.14)),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _DiagnosisBgPainter(),
          ),
        ),
      ],
    );
  }

  Widget _glowBlob(double size, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
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

  Widget _buildTopBar() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: _topBarColor,
        border: Border(
          bottom: BorderSide(color: Colors.white24, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.black87,
              size: 28,
            ),
          ),
          const Spacer(),
          const Text(
            "الفحص الذكي بالذكاء الاصطناعي",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.black87,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Column(
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF251E8E).withOpacity(.88),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF251E8E).withOpacity(.28),
                blurRadius: 22,
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology_alt_outlined,
            color: Colors.white,
            size: 42,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "مرحبا بك في دكتور كار",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "اختر كيف ترغب في تشخيص عطل سيارتك اليوم\nباستخدام تقنية الذكاء الاصطناعي",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF35B2FF),
            fontSize: 14.5,
            height: 1.45,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _choiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.16),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 108,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _cardInner,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _pickedImage != null && title == "رفع صورة"
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _pickedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Icon(
                          icon,
                          size: 40,
                          color: _blue,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressCard() {
    final percent = (_progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.14),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            bottom: -8,
            child: Icon(
              Icons.settings,
              size: 64,
              color: Colors.black.withOpacity(.04),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "$percent%",
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _analyzing
                              ? "جاري التحليل الذكي..."
                              : "تم تحديث التحليل",
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: _progress,
                        backgroundColor: Colors.white.withOpacity(.50),
                        valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.memory_rounded,
                  color: _blue,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentItem(Map<String, String> item) {
    final bool done = item["status"] == "تم الإصلاح";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"] ?? "",
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${item["time"]} • ${item["status"]}",
                  style: TextStyle(
                    color: done ? _green : _blue,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? _green.withOpacity(.14) : _blue.withOpacity(.12),
            ),
            child: Icon(
              done ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: done ? _green : _blue,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            _background(),
            SafeArea(
              top: false,
              child: FadeTransition(
                opacity: _fade,
                child: AnimatedBuilder(
                  animation: _slide,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slide.value),
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      _buildTopBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _hero(),
                              const SizedBox(height: 26),
                              const Center(
                                child: Text(
                                  "اختر وسيلة التشخيص",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white24,
                                        blurRadius: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _choiceCard(
                                    icon: Icons.edit_note_rounded,
                                    title: "وصف العطل",
                                    subtitle: "اكتب تفاصيل ما تشعر به",
                                    onTap: _showProblemDialog,
                                  ),
                                  const SizedBox(width: 12),
                                  _choiceCard(
                                    icon: Icons.add_a_photo_outlined,
                                    title: "رفع صورة",
                                    subtitle: "التقط صورة واضحة للعطل",
                                    onTap: () async {
                                      await _pickFromCamera();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          gradient: const LinearGradient(
                                            colors: [
                                              _blueBtn1,
                                              _blueBtn2,
                                              _blueBtn3,
                                            ],
                                          ),
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: _pickFromGallery,
                                          icon: const Icon(
                                            Icons.photo_library_outlined,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            "اختيار من المعرض",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _progressCard(),
                              const SizedBox(height: 14),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "آخر الفحوصات",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "عرض الكل",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.90),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ..._recentChecks.map(_recentItem),
                            ],
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
      ),
    );
  }
}

class _DiagnosisBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(.03)
      ..strokeWidth = 1;

    for (double x = -size.height; x < size.width + size.height; x += 34) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFF7F9BFF).withOpacity(.18);

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * .5, size.height * .40),
        radius: size.width * .62,
      ),
      math.pi,
      math.pi,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
