import 'package:flutter/material.dart';
import '../../post/domain/entities/post.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

/// Feed card widget for displaying posts in the feed
class FeedCard extends StatelessWidget {
  final Post post;
  final String communityName;
  final String forumName;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onReport;
  final bool isLiked;

  const FeedCard({
    super.key,
    required this.post,
    required this.communityName,
    required this.forumName,
    this.onTap,
    this.onLike,
    this.onReport,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primaryYellowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile and menu
              Row(
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: post.authorPhotoUrl != null
                        ? NetworkImage(post.authorPhotoUrl!)
                        : null,
                    child: post.authorPhotoUrl == null
                        ? Text(
                            post.authorName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Username and community/forum info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.authorName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                            ),
                            // Add verified badge if needed
                            // if (isVerified) ...[
                            //   const SizedBox(width: 4),
                            //   const AppIcon(
                            //     iconName: AppIconNames.verified,
                            //     size: 16,
                            //   ),
                            // ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$communityName • $forumName',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textLight,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // 3-dot menu
                  IconButton(
                    icon: const AppIcon(
                      iconName: AppIconNames.morePoints,
                      size: 20,
                    ),
                    onPressed: () => _showMenu(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Post title
              Text(
                post.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
              ),

              const SizedBox(height: 8),

              // Post content preview
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),

              const SizedBox(height: 16),

              // Footer with like and comment counts
              Row(
                children: [
                  // Like button
                  InkWell(
                    onTap: onLike,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            iconName: isLiked
                                ? AppIconNames.favoriteActive
                                : AppIconNames.favorite,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.likesCount}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Comment count
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppIcon(
                          iconName: AppIconNames.chat,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.commentsCount}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Timestamp
                  Text(
                    _formatDate(post.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Beitrag melden'),
              onTap: () {
                Navigator.pop(context);
                onReport?.call();
              },
            ),
            // Add more menu options as needed
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
