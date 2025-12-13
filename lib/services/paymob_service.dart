import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PaymobService {
  static Future<dynamic> createOrder(int amount) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/payments/create-order");

    final res = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": amount}));

    return jsonDecode(res.body);
  }

  static Future<dynamic> getPaymentKey({
    required int amount,
    required int orderId,
    required String method,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/payments/payment-key");

    final billing = {
      "apartment": "NA",
      "email": "customer@test.com",
      "floor": "NA",
      "first_name": "User",
      "last_name": "DoctorCar",
      "street": "Cairo",
      "building": "NA",
      "phone_number": "+201275649151",
      "city": "Cairo",
      "country": "EG",
      "state": "NA"
    };

    final res = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": amount,
          "orderId": orderId,
          "method": method, // card / wallet / kiosk
          "billingData": billing
        }));

    return jsonDecode(res.body);
  }
}
