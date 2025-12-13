import 'package:flutter/material.dart';
import 'paymob_checkout_screen.dart';
import 'feedback_screen.dart';

class MoveWorkshopScreen extends StatelessWidget {
  final String orderId;
  final String userId;

  const MoveWorkshopScreen({
    super.key,
    required this.orderId,
    required this.userId,
  });

  void _confirmMove(BuildContext context) async {
    // بعد التأكيد → نفتح الدفع
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymobCheckoutScreen(
          amount: 200, // سعر نقل السيارة للورشة (اختياري للتجربة)
          orderId: orderId, iframeUrl: '',
        ),
      ),
    );

    if (result == "success") {
      // بعدها التقييم
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FeedbackScreen(
            orderId: orderId,
            userId: userId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("نقل السيارة للورشة"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(Icons.local_shipping, size: 90, color: Colors.blue),

            const SizedBox(height: 20),

            const Text(
              "هل ترغب في نقل السيارة إلى الورشة؟",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            const Text(
              "الفني لم يتمكن من إصلاح العطل بالكامل، يمكنك سحب السيارة للورشة لاستكمال الإصلاح.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            /// زر نعم → انتقال للدفع
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _confirmMove(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "نعم، أرسل السيارة للورشة",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// زر لا → رجوع
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "لا، العودة للصفحة السابقة",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
// TODO Implement this library.
