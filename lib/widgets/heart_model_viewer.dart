import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart' show JavaScriptMessage;

/// Renders the supplied heart GLB rather than a painted approximation.
class HeartModelViewer extends StatefulWidget {
  final bool autoRotate;
  final double zoomScale;
  final bool enableAr;
  final bool isExploded;

  const HeartModelViewer({
    super.key,
    required this.autoRotate,
    required this.zoomScale,
    this.enableAr = false,
    this.isExploded = false,
  });

  @override
  State<HeartModelViewer> createState() => _HeartModelViewerState();
}

class _HeartModelViewerState extends State<HeartModelViewer> {
  int _attempt = 0;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _loadTimeout;
  Timer? _webReadyFallback;

  @override
  void initState() {
    super.initState();
    _startLoadTimeout();
    // The web implementation has no WebView JavaScript channel. Its native
    // model-viewer element continues to report rendering errors in-browser.
    _startWebReadyFallback();
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    _webReadyFallback?.cancel();
    super.dispose();
  }

  void _startLoadTimeout() {
    _loadTimeout?.cancel();
    _loadTimeout = Timer(const Duration(seconds: 20), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    });
  }

  void _retry() {
    setState(() {
      _attempt++;
      _isLoading = true;
      _hasError = false;
    });
    _startLoadTimeout();
    _startWebReadyFallback();
  }

  void _startWebReadyFallback() {
    if (!kIsWeb) return;
    _webReadyFallback?.cancel();
    _webReadyFallback = Timer(const Duration(milliseconds: 1200), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _onModelStatus(JavaScriptMessage message) {
    if (!mounted) return;
    _loadTimeout?.cancel();
    setState(() {
      _isLoading = false;
      _hasError = message.message != 'loaded';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Automatic framing keeps the complete model visible at its initial scale.
    final cameraDistance = 120 / widget.zoomScale.clamp(0.5, 3.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        ModelViewer(
          key: ValueKey('heart-model-${widget.isExploded}-$_attempt'),
          src: widget.isExploded
              ? 'assets/models/medical/heart/cardiac_anatomy_external_view_of_human_heart.glb'
              : 'assets/models/medical/heart/heart.glb',
          alt: 'Interactive 3D model of a human heart',
          backgroundColor: Colors.transparent,
          cameraControls: true,
          autoRotate: widget.autoRotate,
          autoRotateDelay: 0,
          rotationPerSecond: '18deg',
          cameraOrbit: '0deg 75deg ${cameraDistance.toStringAsFixed(0)}%',
          environmentImage: 'neutral',
          exposure: 1.1,
          shadowIntensity: 0.55,
          shadowSoftness: 0.8,
          ar: widget.enableAr,
          arModes: const ['scene-viewer', 'webxr', 'quick-look'],
          loading: Loading.eager,
          javascriptChannels: {
            JavascriptChannel(
              'HeartModelStatus',
              onMessageReceived: _onModelStatus,
            ),
          },
          relatedJs: '''
            (() => {
              const bindHeartModelEvents = () => {
                const viewer = document.querySelector('model-viewer');
                if (!viewer || viewer.dataset.heartEventsBound) return;
                viewer.dataset.heartEventsBound = 'true';
                viewer.addEventListener('load', () => HeartModelStatus.postMessage('loaded'));
                viewer.addEventListener('error', () => HeartModelStatus.postMessage('error'));
              };
              bindHeartModelEvents();
              document.addEventListener('DOMContentLoaded', bindHeartModelEvents);
            })();
          ''',
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
                  TextButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
