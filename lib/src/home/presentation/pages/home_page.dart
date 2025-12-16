import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../community/domain/entities/community.dart';
import '../../../community/presentation/providers/community_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/feed_card.dart';
import '../../../post/domain/entities/post.dart';
import '../providers/home_providers.dart';

/// Home page with feed and community carousel
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
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
    final communitiesAsync = ref.watch(communitiesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Home',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/communities');
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),
            ),

            // Communities Carousel
            communitiesAsync.when(
              data: (either) => either.fold(
                (failure) => const SizedBox.shrink(),
                (communities) => _buildCommunitiesCarousel(communities),
              ),
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryYellow,
                labelColor: AppColors.textDark,
                unselectedLabelColor: AppColors.textLight,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'My Feed'),
                  Tab(text: 'My Communities'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyFeedTab(),
                  _buildMyCommunitiesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitiesCarousel(List<Community> communities) {
    if (communities.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final community = communities[index];
          return _CommunityCard(community: community);
        },
      ),
    );
  }

  Widget _buildMyFeedTab() {
    final allPostsAsync = ref.watch(allPostsProvider);

    return allPostsAsync.when(
      data: (posts) {
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
                  'Tritt Communities bei, um Posts zu sehen',
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
            ref.invalidate(allPostsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postData = posts[index];
              return FeedCard(
                post: postData['post'] as Post,
                communityName: postData['communityName'] as String,
                forumName: postData['forumName'] as String,
                onTap: () {
                  // Navigate to post detail
                  context.push(
                    '/communities/${postData['communityId']}/forums/${postData['forumId']}/posts/${(postData['post'] as Post).id}',
                    extra: {
                      'community': postData['community'],
                      'forum': postData['forum'],
                      'post': postData['post'],
                    },
                  );
                },
                onLike: () {
                  // TODO: Implement like functionality
                },
                onReport: () {
                  // TODO: Implement report functionality
                },
              );
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(allPostsProvider),
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCommunitiesTab() {
    final myCommunitiesAsync = ref.watch(myCommunitiesProvider);

    return myCommunitiesAsync.when(
      data: (communities) {
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
                const SizedBox(height: 8),
                Text(
                  'Tritt Communities bei, um loszulegen',
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
            ref.invalidate(myCommunitiesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return _CommunityListCard(community: community);
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

/// Community card for carousel
class _CommunityCard extends StatelessWidget {
  final Community community;

  const _CommunityCard({required this.community});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/communities/${community.id}',
          extra: community,
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryYellowLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: community.bannerImage != null
                  ? ClipOval(
                      child: Image.network(
                        community.bannerImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        community.title[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              community.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Community list card for My Communities tab
class _CommunityListCard extends StatelessWidget {
  final Community community;

  const _CommunityListCard({required this.community});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push(
            '/communities/${community.id}',
            extra: community,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image
            if (community.bannerImage != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  community.bannerImage!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_border,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${community.memberCount} Mitglieder',
                        style: Theme.of(context).textTheme.bodySmall,
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
