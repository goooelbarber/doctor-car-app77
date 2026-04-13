import 'dart:ui';
import 'package:doctor_car_app/pages/orders/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  // ignore: unused_field
  static const Color _bg = Color(0xFF07111B);
  // ignore: unused_field
  static const Color _bg2 = Color(0xFF0B1624);
  static const Color _bg3 = Color(0xFF040B14);

  static const Color _brand = Color(0xFF1E6FD9);
  static const Color _brandSoft = Color(0xFF8FD3FF);
  static const Color _success = Color(0xFF7DD3AE);
  static const Color _warning = Color(0xFFFFC85C);

  static const Color _textMain = Color(0xFFF5F7FB);
  static const Color _textSub = Color(0xFFB8C5D4);
  static const Color _textHint = Color(0xFF8EA1B5);

  Color get _stroke => Colors.white.withOpacity(.08);
  Color get _softStroke => Colors.white.withOpacity(.05);

  LinearGradient get _screenBg => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A1830),
          Color(0xFF091321),
          Color(0xFF050B14),
        ],
      );

  LinearGradient get _cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(.09),
          Colors.white.withOpacity(.04),
          Colors.white.withOpacity(.02),
        ],
      );

  LinearGradient get _buttonGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2A8CFF),
          Color(0xFF0C5FB8),
        ],
      );

  List<BoxShadow> get _softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.26),
          blurRadius: 20,
          offset: const Offset(0, 12),
        ),
      ];

  List<_OrderVm> get _orders => const [
        _OrderVm(
          id: 1001,
          title: "طلب قطع صيانة دورية",
          itemCount: 3,
          total: 450,
          status: "قيد الشحن",
          statusType: _OrderStatus.shipping,
          eta: "خلال 24 ساعة",
          date: "اليوم",
        ),
        _OrderVm(
          id: 1002,
          title: "طلب بطارية + فلتر زيت",
          itemCount: 2,
          total: 370,
          status: "تم التأكيد",
          statusType: _OrderStatus.confirmed,
          eta: "جاري التجهيز",
          date: "أمس",
        ),
        _OrderVm(
          id: 1003,
          title: "طلب فحمات فرامل",
          itemCount: 1,
          total: 180,
          status: "تم التوصيل",
          statusType: _OrderStatus.delivered,
          eta: "مكتمل",
          date: "منذ 3 أيام",
        ),
        _OrderVm(
          id: 1004,
          title: "طلب زيت محرك",
          itemCount: 4,
          total: 620,
          status: "قيد المراجعة",
          statusType: _OrderStatus.review,
          eta: "بانتظار الدفع",
          date: "منذ 5 أيام",
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg3,
        body: Stack(
          children: [
            _backgroundDecor(),
            SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              _summaryStrip(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList.separated(
                            itemCount: _orders.length,
                            itemBuilder: (_, i) =>
                                _orderCard(context, _orders[i]),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 24),
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
    );
  }

  Widget _backgroundDecor() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(gradient: _screenBg),
          ),
        ),
        Positioned(
          top: -110,
          right: -70,
          child: _glowOrb(250, _brandSoft.withOpacity(.10)),
        ),
        Positioned(
          top: 260,
          left: -90,
          child: _glowOrb(210, _brand.withOpacity(.08)),
        ),
        Positioned(
          bottom: -100,
          right: -30,
          child: _glowOrb(210, _brandSoft.withOpacity(.08)),
        ),
      ],
    );
  }

  Widget _glowOrb(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 54, sigmaY: 54),
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

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Row(
        children: [
          _iconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "طلباتي",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _textMain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _iconBtn(
            icon: Icons.receipt_long_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _softStroke),
        ),
        child: Icon(icon, color: _textMain, size: 21),
      ),
    );
  }

  Widget _summaryStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _cardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _stroke),
          boxShadow: _softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: _buttonGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "إدارة الطلبات بسهولة",
                    style: GoogleFonts.cairo(
                      color: _textMain,
                      fontSize: 14.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "تتبع الطلبات والحالة والتكلفة في مكان واحد",
                    style: GoogleFonts.cairo(
                      color: _textHint,
                      fontSize: 11.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${_orders.length} طلب",
              style: GoogleFonts.cairo(
                color: _brandSoft,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(BuildContext context, _OrderVm order) {
    final statusColor = _statusColor(order.statusType);
    final statusIcon = _statusIcon(order.statusType);

    return Container(
      decoration: BoxDecoration(
        gradient: _cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _stroke),
        boxShadow: _softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "طلب #${order.id}",
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: _textMain,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: statusColor.withOpacity(.24)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        order.status,
                        style: GoogleFonts.cairo(
                          color: statusColor,
                          fontSize: 11.8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                order.title,
                style: GoogleFonts.cairo(
                  color: _textSub,
                  fontSize: 13.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _miniInfo(
                    icon: Icons.inventory_2_outlined,
                    title: "المنتجات",
                    value: "${order.itemCount}",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _miniInfo(
                    icon: Icons.payments_outlined,
                    title: "الإجمالي",
                    value: "${order.total} ريال",
                    valueColor: _brandSoft,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _miniInfo(
                    icon: Icons.schedule_rounded,
                    title: "الوصول",
                    value: order.eta,
                    valueColor: _warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  order.date,
                  style: GoogleFonts.cairo(
                    color: _textHint,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(.10)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    "تتبع الطلب",
                    style: GoogleFonts.cairo(
                      color: _textMain,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: _buttonGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      child: Text(
                        "عرض التفاصيل",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _miniInfo({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _softStroke),
      ),
      child: Column(
        children: [
          Icon(icon, color: _brandSoft, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              color: _textHint,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: valueColor ?? _textMain,
              fontSize: 12.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(_OrderStatus status) {
    switch (status) {
      case _OrderStatus.confirmed:
        return _brandSoft;
      case _OrderStatus.shipping:
        return _brand;
      case _OrderStatus.delivered:
        return _success;
      case _OrderStatus.review:
        return _warning;
    }
  }

  IconData _statusIcon(_OrderStatus status) {
    switch (status) {
      case _OrderStatus.confirmed:
        return Icons.verified_rounded;
      case _OrderStatus.shipping:
        return Icons.local_shipping_rounded;
      case _OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case _OrderStatus.review:
        return Icons.pending_actions_rounded;
    }
  }
}

enum _OrderStatus {
  confirmed,
  shipping,
  delivered,
  review,
}

class _OrderVm {
  final int id;
  final String title;
  final int itemCount;
  final double total;
  final String status;
  final _OrderStatus statusType;
  final String eta;
  final String date;

  const _OrderVm({
    required this.id,
    required this.title,
    required this.itemCount,
    required this.total,
    required this.status,
    required this.statusType,
    required this.eta,
    required this.date,
  });
}
