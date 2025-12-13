import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'review_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;

  const PaymentScreen({super.key, required this.orderId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selected = "cash";
  final String walletNumber = "01275649151";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("الدفع",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "اختر طريقة الدفع",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            _paymentCard(
              id: "cash",
              title: "الدفع نقدًا",
              subtitle: "الدفع عند إتمام الخدمة",
              icon: Icons.money_rounded,
              color: Colors.green,
            ),
            _paymentCard(
              id: "visa",
              title: "فيزا / ماستر كارد",
              subtitle: "الدفع الإلكتروني عبر البطاقة",
              icon: Icons.credit_card_rounded,
              color: Colors.blueAccent,
            ),
            _paymentCard(
              id: "wallet",
              title: "محفظة فودافون كاش",
              subtitle: "تحويل للمحفظة",
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.redAccent,
            ),
            if (selected == "wallet") _walletBox(),
            const SizedBox(height: 35),
            _totalCard(),
            const SizedBox(height: 35),
            _payButton(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // PAYMENT CARD (Apple-style card)
  // ---------------------------------------------------------
  Widget _paymentCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    bool isActive = selected == id;

    return GestureDetector(
      onTap: () => setState(() => selected = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
            width: isActive ? 2.2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 6),
              color: Colors.black12.withOpacity(.05),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            Icon(
              isActive ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 28,
              color: isActive ? color : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // Wallet (Vodafone Cash Box)
  // ---------------------------------------------------------
  Widget _walletBox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.redAccent, width: 2),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.redAccent.withOpacity(.08),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("للدفع عبر فودافون كاش:",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  walletNumber,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 28),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: walletNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم نسخ رقم المحفظة"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "قم بتحويل المبلغ ثم اضغط \"دفع الآن\" لإتمام الطلب.",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // TOTAL CARD — 3D Apple Style
  // ---------------------------------------------------------
  Widget _totalCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black12.withOpacity(.1),
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("التكلفة الإجمالية",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          SizedBox(height: 14),
          Text(
            "150.00 ج.م",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // PAY BUTTON — Apple Pay Style
  // ---------------------------------------------------------
  Widget _payButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewScreen(orderId: widget.orderId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 6,
        ),
        child: const Text(
          "دفع الآن",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
