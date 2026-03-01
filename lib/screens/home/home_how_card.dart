// PATH: lib/screens/home/home_how_card.dart
part of '../home_screen.dart';

// ================== HOW CARD (ULTRA PRO) ==================
class _HowCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final VoidCallback? onTap; // ✅ optional

  const _HowCard({
    required this.icon,
    required this.text,
    required this.isDark,
    // ignore: unused_element_parameter
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ safer than "!" + provides fallback tokens if not found
    final st = context.findAncestorStateOfType<_HomeScreenState>();

    // ---- Fallback tokens (لو اتستخدم برّه HomeScreen لأي سبب) ----
    final brand = st?.brand ?? const Color.fromARGB(255, 26, 217, 105);

    final greenWhiteGradient = st?.greenWhiteGradient ??
        LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDark
              ? [brand.withOpacity(.92), Colors.white.withOpacity(.16)]
              : [brand.withOpacity(.96), Colors.white],
        );

    final greenWhiteGlow = st?.greenWhiteGlow ??
        [
          BoxShadow(
            color: brand.withOpacity(isDark ? .22 : .16),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .28 : .08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ];

    final textColor = isDark ? Colors.white : const Color(0xff0B1220);

    return Expanded(
      child: Semantics(
        button: onTap != null,
        label: text.replaceAll('\n', ' '),
        child: _HowCardTapScale(
          enabled: onTap != null,
          onTap: onTap,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                height: 140,
                decoration: BoxDecoration(
                  gradient: greenWhiteGradient, // ✅ Green → White
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: brand.withOpacity(.34), width: 1.2),
                  boxShadow: greenWhiteGlow,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ Icon glass container
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isDark ? .10 : .55),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(isDark ? .14 : .55),
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 30,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ✅ Smart text: tries to fit before ellipsis
                      _AutoFitTwoLines(
                        text: text,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          height: 1.15,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ✅ Tap animation wrapper (Pro feel)
class _HowCardTapScale extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final VoidCallback? onTap;

  const _HowCardTapScale({
    required this.child,
    required this.enabled,
    this.onTap,
  });

  @override
  State<_HowCardTapScale> createState() => _HowCardTapScaleState();
}

class _HowCardTapScaleState extends State<_HowCardTapScale> {
  bool _down = false;

  void _setDown(bool v) {
    if (!widget.enabled) return;
    if (_down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setDown(true),
      onPointerUp: (_) => _setDown(false),
      onPointerCancel: (_) => _setDown(false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        scale: _down ? 0.985 : 1.0,
        child: widget.child,
      ),
    );
  }
}

/// ✅ Auto-fit text (no packages):
/// - uses LayoutBuilder to choose a smaller font when space is tight
/// - still has ellipsis as final safety net (prevents red overflow)
class _AutoFitTwoLines extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _AutoFitTwoLines({
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final base = style.fontSize ?? 13;

        // Try sizes (13 -> 12 -> 11.5 -> 11)
        final candidates = <double>[base, base - 1, base - 1.5, base - 2]
            .where((v) => v >= 10.5)
            .toList();

        for (final fs in candidates) {
          final testStyle = style.copyWith(fontSize: fs);

          final tp = TextPainter(
            text: TextSpan(text: text, style: testStyle),
            maxLines: 2,
            textDirection: Directionality.of(context),
            ellipsis: '…',
          )..layout(maxWidth: c.maxWidth);

          if (!tp.didExceedMaxLines) {
            return Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: testStyle,
            );
          }
        }

        // Fallback (guaranteed no overflow)
        return Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(
              fontSize: candidates.isNotEmpty ? candidates.last : 11),
        );
      },
    );
  }
}
