import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/survey_response.dart';

/// Crisis intervention utilities
class CrisisIntervention {
  /// Check if survey responses indicate a crisis situation
  static bool detectsCrisis(List<QuestionResponse> responses) {
    // Check depression scores
    final depScores = responses
        .where((r) => r.domain == 'depression')
        .map((r) => r.score ?? 0)
        .where((score) => score > 0)
        .toList();

    if (depScores.isNotEmpty) {
      final avgDepScore = depScores.reduce((a, b) => a + b) / depScores.length;
      // If average depression score >= 4 (of 5), trigger intervention
      if (avgDepScore >= 4.0) return true;
    }

    // Check anxiety scores
    final anxietyScores = responses
        .where((r) => r.domain == 'anxiety')
        .map((r) => r.score ?? 0)
        .where((score) => score > 0)
        .toList();

    if (anxietyScores.isNotEmpty) {
      final avgAnxietyScore =
          anxietyScores.reduce((a, b) => a + b) / anxietyScores.length;
      // If average anxiety score >= 4.5 (of 5), trigger intervention
      if (avgAnxietyScore >= 4.5) return true;
    }

    // Check for any individual response that is critically high
    final criticalResponses = responses.where((r) =>
        (r.domain == 'depression' || r.domain == 'anxiety') &&
        r.score != null &&
        r.score! == 5);

    // If 3 or more critical responses (score of 5), trigger intervention
    if (criticalResponses.length >= 3) return true;

    return false;
  }

  /// Show crisis intervention dialog with resources
  static void showCrisisDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CrisisInterventionDialog(),
    );
  }
}

/// Dialog showing crisis resources and help options
class CrisisInterventionDialog extends StatelessWidget {
  const CrisisInterventionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.favorite,
        color: theme.colorScheme.error,
        size: 48,
      ),
      title: const Text(
        'Wir sind für Sie da',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ihre Antworten zeigen, dass Sie möglicherweise Unterstützung benötigen. '
              'Bitte zögern Sie nicht, professionelle Hilfe in Anspruch zu nehmen.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Emergency hotlines
            _buildResourceSection(
              theme: theme,
              icon: Icons.phone,
              title: 'Sofortige Hilfe',
              children: [
                _buildHotlineCard(
                  theme: theme,
                  name: 'Telefonseelsorge',
                  number: '0800 111 0 111',
                  description: '24/7 kostenlos & anonym',
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
                _buildHotlineCard(
                  theme: theme,
                  name: 'Telefonseelsorge Alt.',
                  number: '0800 111 0 222',
                  description: '24/7 kostenlos & anonym',
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Online resources
            _buildResourceSection(
              theme: theme,
              icon: Icons.chat,
              title: 'Online-Beratung',
              children: [
                _buildOnlineResourceCard(
                  theme: theme,
                  name: 'Krisenchat',
                  description: 'Chat-Beratung für Jugendliche & junge Erwachsene',
                  url: 'https://krisenchat.de',
                ),
                const SizedBox(height: 8),
                _buildOnlineResourceCard(
                  theme: theme,
                  name: 'NummerGegenKummer',
                  description: 'Beratung für Kinder, Jugendliche & Eltern',
                  url: 'https://www.nummergegenkummer.de',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Emergency notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'In akuten Notfällen rufen Sie bitte den Notruf 112 '
                      'oder wenden Sie sich an die nächste Notaufnahme.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Schließen'),
        ),
      ],
    );
  }

  Widget _buildResourceSection({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildHotlineCard({
    required ThemeData theme,
    required String name,
    required String number,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.phone,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  number,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildOnlineResourceCard({
    required ThemeData theme,
    required String name,
    required String description,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.language,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
