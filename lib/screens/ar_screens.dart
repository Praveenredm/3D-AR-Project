import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ar_view_widget.dart';

// SCREEN 12: AR Mode (Start)
class ARModeStartScreen extends StatelessWidget {
  const ARModeStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      color: AppTheme.textPrimary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Text(
                    'View in AR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.crop_free_rounded,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Central Device Graphic Illustration
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.primarySoft,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smartphone_rounded,
                          color: AppTheme.primaryBlue,
                          size: 70,
                        ),
                      ),
                      Positioned(
                        bottom: 45,
                        right: 45,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF38BDF8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.view_in_ar_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Step Instructions List
              _buildInstructionStep(
                stepNum: '1',
                text: 'Point your camera at a flat surface (like a table or floor).',
              ),
              const SizedBox(height: 16),
              _buildInstructionStep(
                stepNum: '2',
                text: 'Move around slowly to detect the surface.',
              ),
              const SizedBox(height: 16),
              _buildInstructionStep(
                stepNum: '3',
                text: 'Tap to place the 3D model.',
              ),

              const Spacer(flex: 2),

              // Start AR CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final appState = Provider.of<AppState>(
                      context,
                      listen: false,
                    );
                    appState.startARScan();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ARScanningScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Start AR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep({
    required String stepNum,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppTheme.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNum,
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// SCREEN 13: AR Scanning Surface
class ARScanningScreen extends StatefulWidget {
  const ARScanningScreen({super.key});

  @override
  State<ARScanningScreen> createState() => _ARScanningScreenState();
}

class _ARScanningScreenState extends State<ARScanningScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final modelAsset =
        appState.currentModel.arAssetPath ??
        appState.currentModel.assetPath ??
        '';
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: ModelViewer(
              src: modelAsset,
              alt: 'AR model of ${appState.currentModel.title}',
              backgroundColor: Colors.transparent,
              cameraControls: true,
              autoRotate: true,
              ar: true,
              arModes: const ['scene-viewer', 'webxr'],
              loading: Loading.eager,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flash_on_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Text(
                  'Tap the AR button in the viewer to place this model.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SCREEN 14: AR Placement Screen
class ARPlacementScreen extends StatefulWidget {
  const ARPlacementScreen({super.key});

  @override
  State<ARPlacementScreen> createState() => _ARPlacementScreenState();
}

class _ARPlacementScreenState extends State<ARPlacementScreen> {
  double _scale = 1.0;
  double _rotation = 0.0;
  bool _isModelAnchored = true;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final model = appState.currentModel;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Anchored 3D Model on Surface
          Positioned.fill(
            child: ARModelAnchorWidget(
              model: model,
              scale: _scale,
              rotation: _rotation,
            ),
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right AR Floating Controls (Rotate, Scale, Reset)
          Positioned(
            right: 16,
            top: 180,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.rotate_90_degrees_ccw_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Rotate',
                    onPressed: () {
                      setState(() {
                        _rotation += 0.4;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.aspect_ratio_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Scale',
                    onPressed: () {
                      setState(() {
                        _scale = _scale >= 1.4 ? 0.8 : _scale + 0.2;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.replay_rounded, color: Colors.white),
                    tooltip: 'Reset',
                    onPressed: () {
                      setState(() {
                        _scale = 1.0;
                        _rotation = 0.0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action: Tap to Place or Snapshot CTA
          Positioned(
            bottom: 36,
            left: 40,
            right: 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isModelAnchored = !_isModelAnchored;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isModelAnchored
                          ? '3D Model anchored to plane!'
                          : 'Model released for repositioning',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isModelAnchored
                          ? Icons.check_circle_rounded
                          : Icons.touch_app_rounded,
                      color: const Color(0xFF34D399),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isModelAnchored
                          ? 'Model Anchored'
                          : 'Tap to place the model',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
