import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotifications {
  static const String _key = 'doctor_car_notifications';

  /// جلب جميع الإشعارات المخزنة
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  /// إضافة إشعار جديد
  static Future<void> addNotification({
    required String title,
    required String time,
    required String icon,
    required String color,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    notifications.insert(0, {
      'title': title,
      'time': time,
      'icon': icon,
      'color': color,
    });
    final encoded = notifications.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(_key, encoded);
  }

  /// حذف جميع الإشعارات
  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
