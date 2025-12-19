import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../community/domain/entities/community.dart';
import '../../../forum/domain/entities/forum.dart';
import '../../../moderation/presentation/providers/moderation_providers.dart';
import '../providers/post_providers.dart';

/// Page for creating or editing a post
class CreatePostPage extends ConsumerStatefulWidget {
  final Community community;
  final Forum forum;

  const CreatePostPage({
    super.key,
    required this.community,
    required this.forum,
  });

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authControllerProvider);
    final user = authState.user;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Du musst angemeldet sein, um zu posten')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    // Step 1: Moderate content
    final analyzeContent = ref.read(analyzeContentProvider);
    final combinedContent = '${_titleController.text.trim()}\n${_contentController.text.trim()}';

    final moderationResult = await analyzeContent(content: combinedContent);

    // Step 2: Check if content is flagged
    if (moderationResult.isFlagged) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        _showModerationDialog(moderationResult, user.id);
      }
      return;
    }

    // Step 3: Content is safe, create post
    final controller = ref.read(postControllerProvider.notifier);

    final post = await controller.createNewPost(
      communityId: widget.community.id,
      forumId: widget.forum.id,
      authorId: user.id,
      authorName: user.displayName ?? user.email,
      authorPhotoUrl: user.photoUrl,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (post != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post erstellt')),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(postControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $error')),
      );
    }
  }

  void _showModerationDialog(dynamic moderationResult, String userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Inhalt blockiert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dein Post wurde von unserem Moderationssystem blockiert.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Grund: ${moderationResult.analysis}'),
            if (moderationResult.reasons.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Kategorien: ${moderationResult.reasons.join(", ")}'),
            ],
            const SizedBox(height: 12),
            const Text(
              'Du kannst eine manuelle Überprüfung beantragen, wenn du glaubst, dass dies ein Fehler ist.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              await _requestReview(userId, moderationResult);
            },
            child: const Text('Review beantragen'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestReview(String userId, dynamic moderationResult) async {
    try {
      final authState = ref.read(authControllerProvider);
      final user = authState.user;

      final createReview = ref.read(createReviewRequestProvider);
      await createReview(
        userId: userId,
        content: _contentController.text.trim(),
        title: _titleController.text.trim(),
        authorName: user?.displayName ?? user?.email ?? 'Unbekannt',
        authorPhotoUrl: user?.photoUrl,
        contentType: 'post',
        communityId: widget.community.id,
        forumId: widget.forum.id,
        flagReasons: moderationResult.reasons,
        confidenceScore: moderationResult.confidenceScore,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review-Anfrage wurde gesendet. Ein Admin wird deinen Post überprüfen.'),
            duration: Duration(seconds: 4),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Senden der Review-Anfrage: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuer Post'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitPost,
              child: const Text('POSTEN'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Community and Forum info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Poste in:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.community.title} › ${widget.forum.title}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titel',
                hintText: 'Gib deinem Post einen aussagekräftigen Titel',
                border: OutlineInputBorder(),
              ),
              maxLength: 200,
              enabled: !_isSubmitting,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte gib einen Titel ein';
                }
                if (value.trim().length < 5) {
                  return 'Titel muss mindestens 5 Zeichen lang sein';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Content field
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Inhalt',
                hintText: 'Schreibe deinen Post...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              maxLength: 10000,
              enabled: !_isSubmitting,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte gib einen Inhalt ein';
                }
                if (value.trim().length < 10) {
                  return 'Inhalt muss mindestens 10 Zeichen lang sein';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Guidelines
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Posting-Richtlinien',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Sei respektvoll und höflich\n'
                      '• Bleibe beim Thema\n'
                      '• Teile keine persönlichen Informationen\n'
                      '• Keine Spam oder Werbung',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
