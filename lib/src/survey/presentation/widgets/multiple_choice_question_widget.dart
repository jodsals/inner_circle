import 'package:flutter/material.dart';

import '../../domain/entities/survey_question.dart';

/// Widget for multiple choice questions
class MultipleChoiceQuestionWidget extends StatefulWidget {
  final SurveyQuestion question;
  final List<String>? selectedValues;
  final ValueChanged<List<String>> onChanged;

  const MultipleChoiceQuestionWidget({
    super.key,
    required this.question,
    this.selectedValues,
    required this.onChanged,
  });

  @override
  State<MultipleChoiceQuestionWidget> createState() =>
      _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState
    extends State<MultipleChoiceQuestionWidget> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedValues ?? [];
  }

  void _toggleOption(String value) {
    setState(() {
      if (_selected.contains(value)) {
        _selected.remove(value);
      } else {
        _selected.add(value);
      }
    });
    widget.onChanged(_selected);
  }

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

        // Instruction
        Text(
          'Wählen Sie alle zutreffenden Optionen',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 24),

        // Options
        ...widget.question.options.map((option) {
          final optionValue = option.label; // Use label as value for string-based selection
          final isSelected = _selected.contains(optionValue);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _toggleOption(optionValue),
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
                    // Checkbox
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
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
                              Icons.check,
                              size: 16,
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
                  ],
                ),
              ),
            ),
          );
        }),

        // Selection counter
        if (_selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_selected.length} ${_selected.length == 1 ? "Option" : "Optionen"} ausgewählt',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

        // Required indicator
        if (widget.question.isRequired && _selected.isEmpty)
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
                  'Bitte wählen Sie mindestens eine Option',
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