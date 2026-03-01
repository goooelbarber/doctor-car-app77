// PATH: lib/screens/home/home_strings.dart
part of '../home_screen.dart';

extension _HomeStrings on _HomeScreenState {
  // ================== TRANSLATIONS ==================
  Map<String, Map<String, String>> get _strings => const {
        "home": {"ar": "الرئيسية", "en": "Home"},
        "account": {"ar": "حسابي", "en": "Account"},
        "vehicles": {"ar": "مركباتي", "en": "Vehicles"},
        "orders": {"ar": "الطلبات", "en": "Orders"},
        "offers": {"ar": "عروض مراكز الصيانة", "en": "Maintenance Offers"},
        "nearby": {"ar": "مراكز قريبة منك", "en": "Nearby Centers"},
        "urgent": {"ar": "خدمة الطريق", "en": "Road Service"},
        "maint": {"ar": "خدمات الصيانة", "en": "Maintenance"},
        "contact": {"ar": "تواصل معنا", "en": "Contact Us"},
        "how": {"ar": "ازاي تستخدم Doctor Car", "en": "How to use Doctor Car"},
        "why": {"ar": "ليه تختار Doctor Car؟", "en": "Why Doctor Car?"},
        "getOffer": {"ar": "احصل على العرض", "en": "Get Offer"},
        "supportChat": {
          "ar": "الدعم الفني (شات مباشر)",
          "en": "Support (Live Chat)"
        },
        "supportSub": {
          "ar": "تواصل فورًا مع الدعم أو الميكانيكي",
          "en": "Chat with support instantly"
        },
        "emergency": {"ar": "طوارئ 112", "en": "Emergency 112"},
        "emergencySub": {
          "ar": "للحوادث والمواقف الخطيرة فقط",
          "en": "For serious emergencies only"
        },
        "loginFirst": {
          "ar": "يجب تسجيل الدخول أولاً",
          "en": "Please login first"
        },
        "chatError": {
          "ar": "حدث خطأ أثناء فتح الشات",
          "en": "Failed to open chat"
        },
        "callFail": {
          "ar": "لا يمكن فتح الاتصال على هذا الجهاز",
          "en": "Cannot place a call on this device"
        },
        "loadFail": {
          "ar": "تعذر تحميل المراكز",
          "en": "Failed to load centers"
        },
        "retry": {"ar": "إعادة المحاولة", "en": "Retry"},
        "details": {"ar": "تفاصيل", "en": "Details"},
        "noCenters": {
          "ar": "لا يوجد مراكز قريبة الآن",
          "en": "No nearby centers right now"
        },
        "needLocation": {
          "ar": "فعّل الموقع لعرض أقرب المراكز",
          "en": "Enable location to show nearby centers"
        },
        "openSettings": {"ar": "فتح الإعدادات", "en": "Open Settings"},
        "locating": {
          "ar": "جارٍ تحديد موقعك...",
          "en": "Detecting your location..."
        },
        "yourLocation": {"ar": "موقعك", "en": "Your location"},
        "radius": {"ar": "النطاق", "en": "Radius"},
      };

  String trKey(String key) => _strings[key]?[_isArabic ? "ar" : "en"] ?? "";
}
