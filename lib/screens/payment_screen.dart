// PATH: lib/screens/payment_screen.dart
// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import 'review_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double? amount;
  final String? serviceType;

  const PaymentScreen({
    super.key,
    required this.orderId,
    this.amount,
    this.serviceType,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // ================== THEME ==================
  static const Color _bg = Color(0xFF0B1220);

  Color get _surface => const Color(0xFF10233E);
  Color get _surface2 => const Color(0xFF17345F);
  Color get _surface3 => const Color(0xFF0D2140);

  Color get _primary => AppTheme.accent;
  Color get _primaryDark => AppTheme.accentDark;
  // ignore: unused_element
  Color get _primarySoft => AppTheme.accentSoft;
  Color get _textMain => AppTheme.textLight;
  Color get _textSub => AppTheme.muted;
  Color get _danger => AppTheme.danger;
  Color get _success => const Color(0xFF22C55E);
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
  String selected = "cash";
  final String walletNumber = "01275649151";
  bool _isPaying = false;

  late final double servicePrice;
  final double discount = 0;
  final double serviceFee = 5;
  final double taxRate = 0.05;

  double get taxValue => ((servicePrice - discount) + serviceFee) * taxRate;
  double get total => (servicePrice - discount) + serviceFee + taxValue;

  @override
  void initState() {
    super.initState();
    servicePrice = widget.amount ?? 120;
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
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  String _selectedPaymentTitle() {
    switch (selected) {
      case "cash":
        return "الدفع نقدًا";
      case "visa":
        return "فيزا / ماستر كارد";
      case "wallet":
        return "فودافون كاش";
      default:
        return "الدفع";
    }
  }

  String _paymentHintText() {
    switch (selected) {
      case "cash":
        return "هتدفع للمندوب بعد انتهاء الخدمة مباشرة.";
      case "wallet":
        return "حوّل المبلغ على رقم المحفظة ثم اضغط تأكيد الدفع.";
      case "visa":
        return "الدفع الإلكتروني هيتم بشكل آمن بعد التأكيد.";
      default:
        return "";
    }
  }

  IconData _paymentIcon() {
    switch (selected) {
      case "cash":
        return Icons.payments_rounded;
      case "visa":
        return Icons.credit_card_rounded;
      case "wallet":
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Color _paymentColor() {
    switch (selected) {
      case "cash":
        return _primary;
      case "visa":
        return _primaryDark;
      case "wallet":
        return _danger;
      default:
        return _primary;
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

  // ================== BUILD ==================
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: _pageGradient)),
            _content(),
            if (_isPaying) _loadingOverlay(),
          ],
        ),
      ),
    );
  }

  // ================== CONTENT ==================
  Widget _content() {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 14, 16, 24 + bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            _paymentStatusCard(),
            const SizedBox(height: 16),
            Text(
              "اختر طريقة الدفع",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 14),
            _paymentCard(
              id: "cash",
              title: "الدفع نقدًا",
              subtitle: "ادفع بعد انتهاء الخدمة",
              icon: Icons.payments_rounded,
              accent: _primary,
            ),
            _paymentCard(
              id: "visa",
              title: "فيزا / ماستر كارد",
              subtitle: "دفع إلكتروني آمن وسريع",
              icon: Icons.credit_card_rounded,
              accent: _primaryDark,
            ),
            _paymentCard(
              id: "wallet",
              title: "فودافون كاش",
              subtitle: "تحويل مباشر إلى المحفظة",
              icon: Icons.account_balance_wallet_rounded,
              accent: _danger,
            ),
            if (selected == "wallet") ...[
              const SizedBox(height: 10),
              _walletBox(),
            ],
            const SizedBox(height: 18),
            _invoiceCard(),
            const SizedBox(height: 14),
            _paymentNote(),
            const SizedBox(height: 20),
            _payButton(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    final serviceName = (widget.serviceType ?? "").trim();

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
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "الدفع",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceName.isEmpty
                          ? "إتمام عملية الدفع للخدمة"
                          : "الخدمة: $serviceName",
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
                Icons.payments_rounded,
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
                  icon: Icons.account_balance_wallet_rounded,
                  value: "${total.toStringAsFixed(0)} ج.م",
                  label: "الإجمالي",
                  darkCard: true,
                ),
              ),
            ],
          ),
        ],
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

  Widget _paymentStatusCard() {
    final accent = _paymentColor();

    return _card(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accent.withOpacity(.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(.22)),
            ),
            child: Icon(_paymentIcon(), color: accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _selectedPaymentTitle(),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _paymentHintText(),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    color: _textSub,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== PAYMENT METHOD CARD ==================
  Widget _paymentCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    final bool isActive = selected == id;

    return InkWell(
      onTap: _isPaying
          ? null
          : () {
              HapticFeedback.selectionClick();
              setState(() => selected = id);
            },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? accent.withOpacity(.12) : _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? accent.withOpacity(.65) : _border,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: accent.withOpacity(.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isActive ? accent.withOpacity(.16) : _surface3,
                border: Border.all(
                  color: isActive ? accent.withOpacity(.26) : _border,
                ),
              ),
              child: Icon(icon, size: 28, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: _textSub,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isActive ? Icons.check_circle_rounded : Icons.circle_outlined,
                key: ValueKey(isActive),
                size: 24,
                color: isActive ? accent : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== WALLET BOX ==================
  Widget _walletBox() {
    return _card(
      withGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _danger.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.danger,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "رقم فودافون كاش",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _surface3,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Colors.white),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: walletNumber));
                    _snack("تم نسخ رقم المحفظة");
                  },
                ),
                Expanded(
                  child: Text(
                    walletNumber,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _textMain,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "حوّل المبلغ بالكامل ثم اضغط على تأكيد الدفع.",
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              color: _textSub,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openWhatsAppPayMessage,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _surface3,
                side: BorderSide(color: _danger.withOpacity(.55)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.chat_rounded, color: AppTheme.danger),
              label: Text(
                "إرسال رسالة واتساب",
                style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsAppPayMessage() async {
    final msg =
        "تم التحويل فودافون كاش ✅\nرقم الطلب: ${widget.orderId}\nالمبلغ: ${total.toStringAsFixed(0)} جنيه\nرقم المحفظة: $walletNumber";
    final uri = Uri.parse(
      "https://wa.me/2$walletNumber?text=${Uri.encodeComponent(msg)}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack("تعذر فتح واتساب");
    }
  }

  // ================== INVOICE ==================
  Widget _invoiceCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              _iconBadge(Icons.receipt_long_rounded, size: 42, iconSize: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "ملخص الفاتورة",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    color: _textMain,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _invoiceRow("سعر الخدمة", servicePrice),
          _invoiceRow("رسوم الخدمة", serviceFee),
          _invoiceRow("الضريبة", taxValue),
          if (discount != 0) _invoiceRow("خصم", -discount),
          const SizedBox(height: 10),
          Divider(color: Colors.white.withOpacity(.14), height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${total.toStringAsFixed(2)} ج.م",
                style: GoogleFonts.cairo(
                  color: _primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),
              Text(
                "الإجمالي النهائي",
                style: GoogleFonts.cairo(
                  color: _textMain,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "القيمة المعروضة شاملة الرسوم والضريبة.",
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              color: _success,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceRow(String t, double v) {
    final isNeg = v < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${v.toStringAsFixed(2)} ج.م",
            style: GoogleFonts.cairo(
              color: isNeg ? _danger : _textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            t,
            style: GoogleFonts.cairo(
              color: _textSub,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(
            selected == "wallet"
                ? Icons.account_balance_wallet_outlined
                : selected == "visa"
                    ? Icons.credit_card
                    : Icons.info_outline_rounded,
            color: selected == "wallet"
                ? _danger
                : selected == "visa"
                    ? _primaryDark
                    : _primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _paymentHintText(),
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                color: _textMain,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== PAY BUTTON ==================
  Widget _payButton() {
    final btnText = selected == "cash"
        ? "تأكيد الدفع نقدًا"
        : (selected == "wallet" ? "تأكيد فودافون كاش" : "تأكيد الدفع بالبطاقة");

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
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isPaying ? null : _pay,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _isPaying
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      btnText,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _pay() async {
    if (_isPaying) return;

    HapticFeedback.mediumImpact();
    setState(() => _isPaying = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isPaying = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(orderId: widget.orderId),
      ),
    );
  }

  // ================== LOADING ==================
  Widget _loadingOverlay() {
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
                "جاري تأكيد الدفع...",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "من فضلك متقفلش الشاشة",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                  color: _textSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
