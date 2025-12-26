import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/survey_question.dart';
import '../../domain/entities/survey_response.dart';
import '../providers/survey_providers.dart';
import '../widgets/multiple_choice_question_widget.dart';
import '../widgets/open_text_question_widget.dart';
import '../widgets/scale_question_widget.dart';
import '../widgets/crisis_intervention_dialog.dart';
import 'survey_results_page.dart';

/// Main survey page with progress tracking
class SurveyPage extends ConsumerStatefulWidget {
  final SurveyType surveyType;

  const SurveyPage({
    super.key,
    required this.surveyType,
  });

  @override
  ConsumerState<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends ConsumerState<SurveyPage> {
  int _currentQuestionIndex = 0;
  final Map<String, QuestionResponse> _responses = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final controller = ref.read(surveyControllerProvider.notifier);
    final progress = await controller.loadProgress(
      userId: user.id,
      type: widget.surveyType,
    );

    if (progress != null && mounted) {
      setState(() {
        for (final response in progress) {
          _responses[response.questionId] = response;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(surveyQuestionsProvider(widget.surveyType));

    return questionsAsync.when(
      data: (questions) => _buildSurveyContent(questions),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler beim Laden der Fragen: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Zurück'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyContent(List<SurveyQuestion> questions) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Keine Fragen verfügbar')),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / questions.length;
    final isLastQuestion = _currentQuestionIndex == questions.length - 1;
    final isFirstQuestion = _currentQuestionIndex == 0;

    // Check if domain changed
    final showDomainHeader = _currentQuestionIndex == 0 ||
        questions[_currentQuestionIndex - 1].domain != currentQuestion.domain;

    return WillPopScope(
      onWillPop: () => _handleBackButton(questions),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.surveyType == SurveyType.baseline
                ? 'Baseline Umfrage'
                : 'Follow-up Umfrage',
          ),
          actions: [
            // Save progress button
            TextButton.icon(
              onPressed: () => _saveProgress(questions),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Speichern'),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            _buildProgressBar(progress, _currentQuestionIndex + 1, questions.length),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Domain header
                      if (showDomainHeader) ...[
                        _buildDomainHeader(currentQuestion.domain),
                        const SizedBox(height: 32),
                      ],

                      // Question widget
                      _buildQuestionWidget(currentQuestion),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(
              isFirstQuestion: isFirstQuestion,
              isLastQuestion: isLastQuestion,
              currentQuestion: currentQuestion,
              questions: questions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, int current, int total) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frage $current von $total',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainHeader(String domain) {
    final theme = Theme.of(context);

    // Get display name from domain
    String displayName = domain;
    IconData icon = Icons.category;

    if (domain == 'depression') {
      displayName = 'Depression';
      icon = Icons.sentiment_dissatisfied;
    } else if (domain == 'anxiety') {
      displayName = 'Angst';
      icon = Icons.psychology_outlined;
    } else if (domain == 'social_isolation') {
      displayName = 'Soziale Isolation';
      icon = Icons.person_off_outlined;
    } else if (domain == 'emotional_support') {
      displayName = 'Emotionale Unterstützung';
      icon = Icons.favorite_outline;
    } else if (domain == 'social_participation') {
      displayName = 'Soziale Teilhabe';
      icon = Icons.groups_outlined;
    } else if (domain == 'global_health') {
      displayName = 'Lebensqualität';
      icon = Icons.health_and_safety_outlined;
    } else if (domain == 'app_effectiveness') {
      displayName = 'App-Wirksamkeit';
      icon = Icons.star_outline;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Neuer Bereich',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(SurveyQuestion question) {
    final currentResponse = _responses[question.id];

    switch (question.type) {
      case QuestionType.frequency:
      case QuestionType.intensity:
      case QuestionType.agreement:
      case QuestionType.rating:
        return ScaleQuestionWidget(
          question: question,
          selectedValue: currentResponse?.score,
          onChanged: (value) => _handleScaleAnswer(question, value),
        );

      case QuestionType.multipleChoice:
        return MultipleChoiceQuestionWidget(
          question: question,
          selectedValues: currentResponse?.multipleChoiceValues,
          onChanged: (values) => _handleMultipleChoiceAnswer(question, values),
        );

      case QuestionType.openText:
        return OpenTextQuestionWidget(
          question: question,
          initialValue: currentResponse?.textValue,
          onChanged: (value) => _handleOpenTextAnswer(question, value),
        );
    }
  }

  void _handleScaleAnswer(SurveyQuestion question, int value) {
    setState(() {
      _responses[question.id] = QuestionResponse(
        questionId: question.id,
        domain: question.domain,
        score: value,
        answeredAt: DateTime.now(),
      );
    });
  }

  void _handleMultipleChoiceAnswer(SurveyQuestion question, List<String> values) {
    setState(() {
      _responses[question.id] = QuestionResponse(
        questionId: question.id,
        domain: question.domain,
        multipleChoiceValues: values,
        answeredAt: DateTime.now(),
      );
    });
  }

  void _handleOpenTextAnswer(SurveyQuestion question, String value) {
    setState(() {
      _responses[question.id] = QuestionResponse(
        questionId: question.id,
        domain: question.domain,
        textValue: value,
        answeredAt: DateTime.now(),
      );
    });
  }

  Widget _buildNavigationButtons({
    required bool isFirstQuestion,
    required bool isLastQuestion,
    required SurveyQuestion currentQuestion,
    required List<SurveyQuestion> questions,
  }) {
    final theme = Theme.of(context);
    final currentResponse = _responses[currentQuestion.id];
    final canProceed = !currentQuestion.isRequired ||
        currentResponse != null &&
            (currentResponse.score != null ||
                currentResponse.multipleChoiceValues?.isNotEmpty == true ||
                currentResponse.textValue?.isNotEmpty == true);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            if (!isFirstQuestion)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _goToPreviousQuestion,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Zurück'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            if (!isFirstQuestion) const SizedBox(width: 16),

            // Next/Finish button
            Expanded(
              flex: isFirstQuestion ? 1 : 1,
              child: FilledButton.icon(
                onPressed: canProceed && !_isSubmitting
                    ? () {
                        if (isLastQuestion) {
                          _submitSurvey(questions);
                        } else {
                          _goToNextQuestion();
                        }
                      }
                    : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
                label: Text(
                    _isSubmitting ? 'Wird gesendet...' : (isLastQuestion ? 'Abschließen' : 'Weiter')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _goToNextQuestion() {
    setState(() {
      _currentQuestionIndex++;
    });

    // Check for crisis after moving to next question
    _checkForCrisis();
  }

  void _checkForCrisis() {
    // Check if crisis intervention should be triggered
    if (CrisisIntervention.detectsCrisis(_responses.values.toList())) {
      // Show crisis dialog after a short delay to allow UI to update
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          CrisisIntervention.showCrisisDialog(context);
        }
      });
    }
  }

  Future<void> _saveProgress(List<SurveyQuestion> questions) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final controller = ref.read(surveyControllerProvider.notifier);
    final success = await controller.saveProgress(
      userId: user.id,
      type: widget.surveyType,
      responses: _responses.values.toList(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Fortschritt gespeichert'
                : 'Fehler beim Speichern',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _submitSurvey(List<SurveyQuestion> questions) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    // Calculate domain scores
    final calculateDomainScores = ref.read(calculateDomainScoresProvider);
    final domainScores = calculateDomainScores(_responses.values.toList());

    // Create survey response
    final surveyResponse = SurveyResponse(
      id: '', // Will be set by Firestore
      userId: user.id,
      surveyId: 'survey_${widget.surveyType.key}_v1',
      type: widget.surveyType,
      startedAt: DateTime.now().subtract(
        Duration(minutes: _currentQuestionIndex + 1),
      ), // Approximate
      completedAt: DateTime.now(),
      domainScores: domainScores,
      responses: _responses.values.toList(),
      isComplete: true,
    );

    // Submit survey
    final controller = ref.read(surveyControllerProvider.notifier);
    final result = await controller.submitSurvey(surveyResponse);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted && result != null) {
      // Delete saved progress
      await controller.deleteProgress(
        userId: user.id,
        type: widget.surveyType,
      );

      // Update user profile if baseline survey
      if (widget.surveyType == SurveyType.baseline) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .update({
            'hasCompletedInitialSurvey': true,
            'lastSurveyDate': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          // Log error but don't block navigation
          debugPrint('Error updating user profile: $e');
        }
      }

      // Navigate to results page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SurveyResultsPage(
            surveyResponse: result,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler beim Senden der Umfrage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _handleBackButton(List<SurveyQuestion> questions) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Umfrage verlassen?'),
        content: const Text(
          'Ihr Fortschritt wird automatisch gespeichert. '
          'Sie können jederzeit zurückkehren und fortfahren.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () async {
              await _saveProgress(questions);
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Speichern & Verlassen'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }
}