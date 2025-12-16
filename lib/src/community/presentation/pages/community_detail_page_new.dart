import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../forum/domain/entities/forum.dart';
import '../../../forum/presentation/providers/forum_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../membership/presentation/providers/membership_providers.dart';
import '../../../post/presentation/providers/post_providers.dart';
import '../../domain/entities/community.dart';
import '../providers/community_providers.dart';

/// Community detail page with forum tabs and join/leave functionality
class CommunityDetailPageNew extends ConsumerStatefulWidget {
  final Community community;

  const CommunityDetailPageNew({
    super.key,
    required this.community,
  });

  @override
  ConsumerState<CommunityDetailPageNew> createState() => _CommunityDetailPageNewState();
}

class _CommunityDetailPageNewState extends ConsumerState<CommunityDetailPageNew> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final forumsAsync = ref.watch(forumsStreamProvider(widget.community.id));

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.community.title)),
        body: const Center(child: Text('Bitte melden Sie sich an')),
      );
    }

    final isMemberAsync = ref.watch(
      isMemberProvider(MembershipParams(user.id, widget.community.id)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with banner
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.community.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: widget.community.bannerImage != null
                  ? Image.network(
                      widget.community.bannerImage!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryYellowLight,
                            AppColors.primaryYellow,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.groups,
                          size: 80,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
            ),
          ),

          // Community Info & Join/Leave Button
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Member count and Join/Leave button
                  Row(
                    children: [
                      const Icon(
                        Icons.star_border,
                        size: 20,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.community.memberCount} Mitglieder',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      isMemberAsync.when(
                        data: (isMember) => isMember
                            ? OutlinedButton.icon(
                                onPressed: () async {
                                  final success = await ref
                                      .read(
                                          membershipControllerProvider.notifier)
                                      .leave(
                                        userId: user.id,
                                        communityId: widget.community.id,
                                      );

                                  if (success && mounted) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Community verlassen'),
                                        ),
                                      );
                                    }

                                    // Invalidate providers to update UI
                                    ref.invalidate(userCommunitiesStreamProvider(user.id));
                                    ref.invalidate(myCommunitiesProvider);
                                    ref.invalidate(allPostsProvider);
                                    ref.invalidate(communitiesStreamProvider);
                                    ref.invalidate(isMemberProvider(MembershipParams(user.id, widget.community.id)));
                                  }
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Verlassen'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(
                                    color: AppColors.error,
                                    width: 2,
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () async {
                                  final success = await ref
                                      .read(
                                          membershipControllerProvider.notifier)
                                      .join(
                                        userId: user.id,
                                        communityId: widget.community.id,
                                      );

                                  if (success && mounted) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Community beigetreten'),
                                        ),
                                      );
                                    }

                                    // Invalidate providers to update UI
                                    ref.invalidate(userCommunitiesStreamProvider(user.id));
                                    ref.invalidate(myCommunitiesProvider);
                                    ref.invalidate(allPostsProvider);
                                    ref.invalidate(communitiesStreamProvider);
                                    ref.invalidate(isMemberProvider(MembershipParams(user.id, widget.community.id)));
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Beitreten'),
                              ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),

                  if (widget.community.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.community.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Forums Section Header
                  Text(
                    'Foren',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Forums List
          forumsAsync.when(
            data: (either) => either.fold(
              (failure) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Fehler: ${failure.message}'),
                  ),
                ),
              ),
              (forums) {
                if (forums.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Keine Foren vorhanden'),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final forum = forums[index];
                        return _ForumCard(
                          forum: forum,
                          community: widget.community,
                          userId: user.id,
                        );
                      },
                      childCount: forums.length,
                    ),
                  ),
                );
              },
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Fehler: $error'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Forum card widget
class _ForumCard extends ConsumerWidget {
  final Forum forum;
  final Community community;
  final String userId;

  const _ForumCard({
    required this.forum,
    required this.community,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch membership status directly in this widget
    final isMemberAsync = ref.watch(
      isMemberProvider(MembershipParams(userId, community.id)),
    );

    final postsAsync = ref.watch(
      watchPostsProvider(ForumParams(community.id, forum.id)),
    );

    final postCount = postsAsync.when(
      data: (posts) => posts.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final isMember = isMemberAsync.when(
      data: (isMember) => isMember,
      loading: () => false,
      error: (_, __) => false,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (!isMember) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Bitte treten Sie der Community bei, um auf Foren zuzugreifen',
                ),
              ),
            );
            return;
          }

          context.push(
            '/communities/${community.id}/forums/${forum.id}',
            extra: {
              'community': community,
              'forum': forum,
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Forum Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellowLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.forum,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 16),

              // Forum Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      forum.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$postCount Posts',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Lock icon if not member
              if (!isMember)
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.textLight,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
