import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../models/app_models.dart';

class ARSurfaceScanWidget extends StatefulWidget {
  final VoidCallback onSurfaceDetected;

  const ARSurfaceScanWidget({super.key, required this.onSurfaceDetected});

  @override
  State<ARSurfaceScanWidget> createState() => _ARSurfaceScanWidgetState();
}

class _ARSurfaceScanWidgetState extends State<ARSurfaceScanWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _scanProgress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Auto-detect surface after ~2.8 seconds for smooth onboarding experience
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        widget.onSurfaceDetected();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ARSurfaceGridPainter(scanProgress: _scanProgress.value),
        );
      },
    );
  }
}

class ARSurfaceGridPainter extends CustomPainter {
  final double scanProgress;

  ARSurfaceGridPainter({required this.scanProgress});

  @override
  void paint(Canvas canvas, Size size) {
    // Simulated realistic indoor room background backdrop
    final bgShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF1E293B),
        const Color(0xFF0F172A),
        const Color(0xFF27272A),
      ],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = bgShader);

    // Subtle wooden table surface perspective floor
    final tablePath = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final tableShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF523B2A).withValues(alpha: 0.85),
        const Color(0xFF332218).withValues(alpha: 0.95),
      ],
    ).createShader(Offset.zero & size);
    canvas.drawPath(tablePath, Paint()..shader = tableShader);

    // Perspective AR Grid Coordinates
    final pTopLeft = Offset(size.width * 0.22, size.height * 0.58);
    final pTopRight = Offset(size.width * 0.78, size.height * 0.58);
    final pBottomLeft = Offset(size.width * 0.08, size.height * 0.82);
    final pBottomRight = Offset(size.width * 0.92, size.height * 0.82);

    final gridPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Draw boundary quad
    final boundary = Path()
      ..moveTo(pTopLeft.dx, pTopLeft.dy)
      ..lineTo(pTopRight.dx, pTopRight.dy)
      ..lineTo(pBottomRight.dx, pBottomRight.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..close();
    canvas.drawPath(boundary, gridPaint);

    // Horizontal perspective grid lines
    const hDivisions = 6;
    for (int i = 1; i < hDivisions; i++) {
      final t = i / hDivisions;
      final left = Offset.lerp(pTopLeft, pBottomLeft, t)!;
      final right = Offset.lerp(pTopRight, pBottomRight, t)!;
      canvas.drawLine(left, right, gridPaint);
    }

    // Vertical perspective grid lines
    const vDivisions = 8;
    for (int i = 1; i < vDivisions; i++) {
      final t = i / vDivisions;
      final top = Offset.lerp(pTopLeft, pTopRight, t)!;
      final bottom = Offset.lerp(pBottomLeft, pBottomRight, t)!;
      canvas.drawLine(top, bottom, gridPaint);
    }

    // Glowing Laser Scanline across the plane
    final scanLeft = Offset.lerp(pTopLeft, pBottomLeft, scanProgress)!;
    final scanRight = Offset.lerp(pTopRight, pBottomRight, scanProgress)!;

    final laserPaint = Paint()
      ..color = const Color(0xFF34D399)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(scanLeft, scanRight, laserPaint);

    final coreLaserPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawLine(scanLeft, scanRight, coreLaserPaint);

    // Corner reticles
    _drawCornerReticle(canvas, pTopLeft, 14, true, true);
    _drawCornerReticle(canvas, pTopRight, 14, false, true);
    _drawCornerReticle(canvas, pBottomLeft, 14, true, false);
    _drawCornerReticle(canvas, pBottomRight, 14, false, false);
  }

  void _drawCornerReticle(
    Canvas canvas,
    Offset point,
    double length,
    bool isLeft,
    bool isTop,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final dx = isLeft ? length : -length;
    final dy = isTop ? length : -length;

    canvas.drawLine(point, Offset(point.dx + dx, point.dy), paint);
    canvas.drawLine(point, Offset(point.dx, point.dy + dy), paint);
  }

  @override
  bool shouldRepaint(covariant ARSurfaceGridPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress;
  }
}

class ARModelAnchorWidget extends StatelessWidget {
  final ModelItem model;
  final double scale;
  final double rotation;

  const ARModelAnchorWidget({
    super.key,
    required this.model,
    required this.scale,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Realistic simulated environmental background (Table surface)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2C3E50),
                  Color(0xFF1E293B),
                  Color(0xFF4A3525),
                ],
              ),
            ),
          ),
        ),

        // Native AR launch button is provided by model-viewer-plus on Android.
        Positioned.fill(
          child: ModelViewer(
            src: model.arAssetPath ?? model.assetPath ?? '',
            alt: 'AR model of ${model.title}',
            backgroundColor: Colors.transparent,
            cameraControls: true,
            ar: model.hasAR && model.arAssetPath != null,
            arModes: const ['scene-viewer', 'webxr', 'quick-look'],
            arScale: ArScale.auto,
            arPlacement: ArPlacement.floor,
            loading: Loading.eager,
          ),
        ),
      ],
    );
  }
}
