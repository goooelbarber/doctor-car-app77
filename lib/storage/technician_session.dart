import 'package:shared_preferences/shared_preferences.dart';

class TechnicianSession {
  static const _kTechId = 'technician_id';
  static const _kToken = 'technician_token';

  static Future<void> save({
    required String technicianId,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTechId, technicianId);
    if (token != null) await prefs.setString(_kToken, token);
  }

  static Future<String?> getTechnicianId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTechId);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTechId);
    await prefs.remove(_kToken);
  }
}
