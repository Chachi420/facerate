import 'package:flutter/material.dart';

class NoiseBg extends StatelessWidget {
  final Widget child;
  const NoiseBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark
        ? const Color(0x0DC4A8FF)   // subtle lavender in dark
        : const Color(0x18C4B5FD); // slightly visible in light
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _DotGridPainter(color: dotColor)),
        ),
        child,
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  const _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    const step = 22.0;
    const r = 0.9;
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}
