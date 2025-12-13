import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobTestScreen extends StatelessWidget {
  final String orderId;

  const PaymobTestScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse("https://accept.paymobsolutions.com/standalone?ref=testing"),
      );

    return Scaffold(
      appBar: AppBar(
        title: const Text("🧾 صفحة الدفع (نسخة تجريبية)"),
        backgroundColor: Colors.blueAccent,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
