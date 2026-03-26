import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/orders/orders_store.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  static const Color brand = Color(0xFFA8F12A);
  static const Color bg = Color(0xFF0B1220);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ ensure store is initialized once
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = context.read<OrdersStore>();
      try {
        await store.init();
      } catch (_) {
        // لو init مش async أو حصل error silent
        store.init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<OrdersStore>();

    return Scaffold(
      backgroundColor: OrdersScreen.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "الطلبات",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: [
          if (store.all.isNotEmpty)
            IconButton(
              onPressed: () async {
                try {
                  await context.read<OrdersStore>().clearAll();
                } catch (_) {
                  context.read<OrdersStore>().clearAll();
                }
              },
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
              tooltip: "مسح الكل",
            ),
        ],
      ),
      body: !store.isLoaded
          ? _loading()
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // ✅ Tabs header (always visible)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: OrdersScreen.brand.withOpacity(.20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: OrdersScreen.brand.withOpacity(.30),
                        ),
                      ),
                      dividerColor: Colors.transparent,
                      labelStyle:
                          GoogleFonts.cairo(fontWeight: FontWeight.w900),
                      unselectedLabelStyle:
                          GoogleFonts.cairo(fontWeight: FontWeight.w800),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: [
                        Tab(text: "نشطة (${store.active.length})"),
                        Tab(text: "مكتملة (${store.completed.length})"),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        _list(context, store.active,
                            emptyText: "لا يوجد طلبات نشطة"),
                        _list(context, store.completed,
                            emptyText: "لا يوجد طلبات مكتملة"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _loading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: OrdersScreen.brand,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "جاري تحميل الطلبات...",
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(
    BuildContext context,
    List<OrderItem> items, {
    required String emptyText,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: GoogleFonts.cairo(
            color: Colors.white70,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final store = context.read<OrdersStore>();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final o = items[i];

        final statusText = o.status == OrderStatus.active
            ? "نشط"
            : (o.status == OrderStatus.completed ? "مكتمل" : "ملغي");

        final title = o.title.toString().trim();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: OrdersScreen.brand.withOpacity(.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: OrdersScreen.brand.withOpacity(.26),
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: OrdersScreen.brand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? "طلب" : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "الحالة: $statusText"
                      "${o.externalId.isNotEmpty ? " • رقم: ${o.externalId}" : ""}",
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                iconColor: Colors.white,
                color: const Color(0xFF121B2E),
                onSelected: (v) async {
                  try {
                    if (v == "complete") {
                      await store.completeOrder(o.id);
                    } else if (v == "cancel") {
                      await store.cancelOrder(o.id);
                    } else if (v == "delete") {
                      await store.deleteOrder(o.id);
                    }
                  } catch (_) {
                    if (v == "complete") {
                      store.completeOrder(o.id);
                    } else if (v == "cancel") {
                      store.cancelOrder(o.id);
                    } else if (v == "delete") {
                      store.deleteOrder(o.id);
                    }
                  }
                },
                itemBuilder: (_) => [
                  if (o.status == OrderStatus.active)
                    PopupMenuItem(
                      value: "complete",
                      child: Text(
                        "إنهاء الطلب",
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                    ),
                  if (o.status == OrderStatus.active)
                    PopupMenuItem(
                      value: "cancel",
                      child: Text(
                        "إلغاء",
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                    ),
                  PopupMenuItem(
                    value: "delete",
                    child: Text(
                      "حذف",
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
