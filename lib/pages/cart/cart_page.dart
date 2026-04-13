import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<_CartItem> items = [
    _CartItem(
      title: "Oil Filter Premium",
      subtitle: "فلتر زيت أصلي - أداء احترافي",
      price: 150,
      qty: 1,
      image: "https://i.ibb.co/VmYnyjK/oilfilter.jpg",
      inStock: true,
    ),
    _CartItem(
      title: "Brake Pads Pro",
      subtitle: "فحمات فرامل عالية الجودة",
      price: 220,
      qty: 2,
      image: "https://i.ibb.co/VmYnyjK/oilfilter.jpg",
      inStock: true,
    ),
    _CartItem(
      title: "Battery 70A",
      subtitle: "بطارية مضمونة لسيارات متعددة",
      price: 250,
      qty: 1,
      image: "https://i.ibb.co/VmYnyjK/oilfilter.jpg",
      inStock: true,
    ),
  ];

  // ignore: unused_field
  static const Color _bg = Color(0xFF07111B);
  static const Color _bg2 = Color(0xFF0B1624);
  static const Color _bg3 = Color(0xFF040A12);
  static const Color _surface = Color(0xFF101C2B);

  static const Color _brand = Color.fromARGB(255, 17, 103, 189);
  static const Color _brandSoft = Color(0xFF8FD3FF);

  static const Color _textMain = Color(0xFFF5F7FB);
  static const Color _textSub = Color(0xFFB8C5D4);
  static const Color _textHint = Color(0xFF8EA1B5);
  static const Color _success = Color(0xFF7DD3AE);
  static const Color _danger = Color(0xFFFF7B7B);

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

  List<BoxShadow> get _blueGlow => [
        BoxShadow(
          color: _brandSoft.withOpacity(.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: _brand.withOpacity(.16),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  int get totalItems => items.fold(0, (sum, item) => sum + item.qty);

  double get subtotal =>
      items.fold(0, (sum, item) => sum + (item.price * item.qty));

  double get shipping => items.isEmpty ? 0 : 35;
  double get tax => subtotal * 0.15;
  double get total => subtotal + shipping + tax;

  void _completeOrder() {
    if (items.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: _bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _success.withOpacity(.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: _success.withOpacity(.25)),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: _success,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "تأكيد إتمام الطلب",
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "الإجمالي: ${total.toStringAsFixed(0)} ريال\nعدد العناصر: $totalItems",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: _textSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(color: Colors.white.withOpacity(.14)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "إلغاء",
                          style: GoogleFonts.cairo(
                            color: _textMain,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showSuccessDialog();
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: _buttonGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _blueGlow,
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              "تأكيد الطلب",
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
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
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: _bg2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "تم الطلب بنجاح",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: _textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            "تم إرسال طلبك بنجاح وجاري مراجعته.",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: _textSub,
              fontWeight: FontWeight.w700,
              height: 1.7,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => items.clear());
                },
                child: Text(
                  "تم",
                  style: GoogleFonts.cairo(
                    color: _brandSoft,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
                    child: items.isEmpty
                        ? _emptyState()
                        : CustomScrollView(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverList.separated(
                                  itemCount: items.length,
                                  itemBuilder: (_, i) =>
                                      _cartItemCard(items[i], i),
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 26),
                              ),
                            ],
                          ),
                  ),
                  if (items.isNotEmpty) _checkoutSection(),
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
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CartBackgroundPainter(
                lineColor: Colors.white.withOpacity(.022),
                glowColor: _brandSoft.withOpacity(.05),
              ),
            ),
          ),
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
              "السلة",
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
            icon: Icons.delete_sweep_outlined,
            onTap: () {
              setState(() => items.clear());
            },
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
                boxShadow: _blueGlow,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
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
                    "لديك $totalItems عنصر في السلة",
                    style: GoogleFonts.cairo(
                      color: _textMain,
                      fontSize: 14.6,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "راجع العناصر قبل إتمام الطلب",
                    style: GoogleFonts.cairo(
                      color: _textHint,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${subtotal.toStringAsFixed(0)} ريال",
              style: GoogleFonts.cairo(
                color: _brandSoft,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartItemCard(_CartItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: _cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _stroke),
        boxShadow: _softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 92,
                height: 92,
                color: _surface,
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white.withOpacity(.55),
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 92,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: _textMain,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: _textHint,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: item.inStock
                                ? _success.withOpacity(.12)
                                : _danger.withOpacity(.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: item.inStock
                                  ? _success.withOpacity(.24)
                                  : _danger.withOpacity(.24),
                            ),
                          ),
                          child: Text(
                            item.inStock ? "متوفر" : "غير متوفر",
                            style: GoogleFonts.cairo(
                              color: item.inStock ? _success : _danger,
                              fontSize: 10.8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${item.price.toStringAsFixed(0)} ريال",
                          style: GoogleFonts.cairo(
                            color: _brandSoft,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() => items.removeAt(index));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _danger.withOpacity(.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _danger.withOpacity(.18)),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: _danger,
                      size: 20,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _softStroke),
                  ),
                  child: Row(
                    children: [
                      _qtyBtn(Icons.add_rounded, () {
                        setState(() => item.qty++);
                      }),
                      SizedBox(
                        width: 26,
                        child: Center(
                          child: Text(
                            "${item.qty}",
                            style: GoogleFonts.cairo(
                              color: _textMain,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.2,
                            ),
                          ),
                        ),
                      ),
                      _qtyBtn(Icons.remove_rounded, () {
                        if (item.qty > 1) {
                          setState(() => item.qty--);
                        }
                      }),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: _textMain,
          size: 14,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: _cardGradient,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _stroke),
            boxShadow: _softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: _buttonGradient,
                  shape: BoxShape.circle,
                  boxShadow: _blueGlow,
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "السلة فارغة",
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "ابدأ بإضافة المنتجات التي تحتاجها وستظهر هنا بشكل منظم واحترافي.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: _textSub,
                  fontSize: 13,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkoutSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: _bg2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.34),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _priceRow("المجموع الفرعي", "${subtotal.toStringAsFixed(0)} ريال"),
            const SizedBox(height: 10),
            _priceRow("الشحن", "${shipping.toStringAsFixed(0)} ريال"),
            const SizedBox(height: 10),
            _priceRow("الضريبة", "${tax.toStringAsFixed(0)} ريال"),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14),
              height: 1,
              color: Colors.white.withOpacity(.07),
            ),
            _priceRow(
              "الإجمالي النهائي",
              "${total.toStringAsFixed(0)} ريال",
              strong: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _completeOrder,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _buttonGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: _blueGlow,
                  ),
                  child: Center(
                    child: Text(
                      "إتمام الطلب",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 15.8,
                        fontWeight: FontWeight.w900,
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

  Widget _priceRow(String title, String value, {bool strong = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              color: strong ? _textMain : _textSub,
              fontSize: strong ? 15.5 : 13.5,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: strong ? _brandSoft : _textMain,
            fontSize: strong ? 16 : 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CartItem {
  String title;
  String subtitle;
  double price;
  int qty;
  String image;
  bool inStock;

  _CartItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.qty,
    required this.image,
    required this.inStock,
  });
}

class _CartBackgroundPainter extends CustomPainter {
  final Color lineColor;
  final Color glowColor;

  const _CartBackgroundPainter({
    required this.lineColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path1 = Path()
      ..moveTo(0, size.height * .16)
      ..quadraticBezierTo(
        size.width * .24,
        size.height * .07,
        size.width * .55,
        size.height * .16,
      )
      ..quadraticBezierTo(
        size.width * .82,
        size.height * .24,
        size.width,
        size.height * .15,
      );

    final path2 = Path()
      ..moveTo(0, size.height * .54)
      ..quadraticBezierTo(
        size.width * .22,
        size.height * .46,
        size.width * .50,
        size.height * .58,
      )
      ..quadraticBezierTo(
        size.width * .80,
        size.height * .66,
        size.width,
        size.height * .56,
      );

    final path3 = Path()
      ..moveTo(0, size.height * .88)
      ..quadraticBezierTo(
        size.width * .22,
        size.height * .82,
        size.width * .48,
        size.height * .90,
      )
      ..quadraticBezierTo(
        size.width * .76,
        size.height * .99,
        size.width,
        size.height * .90,
      );

    canvas.drawPath(path1, glowPaint);
    canvas.drawPath(path2, linePaint);
    canvas.drawPath(path3, linePaint);

    final dotPaint = Paint()..color = glowColor.withOpacity(.9);
    for (double x = 18; x < size.width; x += 58) {
      canvas.drawCircle(Offset(x, size.height * .22), 1.2, dotPaint);
    }
    for (double x = 8; x < size.width; x += 62) {
      canvas.drawCircle(Offset(x, size.height * .74), 1.1, dotPaint);
    }

    final diagonalPaint = Paint()
      ..color = Colors.white.withOpacity(.014)
      ..strokeWidth = 1;

    for (double x = -40; x < size.width + 80; x += 30) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 80, size.height),
        diagonalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
