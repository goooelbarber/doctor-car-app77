import 'package:flutter/material.dart';

import 'change_password_screen.dart';
import 'devices_screen.dart';
import 'login_history_screen.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {
  bool twoFactorEnabled = true;
  bool appLockEnabled = false;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xffF6F7FB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "الأمان",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _securityScoreCard(),
          const SizedBox(height: 30),
          _sectionTitle("حماية الحساب"),
          const SizedBox(height: 12),
          _tile(
            icon: Icons.lock_outline,
            color: Colors.blue,
            title: "تغيير كلمة المرور",
            subtitle: "ننصح بتحديثها كل 3 أشهر",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          _tile(
            icon: Icons.phonelink_lock,
            color: Colors.deepPurple,
            title: "الأجهزة المتصلة",
            subtitle: "3 أجهزة • آخر نشاط اليوم",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DevicesScreen()),
            ),
          ),
          _switchRow(
            icon: Icons.verified_user,
            color: Colors.green,
            title: "التحقق بخطوتين (2FA)",
            subtitle: twoFactorEnabled
                ? "مفعل • حماية عالية"
                : "غير مفعل • ننصح بالتفعيل",
            value: twoFactorEnabled,
            onChanged: (v) {
              setState(() => twoFactorEnabled = v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    v ? "تم تفعيل التحقق بخطوتين" : "تم إيقاف التحقق بخطوتين",
                  ),
                ),
              );
            },
          ),
          _tile(
            icon: Icons.history,
            color: Colors.orange,
            title: "سجل تسجيل الدخول",
            subtitle: "مراجعة كل محاولات الدخول",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginHistoryScreen()),
            ),
          ),
          const SizedBox(height: 30),
          _sectionTitle("أمان التطبيق"),
          const SizedBox(height: 12),
          _switchRow(
            icon: Icons.fingerprint,
            color: Colors.teal,
            title: "قفل التطبيق",
            subtitle: "بصمة / Face ID",
            value: appLockEnabled,
            onChanged: (v) {
              setState(() => appLockEnabled = v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    v ? "تم تفعيل قفل التطبيق" : "تم إيقاف قفل التطبيق",
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          _sectionTitle("منطقة الخطر"),
          const SizedBox(height: 12),
          _dangerTile(
            icon: Icons.logout,
            title: "تسجيل الخروج من كل الأجهزة",
            subtitle: "سيتم إنهاء جميع الجلسات النشطة",
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );

  Widget _securityScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(.85),
            Colors.green.withOpacity(.55),
          ],
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.security, color: Colors.white, size: 42),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("مستوى أمان الحساب",
                  style: TextStyle(color: Colors.white70)),
              SizedBox(height: 6),
              Text(
                "قوي جداً",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _baseCard(
      child: ListTile(
        onTap: onTap,
        leading: _iconBox(icon, color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  /// ✅ Switch احترافي مع Badge
  Widget _switchRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return _baseCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _iconBox(icon, color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _statusBadge(
              value ? "مفعل" : "غير مفعل",
              value ? Colors.green : Colors.red,
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }

  Widget _dangerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.red.withOpacity(.08),
        border: Border.all(color: Colors.red.withOpacity(.4)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: _iconBox(icon, Colors.red),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.red)),
        subtitle:
            Text(subtitle, style: TextStyle(color: Colors.red.withOpacity(.8))),
      ),
    );
  }

  Widget _baseCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الخروج"),
        content:
            const Text("هل أنت متأكد أنك تريد تسجيل الخروج من كل الأجهزة؟"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              // TODO: API Logout All
            },
            child: const Text("تأكيد"),
          ),
        ],
      ),
    );
  }
}
