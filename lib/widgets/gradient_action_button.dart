import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  /// gradient أخضر → أبيض
  final Gradient gradient;

  /// ألوان
  final Color iconColor;
  final Color textColor;
  final Color borderColor;

  /// sizing
  final double height;
  final double radius;
  final EdgeInsets padding;

  const GradientActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.gradient,
    required this.iconColor,
    required this.textColor,
    required this.borderColor,
    this.height = 54,
    this.radius = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(.55)),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right, color: textColor.withOpacity(.85)),
            ],
          ),
        ),
      ),
    );
  }
}
