import 'package:flutter/material.dart';

/// Dialog for creating or editing a forum
class ForumFormDialog extends StatefulWidget {
  final String? initialTitle;
  final Future<void> Function(String title) onSave;

  const ForumFormDialog({
    super.key,
    this.initialTitle,
    required this.onSave,
  });

  @override
  State<ForumFormDialog> createState() => _ForumFormDialogState();
}

class _ForumFormDialogState extends State<ForumFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.onSave(_titleController.text.trim());
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialTitle != null;

    return AlertDialog(
      title: Text(isEdit ? 'Forum bearbeiten' : 'Forum erstellen'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Titel',
            hintText: 'z.B. Allgemeine Diskussionen',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Bitte geben Sie einen Titel ein';
            }
            return null;
          },
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Aktualisieren' : 'Erstellen'),
        ),
      ],
    );
  }
}