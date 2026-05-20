import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/feature_score.dart';
import '../../../core/theme/app_theme.dart';

class FaceBlueprint extends StatelessWidget {
  final Map<String, FeatureScore> features;
  final double goldenRatioScore;

  const FaceBlueprint({
    super.key,
    required this.features,
    required this.goldenRatioScore,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        const h = 280.0;
        return SizedBox(
          width: w,
          height: h,
          child: CustomPaint(
            painter: _FaceBlueprintPainter(
              features: features,
              goldenRatioScore: goldenRatioScore,
              canvasW: w,
            ),
          ),
        );
      },
    );
  }
}

Color _scoreColor(double score) {
  if (score >= 8.0) return AppColors.signalGreen;
  if (score >= 6.5) return const Color(0xFF8BA050);
  if (score >= 5.0) return const Color(0xFFD4880A);
  return AppColors.scoreDown;
}

class _FaceBlueprintPainter extends CustomPainter {
  final Map<String, FeatureScore> features;
  final double goldenRatioScore;
  final double canvasW;

  const _FaceBlueprintPainter({
    required this.features,
    required this.goldenRatioScore,
    required this.canvasW,
  });

  double get cx => canvasW / 2;
  // cy chosen so annotations fit above (top ≥0) and below (bottom ≤280)
  double get cy => 142.0;

  Offset _s(double x, double y) => Offset(cx + x, cy + y);

  double _feat(String key) => features[key]?.score ?? 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    _drawZoneFills(canvas);
    _drawFaceOutline(canvas);
    _drawMeshLines(canvas);
    _drawGoldenRatioLine(canvas);
    _drawAnnotations(canvas);
  }

  // ── Zone fills ────────────────────────────────────────────────────

  void _drawZoneFills(Canvas canvas) {
    final faceClip = Path()
      ..addOval(Rect.fromCenter(center: Offset(cx, cy), width: 162, height: 216));

    void zone(Path path, Color color) {
      canvas.save();
      canvas.clipPath(faceClip);
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.18));
      canvas.restore();
    }

    // Forehead
    zone(
      Path()..addRect(Rect.fromLTRB(cx - 90, cy - 115, cx + 90, cy - 22)),
      _scoreColor(_feat('forehead')),
    );
    // Eyes
    final eyePath = Path()
      ..addOval(Rect.fromCenter(center: _s(-38, -13), width: 50, height: 28))
      ..addOval(Rect.fromCenter(center: _s(38, -13), width: 50, height: 28));
    zone(eyePath, _scoreColor(_feat('eyes')));
    // Nose
    zone(
      Path()..addOval(Rect.fromCenter(center: _s(0, 8), width: 34, height: 68)),
      _scoreColor(_feat('nose')),
    );
    // Lips
    zone(
      Path()..addOval(Rect.fromCenter(center: _s(0, 60), width: 58, height: 34)),
      _scoreColor(_feat('lips')),
    );
    // Jaw
    zone(
      Path()..addRect(Rect.fromLTRB(cx - 90, cy + 42, cx + 90, cy + 112)),
      _scoreColor(_feat('jawline')),
    );
    // Skin — very light overall tint
    zone(faceClip, _scoreColor(_feat('skin')).withValues(alpha: 0.06 / 0.18));
  }

  // ── Face outline ──────────────────────────────────────────────────

  void _drawFaceOutline(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 162, height: 216),
      Paint()
        ..color = AppColors.inkWhisper
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  // ── Mesh lines (static) ───────────────────────────────────────────

  void _drawMeshLines(Canvas canvas) {
    final p = Paint()
      ..color = AppColors.inkWhisper.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.35
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    _polyline(canvas, p, [
      _s(-56, -8), _s(-47, -17), _s(-38, -20), _s(-29, -17), _s(-20, -8), _s(-38, -1), _s(-56, -8),
    ]);
    _polyline(canvas, p, [
      _s(20, -8), _s(29, -17), _s(38, -20), _s(47, -17), _s(56, -8), _s(38, -1), _s(20, -8),
    ]);
    _polyline(canvas, p, [_s(-60, -34), _s(-50, -42), _s(-38, -45), _s(-27, -40), _s(-18, -33)]);
    _polyline(canvas, p, [_s(18, -33), _s(27, -40), _s(38, -45), _s(50, -42), _s(60, -34)]);
    _polyline(canvas, p, [_s(0, -28), _s(0, -8), _s(0, 30)]);
    _polyline(canvas, p, [_s(-12, 36), _s(0, 42), _s(12, 36)]);
    _polyline(canvas, p, [
      _s(-24, 56), _s(-13, 50), _s(-5, 48), _s(5, 48), _s(13, 50), _s(24, 56),
      _s(12, 62), _s(-12, 62),
    ]);
    _polyline(canvas, p, [_s(-18, 68), _s(0, 74), _s(18, 68), _s(0, 78)]);
    _polyline(canvas, p, [
      _s(-70, 4), _s(-76, 24), _s(-72, 48), _s(-58, 72), _s(-34, 90),
      _s(0, 100), _s(34, 90), _s(58, 72), _s(72, 48), _s(76, 24), _s(70, 4),
    ]);
    _polyline(canvas, p, [_s(-42, -80), _s(-22, -90), _s(0, -93), _s(22, -90), _s(42, -80)]);
  }

  void _polyline(Canvas canvas, Paint paint, List<Offset> pts) {
    if (pts.isEmpty) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    canvas.drawPath(path, paint);
  }

  // ── Golden ratio measurement line ─────────────────────────────────

  void _drawGoldenRatioLine(Canvas canvas) {
    final color = _scoreColor(goldenRatioScore);
    _dashedLine(canvas, _s(-50, -10), _s(50, -10), color.withValues(alpha: 0.35));
    _label(canvas, 'φ  ${goldenRatioScore.toStringAsFixed(1)}',
        _s(4, -19), 7.5, color.withValues(alpha: 0.65));
  }

  void _dashedLine(Canvas canvas, Offset p1, Offset p2, Color color) {
    final path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy);
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 0.5;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, (d + 3.0).clamp(0.0, m.length)), paint);
        d += 6.0;
      }
    }
  }

  // ── Score annotations ─────────────────────────────────────────────

  void _drawAnnotations(Canvas canvas) {
    // [featureKey, displayLabel, anchorSvgX, anchorSvgY, labelOffsetX, labelOffsetY, alignRight]
    final anns = <(String, String, double, double, double, double, bool)>[
      ('forehead', 'FOREHEAD', 0, -93, 0, -112, false),   // top-center
      ('eyes',     'EYES',    -56,  -8, -90, -8, false),   // left
      ('skin',     'SKIN',    -72,  24, -90, 24, false),   // left below eyes
      ('nose',     'NOSE',     12,  36,  86, 36, true),    // right
      ('lips',     'LIPS',     24,  60,  86, 60, true),    // right below nose
      ('jawline',  'JAW',       0, 100,   0, 117, false),  // bottom-center
    ];

    for (final (key, label, ax, ay, lx, ly, alignRight) in anns) {
      final score = _feat(key);
      final color = _scoreColor(score);
      final anchor = _s(ax, ay);
      final labelOrigin = _s(lx, ly);

      // Tick dot at anchor
      canvas.drawCircle(anchor, 2.0, Paint()..color = color.withValues(alpha: 0.85));

      // Tick line from anchor to label
      canvas.drawLine(anchor, labelOrigin, Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 0.5);

      // Score number + label text
      final scoreStr = score.toStringAsFixed(1);
      final isTopBottom = (ly < cy - 80 || ly > cy + 100); // above forehead or below jaw

      if (isTopBottom) {
        // Centered stack: score above, label below (or reverse for bottom)
        final isBelowFace = ly > cy;
        _label(canvas, scoreStr, Offset(labelOrigin.dx, labelOrigin.dy + (isBelowFace ? 0 : -14)),
            11, color, bold: true, centered: true);
        _label(canvas, label, Offset(labelOrigin.dx, labelOrigin.dy + (isBelowFace ? 13 : -24)),
            7, AppColors.inkMuted, centered: true);
      } else if (alignRight) {
        // Right side: score left-aligned, label below
        _label(canvas, scoreStr, Offset(labelOrigin.dx, labelOrigin.dy - 2), 11, color, bold: true);
        _label(canvas, label, Offset(labelOrigin.dx, labelOrigin.dy + 12), 7, AppColors.inkMuted);
      } else {
        // Left side: score right-aligned to labelOrigin, label below
        final scoreW = _textWidth(scoreStr, 11);
        final labelW = _textWidth(label, 7);
        _label(canvas, scoreStr, Offset(labelOrigin.dx - scoreW, labelOrigin.dy - 2), 11, color, bold: true);
        _label(canvas, label, Offset(labelOrigin.dx - labelW, labelOrigin.dy + 12), 7, AppColors.inkMuted);
      }
    }
  }

  void _label(Canvas canvas, String text, Offset origin, double fontSize, Color color,
      {bool bold = false, bool centered = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.dmSans(
          fontSize: fontSize,
          letterSpacing: fontSize < 9 ? 1.1 : 0.2,
          color: color,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = centered ? origin.dx - tp.width / 2 : origin.dx;
    tp.paint(canvas, Offset(dx, origin.dy));
  }

  double _textWidth(String text, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.dmSans(fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  @override
  bool shouldRepaint(_FaceBlueprintPainter old) =>
      old.features != features ||
      old.goldenRatioScore != goldenRatioScore ||
      old.canvasW != canvasW;
}
