import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../car/add_maintenance_screen.dart';
import '../car/maintenance_history_screen.dart';

class CarDashboardScreen extends StatefulWidget {
  final Map vehicle;

  const CarDashboardScreen({super.key, required this.vehicle});

  @override
  State<CarDashboardScreen> createState() => _CarDashboardScreenState();
}

class _CarDashboardScreenState extends State<CarDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController speedCtrl;
  late AnimationController rpmCtrl;

  double speed = 0;
  double rpm = 0;

  List maintenanceHistory = [];
  Map? lastMaintenance;
  bool loadingMaintenance = true;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _isDark ? AppTheme.bgEnd : AppTheme.ink;
  Color get _surface => _isDark ? const Color(0xFF10233E) : Colors.white;
  Color get _surfaceSoft =>
      _isDark ? const Color(0xFF17345F) : const Color(0xFFF7FAFF);

  Color get _textMain => _isDark ? AppTheme.textLight : const Color(0xFF10233E);
  Color get _textSub => _isDark ? AppTheme.muted : const Color(0xFF62738E);

  Color get _border =>
      _isDark ? Colors.white.withOpacity(.10) : AppTheme.line.withOpacity(.12);

  Color get _primary => AppTheme.accent;
  // ignore: unused_element
  Color get _primaryDark => AppTheme.accentDark;
  Color get _danger => AppTheme.danger;

  LinearGradient get _pageGradient => _isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF081A36),
            Color(0xFF122B50),
            Color(0xFF040D1D),
          ],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFF4F7FC),
            Color(0xFFEAF1FB),
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
          color: _isDark
              ? Colors.black.withOpacity(.22)
              : AppTheme.accent.withOpacity(.08),
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
          color: Colors.black.withOpacity(_isDark ? .18 : .04),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  @override
  void initState() {
    super.initState();
    loadMaintenance();
    initAnimations();
  }

  void initAnimations() {
    speedCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    rpmCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    speedCtrl.addListener(() => setState(() => speed = speedCtrl.value * 180));
    rpmCtrl.addListener(() => setState(() => rpm = rpmCtrl.value * 8000));

    speedCtrl.forward();
    rpmCtrl.forward();
  }

  Future<void> loadMaintenance() async {
    setState(() => loadingMaintenance = true);
    try {
      final list =
          await ApiService.getMaintenanceHistory(widget.vehicle["_id"]);
      if (!mounted) return;
      setState(() {
        maintenanceHistory = list;
        lastMaintenance = list.isNotEmpty ? list.first : null;
        loadingMaintenance = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loadingMaintenance = false);
    }
  }

  @override
  void dispose() {
    speedCtrl.dispose();
    rpmCtrl.dispose();
    super.dispose();
  }

  String _stringValue(dynamic value, {String fallback = "غير محدد"}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  int _intValue(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    return int.tryParse(value.toString()) ?? fallback;
  }

  double _nextServiceProgress() {
    final car = widget.vehicle;
    final nextKm = _intValue(car["nextServiceKm"], fallback: 0);
    final currentKm = _intValue(car["km"], fallback: 0);

    if (nextKm <= 0) return 0;
    if (currentKm <= 0) return 0;

    final progress = currentKm / nextKm;
    return progress.clamp(0.0, 1.0);
  }

  String _nextServiceStatus() {
    final p = _nextServiceProgress();
    if (p >= 1) return "مستحقة الآن";
    if (p >= .85) return "قريبة جدًا";
    if (p >= .60) return "اقترب الموعد";
    return "مطمئنة";
  }

  Color _nextServiceStatusColor() {
    final p = _nextServiceProgress();
    if (p >= 1) return _danger;
    if (p >= .85) return Colors.orangeAccent;
    if (p >= .60) return const Color(0xFFFFC857);
    return const Color(0xFF3FAE72);
  }

  Widget _bgOrb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 18,
            ),
          ],
        ),
      ),
    );
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
    double size = 54,
    double iconSize = 24,
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (light ? Colors.white : _primary).withOpacity(.20),
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
        color: darkCard ? Colors.white.withOpacity(.10) : _surfaceSoft,
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
                  : _primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: darkCard ? Colors.white : _primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: darkCard ? Colors.white : _textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: darkCard ? Colors.white.withOpacity(.80) : _textSub,
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

  Widget _header(Map car) {
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "${_stringValue(car["brand"], fallback: "سيارة")} ${_stringValue(car["model"], fallback: "")}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "لوحة تحكم المركبة والصيانة",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.82),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MaintenanceHistoryScreen(
                        vehicleId: car["_id"],
                        vehicle: Map<String, dynamic>.from(car),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  icon: Icons.pin_outlined,
                  value: _stringValue(car["plateNumber"]),
                  label: 'رقم اللوحة',
                  darkCard: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  icon: Icons.palette_outlined,
                  value: _stringValue(car["color"]),
                  label: 'اللون',
                  darkCard: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gaugeCard({
    required double value,
    required double maxValue,
    required Color color,
    required String label,
    required IconData icon,
  }) {
    final progress = (value / maxValue).clamp(0.0, 1.0);

    return Expanded(
      child: _card(
        child: Column(
          children: [
            _iconBadge(icon, size: 46, iconSize: 20),
            const SizedBox(height: 12),
            SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 11,
                      backgroundColor:
                          _isDark ? Colors.white12 : Colors.black12,
                      color: color,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: _textMain,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: _textSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return _card(
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(.20)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _textSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _textMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _textSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextServiceCard(Map car) {
    final nextKm = _stringValue(car["nextServiceKm"]);
    final currentKm = _stringValue(car["km"], fallback: "0");
    final progress = _nextServiceProgress();
    final statusText = _nextServiceStatus();
    final statusColor = _nextServiceStatusColor();

    return _card(
      withGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(.22)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.3,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "الصيانة القادمة",
                style: TextStyle(
                  color: _textMain,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 10),
              _iconBadge(Icons.car_repair_rounded, size: 48, iconSize: 22),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  icon: Icons.speed_rounded,
                  value: currentKm,
                  label: 'العداد الحالي',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  icon: Icons.flag_rounded,
                  value: nextKm,
                  label: 'موعد الصيانة',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: _isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "متابعة المسافة حتى الصيانة التالية تساعدك على الحفاظ على أداء المركبة.",
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _textSub,
              fontSize: 12.3,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lastMaintenanceCard() {
    if (loadingMaintenance) {
      return _card(
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "جاري تحميل بيانات الصيانة...",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: _textSub,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (lastMaintenance == null) {
      return _card(
        child: Column(
          children: [
            _iconBadge(Icons.build_circle_outlined, size: 60, iconSize: 26),
            const SizedBox(height: 12),
            Text(
              "لا توجد عمليات صيانة مسجلة",
              style: TextStyle(
                color: _textMain,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "ابدأ بإضافة أول عملية صيانة للحفاظ على سجل المركبة.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSub,
                fontWeight: FontWeight.w700,
                fontSize: 12.8,
              ),
            ),
          ],
        ),
      );
    }

    final type = _stringValue(lastMaintenance!["type"]);
    final km = _stringValue(lastMaintenance!["km"]);
    final cost = _stringValue(lastMaintenance!["cost"], fallback: "غير محدد");
    final date = _stringValue(lastMaintenance!["date"], fallback: "غير محدد");

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              _iconBadge(Icons.build_rounded, size: 48, iconSize: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "آخر عملية صيانة",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _textMain,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _maintenanceDataRow(
              "النوع", type, Icons.miscellaneous_services_rounded),
          _maintenanceDataRow("الكيلومترات", "$km km", Icons.speed_rounded),
          _maintenanceDataRow("التكلفة", cost, Icons.payments_outlined),
          _maintenanceDataRow("التاريخ", date, Icons.event_outlined),
        ],
      ),
    );
  }

  Widget _maintenanceDataRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _textMain,
                fontSize: 14.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: _textSub,
              fontSize: 12.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onTap,
    required IconData icon,
    bool isPrimary = true,
  }) {
    if (isPrimary) {
      return SizedBox(
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: _primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white),
            label: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: _textMain),
        label: Text(
          label,
          style: TextStyle(
            color: _textMain,
            fontWeight: FontWeight.w900,
            fontSize: 15.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _border),
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.vehicle;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(gradient: _pageGradient),
            ),
            Positioned(
              top: -50,
              right: -40,
              child: _bgOrb(170, _primary.withOpacity(.13)),
            ),
            Positioned(
              bottom: -70,
              left: -50,
              child: _bgOrb(160, Colors.white.withOpacity(_isDark ? .04 : .20)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _header(car),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _gaugeCard(
                          value: speed,
                          maxValue: 180,
                          color: Colors.orangeAccent,
                          label: "km/h",
                          icon: Icons.speed_rounded,
                        ),
                        const SizedBox(width: 12),
                        _gaugeCard(
                          value: rpm,
                          maxValue: 8000,
                          color: Colors.redAccent,
                          label: "RPM",
                          icon: Icons.settings_input_component_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            title: "الماركة",
                            value: _stringValue(car["brand"]),
                            icon: Icons.local_shipping_outlined,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            title: "الموديل",
                            value: _stringValue(car["model"]),
                            icon: Icons.directions_car_filled_rounded,
                            color: const Color(0xFF3FAE72),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _nextServiceCard(car),
                    const SizedBox(height: 16),
                    _lastMaintenanceCard(),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            label: "عرض السجل",
                            icon: Icons.history_rounded,
                            isPrimary: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MaintenanceHistoryScreen(
                                    vehicleId: car["_id"],
                                    vehicle: Map<String, dynamic>.from(car),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionButton(
                            label: "إضافة صيانة",
                            icon: Icons.add_rounded,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddMaintenanceScreen(
                                      vehicle: widget.vehicle),
                                ),
                              );

                              if (result != null) {
                                await ApiService.addMaintenance(
                                  vehicleId: car["_id"],
                                  type: result["type"],
                                  km: result["km"],
                                  cost: result["cost"],
                                  notes: result["notes"],
                                  date: result["date"],
                                );

                                loadMaintenance();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
