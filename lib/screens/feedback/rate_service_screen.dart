import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateServiceScreen extends StatefulWidget {
  final String orderId;

  const RateServiceScreen({super.key, required this.orderId});

  @override
  State<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends State<RateServiceScreen> {
  double rating = 0.0;
  final comment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقييم الخدمة"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              "ما رأيك في الخدمة؟",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            RatingBar.builder(
              minRating: 1,
              itemBuilder: (ctx, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (v) => rating = v,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: comment,
              decoration: InputDecoration(
                hintText: "هل لديك ملاحظات؟ (اختياري)",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("👍 تم إرسال التقييم بنجاح"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text("إرسال التقييم",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
