import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../community/domain/entities/community.dart';
import '../../../forum/domain/entities/forum.dart';
import '../../../moderation/presentation/providers/moderation_providers.dart';
import '../../domain/entities/post.dart';
import '../providers/post_providers.dart';

export '../providers/post_providers.dart' show ForumParams;

/// Page showing all posts in a forum (user-facing view)
class ForumPostsPage extends ConsumerWidget {
  final Community community;
  final Forum forum;

  const ForumPostsPage({
    super.key,
    required this.community,
    required this.forum,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final postsAsyncValue = ref.watch(
      watchPostsProvider(ForumParams(community.id, forum.id)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(forum.title),
            Text(
              community.title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: postsAsyncValue.when(
        data: (posts) {
          print('Posts loaded: ${posts.length} posts'); // Debug output

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Noch keine Posts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sei der Erste, der etwas postet!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Community: ${community.id}\nForum: ${forum.id}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final post = posts[index] as Post;
              return PostCard(
                post: post,
                community: community,
                forum: forum,
                onTap: () {
                  context.push(
                    '/communities/${community.id}/forums/${forum.id}/posts/${post.id}',
                    extra: {
                      'community': community,
                      'forum': forum,
                      'post': post,
                    },
                  );
                },
              );
            },
          );
        },
        loading: () {
          print('Loading posts for community: ${community.id}, forum: ${forum.id}'); // Debug
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Lädt Posts...\nCommunity: ${community.id}\nForum: ${forum.id}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
        error: (error, stack) {
          print('Error loading posts: $error'); // Debug
          print('Stack: $stack'); // Debug
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Fehler: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(watchPostsProvider),
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: authState.user != null
          ? FloatingActionButton.extended(
          onPressed: () {
            context.push(
              '/communities/${community.id}/forums/${forum.id}/posts/create',
              extra: {
                'community': community,
                'forum': forum,
              },
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Neuer Post'),
        )
          : null,
    );
  }
}

/// Card widget for displaying a post
class PostCard extends ConsumerWidget {
  final Post post;
  final Community community;
  final Forum forum;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.community,
    required this.forum,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with more menu
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                  onSelected: (value) async {
                    if (value == 'report') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Beitrag melden'),
                          content: const Text(
                            'Möchten Sie diesen Beitrag melden? Ein Administrator wird ihn überprüfen.',
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
                            userId: post.authorId,
                            content: post.content,
                            contentType: 'post',
                            contentId: post.id,
                            communityId: community.id,
                            forumId: forum.id,
                            title: post.title,
                            authorName: post.authorName,
                            authorPhotoUrl: post.authorPhotoUrl,
                            flagReasons: ['userReport'],
                            confidenceScore: 1.0, // Manual report = 100% confidence
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Beitrag wurde gemeldet'),
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
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Melden'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Content preview
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            // Metadata
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: post.authorPhotoUrl != null
                      ? NetworkImage(post.authorPhotoUrl!)
                      : null,
                  child: post.authorPhotoUrl == null
                      ? Text(
                          post.authorName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  post.authorName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${post.commentsCount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  _formatDate(post.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
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
