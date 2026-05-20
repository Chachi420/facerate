import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/theme/app_theme.dart';

class FaceArOverlay extends StatelessWidget {
  final List<Face> faces;
  final Size imageSize;        // raw camera image size (landscape: width > height)
  final bool isFrontCamera;
  final InputImageRotation rotation;

  const FaceArOverlay({
    super.key,
    required this.faces,
    required this.imageSize,
    required this.isFrontCamera,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FaceContourPainter(
        faces: faces,
        imageSize: imageSize,
        isFrontCamera: isFrontCamera,
        rotation: rotation,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _FaceContourPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final bool isFrontCamera;
  final InputImageRotation rotation;

  const _FaceContourPainter({
    required this.faces,
    required this.imageSize,
    required this.isFrontCamera,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty || imageSize.isEmpty) return;

    // ML Kit returns face coordinates in portrait/display space after applying
    // rotation metadata. For 90°/270° rotations the effective display dimensions
    // are the raw image width and height swapped.
    final bool swapDims = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    final double imageW = swapDims ? imageSize.height : imageSize.width;
    final double imageH = swapDims ? imageSize.width : imageSize.height;

    // BoxFit.cover: uniform scale so image fills the widget on both axes
    final double scale = math.max(size.width / imageW, size.height / imageH);
    final double offsetX = (size.width - imageW * scale) / 2;
    final double offsetY = (size.height - imageH * scale) / 2;

    final glowPaint = Paint()
      ..color = AppColors.signalGreen.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = AppColors.signalGreen.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    for (final face in faces) {
      for (final contourType in FaceContourType.values) {
        final contour = face.contours[contourType];
        if (contour == null) continue;
        for (final point in contour.points) {
          final double rawSx = point.x * scale + offsetX;
          // CameraPreview mirrors the front camera display horizontally, but ML Kit
          // returns unmirrored coordinates — flip X to match the preview.
          final double sx = isFrontCamera ? size.width - rawSx : rawSx;
          final double sy = point.y * scale + offsetY;
          final o = Offset(sx, sy);
          canvas.drawCircle(o, 4.5, glowPaint);
          canvas.drawCircle(o, 2.0, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_FaceContourPainter old) =>
      old.faces != faces ||
      old.imageSize != imageSize ||
      old.isFrontCamera != isFrontCamera ||
      old.rotation != rotation;
}
