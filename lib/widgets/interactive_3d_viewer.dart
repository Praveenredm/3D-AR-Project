import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:vector_math/vector_math_64.dart' as v64;

import '../providers/app_state.dart';
import '../models/app_models.dart';

class Interactive3DViewer extends StatefulWidget {
  final ModelItem model;
  final ViewerMode mode;
  final double explosionRatio;
  final String? selectedPartId;
  final bool showHotspots;
  final bool isAutoRotating;
  final double zoomScale;
  final Function(String partId)? onSelectPart;
  final VoidCallback? onOpenInfoPanel;
  final bool enableAr;

  const Interactive3DViewer({
    super.key,
    required this.model,
    this.mode = ViewerMode.normal,
    this.explosionRatio = 0.0,
    this.selectedPartId,
    this.showHotspots = true,
    this.isAutoRotating = false,
    this.zoomScale = 1.0,
    this.onSelectPart,
    this.onOpenInfoPanel,
    this.enableAr = false,
  });

  @override
  State<Interactive3DViewer> createState() => _Interactive3DViewerState();
}

class _Interactive3DViewerState extends State<Interactive3DViewer>
    with SingleTickerProviderStateMixin {
  double _rotX = 0.15;
  double _rotY = -0.25;
  double _lastFocalRotX = 0.0;
  double _lastFocalRotY = 0.0;
  double _baseScale = 1.0;
  double _currentScale = 1.0;

  late AnimationController _pulseController;

  bool _isLoading = true;
  bool _hasError = false;
  int _attempt = 0;
  String? _selectedModelPath;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _updateSelectedModelPath();
    _startLoadTimeout();
    _startWebReadyFallback();
  }

  @override
  void didUpdateWidget(Interactive3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAutoRotating != oldWidget.isAutoRotating) {
      if (widget.isAutoRotating) {
        _startAutoRotate();
      }
    }
    if (widget.mode != oldWidget.mode ||
        widget.explosionRatio != oldWidget.explosionRatio ||
        widget.model.id != oldWidget.model.id) {
      _updateSelectedModelPath();
      _attempt++;
      _isLoading = true;
      _hasError = false;
      _startLoadTimeout();
      _startWebReadyFallback();
    }
  }

  void _updateSelectedModelPath() {
    final isExploded =
        widget.mode == ViewerMode.exploded || widget.explosionRatio > 0.05;
    if (isExploded && widget.model.explodedAssetPath != null) {
      _selectedModelPath = widget.model.explodedAssetPath;
    } else {
      _selectedModelPath = widget.model.assetPath;
    }
  }

  void _startLoadTimeout() {
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _startWebReadyFallback() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _startAutoRotate() async {
    while (mounted && widget.isAutoRotating) {
      await Future.delayed(const Duration(milliseconds: 16));
      if (mounted && widget.isAutoRotating) {
        setState(() {
          _rotY += 0.015;
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getModelViewerSrc() {
    if (_selectedModelPath != null) {
      return _selectedModelPath!;
    }
    return widget.model.assetPath ?? 'assets/models/medical/heart/heart.glb';
  }

  double _getCameraDistance() {
    return 120 / widget.zoomScale.clamp(0.5, 3.0);
  }

  @override
  Widget build(BuildContext context) {
    final hasGlbModel =
        _selectedModelPath != null || widget.model.assetPath != null;
    final isExploded =
        widget.mode == ViewerMode.exploded || widget.explosionRatio > 0.05;
    final cameraDistance = _getCameraDistance();

    if (hasGlbModel) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ModelViewer(
            key: ValueKey(
              'model-${widget.model.id}-${isExploded ? 'exploded' : 'normal'}-$_attempt',
            ),
            src: _getModelViewerSrc(),
            alt: 'Interactive 3D model of ${widget.model.title}',
            backgroundColor: Colors.transparent,
            cameraControls: true,
            autoRotate: widget.isAutoRotating,
            autoRotateDelay: 0,
            rotationPerSecond: '18deg',
            cameraOrbit: '0deg 75deg ${cameraDistance.toStringAsFixed(0)}%',
            environmentImage: 'neutral',
            exposure: 1.1,
            shadowIntensity: 0.55,
            shadowSoftness: 0.8,
            ar:
                widget.enableAr &&
                widget.model.hasAR &&
                widget.model.arAssetPath != null,
            arModes: const ['scene-viewer', 'webxr', 'quick-look'],
            loading: Loading.eager,
          ),
          if (_isLoading)
            const IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Loading 3D Model...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasError)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xEE0F172A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Unable to load the 3D model.',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _attempt++;
                          _isLoading = true;
                          _hasError = false;
                        });
                        _startLoadTimeout();
                        _startWebReadyFallback();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    final effectiveScale = widget.zoomScale * _currentScale;

    return GestureDetector(
      onScaleStart: (details) {
        _lastFocalRotX = _rotX;
        _lastFocalRotY = _rotY;
        _baseScale = _currentScale;
      },
      onScaleUpdate: (details) {
        setState(() {
          if (details.pointerCount == 1) {
            _rotY = _lastFocalRotY + details.focalPointDelta.dx * 0.012;
            _rotX = (_lastFocalRotX - details.focalPointDelta.dy * 0.012).clamp(
              -math.pi / 2.3,
              math.pi / 2.3,
            );
            _lastFocalRotX = _rotX;
            _lastFocalRotY = _rotY;
          } else {
            _currentScale = (_baseScale * details.scale).clamp(0.6, 2.5);
          }
        });
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: Heart3DPainter(
              rotX: _rotX,
              rotY: _rotY,
              zoom: effectiveScale,
              mode: widget.mode,
              explosion: widget.explosionRatio,
              selectedPartId: widget.selectedPartId,
              pulseValue: _pulseController.value,
              showHotspots: widget.showHotspots,
              onHotspotHit: (partId) {
                widget.onSelectPart?.call(partId);
              },
            ),
          );
        },
      ),
    );
  }
}

class Heart3DPainter extends CustomPainter {
  final double rotX;
  final double rotY;
  final double zoom;
  final ViewerMode mode;
  final double explosion;
  final String? selectedPartId;
  final double pulseValue;
  final bool showHotspots;
  final Function(String partId)? onHotspotHit;

  Heart3DPainter({
    required this.rotX,
    required this.rotY,
    required this.zoom,
    required this.mode,
    required this.explosion,
    required this.selectedPartId,
    required this.pulseValue,
    required this.showHotspots,
    this.onHotspotHit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final isXRay = mode == ViewerMode.xray;

    // Light source vector pointing from top-front-right
    final lightDir = v64.Vector3(0.5, -0.7, 0.9).normalized();

    // Transformation Matrix
    final matrix = v64.Matrix4.identity()
      ..rotateX(rotX)
      ..rotateY(rotY);

    // List of mesh objects to sort by depth (Painter's Algorithm)
    final List<RenderMesh> meshes = [];

    // Base unit radius based on screen size
    final baseRadius = math.min(size.width, size.height) * 0.22 * zoom;

    // 1. Aorta (Red Artery Arch on Top)
    _buildAortaMesh(meshes, matrix, center, baseRadius, lightDir, isXRay);

    // 2. Left Ventricle (Lower Right Anatomical)
    _buildLeftVentricleMesh(
      meshes,
      matrix,
      center,
      baseRadius,
      lightDir,
      isXRay,
    );

    // 3. Right Ventricle (Lower Left Anatomical)
    _buildRightVentricleMesh(
      meshes,
      matrix,
      center,
      baseRadius,
      lightDir,
      isXRay,
    );

    // 4. Pulmonary Artery Trunk (Blue Vessel Crossing)
    _buildPulmonaryArteryMesh(
      meshes,
      matrix,
      center,
      baseRadius,
      lightDir,
      isXRay,
    );

    // 5. Superior Vena Cava (Top Left Blue Vessel)
    _buildVenaCavaMesh(meshes, matrix, center, baseRadius, lightDir, isXRay);

    // Sort meshes back-to-front (Z-sorting)
    meshes.sort((a, b) => a.depth.compareTo(b.depth));

    // Paint all sorted 3D meshes
    for (final mesh in meshes) {
      mesh.paint(canvas);
    }

    // Paint Hotspots if enabled
    if (showHotspots && mode != ViewerMode.exploded) {
      _paintHotspots(canvas, center, matrix, baseRadius);
    }
  }

  void _buildAortaMesh(
    List<RenderMesh> meshes,
    v64.Matrix4 matrix,
    Offset center,
    double r,
    v64.Vector3 lightDir,
    bool isXRay,
  ) {
    final explosionOffset = v64.Vector3(0, -90 * explosion, 20 * explosion);
    final partCenter = v64.Vector3(5, -r * 0.75, 5) + explosionOffset;
    final transformed = matrix.transformed3(partCenter);

    final isSelected = selectedPartId == 'aorta';

    meshes.add(
      RenderMesh(
        depth: transformed.z,
        paint: (canvas) {
          final pCenter = Offset(
            center.dx + transformed.x,
            center.dy + transformed.y,
          );
          final p = Path();
          // Arch curve
          final archRadius = r * 0.48;
          p.moveTo(
            pCenter.dx - archRadius * 0.6,
            pCenter.dy + archRadius * 0.6,
          );
          p.cubicTo(
            pCenter.dx - archRadius * 0.8,
            pCenter.dy - archRadius * 0.9,
            pCenter.dx + archRadius * 0.6,
            pCenter.dy - archRadius * 1.0,
            pCenter.dx + archRadius * 0.8,
            pCenter.dy + archRadius * 0.8,
          );

          if (isXRay) {
            final xRayPaint = Paint()
              ..color = const Color(0xFF38BDF8).withValues(alpha: 0.85)
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.28
              ..strokeCap = StrokeCap.round;
            canvas.drawPath(p, xRayPaint);

            final glowPaint = Paint()
              ..color = const Color(0xFF0284C7).withValues(alpha: 0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.42
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
            canvas.drawPath(p, glowPaint);
          } else {
            // Realistic Shading with 3D gradient
            final baseColor = isSelected
                ? const Color(0xFFFF2E2E)
                : const Color(0xFFDC2626);
            final shader =
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFF6B6B),
                    baseColor,
                    const Color(0xFF881337),
                  ],
                ).createShader(
                  Rect.fromCircle(center: pCenter, radius: archRadius),
                );

            final paint = Paint()
              ..shader = shader
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.34
              ..strokeCap = StrokeCap.round;
            canvas.drawPath(p, paint);

            // Three branching arterial trunks on top of aortic arch
            _drawArterialBranch(
              canvas,
              pCenter + Offset(-archRadius * 0.3, -archRadius * 0.7),
              r * 0.08,
              r * 0.26,
            );
            _drawArterialBranch(
              canvas,
              pCenter + Offset(archRadius * 0.0, -archRadius * 0.85),
              r * 0.08,
              r * 0.32,
            );
            _drawArterialBranch(
              canvas,
              pCenter + Offset(archRadius * 0.35, -archRadius * 0.75),
              r * 0.08,
              r * 0.28,
            );
          }

          if (isSelected) {
            _drawSelectionHalo(canvas, pCenter, archRadius);
          }
        },
      ),
    );
  }

  void _drawArterialBranch(
    Canvas canvas,
    Offset pos,
    double width,
    double height,
  ) {
    final branchPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: pos, width: width, height: height),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, branchPaint);
  }

  void _buildLeftVentricleMesh(
    List<RenderMesh> meshes,
    v64.Matrix4 matrix,
    Offset center,
    double r,
    v64.Vector3 lightDir,
    bool isXRay,
  ) {
    final explosionOffset = v64.Vector3(
      75 * explosion,
      50 * explosion,
      10 * explosion,
    );
    final partCenter = v64.Vector3(r * 0.35, r * 0.25, 10) + explosionOffset;
    final transformed = matrix.transformed3(partCenter);
    final isSelected = selectedPartId == 'left_ventricle';

    meshes.add(
      RenderMesh(
        depth: transformed.z,
        paint: (canvas) {
          final pCenter = Offset(
            center.dx + transformed.x,
            center.dy + transformed.y,
          );
          final bodyRect = Rect.fromCenter(
            center: pCenter,
            width: r * 0.85,
            height: r * 1.15,
          );

          if (isXRay) {
            final xRayPaint = Paint()
              ..color = const Color(0xFF06B6D4).withValues(alpha: 0.35)
              ..style = PaintingStyle.fill;
            canvas.drawOval(bodyRect, xRayPaint);

            final linePaint = Paint()
              ..color = const Color(0xFF38BDF8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0;
            canvas.drawOval(bodyRect, linePaint);
          } else {
            final shader = RadialGradient(
              center: const Alignment(-0.35, -0.45),
              radius: 0.85,
              colors: [
                const Color(0xFFF87171),
                isSelected ? const Color(0xFFDC2626) : const Color(0xFF991B1B),
                const Color(0xFF450A0A),
              ],
            ).createShader(bodyRect);

            final paint = Paint()
              ..shader = shader
              ..style = PaintingStyle.fill;
            canvas.drawOval(bodyRect, paint);

            // Cardiac muscle striations / coronary vessels overlay
            final vesselPaint = Paint()
              ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0;
            final path = Path()
              ..moveTo(pCenter.dx - r * 0.15, pCenter.dy - r * 0.35)
              ..quadraticBezierTo(
                pCenter.dx + r * 0.1,
                pCenter.dy,
                pCenter.dx + r * 0.25,
                pCenter.dy + r * 0.35,
              );
            canvas.drawPath(path, vesselPaint);
          }

          if (isSelected) {
            _drawSelectionHalo(canvas, pCenter, r * 0.5);
          }
        },
      ),
    );
  }

  void _buildRightVentricleMesh(
    List<RenderMesh> meshes,
    v64.Matrix4 matrix,
    Offset center,
    double r,
    v64.Vector3 lightDir,
    bool isXRay,
  ) {
    final explosionOffset = v64.Vector3(
      -75 * explosion,
      50 * explosion,
      10 * explosion,
    );
    final partCenter = v64.Vector3(-r * 0.35, r * 0.28, -5) + explosionOffset;
    final transformed = matrix.transformed3(partCenter);
    final isSelected = selectedPartId == 'right_ventricle';

    meshes.add(
      RenderMesh(
        depth: transformed.z,
        paint: (canvas) {
          final pCenter = Offset(
            center.dx + transformed.x,
            center.dy + transformed.y,
          );
          final bodyRect = Rect.fromCenter(
            center: pCenter,
            width: r * 0.80,
            height: r * 1.05,
          );

          if (isXRay) {
            final xRayPaint = Paint()
              ..color = const Color(0xFF0EA5E9).withValues(alpha: 0.35)
              ..style = PaintingStyle.fill;
            canvas.drawOval(bodyRect, xRayPaint);

            final linePaint = Paint()
              ..color = const Color(0xFF38BDF8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0;
            canvas.drawOval(bodyRect, linePaint);
          } else {
            final shader = RadialGradient(
              center: const Alignment(0.3, -0.4),
              radius: 0.85,
              colors: [
                const Color(0xFFEF4444),
                isSelected ? const Color(0xFFDC2626) : const Color(0xFF7F1D1D),
                const Color(0xFF3A0606),
              ],
            ).createShader(bodyRect);

            final paint = Paint()
              ..shader = shader
              ..style = PaintingStyle.fill;
            canvas.drawOval(bodyRect, paint);
          }

          if (isSelected) {
            _drawSelectionHalo(canvas, pCenter, r * 0.45);
          }
        },
      ),
    );
  }

  void _buildPulmonaryArteryMesh(
    List<RenderMesh> meshes,
    v64.Matrix4 matrix,
    Offset center,
    double r,
    v64.Vector3 lightDir,
    bool isXRay,
  ) {
    final explosionOffset = v64.Vector3(
      -40 * explosion,
      -55 * explosion,
      -25 * explosion,
    );
    final partCenter = v64.Vector3(-r * 0.15, -r * 0.3, 20) + explosionOffset;
    final transformed = matrix.transformed3(partCenter);
    final isSelected = selectedPartId == 'pulmonary_artery';

    meshes.add(
      RenderMesh(
        depth: transformed.z + 15, // Prominently in front of aortic base
        paint: (canvas) {
          final pCenter = Offset(
            center.dx + transformed.x,
            center.dy + transformed.y,
          );
          final rect = Rect.fromCenter(
            center: pCenter,
            width: r * 0.42,
            height: r * 0.65,
          );

          if (isXRay) {
            final xRayPaint = Paint()
              ..color = const Color(0xFF60A5FA).withValues(alpha: 0.7)
              ..style = PaintingStyle.fill;
            canvas.drawOval(rect, xRayPaint);
          } else {
            final shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF60A5FA),
                isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1D4ED8),
                const Color(0xFF1E3A8A),
              ],
            ).createShader(rect);

            final paint = Paint()
              ..shader = shader
              ..style = PaintingStyle.fill;
            canvas.drawOval(rect, paint);
          }

          if (isSelected) {
            _drawSelectionHalo(canvas, pCenter, r * 0.3);
          }
        },
      ),
    );
  }

  void _buildVenaCavaMesh(
    List<RenderMesh> meshes,
    v64.Matrix4 matrix,
    Offset center,
    double r,
    v64.Vector3 lightDir,
    bool isXRay,
  ) {
    final explosionOffset = v64.Vector3(
      -60 * explosion,
      -70 * explosion,
      -10 * explosion,
    );
    final partCenter = v64.Vector3(-r * 0.55, -r * 0.55, -15) + explosionOffset;
    final transformed = matrix.transformed3(partCenter);
    final isSelected = selectedPartId == 'superior_vena_cava';

    meshes.add(
      RenderMesh(
        depth: transformed.z - 20, // Anatomically behind right atrium
        paint: (canvas) {
          final pCenter = Offset(
            center.dx + transformed.x,
            center.dy + transformed.y,
          );
          final rrect = RRect.fromRectAndRadius(
            Rect.fromCenter(center: pCenter, width: r * 0.28, height: r * 0.75),
            Radius.circular(r * 0.14),
          );

          if (isXRay) {
            final xRayPaint = Paint()
              ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
              ..style = PaintingStyle.fill;
            canvas.drawRRect(rrect, xRayPaint);
          } else {
            final shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF3B82F6),
                isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E40AF),
                const Color(0xFF172554),
              ],
            ).createShader(rrect.outerRect);

            final paint = Paint()
              ..shader = shader
              ..style = PaintingStyle.fill;
            canvas.drawRRect(rrect, paint);
          }

          if (isSelected) {
            _drawSelectionHalo(canvas, pCenter, r * 0.3);
          }
        },
      ),
    );
  }

  void _drawSelectionHalo(Canvas canvas, Offset center, double radius) {
    final haloPaint = Paint()
      ..color = const Color(0xFF38BDF8)
          .withValues(alpha: 0.6 + pulseValue * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius * (1.1 + pulseValue * 0.08), haloPaint);
  }

  void _paintHotspots(
    Canvas canvas,
    Offset center,
    v64.Matrix4 matrix,
    double r,
  ) {
    // Coordinate definitions for hotspots
    final hotspots = [
      {'id': 'aorta', 'name': 'Aorta', 'pos': v64.Vector3(10, -r * 0.85, 25)},
      {
        'id': 'left_ventricle',
        'name': 'Left Ventricle',
        'pos': v64.Vector3(r * 0.45, r * 0.3, 20),
      },
      {
        'id': 'right_ventricle',
        'name': 'Right Ventricle',
        'pos': v64.Vector3(-r * 0.45, r * 0.35, 15),
      },
    ];

    for (final h in hotspots) {
      final pos = h['pos'] as v64.Vector3;
      final transformed = matrix.transformed3(pos);

      // Only draw if facing towards camera (Z > -30)
      if (transformed.z > -40) {
        final screenPos = Offset(
          center.dx + transformed.x,
          center.dy + transformed.y,
        );
        final isSelected = selectedPartId == h['id'];

        // Outer pulse circle
        final pulseRadius = isSelected ? 16.0 + pulseValue * 6.0 : 12.0;
        final pulsePaint = Paint()
          ..color = (isSelected ? const Color(0xFF1E6BFF) : Colors.white)
              .withValues(alpha: 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(screenPos, pulseRadius, pulsePaint);

        // Core Pin
        final corePaint = Paint()
          ..color = isSelected ? const Color(0xFF1E6BFF) : Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(screenPos, 7.0, corePaint);

        final ringPaint = Paint()
          ..color = isSelected ? Colors.white : const Color(0xFF1E6BFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(screenPos, 7.0, ringPaint);

        // Callout Tag if selected
        if (isSelected) {
          _drawHotspotCallout(canvas, screenPos, h['name'] as String);
        }
      }
    }
  }

  void _drawHotspotCallout(Canvas canvas, Offset pinPos, String partName) {
    final textSpan = TextSpan(
      text: '$partName: Carries oxygen-rich\nblood to the body.',
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 180);

    const padding = 12.0;
    final boxWidth = textPainter.width + padding * 2;
    final boxHeight = textPainter.height + padding * 2;
    final boxOffset = Offset(
      pinPos.dx - boxWidth / 2,
      pinPos.dy - boxHeight - 16,
    );

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxOffset.dx, boxOffset.dy, boxWidth, boxHeight),
      const Radius.circular(12),
    );

    // Callout bubble shadow & background
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(bubbleRect.shift(const Offset(0, 4)), shadowPaint);

    final bubblePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bubbleRect, bubblePaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF1E6BFF).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(bubbleRect, borderPaint);

    // Pointer arrow downward to pin
    final arrowPath = Path()
      ..moveTo(pinPos.dx - 6, boxOffset.dy + boxHeight)
      ..lineTo(pinPos.dx, pinPos.dy - 2)
      ..lineTo(pinPos.dx + 6, boxOffset.dy + boxHeight)
      ..close();
    canvas.drawPath(arrowPath, bubblePaint);

    // Draw text inside
    textPainter.paint(
      canvas,
      Offset(boxOffset.dx + padding, boxOffset.dy + padding),
    );
  }

  @override
  bool shouldRepaint(covariant Heart3DPainter oldDelegate) {
    return oldDelegate.rotX != rotX ||
        oldDelegate.rotY != rotY ||
        oldDelegate.zoom != zoom ||
        oldDelegate.mode != mode ||
        oldDelegate.explosion != explosion ||
        oldDelegate.selectedPartId != selectedPartId ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.showHotspots != showHotspots;
  }
}

class RenderMesh {
  final double depth;
  final Function(Canvas canvas) paint;

  RenderMesh({required this.depth, required this.paint});
}
