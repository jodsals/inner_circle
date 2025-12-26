import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/survey_response.dart';
import '../providers/survey_providers.dart';
import 'survey_page.dart';

/// Survey introduction page with informed consent
class SurveyIntroPage extends ConsumerStatefulWidget {
  final SurveyType surveyType;

  const SurveyIntroPage({
    super.key,
    required this.surveyType,
  });

  @override
  ConsumerState<SurveyIntroPage> createState() => _SurveyIntroPageState();
}

class _SurveyIntroPageState extends ConsumerState<SurveyIntroPage> {
  bool _isLoading = true;
  bool _hasProgress = false;

  @override
  void initState() {
    super.initState();
    _checkForProgress();
  }

  Future<void> _checkForProgress() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final controller = ref.read(surveyControllerProvider.notifier);
    final progress = await controller.loadProgress(
      userId: user.id,
      type: widget.surveyType,
    );

    if (mounted) {
      setState(() {
        _hasProgress = progress != null && progress.isNotEmpty;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBaseline = widget.surveyType == SurveyType.baseline;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Lade Umfrage...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isBaseline ? 'Willkommensumfrage' : 'Follow-up Umfrage'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon and title
                Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),

                Text(
                  isBaseline
                      ? 'Willkommen bei InnerCircle!'
                      : 'Ihre Meinung ist uns wichtig',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  isBaseline
                      ? 'Bevor Sie beginnen, möchten wir Sie bitten, einen kurzen Fragebogen auszufüllen.'
                      : 'Nach 8 Wochen Nutzung möchten wir gerne von Ihren Erfahrungen hören.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Purpose Card
                _InfoCard(
                  icon: Icons.psychology_outlined,
                  title: 'Zweck der Umfrage',
                  content: isBaseline
                      ? 'Diese wissenschaftlich validierte Umfrage hilft uns, Ihr aktuelles Wohlbefinden zu verstehen und die App-Erfahrung auf Ihre Bedürfnisse anzupassen.'
                      : 'Wir möchten verstehen, wie die App Ihnen geholfen hat und welche Verbesserungen wir vornehmen können.',
                ),
                const SizedBox(height: 16),

                // Duration Card
                _InfoCard(
                  icon: Icons.timer_outlined,
                  title: 'Geschätzte Dauer',
                  content: isBaseline
                      ? '8-12 Minuten (27 Fragen in 6 Bereichen)'
                      : '12-15 Minuten (27 Fragen + 5 Feedback-Fragen)',
                ),
                const SizedBox(height: 16),

                // Privacy Card
                _InfoCard(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Datenschutz',
                  content:
                      'Ihre Antworten werden verschlüsselt und pseudonymisiert gespeichert. '
                      'Die Daten werden ausschließlich zur Verbesserung der App verwendet und '
                      'niemals an Dritte weitergegeben.',
                ),
                const SizedBox(height: 16),

                // Mandatory participation Card
                _InfoCard(
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'Verpflichtende Teilnahme',
                  content:
                      'Die Teilnahme an dieser Umfrage ist verpflichtend, um die App nutzen zu können. '
                      'Ihre Antworten helfen uns, die App optimal auf Ihre Bedürfnisse anzupassen.',
                ),
                const SizedBox(height: 16),

                // Survey domains info
                if (isBaseline) ...[
                  _InfoCard(
                    icon: Icons.category_outlined,
                    title: 'Bereiche der Umfrage',
                    content: 'Die Fragen beziehen sich auf:\n'
                        '• Emotionales Wohlbefinden\n'
                        '• Soziale Beziehungen\n'
                        '• Lebensqualität\n'
                        '• Unterstützungssysteme',
                  ),
                  const SizedBox(height: 16),
                ],

                // Scientific validity
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Wissenschaftlich validiert nach PROMIS-Standards',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Informed Consent Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Einverständniserklärung',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Durch Ihre Teilnahme bestätigen Sie:\n\n'
                        '• Sie haben die Informationen gelesen und verstanden\n'
                        '• Sie sind über die Verwendung Ihrer Daten informiert\n'
                        '• Die Teilnahme ist erforderlich für die Nutzung der App\n'
                        '• Sie können die Umfrage unterbrechen und später fortsetzen',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Progress info if exists
                if (_hasProgress) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.restore,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gespeicherter Fortschritt gefunden',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sie können dort fortfahren, wo Sie aufgehört haben.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action Button
                FilledButton(
                  onPressed: () => _handleAccept(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_hasProgress ? 'Fortsetzen' : 'Jetzt beginnen'),
                ),
                const SizedBox(height: 16),

                // Help text
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showHelpDialog(context),
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Fragen zur Umfrage?'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAccept(BuildContext context) {
    context.push('/survey/${widget.surveyType.key}');
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Häufig gestellte Fragen'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFAQItem(
                'Warum diese Umfrage?',
                'Die Umfrage basiert auf wissenschaftlichen PROMIS-Standards und hilft uns, '
                    'die Wirksamkeit der App zu messen und zu verbessern.',
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'Muss ich teilnehmen?',
                'Ja, die Teilnahme an dieser Umfrage ist verpflichtend, um die App nutzen zu können. '
                    'Sie können die Umfrage jedoch jederzeit unterbrechen und später fortsetzen.',
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'Was passiert mit meinen Daten?',
                'Ihre Antworten werden verschlüsselt gespeichert und nur in anonymisierter '
                    'Form für Statistiken verwendet. Wir geben keine Daten an Dritte weiter.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Reusable info card widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
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
}