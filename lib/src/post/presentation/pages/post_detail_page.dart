import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../comment/domain/entities/comment.dart';
import '../../../comment/presentation/providers/comment_providers.dart';
import '../../../community/domain/entities/community.dart';
import '../../../forum/domain/entities/forum.dart';
import '../../../moderation/presentation/providers/moderation_providers.dart';
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
    final currentUser = authState.user;
    final isPostAuthor = currentUser?.id == widget.post.authorId;

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
                    // Post menu button (only show delete if user is author)
                    if (isPostAuthor)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                        onSelected: (value) async {
                          if (value == 'delete') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Post löschen'),
                                content: const Text(
                                  'Möchten Sie diesen Post wirklich löschen? Alle Kommentare werden ebenfalls gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Abbrechen'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Löschen'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true && context.mounted) {
                              try {
                                final success = await ref
                                    .read(postControllerProvider.notifier)
                                    .deleteExistingPost(
                                      widget.community.id,
                                      widget.forum.id,
                                      widget.post.id,
                                    );

                                if (context.mounted) {
                                  if (success) {
                                    // Navigate back to forum page
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Post gelöscht'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Fehler beim Löschen'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Fehler: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Löschen', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
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
                    final parentCount = comments.where((c) => c.parentId == null).length;
                    final replyCount = comments.where((c) => c.parentId != null).length;
                    print('Parent comments: $parentCount, Replies: $replyCount'); // Debug

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

                    // Separate parent comments from replies
                    final parentComments = comments
                        .where((c) => c.parentId == null)
                        .toList();

                    // Group ALL replies by parent ID (for recursion lookup)
                    final repliesMap = <String, List<Comment>>{};
                    for (final comment in comments) {
                      if (comment.parentId != null) {
                        repliesMap.putIfAbsent(comment.parentId!, () => []);
                        repliesMap[comment.parentId!]!.add(comment);
                      }
                    }

                    // Helper function to get all replies in a thread (flattened)
                    List<Comment> getAllRepliesInThread(String parentId) {
                      final result = <Comment>[];
                      final directReplies = repliesMap[parentId] ?? [];

                      for (final reply in directReplies) {
                        result.add(reply);
                        // Recursively get replies to this reply
                        result.addAll(getAllRepliesInThread(reply.id));
                      }

                      return result;
                    }

                    print('Replies map: ${repliesMap.map((k, v) => MapEntry(k, v.length))}'); // Debug

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: parentComments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final comment = parentComments[index];
                        final allReplies = getAllRepliesInThread(comment.id);

                        return CommentWithReplies(
                          comment: comment,
                          replies: allReplies,
                          community: widget.community,
                          forum: widget.forum,
                          post: widget.post,
                        );
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

/// Widget for displaying a comment with its replies (flattened, max 2 levels)
class CommentWithReplies extends StatefulWidget {
  final Comment comment;
  final List<Comment> replies;
  final Community community;
  final Forum forum;
  final Post post;

  const CommentWithReplies({
    super.key,
    required this.comment,
    required this.replies,
    required this.community,
    required this.forum,
    required this.post,
  });

  @override
  State<CommentWithReplies> createState() => _CommentWithRepliesState();
}

class _CommentWithRepliesState extends State<CommentWithReplies> {
  bool _showReplies = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent comment
        CommentCard(
          comment: widget.comment,
          community: widget.community,
          forum: widget.forum,
          post: widget.post,
        ),

        // Replies section (all at same indentation level)
        if (widget.replies.isNotEmpty) ...[
          const SizedBox(height: 8),

          // Toggle button for replies
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showReplies = !_showReplies;
                });
              },
              icon: Icon(
                _showReplies ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
              label: Text(
                _showReplies
                  ? 'Antworten ausblenden'
                  : '${widget.replies.length} ${widget.replies.length == 1 ? 'Antwort' : 'Antworten'} anzeigen',
                style: const TextStyle(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          // Display all replies at same level (no further nesting)
          if (_showReplies) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Column(
                children: widget.replies.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 12),
                      child: CommentCard(
                        comment: reply,
                        community: widget.community,
                        forum: widget.forum,
                        post: widget.post,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Card widget for displaying a comment
class CommentCard extends ConsumerStatefulWidget {
  final Comment comment;
  final Community community;
  final Forum forum;
  final Post post;

  const CommentCard({
    super.key,
    required this.comment,
    required this.community,
    required this.forum,
    required this.post,
  });

  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends ConsumerState<CommentCard> {
  bool _showReplyField = false;
  final _replyController = TextEditingController();
  final _replyFocusNode = FocusNode();
  bool _isSubmittingReply = false;

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;
    if (_isSubmittingReply) return;

    setState(() {
      _isSubmittingReply = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      final postDataSource = ref.read(postRemoteDataSourceProvider);

      await ref.read(commentControllerProvider.notifier).createNewComment(
        communityId: widget.community.id,
        forumId: widget.forum.id,
        postId: widget.post.id,
        authorId: user!.id,
        authorName: user.displayName ?? user.email ?? 'Anonym',
        authorPhotoUrl: user.photoUrl,
        content: _replyController.text.trim(),
        parentId: widget.comment.id,
        postDataSource: postDataSource,
      );

      _replyController.clear();
      _replyFocusNode.unfocus();
      setState(() {
        _showReplyField = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Antwort gesendet'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Senden: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingReply = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isAuthor = currentUser?.id == widget.comment.authorId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.comment.authorPhotoUrl != null
                  ? NetworkImage(widget.comment.authorPhotoUrl!)
                  : null,
              child: widget.comment.authorPhotoUrl == null
                  ? Text(
                      widget.comment.authorName[0].toUpperCase(),
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
                    widget.comment.authorName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(widget.comment.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
                    onSelected: (value) async {
                      if (value == 'report') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Kommentar melden'),
                            content: const Text(
                              'Möchten Sie diesen Kommentar melden? Ein Administrator wird ihn überprüfen.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Abbrechen'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Melden'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          try {
                            final createReview = ref.read(createReviewRequestProvider);
                            await createReview(
                              userId: widget.comment.authorId,
                              content: widget.comment.content,
                              contentType: 'comment',
                              contentId: widget.comment.id,
                              postId: widget.post.id,
                              communityId: widget.community.id,
                              forumId: widget.forum.id,
                              title: 'Kommentar zu: ${widget.post.title}',
                              authorName: widget.comment.authorName,
                              authorPhotoUrl: widget.comment.authorPhotoUrl,
                              flagReasons: ['userReport'],
                              confidenceScore: 1.0, // Manual report = 100% confidence
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kommentar wurde gemeldet'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Fehler beim Melden: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      } else if (value == 'reply') {
                        if (_showReplyField) {
                          // Hide reply field - unfocus first
                          _replyFocusNode.unfocus();
                          setState(() {
                            _showReplyField = false;
                          });
                        } else {
                          // Show reply field
                          setState(() {
                            _showReplyField = true;
                          });
                          // Focus after a brief delay to ensure widget is built
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (mounted && _showReplyField) {
                              _replyFocusNode.requestFocus();
                            }
                          });
                        }
                      } else if (value == 'delete') {
                        // Confirm deletion
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Kommentar löschen'),
                            content: const Text(
                              'Möchten Sie diesen Kommentar wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Abbrechen'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Löschen'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          try {
                            final postDataSource = ref.read(postRemoteDataSourceProvider);
                            final success = await ref
                                .read(commentControllerProvider.notifier)
                                .deleteExistingComment(
                                  communityId: widget.community.id,
                                  forumId: widget.forum.id,
                                  postId: widget.post.id,
                                  commentId: widget.comment.id,
                                  postDataSource: postDataSource,
                                );

                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Kommentar gelöscht'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fehler beim Löschen'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Fehler: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'reply',
                        child: Row(
                          children: [
                            Icon(Icons.reply),
                            SizedBox(width: 12),
                            Text('Antworten'),
                          ],
                        ),
                      ),
                      if (isAuthor)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Löschen', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag, color: Colors.orange),
                            SizedBox(width: 12),
                            Text('Melden'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.comment.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    ),
        // Reply field
        if (_showReplyField)
          Padding(
            padding: const EdgeInsets.only(left: 44, top: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: ValueKey('reply_${widget.comment.id}'),
                    controller: _replyController,
                    focusNode: _replyFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Antwort schreiben...',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: _isSubmittingReply
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _submitReply,
                            ),
                    ),
                    enabled: !_isSubmittingReply,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitReply(),
                  ),
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
