import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:doctor_car_app/services/orders/orders_store.dart';

class OrderDetailsSheet {
  static const Color brand = Color(0xFFA8F12A);
  static const Color bg = Color(0xFF0B1220);
  static const Color card = Color(0xFF121B2E);

  static Future<void> show(
    BuildContext context, {
    required OrderItem order,
  }) async {
    HapticFeedback.selectionClick();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.55),
      builder: (_) => _OrderDetailsContent(order: order),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  const _OrderDetailsContent({required this.order});
  final OrderItem order;

  String _statusText(OrderStatus st) {
    switch (st) {
      case OrderStatus.active:
        return "نشط";
      case OrderStatus.completed:
        return "مكتمل";
      case OrderStatus.cancelled:
        return "ملغي";
    }
  }

  Color _statusColor(OrderStatus st) {
    if (st == OrderStatus.active) return OrderDetailsSheet.brand;
    if (st == OrderStatus.completed) return Colors.lightBlueAccent;
    return Colors.redAccent;
  }

  String _prettyDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return "$y-$m-$day  •  $hh:$mm";
  }

  Future<void> _copy(BuildContext context, String text) async {
    HapticFeedback.selectionClick();
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم النسخ", textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _confirmDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmText,
    bool danger = false,
  }) async {
    HapticFeedback.selectionClick();
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121B2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            body,
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                "إلغاء",
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: danger
                    ? Colors.redAccent.withOpacity(.25)
                    : OrderDetailsSheet.brand.withOpacity(.22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: danger
                        ? Colors.redAccent.withOpacity(.55)
                        : OrderDetailsSheet.brand.withOpacity(.35),
                  ),
                ),
              ),
              child: Text(
                confirmText,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.66,
        minChildSize: 0.40,
        maxChildSize: 0.94,
        builder: (ctx, scrollCtrl) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: OrderDetailsSheet.bg.withOpacity(.92),
                  border: Border.all(color: Colors.white12),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Stack(
                  children: [
                    // Glow blob
                    Positioned(
                      top: -90,
                      left: -90,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              OrderDetailsSheet.brand.withOpacity(.20),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          // Handle + close
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      width: 46,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: "إغلاق",
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close_rounded,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          Expanded(
                            child: ListView(
                              controller: scrollCtrl,
                              padding:
                                  EdgeInsets.fromLTRB(16, 0, 16, 16 + h * 0.02),
                              children: [
                                _Header(order: order),
                                const SizedBox(height: 12),
                                _Section(
                                  title: "معلومات الطلب",
                                  child: Column(
                                    children: [
                                      _InfoRow(
                                        label: "الحالة",
                                        value: _statusText(order.status),
                                        valueColor: _statusColor(order.status),
                                      ),
                                      _InfoRow(
                                        label: "اسم الخدمة",
                                        value: order.title.trim().isEmpty
                                            ? "طلب"
                                            : order.title.trim(),
                                      ),
                                      _InfoRow(
                                        label: "نوع الخدمة (serviceKey)",
                                        value: order.serviceKey,
                                      ),
                                      _InfoRow(
                                        label: "رقم الطلب",
                                        value: order.externalId.isEmpty
                                            ? "غير متوفر"
                                            : order.externalId,
                                        trailing: order.externalId.isEmpty
                                            ? null
                                            : _MiniBtn(
                                                label: "نسخ",
                                                onTap: () => _copy(
                                                    context, order.externalId),
                                              ),
                                      ),
                                      _InfoRow(
                                        label: "المعرّف المحلي",
                                        value: order.id,
                                        trailing: _MiniBtn(
                                          label: "نسخ",
                                          onTap: () => _copy(context, order.id),
                                        ),
                                      ),
                                      _InfoRow(
                                        label: "وقت الإنشاء",
                                        value: _prettyDate(order.createdAt),
                                      ),
                                      if (order.completedAt != null)
                                        _InfoRow(
                                          label: "وقت الإنهاء",
                                          value:
                                              _prettyDate(order.completedAt!),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _Section(
                                  title: "إجراءات",
                                  child: _Actions(
                                    order: order,
                                    confirmDialog: _confirmDialog,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});
  final OrderItem order;

  @override
  Widget build(BuildContext context) {
    final title = order.title.trim().isEmpty ? "طلب" : order.title.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OrderDetailsSheet.card.withOpacity(.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: OrderDetailsSheet.brand.withOpacity(.16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: OrderDetailsSheet.brand.withOpacity(.28),
              ),
            ),
            child:
                const Icon(Icons.receipt_long, color: OrderDetailsSheet.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "تفاصيل الطلب بالكامل",
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OrderDetailsSheet.card.withOpacity(.62),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.valueColor,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    color: Colors.white60,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    color: valueColor ?? Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ]
        ],
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  const _MiniBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: OrderDetailsSheet.brand.withOpacity(.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: OrderDetailsSheet.brand.withOpacity(.22)),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: OrderDetailsSheet.brand,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.order,
    required this.confirmDialog,
  });

  final OrderItem order;
  final Future<bool> Function(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmText,
    bool danger,
  }) confirmDialog;

  @override
  Widget build(BuildContext context) {
    OrdersStore? store;
    try {
      store = context.read<OrdersStore>();
    } catch (_) {
      store = null;
    }

    Future<void> _run(Future<void> Function() fn) async {
      HapticFeedback.mediumImpact();
      await fn();
      if (context.mounted) Navigator.pop(context);
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (order.status == OrderStatus.active)
          _ActionChip(
            label: "إنهاء",
            icon: Icons.check_circle_rounded,
            color: Colors.lightBlueAccent.withOpacity(.18),
            border: Colors.lightBlueAccent.withOpacity(.35),
            onTap: store == null
                ? null
                : () async {
                    final ok = await confirmDialog(
                      context,
                      title: "إنهاء الطلب؟",
                      body: "هل تريد تحويل الطلب إلى مكتمل؟",
                      confirmText: "إنهاء",
                    );
                    if (!ok) return;
                    await _run(() => store!.completeOrder(order.id));
                  },
          ),
        if (order.status == OrderStatus.active)
          _ActionChip(
            label: "إلغاء",
            icon: Icons.cancel_rounded,
            color: Colors.redAccent.withOpacity(.14),
            border: Colors.redAccent.withOpacity(.35),
            onTap: store == null
                ? null
                : () async {
                    final ok = await confirmDialog(
                      context,
                      title: "إلغاء الطلب؟",
                      body: "هل تريد إلغاء هذا الطلب؟",
                      confirmText: "إلغاء",
                      danger: true,
                    );
                    if (!ok) return;
                    await _run(() => store!.cancelOrder(order.id));
                  },
          ),
        _ActionChip(
          label: "حذف",
          icon: Icons.delete_rounded,
          color: Colors.white.withOpacity(.08),
          border: Colors.white12,
          onTap: store == null
              ? null
              : () async {
                  final ok = await confirmDialog(
                    context,
                    title: "حذف الطلب؟",
                    body: "سيتم حذف الطلب نهائيًا من الجهاز.",
                    confirmText: "حذف",
                    danger: true,
                  );
                  if (!ok) return;
                  await _run(() => store!.deleteOrder(order.id));
                },
        ),
        if (store == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              "ملحوظة: OrdersStore غير متوفر في Provider هنا.",
              style: GoogleFonts.cairo(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.border,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
