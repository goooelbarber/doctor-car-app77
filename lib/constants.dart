import 'package:flutter/material.dart';

// 🎨 الألوان الأساسية
const Color kPrimaryColor = Color(0xFF0D47A1); // أزرق داكن
const Color kAccentColor = Color(0xFFFFCC80); // لون مميز
const Color kBackgroundColor = Color(0xFFF5F5F5); // خلفية التطبيق
const Color kSuccessColor = Color(0xFF4CAF50); // لون النجاح
const Color kErrorColor = Color(0xFFF44336); // لون الخطأ

// 💡 تعريف الـ ColorScheme (مخطط الألوان)
const ColorScheme customColorScheme = ColorScheme.light(
  primary: kPrimaryColor,
  secondary: kAccentColor,
  // ignore: deprecated_member_use
  background: kBackgroundColor,
  error: kErrorColor,
);
