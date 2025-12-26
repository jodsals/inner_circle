import 'package:flutter/material.dart';

import '../../domain/entities/survey_question.dart';

/// Widget for scale-based questions (frequency, intensity, agreement, rating)
class ScaleQuestionWidget extends StatefulWidget {
  final SurveyQuestion question;
  final int? selectedValue;
  final ValueChanged<int> onChanged;

  const ScaleQuestionWidget({
    super.key,
    required this.question,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  State<ScaleQuestionWidget> createState() => _ScaleQuestionWidgetState();
}

class _ScaleQuestionWidgetState extends State<ScaleQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question text
        Text(
          widget.question.questionText,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),

        // Timeframe
        if (widget.question.timeframe.isNotEmpty)
          Text(
            widget.question.timeframe,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        const SizedBox(height: 24),

        // Options
        ...widget.question.options.map((option) {
          final isSelected = widget.selectedValue == option.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => widget.onChanged(option.value),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Radio button
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          width: 2,
                        ),
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.circle,
                              size: 12,
                              color: theme.colorScheme.onPrimary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // Option label
                    Expanded(
                      child: Text(
                        option.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),

                    // Score indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.2)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${option.value}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Required indicator
        if (widget.question.isRequired && widget.selectedValue == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  'Bitte wählen Sie eine Antwort',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}