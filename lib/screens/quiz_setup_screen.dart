import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../data/app_data.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  String? _selectedDomainId;
  String? _selectedCategory;
  int _questionCount = 5;

  static const _countOptions = [5, 10];

  List<String> get _availableCategories {
    if (_selectedDomainId == null) return [];
    return AppData.quizCategoriesForDomain(_selectedDomainId!);
  }

  int get _availableCount {
    if (_selectedDomainId == null || _selectedCategory == null) return 0;
    return AppData.quizQuestionCountFor(
      domainId: _selectedDomainId!,
      category: _selectedCategory!,
    );
  }

  bool get _canStart =>
      _selectedDomainId != null &&
      _selectedCategory != null &&
      _availableCount > 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
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
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Start a Quiz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------------------------------------------
                      // STEP 1: Domain — reuses your DomainItem visuals
                      // ---------------------------------------------------
                      const _StepLabel(number: '1', label: 'Choose a domain'),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.95,
                            ),
                        itemCount: AppData.domains.length,
                        itemBuilder: (context, index) {
                          final domain = AppData.domains[index];
                          final isSelected = _selectedDomainId == domain.id;

                          // Only allow domains that actually have questions
                          final hasQuestions = AppData.quizCategoriesForDomain(
                            domain.id,
                          ).isNotEmpty;

                          return GestureDetector(
                            onTap: hasQuestions
                                ? () {
                                    setState(() {
                                      _selectedDomainId = domain.id;
                                      _selectedCategory = null;
                                    });
                                  }
                                : null,
                            child: Opacity(
                              opacity: hasQuestions ? 1.0 : 0.4,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? domain.iconColor.withValues(alpha: 0.12)
                                      : domain.bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? domain.iconColor
                                        : Colors.transparent,
                                    width: 1.6,
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      domain.icon,
                                      color: domain.iconColor,
                                      size: 26,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      domain.title.replaceAll('\n', ' '),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                        height: 1.15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // ---------------------------------------------------
                      // STEP 2: Category (only shown once domain picked)
                      // ---------------------------------------------------
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _selectedDomainId == null
                            ? const SizedBox.shrink()
                            : Column(
                                key: ValueKey(_selectedDomainId),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _StepLabel(
                                    number: '2',
                                    label: 'Choose a topic',
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      _CategoryChip(
                                        label: 'All',
                                        isSelected: _selectedCategory == 'All',
                                        onTap: () => setState(
                                          () => _selectedCategory = 'All',
                                        ),
                                      ),
                                      ..._availableCategories.map((cat) {
                                        final isSelected =
                                            _selectedCategory == cat;
                                        return _CategoryChip(
                                          label: cat,
                                          isSelected: isSelected,
                                          onTap: () => setState(
                                            () => _selectedCategory = cat,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                ],
                              ),
                      ),

                      // ---------------------------------------------------
                      // STEP 3: Number of questions
                      // ---------------------------------------------------
                      if (_selectedCategory != null) ...[
                        const _StepLabel(
                          number: '3',
                          label: 'Number of questions',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: _countOptions.map((count) {
                            final isSelected = _questionCount == count;
                            final disabled = count > _availableCount;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: disabled
                                    ? null
                                    : () => setState(
                                        () => _questionCount = count,
                                      ),
                                child: Opacity(
                                  opacity: disabled ? 0.4 : 1.0,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 64,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primaryBlue
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primaryBlue
                                            : const Color(0xFFE2E8F0),
                                        width: 1.4,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_availableCount question${_availableCount == 1 ? '' : 's'} available for this selection',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ---------------------------------------------------------
              // Start button
              // ---------------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canStart
                      ? () {
                          final count = _questionCount > _availableCount
                              ? _availableCount
                              : _questionCount;
                          appState.startQuiz(
                            domainId: _selectedDomainId!,
                            category: _selectedCategory!,
                            questionCount: count,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuizScreen(),
                            ),
                          );
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
                  child: const Text(
                    'Start Quiz',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
}

class _StepLabel extends StatelessWidget {
  final String number;
  final String label;

  const _StepLabel({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primarySoft : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
