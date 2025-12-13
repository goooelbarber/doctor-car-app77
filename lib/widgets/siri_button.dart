// ignore_for_file: depend_on_referenced_packages

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SiriButton extends StatefulWidget {
  final Function(String text) onSpeechResult;

  const SiriButton(
      {super.key,
      required this.onSpeechResult,
      required Future<void> Function(dynamic speech) onResult});

  @override
  State<SiriButton> createState() => _SiriButtonState();
}

class _SiriButtonState extends State<SiriButton> with TickerProviderStateMixin {
  late SpeechToText _speech;
  bool _listening = false;
  String _recognizedText = "";

  late AnimationController _wave1;
  late AnimationController _wave2;
  late AnimationController _wave3;

  @override
  void initState() {
    super.initState();

    _speech = SpeechToText();

    _wave1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _wave2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _wave3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _wave1.dispose();
    _wave2.dispose();
    _wave3.dispose();
    super.dispose();
  }

  void _startListening() async {
    bool available = await _speech.initialize();

    if (!available) return;

    setState(() => _listening = true);

    _speech.listen(
      onResult: (result) {
        setState(() => _recognizedText = result.recognizedWords);

        if (result.finalResult) {
          widget.onSpeechResult(_recognizedText);
        }
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _listening = false);

    if (_recognizedText.isNotEmpty) {
      widget.onSpeechResult(_recognizedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startListening(),
      onTapUp: (_) => _stopListening(),
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildWave(_wave1, 110, Colors.blueAccent.withOpacity(.25)),
            _buildWave(_wave2, 140, Colors.purpleAccent.withOpacity(.25)),
            _buildWave(_wave3, 170, Colors.cyanAccent.withOpacity(.20)),

            // زر ميكروفون Siri
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _listening ? 95 : 85,
              height: _listening ? 95 : 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff3D8BFF),
                    Color(0xff7BC6FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: _listening
                    ? [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(.6),
                          blurRadius: 35,
                          spreadRadius: 10,
                        )
                      ]
                    : [],
              ),
              child:
                  const Icon(Icons.mic_rounded, color: Colors.white, size: 42),
            ),
          ],
        ),
      ),
    );
  }

  // دالة رسم موجات Siri الاحترافية
  Widget _buildWave(AnimationController controller, double size, Color color) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        double value = sin(controller.value * 2 * pi);
        double scale = 1 + (value * .12);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color,
                  color.withOpacity(0.01),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
