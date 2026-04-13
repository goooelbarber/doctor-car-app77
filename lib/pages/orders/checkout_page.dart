import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int selectedPayment = 0;
  int selectedAddress = 0;

  // ignore: unused_field
  static const Color _bg = Color(0xFF07111B);
  static const Color _bg2 = Color(0xFF0B1624);
  static const Color _bg3 = Color(0xFF040B14);

  static const Color _brand = Color(0xFF1E6FD9);
  static const Color _brandSoft = Color(0xFF8FD3FF);
  static const Color _success = Color(0xFF7DD3AE);
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

  double get subtotal => 620;
  double get shipping => 35;
  double get tax => subtotal * 0.15;
  double get total => subtotal + shipping + tax;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg3,
        bottomNavigationBar: _bottomPayBar(),
        body: Stack(
          children: [
            _backgroundDecor(),
            SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _summaryCard(),
                          const SizedBox(height: 18),
                          _sectionTitle("عنوان التوصيل"),
                          _addressSelector(),
                          const SizedBox(height: 18),
                          _sectionTitle("طريقة الدفع"),
                          _paymentSelector(),
                          const SizedBox(height: 18),
                          _sectionTitle("ملخص الفاتورة"),
                          _invoiceCard(),
                          const SizedBox(height: 18),
                          _sectionTitle("ملاحظات الطلب"),
                          _notesBox(),
                        ],
                      ),
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
          bottom: -100,
          left: -30,
          child: _glowOrb(210, _brand.withOpacity(.08)),
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
              "إتمام الطلب",
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
            icon: Icons.lock_outline_rounded,
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

  Widget _summaryCard() {
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
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: _buttonGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.credit_score_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "دفع آمن ومشفر",
                    style: GoogleFonts.cairo(
                      color: _textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "أكمل عملية الدفع بثقة وسرعة",
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
              "${total.toStringAsFixed(0)} ريال",
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: _buttonGradient,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: _textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressSelector() {
    final addresses = [
      "المنزل - الرياض، حي الياسمين",
      "العمل - الرياض، طريق الملك فهد",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(addresses.length, (i) {
          final active = selectedAddress == i;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => selectedAddress = i),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: active ? _cardGradient : null,
                  color: active ? null : Colors.white.withOpacity(.04),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: active ? _brandSoft.withOpacity(.30) : _softStroke,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      active
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: active ? _brandSoft : _textHint,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        addresses[i],
                        style: GoogleFonts.cairo(
                          color: _textMain,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _paymentSelector() {
    final methods = [
      {"icon": Icons.credit_card_rounded, "title": "بطاقة بنكية"},
      {
        "icon": Icons.account_balance_wallet_rounded,
        "title": "محفظة إلكترونية"
      },
      {"icon": Icons.payments_outlined, "title": "الدفع عند الاستلام"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(methods.length, (i) {
          final active = selectedPayment == i;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => selectedPayment = i),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: active ? _cardGradient : null,
                  color: active ? null : Colors.white.withOpacity(.04),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: active ? _brandSoft.withOpacity(.30) : _softStroke,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: active ? _buttonGradient : null,
                        color: active ? null : Colors.white.withOpacity(.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        methods[i]["icon"] as IconData,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        methods[i]["title"] as String,
                        style: GoogleFonts.cairo(
                          color: _textMain,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    Icon(
                      active
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: active ? _success : _textHint,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _invoiceCard() {
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
        child: Column(
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
          ],
        ),
      ),
    );
  }

  Widget _notesBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: _cardGradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _softStroke),
        ),
        child: TextField(
          maxLines: 4,
          style: GoogleFonts.cairo(color: _textMain),
          decoration: InputDecoration(
            hintText: "أضف ملاحظاتك هنا...",
            hintStyle: GoogleFonts.cairo(color: _textHint),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _bottomPayBar() {
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    "الإجمالي",
                    style: GoogleFonts.cairo(
                      color: _textSub,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  "${total.toStringAsFixed(0)} ريال",
                  style: GoogleFonts.cairo(
                    color: _brandSoft,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
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
                  ),
                  child: Center(
                    child: Text(
                      "تأكيد الدفع",
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
              fontSize: strong ? 15.2 : 13.5,
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
