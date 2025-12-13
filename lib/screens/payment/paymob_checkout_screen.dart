import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobCheckoutScreen extends StatelessWidget {
  final String iframeUrl;

  const PaymobCheckoutScreen(
      {super.key,
      required this.iframeUrl,
      required String orderId,
      required int amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الدفع"),
        backgroundColor: Colors.redAccent,
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(iframeUrl)),
      ),
    );
  }
}
