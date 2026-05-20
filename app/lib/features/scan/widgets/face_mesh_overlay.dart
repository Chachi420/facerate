import 'dart:math';
import 'package:flutter/material.dart';

// Face landmark positions in face-oval space (center = 0,0).
// Oval: 168×222 px → x ∈ [-84,84], y ∈ [-111,111]
// Sourced from the mirror_design JSX reference.
const _foreheadPts = [
  Offset(-42, -80), Offset(-22, -90), Offset(0, -93), Offset(22, -90), Offset(42, -80),
];
const _leftBrowPts = [
  Offset(-60, -34), Offset(-50, -42), Offset(-38, -45), Offset(-27, -40), Offset(-18, -33),
];
const _rightBrowPts = [
  Offset(18, -33), Offset(27, -40), Offset(38, -45), Offset(50, -42), Offset(60, -34),
];
const _leftEyePts = [
  Offset(-56, -8), Offset(-47, -17), Offset(-38, -20), Offset(-29, -17), Offset(-20, -8), Offset(-38, -1),
];
const _rightEyePts = [
  Offset(20, -8), Offset(29, -17), Offset(38, -20), Offset(47, -17), Offset(56, -8), Offset(38, -1),
];
const _nosePts = [
  Offset(0, -28), Offset(0, -8), Offset(0, 30), Offset(-12, 36), Offset(12, 36), Offset(0, 42),
];
const _mouthPts = [
  Offset(-24, 56), Offset(-13, 50), Offset(-5, 48), Offset(5, 48), Offset(13, 50), Offset(24, 56),
  Offset(12, 62), Offset(-12, 62), Offset(-18, 68), Offset(0, 74), Offset(18, 68), Offset(0, 78),
];
const _jawPts = [
  Offset(-70, 4), Offset(-76, 24), Offset(-72, 48), Offset(-58, 72), Offset(-34, 90),
  Offset(0, 100), Offset(34, 90), Offset(58, 72), Offset(72, 48), Offset(76, 24), Offset(70, 4),
];
const _secondaryPts = [
  Offset(-74, -6), Offset(74, -6),
  Offset(-70, 18), Offset(70, 18),
  Offset(-66, 38), Offset(66, 38),
  Offset(-60, 56), Offset(60, 56),
  Offset(-48, -4), Offset(48, -4),
  Offset(-33, -3), Offset(33, -3),
  Offset(-10, 12), Offset(10, 12),
  Offset(-18, 20), Offset(18, 20),
  Offset(-32, -38), Offset(32, -38),
  Offset(-58, -72), Offset(58, -72),
  Offset(-68, -52), Offset(68, -52),
  Offset(-22, 86), Offset(22, 86),
  Offset(-44, 96), Offset(44, 96),
  Offset(-5, 44), Offset(5, 44),
  Offset(-24, 58), Offset(24, 58),
  Offset(-52, 8), Offset(52, 8),
];

// Dot groups in stagger order
const _dotGroups = [
  _foreheadPts, _leftBrowPts, _rightBrowPts,
  _leftEyePts, _rightEyePts,
  _nosePts, _mouthPts, _jawPts,
];
const _groupStartMs = <int>[0, 80, 160, 240, 320, 400, 480, 640];

// Mesh polylines
List<List<Offset>> _buildMeshLines() => [
  [..._leftEyePts, _leftEyePts[0]],
  [..._rightEyePts, _rightEyePts[0]],
  _leftBrowPts,
  _rightBrowPts,
  [_nosePts[0], _nosePts[1], _nosePts[2]],
  [_nosePts[3], _nosePts[5], _nosePts[4]],
  _mouthPts.sublist(0, 8),
  _mouthPts.sublist(8),
  _jawPts,
  _foreheadPts,
];
// The ms offset at which each mesh line starts appearing (mirrors its dot group)
const _meshLineGroupMs = <int>[240, 320, 160, 240, 0, 400, 480, 640, 640, 0];

class FaceMeshOverlay extends StatefulWidget {
  final bool detected;
  const FaceMeshOverlay({super.key, required this.detected});

  @override
  State<FaceMeshOverlay> createState() => _FaceMeshOverlayState();
}

class _FaceMeshOverlayState extends State<FaceMeshOverlay> with TickerProviderStateMixin {
  late final AnimationController _dotController;
  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _sweepController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
    if (widget.detected) _dotController.forward();
  }

  @override
  void didUpdateWidget(FaceMeshOverlay old) {
    super.didUpdateWidget(old);
    if (!old.detected && widget.detected) _dotController.forward();
    if (old.detected && !widget.detected) _dotController.reset();
  }

  @override
  void dispose() {
    _dotController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_dotController, _sweepController]),
      builder: (_, __) => CustomPaint(
        painter: _FaceMeshPainter(
          detected: widget.detected,
          progress: _dotController.value,
          sweepY: _sweepController.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _FaceMeshPainter extends CustomPainter {
  final bool detected;
  final double progress; // 0→1 over 1600ms
  final double sweepY;   // 0→1 repeating

  const _FaceMeshPainter({
    required this.detected,
    required this.progress,
    required this.sweepY,
  });

  static const _green = Color(0xFF3DDC97);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    Offset s(Offset p) => Offset(cx + p.dx, cy + p.dy);

    final ovalRect = Rect.fromCenter(center: Offset(cx, cy), width: 168, height: 222);

    if (!detected) {
      _drawDashedOval(canvas, ovalRect);
      return;
    }

    // Glow ring
    canvas.drawOval(ovalRect, Paint()
      ..color = _green.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10);
    // Green oval stroke
    canvas.drawOval(ovalRect, Paint()
      ..color = _green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    final elapsed = progress * 1600;
    final meshLines = _buildMeshLines();

    // Mesh connector lines
    for (int li = 0; li < meshLines.length; li++) {
      final lineStartMs = _meshLineGroupMs[li] + 120.0;
      final lineOpacity = ((elapsed - lineStartMs) / 200.0).clamp(0.0, 1.0) * 0.28;
      if (lineOpacity <= 0) continue;

      final pts = meshLines[li];
      final path = Path()..moveTo(s(pts[0]).dx, s(pts[0]).dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(s(pts[i]).dx, s(pts[i]).dy);
      }
      canvas.drawPath(path, Paint()
        ..color = _green.withValues(alpha: lineOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round);
    }

    // Sweep line (fades in after dots start, sweeps within the oval)
    if (progress > 0.35) {
      final sweepFade = ((progress - 0.35) / 0.2).clamp(0.0, 1.0);
      final ovalTop = cy - 111.0;
      final ovalBottom = cy + 111.0;
      final sy = ovalTop + (ovalBottom - ovalTop) * sweepY;
      // Clip sweep to oval width at that y
      final normY = (sy - cy) / 109.0;
      final halfW = sqrt(max(0.0, 1.0 - normY * normY)) * 82.0;

      canvas.drawLine(Offset(cx - halfW, sy), Offset(cx + halfW, sy), Paint()
        ..color = _green.withValues(alpha: 0.12 * sweepFade)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round);
      canvas.drawLine(Offset(cx - halfW, sy), Offset(cx + halfW, sy), Paint()
        ..color = _green.withValues(alpha: 0.6 * sweepFade)
        ..strokeWidth = 1.0);
    }

    // Secondary fill dots (appear last)
    if (progress > 0.78) {
      final secP = ((progress - 0.78) / 0.22).clamp(0.0, 1.0);
      for (int i = 0; i < _secondaryPts.length; i++) {
        final stagger = i / _secondaryPts.length * 0.7;
        final op = ((secP - stagger) / 0.3).clamp(0.0, 1.0) * 0.35;
        if (op <= 0) continue;
        canvas.drawCircle(s(_secondaryPts[i]), 1.0, Paint()..color = _green.withValues(alpha: op));
      }
    }

    // Primary landmark dots — staggered per group
    for (int gi = 0; gi < _dotGroups.length; gi++) {
      final groupMs = _groupStartMs[gi].toDouble();
      for (int di = 0; di < _dotGroups[gi].length; di++) {
        final dotMs = groupMs + di * 14.0;
        final opacity = ((elapsed - dotMs) / 120.0).clamp(0.0, 1.0);
        if (opacity <= 0) continue;

        final screen = s(_dotGroups[gi][di]);

        // Dark halo
        canvas.drawCircle(screen, 2.5, Paint()
          ..color = const Color(0xFF110F0E).withValues(alpha: 0.6 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);
        // Green dot
        canvas.drawCircle(screen, 1.5, Paint()
          ..color = _green.withValues(alpha: opacity));
      }
    }
  }

  void _drawDashedOval(Canvas canvas, Rect rect) {
    final path = Path()..addOval(rect);
    final paint = Paint()
      ..color = const Color(0x66E6E0D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final end = (dist + 5.0).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += 9.0;
      }
    }
  }

  @override
  bool shouldRepaint(_FaceMeshPainter old) =>
    old.detected != detected || old.progress != progress || old.sweepY != sweepY;
}
