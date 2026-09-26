import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final questions = appState.questions;
    final question = questions[appState.currentQuizIndex];
    final letters = ['A', 'B', 'C', 'D'];

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
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          appState.setNavIndex(0);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Quick Quiz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${appState.currentQuizIndex + 1}/${questions.length}',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (appState.currentQuizIndex + 1) / questions.length,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue,
                  ),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 36),

              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.35,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 28),

              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final isSelected =
                        appState.selectedQuizAnswerIndex == index;
                    final isCorrect = question.correctIndex == index;
                    final isSubmitted = appState.isAnswerSubmitted;

                    Color cardBorderColor = const Color(0xFFE2E8F0);
                    Color cardBgColor = Colors.white;
                    Color badgeBg = const Color(0xFFF1F5F9);
                    Color badgeTextColor = AppTheme.textPrimary;

                    if (isSubmitted) {
                      if (isCorrect) {
                        cardBorderColor = const Color(0xFF10B981);
                        cardBgColor = const Color(0xFFECFDF5);
                        badgeBg = const Color(0xFF10B981);
                        badgeTextColor = Colors.white;
                      } else if (isSelected) {
                        cardBorderColor = const Color(0xFFEF4444);
                        cardBgColor = const Color(0xFFFEF2F2);
                        badgeBg = const Color(0xFFEF4444);
                        badgeTextColor = Colors.white;
                      }
                    } else if (isSelected) {
                      cardBorderColor = AppTheme.primaryBlue;
                      cardBgColor = AppTheme.primarySoft;
                      badgeBg = AppTheme.primaryBlue;
                      badgeTextColor = Colors.white;
                    }

                    return GestureDetector(
                      onTap: () {
                        appState.selectQuizAnswer(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cardBorderColor,
                            width: 1.6,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: cardBorderColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: badgeBg,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  letters[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: badgeTextColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSubmitted && isCorrect
                                      ? const Color(0xFF065F46)
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            if (isSubmitted && isCorrect)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF10B981),
                                size: 22,
                              )
                            else if (isSubmitted && isSelected && !isCorrect)
                              const Icon(
                                Icons.cancel_rounded,
                                color: Color(0xFFEF4444),
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (appState.isAnswerSubmitted) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          question.explanation,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: appState.isAnswerSubmitted
                      ? () {
                          if (appState.currentQuizIndex ==
                              questions.length - 1) {
                            _showResultDialog(context, appState);
                          } else {
                            appState.nextQuizQuestion();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    appState.currentQuizIndex == questions.length - 1
                        ? 'Finish Quiz'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, AppState appState) {
    final total = appState.questions.length;
    appState.nextQuizQuestion(); // Marks complete

    final score = appState.quizScore;
    final percentage = total == 0 ? 0.0 : score / total;

    final bool isGreat = percentage >= 0.8;
    final bool isGood = percentage >= 0.5 && percentage < 0.8;

    final String headline = isGreat
        ? 'Good, Keep it up! 🎉'
        : isGood
        ? 'Nice Effort!'
        : 'Keep Practicing!';

    final String subline = isGreat
        ? 'You\'re mastering this topic — outstanding work!'
        : isGood
        ? 'You\'re getting there. A bit more practice will help.'
        : 'Review the explanations and try again — you\'ve got this.';

    final Color accentColor = isGreat
        ? const Color(0xFF10B981)
        : isGood
        ? AppTheme.primaryBlue
        : const Color(0xFFF59E0B);

    final IconData icon = isGreat
        ? Icons.emoji_events_rounded
        : isGood
        ? Icons.thumb_up_rounded
        : Icons.refresh_rounded;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ResultDialog(
        score: score,
        total: total,
        headline: headline,
        subline: subline,
        accentColor: accentColor,
        icon: icon,
        showConfetti: isGreat,
        onViewProgress: () {
          Navigator.of(ctx).pop();
          appState.restartQuiz();
          appState.setNavIndex(4);
        },
        onRetry: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop(); // back to setup screen
        },
      ),
    );
  }
}

// =============================================================================
// RESULT DIALOG — with confetti burst when score is high
// =============================================================================

class _ResultDialog extends StatefulWidget {
  final int score;
  final int total;
  final String headline;
  final String subline;
  final Color accentColor;
  final IconData icon;
  final bool showConfetti;
  final VoidCallback onViewProgress;
  final VoidCallback onRetry;

  const _ResultDialog({
    required this.score,
    required this.total,
    required this.headline,
    required this.subline,
    required this.accentColor,
    required this.icon,
    required this.showConfetti,
    required this.onViewProgress,
    required this.onRetry,
  });

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog>
    with TickerProviderStateMixin {
  late final AnimationController _popController;
  late final Animation<double> _popScale;

  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _popScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (widget.showConfetti) {
      _confettiController.forward();
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main card
          ScaleTransition(
            scale: _popScale,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.accentColor,
                      size: 46,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${widget.score} / ${widget.total}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: widget.accentColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onViewProgress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'View Progress',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: widget.onRetry,
                      child: const Text(
                        'Try Another Quiz',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti burst overlay — only for high scores
          if (widget.showConfetti)
            Positioned(
              top: -40,
              left: -20,
              right: -20,
              height: 320,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ConfettiPainter(
                        progress: _confettiController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// CONFETTI PAINTER — lightweight, no external package required
// =============================================================================

class _ConfettiPiece {
  final double startX;
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;

  _ConfettiPiece({
    required this.startX,
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  static final List<_ConfettiPiece> _pieces = _generatePieces();

  _ConfettiPainter({required this.progress});

  static List<_ConfettiPiece> _generatePieces() {
    final rnd = math.Random(7);
    const colors = [
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFF3B82F6),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
    ];

    return List.generate(40, (i) {
      return _ConfettiPiece(
        startX: rnd.nextDouble(),
        angle: (rnd.nextDouble() - 0.5) * 1.4,
        speed: 0.6 + rnd.nextDouble() * 0.6,
        size: 4 + rnd.nextDouble() * 5,
        color: colors[i % colors.length],
        rotationSpeed: (rnd.nextDouble() - 0.5) * 10,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in _pieces) {
      // Fall + slight horizontal drift, fade out near the end
      final fallProgress = progress;
      final dy = fallProgress * size.height * 1.1;
      final dx =
          piece.startX * size.width +
          math.sin(piece.angle * math.pi * fallProgress * 2) * 20;

      final opacity = (1.0 - fallProgress).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final paint = Paint()..color = piece.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(fallProgress * piece.rotationSpeed);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: piece.size,
          height: piece.size * 1.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
