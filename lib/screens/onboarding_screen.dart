import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  int _currentPage = 0;

  static const int _totalPages = 3;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // NEXT / GET STARTED
  // ---------------------------------------------------------------------------

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  // ---------------------------------------------------------------------------
  // PREVIOUS PAGE
  // ---------------------------------------------------------------------------

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // GET STARTED
  // ---------------------------------------------------------------------------

  void _onGetStarted() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AuthScreen(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // TOP BAR
            // =================================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BACK BUTTON
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      color: _currentPage > 0
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary.withValues(
                              alpha: 0.35,
                            ),
                      onPressed:
                          _currentPage > 0 ? _goToPreviousPage : null,
                    ),

                    // SKIP
                    TextButton(
                      onPressed: _onGetStarted,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =================================================================
            // PAGE VIEW
            // =================================================================

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // -----------------------------------------------------------
                  // PAGE 1
                  // -----------------------------------------------------------

                  _buildOnboardingPage(
                    imagePath: 'assets/onboarding/learn_3d.png',
                    title: 'Learn Anything\nin 3D',
                    description:
                        'Explore real models, interact,\nvisualize and learn with\nAugmented Reality.',
                  ),

                  // -----------------------------------------------------------
                  // PAGE 2
                  // -----------------------------------------------------------

                  _buildOnboardingPage(
                    imagePath:
                        'assets/onboarding/interactive_3d_models.png',
                    title: 'Explore Interactive\n3D Models',
                    description:
                        'Rotate, zoom and interact with\ndetailed models to understand\ncomplex concepts.',
                  ),

                  // -----------------------------------------------------------
                  // PAGE 3
                  // -----------------------------------------------------------

                  _buildOnboardingPage(
                    imagePath:
                        'assets/onboarding/augmented_reality.png',
                    title: 'Learn with\nAugmented Reality',
                    description:
                        'Bring 3D models into the real\nworld and learn by interacting\nwith them.',
                  ),
                ],
              ),
            ),

            // =================================================================
            // PAGE INDICATORS
            // =================================================================

            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) {
                    final bool isActive = index == _currentPage;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      width: isActive ? 30 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.primaryBlue
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ),
            ),

            // =================================================================
            // NEXT / GET STARTED BUTTON
            // =================================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                24,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToNextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.primaryBlue.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _totalPages - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ONBOARDING PAGE
  // ===========================================================================

  Widget _buildOnboardingPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // =============================================================
                // IMAGE
                // =============================================================

                SizedBox(
                  width: 320,
                  height: 320,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 320,
                        height: 320,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // =============================================================
                // TITLE
                // =============================================================

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 16),

                // =============================================================
                // DESCRIPTION
                // =============================================================

                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}