import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 تم إضافة الاستيراد هنا

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'preferred_locale';
  Locale _appLocale = const Locale('ar'); // 1. تعيين اللغة الافتراضية

  LocaleProvider() {
    _loadLocale(); // تحميل اللغة المحفوظة عند إنشاء الكائن
  }

  Locale get appLocale => _appLocale;

  // 🛠️ 1. دالة تحميل اللغة من SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localeKey);

    if (savedCode != null) {
      // إذا كانت هناك لغة محفوظة، نستخدمها
      _appLocale = Locale(savedCode);
    } else {
      // إذا لم يكن هناك لغة محفوظة، نستخدم الافتراضية 'ar' ونحفظها
      _appLocale = const Locale('ar');
      await prefs.setString(_localeKey, 'ar');
    }
    notifyListeners(); // إشعار التطبيق باللغة بعد التحميل
  }

  // 🛠️ 2. دالة حفظ اللغة في SharedPreferences
  Future<void> _saveLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }

  // 🚀 3. دالة تغيير اللغة وحفظها
  void setLocale(Locale newLocale) {
    if (_appLocale.languageCode != newLocale.languageCode) {
      _appLocale = newLocale;
      // حفظ اللغة الجديدة
      _saveLocale(newLocale.languageCode);
      // إرسال إشعار للمستمعين (مثل MaterialApp) لإعادة البناء
      notifyListeners();
    }
  }
}
