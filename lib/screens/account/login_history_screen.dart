import 'package:flutter/material.dart';

class LoginHistoryScreen extends StatelessWidget {
  const LoginHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xffF6F7FB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "سجل تسجيل الدخول",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoCard(),
          const SizedBox(height: 20),
          _loginItem(
            icon: Icons.phone_android,
            device: "Android • Galaxy S23",
            location: "القاهرة، مصر",
            time: "اليوم • 5:30 م",
            status: LoginStatus.current,
          ),
          _loginItem(
            icon: Icons.laptop_mac,
            device: "MacBook Pro",
            location: "دبي، الإمارات",
            time: "أمس • 11:10 م",
            status: LoginStatus.success,
          ),
          _loginItem(
            icon: Icons.phone_iphone,
            device: "iPhone 14",
            location: "الرياض، السعودية",
            time: "منذ 3 أيام",
            status: LoginStatus.success,
          ),
          _loginItem(
            icon: Icons.warning_amber_rounded,
            device: "محاولة تسجيل دخول مشبوهة",
            location: "موقع غير معروف",
            time: "منذ أسبوع",
            status: LoginStatus.failed,
          ),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.blue.withOpacity(.1),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "راجع هذا السجل للتأكد من عدم وجود محاولات تسجيل دخول غير مصرح بها.",
              style: TextStyle(fontSize: 13),
            ),
          )
        ],
      ),
    );
  }

  Widget _loginItem({
    required IconData icon,
    required String device,
    required String location,
    required String time,
    required LoginStatus status,
  }) {
    Color statusColor;
    String statusText;

    switch (status) {
      case LoginStatus.current:
        statusColor = Colors.green;
        statusText = "هذا الجهاز";
        break;
      case LoginStatus.success:
        statusColor = Colors.blue;
        statusText = "نجاح";
        break;
      case LoginStatus.failed:
        statusColor = Colors.red;
        statusText = "محاولة فاشلة";
        break;
    }

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
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: statusColor),
        ),
        title: Text(
          device,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("$location\n$time"),
        isThreeLine: true,
        trailing: _statusBadge(statusText, statusColor),
      ),
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
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

enum LoginStatus {
  current,
  success,
  failed,
}
