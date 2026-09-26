import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Entrance animation (cube pop-in + fade)
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Staggered text reveal
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _footerFade;

  // Continuous idle animations (loop forever while splash is visible)
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Progress bar
  late AnimationController _progressController;

  Timer? _navigationTimer;

  static const _splashDuration = Duration(milliseconds: 3200);

  @override
  void initState() {
    super.initState();

    // -----------------------------------------------------------------------
    // Entrance controller — cube scales/fades in, then text staggers in
    // -----------------------------------------------------------------------
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.55, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // -----------------------------------------------------------------------
    // Gentle up/down float for the cube — loops continuously
    // -----------------------------------------------------------------------
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // -----------------------------------------------------------------------
    // Slow continuous "breathing" rotation of the isometric cube
    // -----------------------------------------------------------------------
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // -----------------------------------------------------------------------
    // Pulsing glow behind the cube
    // -----------------------------------------------------------------------
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // -----------------------------------------------------------------------
    // Progress indicator that fills over the splash duration
    // -----------------------------------------------------------------------
    _progressController = AnimationController(
      vsync: this,
      duration: _splashDuration,
    )..forward();

    // Auto navigate after splash duration
    _navigationTimer = Timer(_splashDuration, _goToOnboarding);
  }

  void _goToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    _floatController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _navigationTimer?.cancel();
          _goToOnboarding();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF0F172A)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Subtle floating background particles for depth
                const Positioned.fill(child: _BackgroundParticles()),

                // Top Bar
                Positioned(
                  top: 12,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),

                // Center 3D Cube & Branding
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // -------------------------------------------------------
                      // Cube: entrance scale/fade + continuous float/rotate/glow
                      // -------------------------------------------------------
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _floatController,
                              _rotationController,
                              _glowController,
                            ]),
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatAnimation.value),
                                child: Transform.rotate(
                                  angle: _rotationAnimation.value,
                                  child: Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E40AF)
                                          .withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(36),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF38BDF8)
                                              .withValues(
                                                alpha: _glowAnimation.value,
                                              ),
                                          blurRadius: 36,
                                          spreadRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: CustomPaint(
                                        size: const Size(80, 80),
                                        painter: IsometricCubePainter(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // -------------------------------------------------------
                      // Title — slides + fades in
                      // -------------------------------------------------------
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleFade,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFBFDBFE)],
                            ).createShader(bounds),
                            child: const Text(
                              '3D Learn AR',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // -------------------------------------------------------
                      // Subtitle — slides + fades in slightly after the title
                      // -------------------------------------------------------
                      SlideTransition(
                        position: _subtitleSlide,
                        child: FadeTransition(
                          opacity: _subtitleFade,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Explore Real World Concepts\nin 3D & Augmented Reality',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF93C5FD),
                                height: 1.45,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Footer
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _footerFade,
                    child: Column(
                      children: [
                        const Text(
                          'Learning Today\nfor a Brighter Tomorrow',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                            height: 1.4,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // -----------------------------------------------------
                        // Animated progress bar — fills over splash duration
                        // -----------------------------------------------------
                        Container(
                          width: 120,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  widthFactor: _progressController.value,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF38BDF8),
                                          Color(0xFF67E8F9),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF38BDF8)
                                              .withValues(alpha: 0.6),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BACKGROUND PARTICLES — soft floating dots for depth, purely decorative
// =============================================================================

class _BackgroundParticles extends StatefulWidget {
  const _BackgroundParticles();

  @override
  State<_BackgroundParticles> createState() => _BackgroundParticlesState();
}

class _BackgroundParticlesState extends State<_BackgroundParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Fixed pseudo-random layout so particles don't jump around each rebuild
  final List<_Particle> _particles = List.generate(14, (i) {
    final rnd = math.Random(i * 37);
    return _Particle(
      dx: rnd.nextDouble(),
      dy: rnd.nextDouble(),
      size: 2 + rnd.nextDouble() * 3,
      speed: 0.4 + rnd.nextDouble() * 0.6,
      phase: rnd.nextDouble() * math.pi * 2,
    );
  });

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
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
          painter: _ParticlePainter(
            particles: _particles,
            t: _controller.value,
          ),
        );
      },
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;
  final double speed;
  final double phase;

  _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  _ParticlePainter({required this.particles, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.12);

    for (final p in particles) {
      final baseY = p.dy * size.height;
      final drift = math.sin((t * math.pi * 2 * p.speed) + p.phase) * 14;
      final offset = Offset(p.dx * size.width, baseY + drift);

      canvas.drawCircle(offset, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

// =============================================================================
// ISOMETRIC CUBE PAINTER — unchanged visual, same theme
// =============================================================================

class IsometricCubePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final r = w * 0.45;

    // Isometric Cube 3 Faces: Top, Left, Right
    final pTop = Offset(center.dx, center.dy - r);
    final pTopRight = Offset(center.dx + r * 0.866, center.dy - r * 0.5);
    final pCenter = Offset(center.dx, center.dy);
    final pTopLeft = Offset(center.dx - r * 0.866, center.dy - r * 0.5);
    final pBottomRight = Offset(center.dx + r * 0.866, center.dy + r * 0.5);
    final pBottom = Offset(center.dx, center.dy + r);
    final pBottomLeft = Offset(center.dx - r * 0.866, center.dy + r * 0.5);

    // Top Face (Light cyan blue)
    final topPath = Path()
      ..moveTo(pCenter.dx, pCenter.dy)
      ..lineTo(pTopRight.dx, pTopRight.dy)
      ..lineTo(pTop.dx, pTop.dy)
      ..lineTo(pTopLeft.dx, pTopLeft.dy)
      ..close();
    canvas.drawPath(
      topPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF67E8F9), Color(0xFF38BDF8)],
        ).createShader(Offset.zero & size),
    );

    // Right Face (Deep vibrant blue)
    final rightPath = Path()
      ..moveTo(pCenter.dx, pCenter.dy)
      ..lineTo(pTopRight.dx, pTopRight.dy)
      ..lineTo(pBottomRight.dx, pBottomRight.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..close();
    canvas.drawPath(
      rightPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ).createShader(Offset.zero & size),
    );

    // Left Face (Mid cyan/royal blue)
    final leftPath = Path()
      ..moveTo(pCenter.dx, pCenter.dy)
      ..lineTo(pTopLeft.dx, pTopLeft.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..close();
    canvas.drawPath(
      leftPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
        ).createShader(Offset.zero & size),
    );

    // Crisp white bevel outline
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(topPath, strokePaint);
    canvas.drawPath(rightPath, strokePaint);
    canvas.drawPath(leftPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
