import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../data/app_data.dart';
import '../theme/app_theme.dart';

import 'domain_screen.dart';
import 'topic_screen.dart';
import 'model_info_screen.dart';
import 'ar_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ===========================================================================
  // DOMAIN TITLE
  // ===========================================================================
  static String _domainTitle(String id) {
    switch (id.toLowerCase()) {
      case 'medical':
        return 'Medical';
      case 'computer_hardware':
      case 'computer-hardware':
      case 'computerhardware':
      case 'hardware':
        return 'Computer\nHardware';
      case 'electronics':
        return 'Electronics';
      case 'automobile':
      case 'automotive':
        return 'Automobile';
      case 'mechanical':
        return 'Mechanical';
      case 'biology':
        return 'Biology';
      default:
        return id
            .replaceAll('_', ' ')
            .replaceAll('-', ' ')
            .split(' ')
            .map(
              (word) => word.isEmpty
                  ? ''
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
    }
  }

  // ===========================================================================
  // DOMAIN DESCRIPTION (subtitle shown under the title, like the reference UI)
  // ===========================================================================
  static String _domainDescription(String id) {
    switch (id.toLowerCase()) {
      case 'medical':
        return 'Explore the human body';
      case 'computer_hardware':
      case 'computer-hardware':
      case 'computerhardware':
      case 'hardware':
        return 'Discover how computers work';
      case 'electronics':
        return 'Learn circuits and devices';
      case 'automobile':
      case 'automotive':
        return 'Explore vehicle systems';
      case 'mechanical':
        return 'Understand machines and mechanisms';
      case 'biology':
        return 'Explore life and living organisms';
      default:
        return 'Explore this domain in AR';
    }
  }

  // ===========================================================================
  // DOMAIN ICON (used as a lightweight fallback / accent glyph)
  // ===========================================================================
  static IconData _domainIcon(String id) {
    switch (id.toLowerCase()) {
      case 'medical':
        return Icons.favorite_rounded;
      case 'computer_hardware':
      case 'computer-hardware':
      case 'computerhardware':
      case 'hardware':
        return Icons.memory_rounded;
      case 'electronics':
        return Icons.bolt_rounded;
      case 'automobile':
      case 'automotive':
        return Icons.directions_car_filled_rounded;
      case 'mechanical':
        return Icons.settings_rounded;
      case 'biology':
        return Icons.eco_rounded;
      default:
        return Icons.view_in_ar_rounded;
    }
  }

  // ===========================================================================
  // DOMAIN IMAGE
  // ===========================================================================
  static String _domainImage(String id) {
    switch (id.toLowerCase()) {
      case 'medical':
        return 'assets/images/domains/medical.png';
      case 'computer_hardware':
      case 'computer-hardware':
      case 'computerhardware':
      case 'hardware':
        return 'assets/images/domains/computer_hardware.png';
      case 'electronics':
        return 'assets/images/domains/electronics.png';
      case 'automobile':
      case 'automotive':
        return 'assets/images/domains/automobile.png';
      case 'mechanical':
        return 'assets/images/domains/mechanical.png';
      case 'biology':
        return 'assets/images/domains/biology.png';
      default:
        return 'assets/images/domains/medical.png';
    }
  }

  // ===========================================================================
  // DOMAIN COLORS
  // ===========================================================================
  static Color _domainBackground(String id) {
    switch (id.toLowerCase()) {
      case 'medical':
        return const Color(0xFFFFE9EC);
      case 'computer_hardware':
      case 'computer-hardware':
      case 'computerhardware':
      case 'hardware':
        return const Color(0xFFE7F0FF);
      case 'electronics':
        return const Color(0xFFFFF3D9);
      case 'automobile':
      case 'automotive':
        return const Color(0xFFEEE7FF);
      case 'mechanical':
        return const Color(0xFFE3FBEA);
      case 'biology':
        return const Color(0xFFE1FBF7);
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  static Color _domainAccent(String id) {
    switch (id.toLowerCase()) {
      case 'medical':
        return const Color(0xFFE4405F);
      case 'computer_hardware':
      case 'computer-hardware':
      case 'computerhardware':
      case 'hardware':
        return const Color(0xFF3B82F6);
      case 'electronics':
        return const Color(0xFFF59E0B);
      case 'automobile':
      case 'automotive':
        return const Color(0xFF8B5CF6);
      case 'mechanical':
        return const Color(0xFF16A34A);
      case 'biology':
        return const Color(0xFF0D9488);
      default:
        return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================================
              // TOP HEADER
              // =================================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hi, ${appState.userName}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('👋', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Ready to explore today?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => appState.setNavIndex(4),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE2E8F0),
                        child: Icon(
                          Icons.person_rounded,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================================
              // SEARCH BAR
              // =================================================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                  border: Border.all(color: AppTheme.borderSubtle, width: 1),
                ),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search models, e.g. Heart, CPU...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textTertiary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (value) {
                    final query = value.trim().toLowerCase();
                    if (query.isEmpty) return;

                    if (query.contains('heart')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ModelInfoScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TopicScreen()),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 22),

              // =================================================================
              // AR HERO BANNER
              // =================================================================
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ARModeStartScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E6BFF),
                        Color(0xFF2563EB),
                        Color(0xFF3B82F6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E6BFF).withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        bottom: -30,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 100,
                        top: -35,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Visualize\nExplore\nLearn',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            _ARBadge(),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 18,
                        bottom: 12,
                        top: 12,
                        child: Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              const Icon(
                                Icons.view_in_ar_rounded,
                                color: Colors.white,
                                size: 52,
                              ),
                              Positioned(
                                right: 18,
                                top: 18,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 18,
                        bottom: 18,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // =================================================================
              // DOMAIN HEADER
              // =================================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose a Domain',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DomainScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // =================================================================
              // DOMAIN GRID — 2 columns, like the reference image
              // =================================================================
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.98,
                ),
                itemCount: AppData.domains.length,
                itemBuilder: (context, index) {
                  final domain = AppData.domains[index];

                  return _DomainImageCard(
                    title: _domainTitle(domain.id),
                    description: _domainDescription(domain.id),
                    imagePath: _domainImage(domain.id),
                    fallbackIcon: _domainIcon(domain.id),
                    backgroundColor: _domainBackground(domain.id),
                    accentColor: _domainAccent(domain.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            if (domain.id == 'medical') {
                              return const DomainScreen();
                            }
                            return DomainScreen(initialDomain: domain);
                          },
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// AR BADGE
// =============================================================================

class _ARBadge extends StatelessWidget {
  const _ARBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: const Text(
        'in Augmented Reality',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// =============================================================================
// DOMAIN IMAGE CARD — matches reference: image block + title/desc + arrow row
// =============================================================================

class _DomainImageCard extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback onTap;

  const _DomainImageCard({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.fallbackIcon,
    required this.backgroundColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_DomainImageCard> createState() => _DomainImageCardState();
}

class _DomainImageCardState extends State<_DomainImageCard> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails details) =>
      setState(() => _pressed = true);

  void _handleTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
    widget.onTap();
  }

  void _handleTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===========================================================
                // IMAGE SECTION — soft colored background, image sits inside
                // ===========================================================
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.infinity,
                    color: widget.backgroundColor,
                    child: Stack(
                      children: [
                        // Decorative blob behind the image, like the reference
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.accentColor.withValues(alpha: 0.10),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Image.asset(
                              widget.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return _ImageFallback(
                                  icon: widget.fallbackIcon,
                                  accentColor: widget.accentColor,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===========================================================
                // TEXT + ARROW SECTION
                // ===========================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                height: 1.15,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: widget.accentColor,
                        ),
                      ),
                    ],
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
// IMAGE FALLBACK
// =============================================================================

class _ImageFallback extends StatelessWidget {
  final IconData icon;
  final Color accentColor;

  const _ImageFallback({required this.icon, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: accentColor, size: 32),
      ),
    );
  }
}
