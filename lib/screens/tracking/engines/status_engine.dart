import 'package:flutter/material.dart';

class StatusEngine {
  /// الحالة الحالية (جاية من السيرفر)
  /// أمثلة: searching | assigned | in_progress | arrived | completed | canceled | failed
  String status = "searching";

  /// تحديث الحالة (آمن)
  void update(String newStatus) {
    status = newStatus;
  }

  /// ============================
  /// TEXT (Uber-like)
  /// ============================
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

      case "canceled":
        return "❌ تم إلغاء الطلب";

      case "failed":
        return "⚠️ تعذر تنفيذ الطلب";

      case "timeout":
        return "⌛ لم يتم العثور على فني";

      default:
        return "🔍 جاري البحث عن أقرب فني…";
    }
  }

  /// ============================
  /// ICON
  /// ============================
  IconData getStatusIcon() {
    switch (status) {
      case "assigned":
        return Icons.directions_car;

      case "in_progress":
        return Icons.build_circle;

      case "arrived":
        return Icons.location_on;

      case "completed":
        return Icons.check_circle;

      case "canceled":
        return Icons.cancel;

      case "failed":
        return Icons.error;

      case "timeout":
        return Icons.hourglass_bottom;

      default:
        return Icons.search;
    }
  }

  /// ============================
  /// HELPERS (اختياري لكن مفيد)
  /// ============================
  bool get isSearching => status == "searching";
  bool get isAssigned => status == "assigned";
  bool get isArrived => status == "arrived";
  bool get isCompleted => status == "completed";
  bool get isCanceled => status == "canceled" || status == "failed";
}
