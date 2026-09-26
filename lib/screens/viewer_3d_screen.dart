import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/interactive_3d_viewer.dart';
import 'ar_screens.dart';

class Viewer3DScreen extends StatefulWidget {
  final ViewerMode initialMode;
  final bool initialExploded;

  const Viewer3DScreen({
    super.key,
    this.initialMode = ViewerMode.normal,
    this.initialExploded = false,
  });

  @override
  State<Viewer3DScreen> createState() => _Viewer3DScreenState();
}

class _Viewer3DScreenState extends State<Viewer3DScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (widget.initialExploded && appState.currentModel.hasExplodedView) {
        appState.setViewerMode(ViewerMode.exploded);
        appState.setExplosionRatio(0.65);
      } else {
        appState.setViewerMode(widget.initialMode);
      }
    });
  }

  void _showInfoPanel(BuildContext context, AnatomicalPart part) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildInfoPanelModal(context, part),
    );
  }

  Widget _buildInfoPanelModal(BuildContext context, AnatomicalPart part) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          // Part Render Preview Box
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: part.partColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bubble_chart_rounded,
                      color: part.partColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Anatomical Component: ${part.name}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: part.partColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Title & Description (Screen 11: Information Panel)
          Text(
            part.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            part.description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),

          if (part.function.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Function',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBlue,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              part.function,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],

          if (part.bloodFlow.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Blood Flow',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBlue,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              part.bloodFlow,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Key Points
          const Text(
            'Key Points',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          ...part.keyPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.arrow_right_alt_rounded,
                      color: AppTheme.primaryBlue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Read More Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Opening medical encyclopedia for ${part.name}...',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Read More',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final model = appState.currentModel;
    final canExplode = model.hasExplodedView && model.explodedAssetPath != null;
    final selectedPart = model.parts.firstWhere(
      (p) => p.id == appState.selectedPartId,
      orElse: () => model.parts.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark 3D Studio Canvas
      body: SafeArea(
        child: Stack(
          children: [
            // Center Interactive 3D Canvas
            Positioned.fill(
              child: Interactive3DViewer(
                model: model,
                mode: appState.viewerMode,
                explosionRatio: appState.explosionRatio,
                selectedPartId: appState.selectedPartId,
                showHotspots: appState.showHotspots,
                isAutoRotating: appState.isAutoRotating,
                zoomScale: appState.zoomScale,
                onSelectPart: (partId) {
                  appState.setSelectedPartId(partId);
                },
                onOpenInfoPanel: () {
                  _showInfoPanel(context, selectedPart);
                },
              ),
            ),

            // Top Header Bar
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(width: 14),
                  Text(
                    model.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // AR Switch Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.view_in_ar_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ARModeStartScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Floating Tools Panel on the Right
            Positioned(
              right: 16,
              top: 90,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToolButton(
                      icon: Icons.rotate_right_rounded,
                      label: 'Rotate',
                      isActive: appState.isAutoRotating,
                      onTap: () => appState.toggleAutoRotate(),
                    ),
                    const SizedBox(height: 12),
                    _buildToolButton(
                      icon: Icons.zoom_in_rounded,
                      label: 'Zoom',
                      isActive: appState.zoomScale > 1.0,
                      onTap: () => appState.zoomIn(),
                    ),
                    const SizedBox(height: 12),
                    _buildToolButton(
                      icon: Icons.view_sidebar_rounded,
                      label: 'Explode',
                      isActive: appState.viewerMode == ViewerMode.exploded,
                      isEnabled: canExplode,
                      onTap: () {
                        if (appState.viewerMode == ViewerMode.exploded) {
                          appState.setViewerMode(ViewerMode.normal);
                        } else {
                          appState.setViewerMode(ViewerMode.exploded);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildToolButton(
                      icon: Icons.adjust_rounded,
                      label: 'Parts',
                      isActive: appState.showHotspots,
                      onTap: () => appState.toggleHotspots(),
                    ),
                    const SizedBox(height: 12),
                    _buildToolButton(
                      icon: Icons.info_outline_rounded,
                      label: 'Info',
                      isActive: false,
                      onTap: () => _showInfoPanel(context, selectedPart),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Controls Area
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Explode Slider (Screen 9: Exploded View)
                  if (appState.viewerMode == ViewerMode.exploded)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Explode',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(appState.explosionRatio * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: appState.explosionRatio,
                              min: 0.0,
                              max: 1.0,
                              activeColor: AppTheme.primaryBlue,
                              inactiveColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              onChanged: (val) {
                                appState.setExplosionRatio(val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Horizontal Part Pills (Screen 10: Parts / Hotspots)
                  if (appState.showHotspots)
                    Container(
                      height: 44,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: model.parts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final part = model.parts[index];
                          final isSelected = appState.selectedPartId == part.id;

                          return GestureDetector(
                            onTap: () {
                              appState.setSelectedPartId(part.id);
                              _showInfoPanel(context, part);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : const Color(0xFF1E293B)
                                          .withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.adjust_rounded,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.primaryLight,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    part.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Mode Toggle Bar (Normal, Exploded, X-Ray) - Screen 8
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildModeTab(
                          label: 'Normal',
                          icon: Icons.view_in_ar_rounded,
                          isSelected: appState.viewerMode == ViewerMode.normal,
                          onTap: () =>
                              appState.setViewerMode(ViewerMode.normal),
                        ),
                        _buildModeTab(
                          label: 'Exploded',
                          icon: Icons.grain_rounded,
                          isSelected:
                              appState.viewerMode == ViewerMode.exploded,
                          isEnabled: canExplode,
                          onTap: () =>
                              appState.setViewerMode(ViewerMode.exploded),
                        ),
                        _buildModeTab(
                          label: 'X-Ray',
                          icon: Icons.blur_on_rounded,
                          isSelected: appState.viewerMode == ViewerMode.xray,
                          onTap: () => appState.setViewerMode(ViewerMode.xray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isActive,
    bool isEnabled = true,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: !isEnabled
                  ? Colors.white.withValues(alpha: 0.03)
                  : isActive
                  ? AppTheme.primaryBlue
                  : Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: !isEnabled
                  ? Colors.white24
                  : isActive
                  ? Colors.white
                  : Colors.white70,
              size: 20,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: !isEnabled
                  ? Colors.white24
                  : isActive
                  ? AppTheme.primaryLight
                  : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isEnabled && isSelected
                ? AppTheme.primaryBlue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: !isEnabled
                    ? Colors.white24
                    : isSelected
                    ? Colors.white
                    : Colors.white60,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: !isEnabled
                      ? Colors.white24
                      : isSelected
                      ? Colors.white
                      : Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
