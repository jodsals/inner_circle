import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../domain/entities/community.dart';
import '../providers/community_providers.dart';

/// Page for users to browse and manage communities
class UserCommunitiesPage extends ConsumerStatefulWidget {
  const UserCommunitiesPage({super.key});

  @override
  ConsumerState<UserCommunitiesPage> createState() =>
      _UserCommunitiesPageState();
}

class _UserCommunitiesPageState extends ConsumerState<UserCommunitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Communities'),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.textDark,
          unselectedLabelColor: AppColors.textLight,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'All Communities'),
            Tab(text: 'My Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllCommunitiesTab(),
          _buildMyFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildAllCommunitiesTab() {
    final allCommunitiesAsync = ref.watch(communitiesStreamProvider);

    return allCommunitiesAsync.when(
      data: (either) => either.fold(
        (failure) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler: ${failure.message}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(communitiesStreamProvider),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
        (communities) {
          if (communities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Noch keine Communities',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(communitiesStreamProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final community = communities[index];
                return _CommunityCard(community: community);
              },
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Fehler: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildMyFavoritesTab() {
    final favoritesAsync = ref.watch(favoritesCommunitiesProvider);

    return favoritesAsync.when(
      data: (communities) {
        if (communities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Keine Favoriten',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Like Communities, um sie hier zu sehen',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(favoritesCommunitiesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return _CommunityCard(community: community);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Fehler: $error'),
          ],
        ),
      ),
    );
  }
}

/// Community card widget with new design
class _CommunityCard extends ConsumerWidget {
  final Community community;

  const _CommunityCard({required this.community});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(
            '/communities/${community.id}',
            extra: community,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image
            if (community.bannerImage != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  community.bannerImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primaryYellowLight,
                    child: const Center(
                      child: Icon(Icons.groups, size: 48),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 140,
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
                    size: 64,
                    color: AppColors.textDark,
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    community.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Description (if available)
                  if (community.description.isNotEmpty) ...[
                    Text(
                      community.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Member count, like button, and view button
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 20,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${community.memberCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(width: 16),
                      // Like button
                      if (user != null) ...[
                        InkWell(
                          onTap: () async {
                            final likeFunc = ref.read(likeCommunityProvider);
                            await likeFunc(
                              userId: user.id,
                              communityId: community.id,
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Consumer(
                                  builder: (context, ref, child) {
                                    final isLikedAsync = ref.watch(
                                      isLikedProvider(LikeParams(user.id, community.id)),
                                    );
                                    return isLikedAsync.when(
                                      data: (isLiked) => Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        size: 20,
                                        color: isLiked ? Colors.red : AppColors.textLight,
                                      ),
                                      loading: () => const Icon(
                                        Icons.favorite_border,
                                        size: 20,
                                        color: AppColors.textLight,
                                      ),
                                      error: (_, __) => const Icon(
                                        Icons.favorite_border,
                                        size: 20,
                                        color: AppColors.textLight,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${community.likeCount}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          context.push(
                            '/communities/${community.id}',
                            extra: community,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('View Community'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
