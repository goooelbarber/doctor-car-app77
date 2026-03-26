// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/api_config.dart';
import '../core/theme/app_theme.dart';
import 'searching_technician_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  // ======================
  // THEME
  // ======================
  static const Color _bg = Color(0xFF0B1220);

  Color get _cardColor => const Color(0xFF10233E);
  Color get _cardSoft => const Color(0xFF17345F);
  Color get _inputFill => const Color(0xFF0D2140);

  Color get _primary => AppTheme.accent;
  // ignore: unused_element
  Color get _primaryDark => AppTheme.accentDark;
  Color get _danger => AppTheme.danger;
  Color get _textMain => AppTheme.textLight;
  Color get _textSub => AppTheme.muted;
  Color get _border => Colors.white.withOpacity(.10);

  LinearGradient get _primaryGradient => AppTheme.ctaAquaGradient;

  bool loading = false;
  bool estimating = false;

  String selectedService = "battery";

  // payment
  String paymentMethod = "cash"; // cash | card | wallet

  // location
  LatLng? pickedLocation; // manual pick
  Position? gpsPosition;

  // note / promo
  final TextEditingController notesCtrl = TextEditingController();
  final TextEditingController promoCtrl = TextEditingController();

  // estimate
  String currency = "EGP";
  double? estimatedFare;
  Map<String, dynamic> fareBreakdown = {};
  bool showBreakdown = false;

  // debounce for estimate
  Timer? _estimateDebounce;

  final Map<String, String> services = const {
    "battery": "خدمة البطارية",
    "tow": "خدمة السحب",
    "fuel": "توصيل وقود",
    "tire": "تبديل الإطارات",
  };

  // local fallback pricing
  final Map<String, double> _fallbackBase = const {
    "battery": 60,
    "tow": 120,
    "fuel": 70,
    "tire": 80,
  };

  void _snack(String msg, {bool danger = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: danger ? _danger : _cardSoft,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          msg,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("userId");
    if (id == null || id.isEmpty) throw Exception("المستخدم غير مسجل");
    return id;
  }

  Future<Position> _getMyLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("فعّل GPS أولًا");

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw Exception("تم رفض صلاحية الموقع");
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  LatLng? get _effectiveLocation {
    if (pickedLocation != null) return pickedLocation;
    if (gpsPosition != null) {
      return LatLng(gpsPosition!.latitude, gpsPosition!.longitude);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initLocationAndEstimate();
  }

  Future<void> _initLocationAndEstimate() async {
    try {
      gpsPosition = await _getMyLocation();
      if (!mounted) return;
      setState(() {});
      await _refreshEstimate();
    } catch (e) {
      _snack(e.toString().replaceAll("Exception:", "").trim(), danger: true);
    }
  }

  Future<void> _refreshEstimate() async {
    final loc = _effectiveLocation;
    if (loc == null) return;

    setState(() => estimating = true);

    try {
      final uri = Uri.parse(
        "${ApiConfig.baseUrl}/api/pricing/estimate"
        "?serviceType=$selectedService&lat=${loc.latitude}&lng=${loc.longitude}",
      );

      final res = await http.get(uri).timeout(ApiConfig.requestTimeout);

      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          res.body.isNotEmpty) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map) {
          final m = Map<String, dynamic>.from(decoded);
          setState(() {
            currency = (m["currency"] ?? "EGP").toString();
            estimatedFare = (m["estimatedFare"] as num?)?.toDouble();
            final b = m["breakdown"];
            fareBreakdown = (b is Map) ? Map<String, dynamic>.from(b) : {};
          });
        } else {
          _applyLocalFallbackEstimate();
        }
      } else {
        _applyLocalFallbackEstimate();
      }
    } catch (_) {
      _applyLocalFallbackEstimate();
    } finally {
      if (mounted) setState(() => estimating = false);
    }
  }

  void _applyLocalFallbackEstimate() {
    final base = _fallbackBase[selectedService] ?? 60;
    final serviceFee = 5.0;
    final tax = (base + serviceFee) * 0.05;

    setState(() {
      currency = "EGP";
      estimatedFare = (base + serviceFee + tax);
      fareBreakdown = {
        "baseFee": base,
        "serviceFee": serviceFee,
        "tax": tax,
        "surgeMultiplier": 1.0,
        "discount": 0.0,
        "note": "تقدير مبدئي",
      };
    });
  }

  void _scheduleEstimate() {
    _estimateDebounce?.cancel();
    _estimateDebounce = Timer(const Duration(milliseconds: 350), () {
      _refreshEstimate();
    });
  }

  Future<void> _pickLocationOnMap() async {
    final loc = _effectiveLocation;
    if (loc == null) {
      _snack("لا يوجد موقع متاح حاليًا", danger: true);
      return;
    }

    final result = await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickOnMapSheet(initial: loc),
    );

    if (result != null) {
      setState(() => pickedLocation = result);
      _scheduleEstimate();
    }
  }

  Future<void> _confirmAndCreateOrder() async {
    final loc = _effectiveLocation;
    if (loc == null) {
      _snack("حدد موقعك أولاً", danger: true);
      return;
    }

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmOrderSheet(
        serviceName: services[selectedService]!,
        paymentMethod: paymentMethod,
        estimatedFare: estimatedFare,
        currency: currency,
        location: loc,
        notes: notesCtrl.text.trim(),
      ),
    );

    if (ok == true) {
      await createOrder();
    }
  }

  Future<void> createOrder() async {
    if (loading) return;

    final loc = _effectiveLocation;
    if (loc == null) {
      _snack("حدد موقعك أولاً", danger: true);
      return;
    }

    setState(() => loading = true);

    try {
      final userId = await _getUserId();

      final body = {
        "userId": userId,
        "serviceName": services[selectedService],
        "serviceType": selectedService,
        "location": {"lat": loc.latitude, "lng": loc.longitude},
        "paymentMethod": paymentMethod,
        "notes": notesCtrl.text.trim(),
        if (promoCtrl.text.trim().isNotEmpty)
          "promoCode": promoCtrl.text.trim(),
        if (estimatedFare != null)
          "clientEstimate": {
            "currency": currency,
            "estimatedFare": estimatedFare,
            "breakdown": fareBreakdown,
          },
      };

      final res = await http
          .post(
            Uri.parse(ApiConfig.createOrder),
            headers: ApiConfig.jsonHeaders(),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      if (res.statusCode != 201 && res.statusCode != 200) {
        final msg = (decoded is Map ? decoded["message"] : null)?.toString();
        throw Exception(msg ?? "فشل إنشاء الطلب");
      }

      final data = decoded as Map<String, dynamic>;
      final order = (data["order"] ?? data) as Map<String, dynamic>;

      final orderId = (order["_id"] ?? order["orderId"])?.toString();
      if (orderId == null || orderId.isEmpty) {
        throw Exception("orderId غير موجود في response");
      }

      _snack("✅ تم إرسال الطلب، جاري البحث عن فني قريب...");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SearchingTechnicianScreen(
            userId: userId,
            serviceType: selectedService,
            lat: loc.latitude,
            lng: loc.longitude,
            orderId: orderId,
            fakeMode: false,
            selectedServices: const [],
            address: '',
          ),
        ),
      );
    } catch (e) {
      _snack(e.toString().replaceAll("Exception:", "").trim(), danger: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ======================
  // UI helpers
  // ======================
  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor.withOpacity(.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: _primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              color: _textMain,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _serviceTile({
    required String keyValue,
    required String title,
    required IconData icon,
  }) {
    final selected = selectedService == keyValue;

    return GestureDetector(
      onTap: loading
          ? null
          : () {
              setState(() => selectedService = keyValue);
              _scheduleEstimate();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _primary.withOpacity(.16) : _inputFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _primary.withOpacity(.70) : _border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: selected ? _primaryGradient : null,
                color: selected ? null : _cardSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.8,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? _primary : _textSub,
            ),
          ],
        ),
      ),
    );
  }

  IconData _serviceIcon(String key) {
    switch (key) {
      case 'battery':
        return Icons.battery_charging_full_rounded;
      case 'tow':
        return Icons.local_shipping_rounded;
      case 'fuel':
        return Icons.local_gas_station_rounded;
      case 'tire':
        return Icons.tire_repair_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Widget _paymentItem(String key, String title, IconData icon) {
    final selected = paymentMethod == key;
    return Expanded(
      child: GestureDetector(
        onTap: loading ? null : () => setState(() => paymentMethod = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? _primary.withOpacity(.18) : _inputFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _primary.withOpacity(.60) : _border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? _primary : _textSub,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(color: _textSub.withOpacity(.70)),
      filled: true,
      fillColor: _inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primary, width: 1.4),
      ),
    );
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "طلب خدمة",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _serviceSelector(),
          const SizedBox(height: 14),
          _locationCard(),
          const SizedBox(height: 14),
          _estimateCard(),
          const SizedBox(height: 14),
          _notesCard(),
          const SizedBox(height: 14),
          _paymentCard(),
          const SizedBox(height: 18),
          _submitButton(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _serviceSelector() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
              "اختر نوع الخدمة", Icons.miscellaneous_services_rounded),
          const SizedBox(height: 12),
          ...services.entries.map(
            (e) => _serviceTile(
              keyValue: e.key,
              title: e.value,
              icon: _serviceIcon(e.key),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationCard() {
    final loc = _effectiveLocation;
    final text = loc == null
        ? "غير محدد"
        : "${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}";

    return _buildCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: _primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.my_location_rounded,
                color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "موقع الطلب",
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: GoogleFonts.cairo(
                    color: _textSub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: loading ? null : _pickLocationOnMap,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _primary.withOpacity(.45)),
              foregroundColor: Colors.white,
              backgroundColor: _inputFill,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              "تحديد",
              style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estimateCard() {
    String fmt(double v) => v.toStringAsFixed(0);

    return _buildCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: _primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.payments_rounded,
                    color: Colors.white, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "السعر التقديري",
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (estimating)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: _primary,
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _primary.withOpacity(.28)),
                  ),
                  child: Text(
                    estimatedFare == null
                        ? "--"
                        : "${fmt(estimatedFare!)} $currency",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => showBreakdown = !showBreakdown),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Text(
                    showBreakdown ? "إخفاء التفاصيل" : "عرض تفاصيل السعر",
                    style: GoogleFonts.cairo(
                      color: _textSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    showBreakdown ? Icons.expand_less : Icons.expand_more,
                    color: _textSub,
                  ),
                ],
              ),
            ),
          ),
          if (showBreakdown) ...[
            const SizedBox(height: 12),
            ..._breakdownLines(),
          ],
        ],
      ),
    );
  }

  List<Widget> _breakdownLines() {
    String fmt(num? v) => (v ?? 0).toStringAsFixed(0);

    Widget line(String k, String v) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _inputFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    k,
                    style: GoogleFonts.cairo(
                      color: _textSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  v,
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );

    final baseFee = (fareBreakdown["baseFee"] as num?) ?? 0;
    final serviceFee = (fareBreakdown["serviceFee"] as num?) ?? 0;
    final tax = (fareBreakdown["tax"] as num?) ?? 0;
    final surge = (fareBreakdown["surgeMultiplier"] as num?) ?? 1.0;
    final discount = (fareBreakdown["discount"] as num?) ?? 0;
    final note = fareBreakdown["note"]?.toString();

    final out = <Widget>[
      line("رسوم أساسية", "${fmt(baseFee)} $currency"),
      line("رسوم خدمة", "${fmt(serviceFee)} $currency"),
      line("ضريبة", "${fmt(tax)} $currency"),
      if (surge.toDouble() > 1.0) line("Surge", "x${surge.toStringAsFixed(1)}"),
      if (discount.toDouble() > 0) line("خصم", "-${fmt(discount)} $currency"),
    ];

    if (note != null && note.trim().isNotEmpty) {
      out.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            note,
            style: GoogleFonts.cairo(
              color: _textSub.withOpacity(.85),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    return out;
  }

  Widget _notesCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("ملاحظات إضافية", Icons.edit_note_rounded),
          const SizedBox(height: 12),
          TextField(
            controller: notesCtrl,
            maxLines: 2,
            style: GoogleFonts.cairo(
              color: _textMain,
              fontWeight: FontWeight.w700,
            ),
            decoration: _fieldDecoration(
              "مثال: العربية مش بتدور / أنا واقف عند محطة ...",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: promoCtrl,
            style: GoogleFonts.cairo(
              color: _textMain,
              fontWeight: FontWeight.w700,
            ),
            decoration: _fieldDecoration("Promo code (اختياري)"),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("طريقة الدفع", Icons.account_balance_wallet_rounded),
          const SizedBox(height: 12),
          Row(
            children: [
              _paymentItem("cash", "كاش", Icons.money_rounded),
              const SizedBox(width: 10),
              _paymentItem("card", "بطاقة", Icons.credit_card_rounded),
              const SizedBox(width: 10),
              _paymentItem(
                "wallet",
                "محفظة",
                Icons.account_balance_wallet_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
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
        child: ElevatedButton(
          onPressed: loading ? null : _confirmAndCreateOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  "طلب الفني الآن",
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _estimateDebounce?.cancel();
    notesCtrl.dispose();
    promoCtrl.dispose();
    super.dispose();
  }
}

// ============================================================
// Pick location on map sheet
// ============================================================
class _PickOnMapSheet extends StatefulWidget {
  final LatLng initial;
  const _PickOnMapSheet({required this.initial});

  @override
  State<_PickOnMapSheet> createState() => _PickOnMapSheetState();
}

class _PickOnMapSheetState extends State<_PickOnMapSheet> {
  late LatLng picked = widget.initial;
  GoogleMapController? c;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFF10233E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 56,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: picked, zoom: 16),
                  onMapCreated: (cc) => c = cc,
                  onCameraMove: (pos) => picked = pos.target,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
                const Center(
                  child: Icon(Icons.place, color: Colors.amber, size: 42),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, picked),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "تأكيد الموقع",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Confirm order sheet
// ============================================================
class _ConfirmOrderSheet extends StatelessWidget {
  final String serviceName;
  final String paymentMethod;
  final double? estimatedFare;
  final String currency;
  final LatLng location;
  final String notes;

  const _ConfirmOrderSheet({
    required this.serviceName,
    required this.paymentMethod,
    required this.estimatedFare,
    required this.currency,
    required this.location,
    required this.notes,
  });

  String pmText() {
    if (paymentMethod == "card") return "بطاقة";
    if (paymentMethod == "wallet") return "محفظة";
    return "كاش";
  }

  @override
  Widget build(BuildContext context) {
    String fmt(double v) => v.toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF10233E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
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
            Text(
              "تأكيد الطلب",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _row("الخدمة", serviceName),
            _row("الدفع", pmText()),
            _row(
              "السعر التقديري",
              estimatedFare == null ? "--" : "${fmt(estimatedFare!)} $currency",
            ),
            _row(
              "الموقع",
              "${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}",
            ),
            if (notes.trim().isNotEmpty) _row("ملاحظات", notes),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF0D2140),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "رجوع",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "تأكيد",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2140),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: Text(
                k,
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                v,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
