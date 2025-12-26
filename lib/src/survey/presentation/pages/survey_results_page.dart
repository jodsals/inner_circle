import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/survey_response.dart';

/// Survey results page shown after completion
class SurveyResultsPage extends StatelessWidget {
  final SurveyResponse surveyResponse;

  const SurveyResultsPage({
    super.key,
    required this.surveyResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBaseline = surveyResponse.type == SurveyType.baseline;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Success icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Thank you message
                Text(
                  'Vielen Dank!',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  isBaseline
                      ? 'Sie haben die Willkommensumfrage erfolgreich abgeschlossen.'
                      : 'Sie haben die Follow-up Umfrage erfolgreich abgeschlossen.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Domain scores overview
                _buildDomainScoresCard(theme),
                const SizedBox(height: 24),

                // Next steps
                _buildNextStepsCard(theme, isBaseline),
                const SizedBox(height: 32),

                // Info boxes
                _buildInfoBox(
                  theme: theme,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Datenschutz',
                  content:
                      'Ihre Antworten wurden sicher gespeichert und werden nur zur Verbesserung der App verwendet.',
                ),
                const SizedBox(height: 16),

                if (isBaseline)
                  _buildInfoBox(
                    theme: theme,
                    icon: Icons.notifications_outlined,
                    title: 'Erinnerung',
                    content:
                        'Wir werden Sie in 8 Wochen daran erinnern, die Follow-up Umfrage auszufüllen.',
                  ),
                const SizedBox(height: 32),

                // Action button
                FilledButton.icon(
                  onPressed: () => _navigateToHome(context),
                  icon: const Icon(Icons.home),
                  label: Text(isBaseline ? 'Zur App' : 'Zurück zur App'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDomainScoresCard(ThemeData theme) {
    // Filter out app effectiveness domain for display
    final displayScores = Map<String, double>.from(surveyResponse.domainScores)
      ..removeWhere((key, value) => key == 'app_effectiveness');

    if (displayScores.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ihre Ergebnisse',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Diese Werte dienen als Ausgangsbasis für Ihre persönliche Entwicklung.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Domain scores
            ...displayScores.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDomainScoreItem(
                  theme,
                  _getDomainDisplayName(entry.key),
                  entry.value,
                ),
              );
            }),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Werte von 1-5: Niedriger ist besser bei negativen Aspekten',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
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

  Widget _buildDomainScoreItem(ThemeData theme, String domain, double score) {
    // Determine color based on score
    Color scoreColor;
    IconData scoreIcon;

    if (domain.contains('Unterstützung') || domain.contains('Teilhabe') || domain.contains('Lebensqualität')) {
      // For positive domains, higher is better
      if (score >= 4) {
        scoreColor = Colors.green;
        scoreIcon = Icons.trending_up;
      } else if (score >= 3) {
        scoreColor = Colors.orange;
        scoreIcon = Icons.trending_flat;
      } else {
        scoreColor = Colors.red;
        scoreIcon = Icons.trending_down;
      }
    } else {
      // For negative domains (depression, anxiety, isolation), lower is better
      if (score <= 2) {
        scoreColor = Colors.green;
        scoreIcon = Icons.check_circle_outline;
      } else if (score <= 3) {
        scoreColor = Colors.orange;
        scoreIcon = Icons.warning_amber_outlined;
      } else {
        scoreColor = Colors.red;
        scoreIcon = Icons.error_outline;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                domain,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Row(
              children: [
                Icon(scoreIcon, size: 16, color: scoreColor),
                const SizedBox(width: 6),
                Text(
                  score.toStringAsFixed(1),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 5,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepsCard(ThemeData theme, bool isBaseline) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Nächste Schritte',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isBaseline) ...[
              _buildNextStepItem(
                theme,
                '1',
                'Entdecken Sie die App',
                'Erkunden Sie Communities, teilen Sie Erfahrungen und knüpfen Sie Kontakte.',
              ),
              const SizedBox(height: 12),
              _buildNextStepItem(
                theme,
                '2',
                'Bleiben Sie aktiv',
                'Nutzen Sie die App regelmäßig für den größten Nutzen.',
              ),
              const SizedBox(height: 12),
              _buildNextStepItem(
                theme,
                '3',
                'Follow-up in 8 Wochen',
                'Wir werden Sie daran erinnern, die Follow-up Umfrage auszufüllen.',
              ),
            ] else ...[
              _buildNextStepItem(
                theme,
                '✓',
                'Umfrage abgeschlossen',
                'Vielen Dank für Ihr wertvolles Feedback!',
              ),
              const SizedBox(height: 12),
              _buildNextStepItem(
                theme,
                '📊',
                'Ihre Daten helfen uns',
                'Ihre Antworten tragen zur Verbesserung der App bei.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepItem(
      ThemeData theme, String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDomainDisplayName(String domain) {
    switch (domain) {
      case 'depression':
        return 'Depression';
      case 'anxiety':
        return 'Angst';
      case 'social_isolation':
        return 'Soziale Isolation';
      case 'emotional_support':
        return 'Emotionale Unterstützung';
      case 'social_participation':
        return 'Soziale Teilhabe';
      case 'global_health':
        return 'Lebensqualität';
      default:
        return domain;
    }
  }

  void _navigateToHome(BuildContext context) {
    // Navigate to app home and clear all previous routes
    context.go('/app');
  }
}
