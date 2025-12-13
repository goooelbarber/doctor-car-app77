import 'package:flutter/material.dart';

class StatusEngine {
  String status = "pending";

  /// نصوص الحالة حسب حالة الطلب
  String getStatusText(int eta) {
    switch (status) {
      case "assigned":
        return "🚗 الفني في الطريق — يصل خلال $eta دقيقة";
      case "in_progress":
        return "🔧 جاري تنفيذ خدمتك الآن";
      case "arrived":
        return "📍 الفني وصل إلى موقعك";
      case "completed":
        return "✔ تمت الخدمة — سيتم تحويلك للدفع";
      default:
        return "🔍 جاري البحث عن أقرب فني…";
    }
  }

  /// أيقونة الحالة
  IconData getStatusIcon() {
    switch (status) {
      case "assigned":
        return Icons.local_shipping;
      case "in_progress":
        return Icons.build_circle;
      case "arrived":
        return Icons.location_on;
      case "completed":
        return Icons.check_circle;
      default:
        return Icons.search;
    }
  }

  /// تحديث الحالة ببساطة
  void update(String newStatus) {
    status = newStatus;
  }
}
