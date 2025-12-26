import 'package:flutter/material.dart';

import '../../domain/entities/survey_question.dart';

/// Widget for open text questions
class OpenTextQuestionWidget extends StatefulWidget {
  final SurveyQuestion question;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const OpenTextQuestionWidget({
    super.key,
    required this.question,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<OpenTextQuestionWidget> createState() =>
      _OpenTextQuestionWidgetState();
}

class _OpenTextQuestionWidgetState extends State<OpenTextQuestionWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          'Bitte teilen Sie Ihre Gedanken und Erfahrungen',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 24),

        // Text field
        TextField(
          controller: _controller,
          maxLines: 6,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Ihre Antwort...',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            counterStyle: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          style: theme.textTheme.bodyLarge,
        ),

        // Helper text
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.question.isRequired
                      ? 'Dieses Feld ist optional - Sie können es auch leer lassen'
                      : 'Optional',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}