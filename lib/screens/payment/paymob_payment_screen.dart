import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobPaymentScreen extends StatelessWidget {
  final String url;

  const PaymobPaymentScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(
        title: const Text("الدفع الإلكتروني"),
        backgroundColor: Colors.blueAccent,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
