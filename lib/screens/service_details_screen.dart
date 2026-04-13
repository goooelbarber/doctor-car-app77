// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'map_picker_screen.dart';
import 'searching_technician_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ServiceDetailsScreen({
    super.key,
    required this.service,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen>
    with TickerProviderStateMixin {
  static const Color _bg1 = Color(0xFF081A36);
  static const Color _bg2 = Color(0xFF0B2348);
  static const Color _bg3 = Color(0xFF040D1D);

  static const Color _brand = Color(0xFF1B4F9C);
  // ignore: unused_field
  static const Color _brandDark = Color(0xFF153F78);
  static const Color _brandSoft = Color(0xFF7CC4F5);

  static const Color _text = Color(0xFFF2F6FB);
  static const Color _muted = Color(0xFFC9D6EA);
  static const Color _success = Color(0xFF36C690);
  static const Color _warning = Color(0xFFFFB84D);

  bool isFavorite = false;

  late final AnimationController _fadeCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _fadeAnim;

  LinearGradient get _screenBgGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_bg1, _bg2, _bg3],
      );

  LinearGradient get _bluePrimary => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF1B4F99),
          Color(0xFF245AA6),
          Color(0xFF153F78),
        ],
        stops: [0.0, 0.56, 1.0],
      );

  // ignore: unused_element
  LinearGradient get _glass => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(.09),
          Colors.white.withOpacity(.06),
          Colors.white.withOpacity(.04),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

  // ignore: deprecated_member_use, unused_element
  Color get _stroke => Colors.white.withOpacity(.12);

  List<BoxShadow> get _shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(.20),
          blurRadius: 16,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get _glow => [
        BoxShadow(
          color: _brand.withOpacity(.22),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(.20),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> get s => widget.service;

  Color get _serviceAccent {
    final color = s["color"];
    if (color is Color) return color;
    return _brandSoft;
  }

  String get _serviceName => s["name"]?.toString() ?? "الخدمة";
  String get _serviceDesc => s["desc"]?.toString() ?? "لا يوجد وصف للخدمة";
  String get _serviceTime => s["time"]?.toString() ?? "--";
  String get _serviceCategory => s["category"]?.toString() ?? "عام";
  String get _servicePrice => "${s["price"] ?? "--"} جنيه";
  String get _serviceRating => "${s["rating"] ?? "--"}";
  IconData get _serviceIcon =>
      (s["icon"] is IconData) ? s["icon"] as IconData : Icons.build_rounded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg1,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _background(),
          FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroSection(),
                  const SizedBox(height: 14),
                  _quickStats(),
                  const SizedBox(height: 14),
                  _glassSection(
                    title: "وصف الخدمة",
                    icon: Icons.description_rounded,
                    child: Text(
                      _serviceDesc,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 14.6,
                        height: 1.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _glassSection(
                    title: "تفاصيل سريعة",
                    icon: Icons.info_outline_rounded,
                    child: Column(
                      children: [
                        _detailRow(
                          title: "نوع الخدمة",
                          value: _serviceCategory,
                          icon: Icons.widgets_rounded,
                          color: _brandSoft,
                        ),
                        const SizedBox(height: 10),
                        _detailRow(
                          title: "الزمن المتوقع",
                          value: _serviceTime,
                          icon: Icons.timer_rounded,
                          color: _warning,
                        ),
                        const SizedBox(height: 10),
                        _detailRow(
                          title: "السعر المتوقع",
                          value: _servicePrice,
                          icon: Icons.payments_rounded,
                          color: _success,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _glassSection(
                    title: "مميزات الخدمة",
                    icon: Icons.auto_awesome_rounded,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _featureChip(
                          icon: Icons.verified_rounded,
                          text: "خدمة موثوقة",
                          color: _serviceAccent,
                        ),
                        _featureChip(
                          icon: Icons.bolt_rounded,
                          text: "استجابة سريعة",
                          color: _warning,
                        ),
                        _featureChip(
                          icon: Icons.support_agent_rounded,
                          text: "دعم مستمر",
                          color: _success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        _serviceName,
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: Colors.redAccent,
          ),
          onPressed: () => setState(() => isFavorite = !isFavorite),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _background() {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: _screenBgGradient),
          ),
        ),
        Positioned(
          top: -50,
          right: -20,
          child: _blurGlow(
            size: 180,
            color: _serviceAccent.withOpacity(.08),
          ),
        ),
        Positioned(
          bottom: -40,
          left: -10,
          child: _blurGlow(
            size: 160,
            color: _brand.withOpacity(.08),
          ),
        ),
      ],
    );
  }

  Widget _blurGlow({required double size, required Color color}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _heroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF173B6D),
            Color(0xFF12315C),
            Color(0xFF0D2343),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: _glow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _serviceName,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: _text,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "خدمة احترافية وسريعة ضمن منظومة Doctor Car مع تجربة واضحة وآمنة.",
                  style: GoogleFonts.cairo(
                    color: _muted,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w700,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _heroPill(
                      icon: Icons.star_rounded,
                      text: _serviceRating,
                    ),
                    _heroPill(
                      icon: Icons.timer_rounded,
                      text: _serviceTime,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              return Transform.scale(
                scale: 1 + (_pulseCtrl.value * .05),
                child: _serviceIconCard(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _serviceIconCard() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _serviceAccent.withOpacity(.30),
            _serviceAccent.withOpacity(.12),
          ],
        ),
        border: Border.all(color: _serviceAccent.withOpacity(.28)),
        boxShadow: [
          BoxShadow(
            color: _serviceAccent.withOpacity(.20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _serviceAccent,
              ),
            ),
          ),
          Positioned(
            bottom: 11,
            left: 11,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _serviceAccent.withOpacity(.75),
              ),
            ),
          ),
          Icon(
            _serviceIcon,
            size: 40,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _heroPill({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: "التقييم",
            value: _serviceRating,
            icon: Icons.star_rounded,
            color: _warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            title: "الوقت",
            value: _serviceTime,
            icon: Icons.timer_rounded,
            color: _brandSoft,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            title: "السعر",
            value: s["price"]?.toString() ?? "--",
            icon: Icons.payments_rounded,
            color: _success,
            suffix: "ج.م",
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: _shadowSm,
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: color.withOpacity(.14),
              border: Border.all(color: color.withOpacity(.18)),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.cairo(
              color: _muted,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            suffix == null ? value : "$value $suffix",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: _text,
              fontWeight: FontWeight.w900,
              fontSize: 13.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(.10)),
            boxShadow: _shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _sectionIcon(icon),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionIcon(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: _bluePrimary,
        boxShadow: _glow.take(1).toList(),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          Icon(icon, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _detailRow({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(.12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                color: _muted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: _text,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: _text,
              fontWeight: FontWeight.w800,
              fontSize: 12.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 1, 10, 23),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(.08)),
        ),
      ),
      child: SizedBox(
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: _bluePrimary,
            boxShadow: _glow,
          ),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.location_on_rounded, color: Colors.white),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () async {
              final location = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapPickerScreen(
                    selectedService: _serviceName,
                  ),
                ),
              );

              if (location == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchingTechnicianScreen(
                    userId: "user_001",
                    serviceType: _serviceName,
                    lat: location.latitude,
                    lng: location.longitude,
                    orderId: DateTime.now().millisecondsSinceEpoch.toString(),
                    selectedServices: [],
                    address: '',
                  ),
                ),
              );
            },
            label: Text(
              "تحديد الموقع وبدء الطلب",
              style: GoogleFonts.cairo(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
