// ================================================================
// FILE: lib/widgets/account/account_quick_actions.dart
// DOCTOR CAR - PREMIUM QUICK ACTIONS
// ================================================================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountQuickActions extends StatelessWidget {
  const AccountQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_QuickActionItem>[
      const _QuickActionItem(
        icon: Icons.local_shipping_rounded,
        title: 'سحبات',
        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      ),
      const _QuickActionItem(
        icon: Icons.directions_car_filled_rounded,
        title: 'فحص',
        colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
      ),
      const _QuickActionItem(
        icon: Icons.error_rounded,
        title: 'حادث',
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      ),
      const _QuickActionItem(
        icon: Icons.support_agent_rounded,
        title: 'دعم',
        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1422).withOpacity(.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(.06)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(.035),
                Colors.white.withOpacity(.010),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.24),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: _QuickActionButton(item: item),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.item,
  });

  final _QuickActionItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: item.colors.first.withOpacity(.24),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              item.colors.first,
                              item.colors.last,
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(.16),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 7,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(.35),
                              Colors.white.withOpacity(.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(.35),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final List<Color> colors;
}
