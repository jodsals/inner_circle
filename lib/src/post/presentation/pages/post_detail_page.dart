import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../comment/domain/entities/comment.dart';
import '../../../comment/presentation/providers/comment_providers.dart';
import '../../../community/domain/entities/community.dart';
import '../../../forum/domain/entities/forum.dart';
import '../../../post/presentation/providers/post_providers.dart';
import '../../domain/entities/post.dart';

/// Page showing post detail with comments
class PostDetailPage extends ConsumerStatefulWidget {
  final Community community;
  final Forum forum;
  final Post post;

  const PostDetailPage({
    super.key,
    required this.community,
    required this.forum,
    required this.post,
  });

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final authState = ref.read(authControllerProvider);
    final user = authState.user;

    if (user == null) return;

    setState(() => _isSubmitting = true);

    final controller = ref.read(commentControllerProvider.notifier);
    final postDataSource = ref.read(postRemoteDataSourceProvider);

    final comment = await controller.createNewComment(
      communityId: widget.community.id,
      forumId: widget.forum.id,
      postId: widget.post.id,
      authorId: user.id,
      authorName: user.displayName ?? user.email,
      authorPhotoUrl: user.photoUrl,
      content: content,
      postDataSource: postDataSource,
    );

    setState(() => _isSubmitting = false);

    if (comment != null) {
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kommentar hinzugefügt')),
        );
      }
    } else {
      if (mounted) {
        final error = ref.read(commentControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final commentsAsyncValue = ref.watch(
      watchCommentsProvider(
        CommentParams(
          widget.community.id,
          widget.forum.id,
          widget.post.id,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forum.title),
      ),
      body: Column(
        children: [
          // Post content
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Post header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: widget.post.authorPhotoUrl != null
                          ? NetworkImage(widget.post.authorPhotoUrl!)
                          : null,
                      child: widget.post.authorPhotoUrl == null
                          ? Text(widget.post.authorName[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.authorName,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatDate(widget.post.createdAt),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Post title
                Text(
                  widget.post.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Post content
                Text(
                  widget.post.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                const Divider(),
                const SizedBox(height: 16),

                // Comments section header
                Text(
                  'Kommentare (${widget.post.commentsCount})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Comments list
                commentsAsyncValue.when(
                  data: (comments) {
                    print('Comments loaded: ${comments.length} comments'); // Debug

                    if (comments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              const Text('Noch keine Kommentare'),
                              const SizedBox(height: 8),
                              Text(
                                'Post ID: ${widget.post.id}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final comment = comments[index] as Comment;
                        return CommentCard(comment: comment);
                      },
                    );
                  },
                  loading: () {
                    print('Loading comments for post: ${widget.post.id}'); // Debug
                    return const Center(child: CircularProgressIndicator());
                  },
                  error: (error, stack) {
                    print('Error loading comments: $error'); // Debug
                    print('Stack: $stack'); // Debug
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 32, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('Fehler beim Laden der Kommentare: $error'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(watchCommentsProvider),
                            child: const Text('Erneut versuchen'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Comment input (only for authenticated users)
          authState.user != null
              ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Kommentar schreiben...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Gerade eben';
        }
        return 'vor ${difference.inMinutes}m';
      }
      return 'vor ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Gestern';
    } else if (difference.inDays < 7) {
      return 'vor ${difference.inDays}d';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}

/// Card widget for displaying a comment
class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: comment.authorPhotoUrl != null
              ? NetworkImage(comment.authorPhotoUrl!)
              : null,
          child: comment.authorPhotoUrl == null
              ? Text(
                  comment.authorName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 14),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.authorName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(comment.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Gerade eben';
        }
        return 'vor ${difference.inMinutes}m';
      }
      return 'vor ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Gestern';
    } else if (difference.inDays < 7) {
      return 'vor ${difference.inDays}d';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
