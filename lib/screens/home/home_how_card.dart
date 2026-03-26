// PATH: lib/screens/home/home_how_card.dart
part of '../home_screen.dart';

// ================== HOW CARD (ULTRA PRO) ==================
class _HowCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final VoidCallback? onTap;

  const _HowCard({
    required this.icon,
    required this.text,
    required this.isDark,
    // ignore: unused_element_parameter
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final st = context.findAncestorStateOfType<_HomeScreenState>();

    // ================== shared palette from home ==================
    final accent = st?._accent ?? const Color.fromARGB(255, 62, 119, 204);
    final accentDark =
        st?._accentDark ?? const Color.fromARGB(255, 49, 115, 201);
    final accentSoft = st?._accentSoft ?? const Color(0xFFE7EEF9);
    // ignore: unused_local_variable
    final panel = st?._panel ?? const Color.fromARGB(255, 29, 102, 204);
    final textMain = st?._text ?? const Color(0xFFFFFFFF);
    final ink = st?._ink ?? const Color(0xFFF2F6FB);
    final muted = st?._muted ?? const Color(0xFFC9D6EA);

    final borderColor =
        isDark ? Colors.white.withOpacity(.12) : accent.withOpacity(.22);

    final cardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [
              Color.fromARGB(255, 24, 54, 100),
              Color(0xFF143F7C),
              Color(0xFF10386B),
            ]
          : const [
              Color.fromARGB(255, 61, 127, 225),
              Color.fromARGB(255, 40, 84, 150),
              Color.fromARGB(255, 17, 43, 83),
            ],
      stops: const [0.0, 0.52, 1.0],
    );

    final overlayGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withOpacity(.05),
              Colors.transparent,
              Colors.black.withOpacity(.06),
            ]
          : [
              accent.withOpacity(.10),
              Colors.transparent,
              accentDark.withOpacity(.06),
            ],
    );

    final iconBoxGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withOpacity(.12),
              Colors.white.withOpacity(.05),
            ]
          : [
              Colors.white.withOpacity(.16),
              accent.withOpacity(.18),
              accentDark.withOpacity(.24),
            ],
    );

    final cardGlow = [
      BoxShadow(
        color: accent.withOpacity(isDark ? .18 : .12),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? .22 : .12),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ];

    final textColor = isDark ? textMain : ink;
    final iconColor = isDark ? textMain : accentSoft;
    final underlineColor =
        isDark ? Colors.white.withOpacity(.20) : muted.withOpacity(.40);

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
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                height: 140,
                decoration: BoxDecoration(
                  gradient: cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: borderColor,
                    width: 1.15,
                  ),
                  boxShadow: cardGlow,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: overlayGradient,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: iconBoxGradient,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(.12)
                                    : accent.withOpacity(.20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(.12),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              icon,
                              size: 30,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _AutoFitTwoLines(
                            text: text,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              height: 1.15,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 22,
                            height: 4,
                            decoration: BoxDecoration(
                              color: underlineColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ================== Tap animation wrapper ==================
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

/// ================== Auto-fit text ==================
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

        return Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(
            fontSize: candidates.isNotEmpty ? candidates.last : 11,
          ),
        );
      },
    );
  }
}
