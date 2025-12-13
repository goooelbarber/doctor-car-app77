import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_NotificationModel> _all = [
    _NotificationModel(
      type: "order",
      icon: Icons.local_shipping,
      title: "السطحة في الطريق",
      message: "السائق على بعد 8 دقائق",
      time: "الآن",
      color: Colors.green,
      status: "جاري",
      isNew: true,
    ),
    _NotificationModel(
      type: "offer",
      icon: Icons.local_offer,
      title: "عرض خاص 🎉",
      message: "خصم 20% على خدمات الطريق",
      time: "منذ ساعتين",
      color: Colors.orange,
      status: "جديد",
      isNew: true,
    ),
    _NotificationModel(
      type: "order",
      icon: Icons.build,
      title: "تنبيه صيانة",
      message: "موعد تغيير الزيت اقترب",
      time: "أمس",
      color: Colors.blue,
      status: "منتهي",
      isNew: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  List<_NotificationModel> _filtered(String type) {
    if (type == "all") return _all;
    return _all.where((e) => e.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff0D0F22) : const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text("الإشعارات"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "الكل"),
            Tab(text: "الطلبات"),
            Tab(text: "العروض"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _list(_filtered("all")),
          _list(_filtered("order")),
          _list(_filtered("offer")),
        ],
      ),
    );
  }

  Widget _list(List<_NotificationModel> list) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final item = list[i];
        return Dismissible(
          key: ValueKey(item.title),
          background:
              _swipeBg(Icons.archive, Colors.blue, Alignment.centerLeft),
          secondaryBackground:
              _swipeBg(Icons.delete, Colors.red, Alignment.centerRight),
          onDismissed: (_) {
            setState(() => _all.remove(item));
          },
          child: _NotificationCard(item: item),
        );
      },
    );
  }

  Widget _swipeBg(IconData icon, Color color, Alignment align) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: color.withOpacity(.15),
      child: Icon(icon, color: color),
    );
  }
}

// =================================================================

class _NotificationCard extends StatelessWidget {
  final _NotificationModel item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: item.color.withOpacity(.15),
                child: Icon(item.icon, color: item.color),
              ),
              if (item.isNew)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                )
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    _status(item.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(item.message, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text(item.time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _status(String s) {
    final c = s == "جاري"
        ? Colors.green
        : s == "جديد"
            ? Colors.orange
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(s,
          style:
              TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

// =================================================================

class _NotificationModel {
  final String type;
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;
  final String status;
  final bool isNew;

  _NotificationModel({
    required this.type,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
    required this.status,
    required this.isNew,
  });
}
