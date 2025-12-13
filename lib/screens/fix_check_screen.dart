import 'package:flutter/material.dart';
// ignore: unused_import
import 'move_workshop_screen.dart';
import 'paymob_checkout_screen.dart';

class FixCheckScreen extends StatelessWidget {
  final String orderId;
  final String userId;
  final int amount;

  const FixCheckScreen({
    super.key,
    required this.orderId,
    required this.userId,
    required this.amount,
  });

  void _goToPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymobCheckoutScreen(
          amount: amount,
          orderId: orderId,
          iframeUrl: '',
        ),
      ),
    );
  }

  void _goToWorkshop(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoveWorkshopScreen(
          orderId: orderId,
          userId: userId,
        ),
      ),
    );
  }

  void _stayHome(BuildContext context) {
    Navigator.pop(context); // يرجع للخريطة أو الشاشة السابقة
  }

  // نافذة تختار هل تريد الذهاب للورشة؟
  void _askWorkshop(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "هل تريد الذهاب للورشة؟",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "الفني لم يتمكن من إصلاح العطل بالكامل. يمكنك الانتقال للورشة أو العودة للمنزل.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _stayHome(context);
            },
            child: const Text(
              "العودة للمنزل",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToWorkshop(context);
            },
            child: const Text(
              "الذهاب للورشة",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        title: const Text("هل تم إصلاح العطل؟"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 30),

            /// Icon
            const Icon(Icons.build_circle, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 25),

            /// Title
            const Text(
              "هل تم إصلاح المشكلة؟",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const Text(
              "يرجى تحديد ما إذا تم حل المشكلة أم لا، للمتابعة في الإجراء التالي.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            /// زر تم الإصلاح — Yes
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _goToPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "نعم، تم الإصلاح — الانتقال للدفع",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// زر لم يتم الإصلاح — No
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _askWorkshop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "لا، المشكلة لم تُحل",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  MoveWorkshopScreen({required String orderId, required String userId}) {}
}
