import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../community/presentation/providers/community_providers.dart';
import '../../../forum/presentation/providers/forum_providers.dart';
import '../../../membership/presentation/providers/membership_providers.dart';
import '../../../post/domain/entities/post.dart';
import '../../../post/presentation/providers/post_providers.dart';

/// Provider for all posts from communities user is member of (for My Feed)
/// Auto-reloads when user logs in or when invalidated
final allPostsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];

  // Watch user's community memberships - this will rebuild when memberships change
  final userCommunitiesAsync = ref.watch(userCommunitiesStreamProvider(user.id));

  return await userCommunitiesAsync.when(
    data: (communityIds) async {
      if (communityIds.isEmpty) return [];

      final List<Map<String, dynamic>> allPosts = [];

      // Get all communities
      final communitiesAsync = await ref.watch(communitiesStreamProvider.future);

      await communitiesAsync.fold(
        (failure) async {},
        (communities) async {
          // Filter to only communities user is member of
          final memberCommunities = communities
              .where((c) => communityIds.contains(c.id))
              .toList();

          for (final community in memberCommunities) {
            // Get forums for this community
            final forumsEither = await ref.watch(
              watchForumsProvider(community.id).future,
            );

            await forumsEither.fold(
              (failure) async {
                // Skip this community on error
              },
              (forums) async {
                for (final forum in forums) {
                  // Get posts for this forum
                  final postsAsync = await ref.watch(
                    watchPostsProvider(ForumParams(community.id, forum.id)).future,
                  );

                  for (final post in postsAsync) {
                    allPosts.add({
                      'post': post as Post,
                      'community': community,
                      'communityId': community.id,
                      'communityName': community.title,
                      'forum': forum,
                      'forumId': forum.id,
                      'forumName': forum.title,
                    });
                  }
                }
              },
            );
          }
        },
      );

      // Sort by creation date (newest first)
      allPosts.sort((a, b) {
        final aDate = (a['post'] as Post).createdAt;
        final bDate = (b['post'] as Post).createdAt;
        return bDate.compareTo(aDate);
      });

      return allPosts;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for user's joined communities
final myCommunitiesProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];

  // Get user's community memberships
  final userCommunitiesStream = ref.watch(userCommunitiesStreamProvider(user.id));

  return userCommunitiesStream.when(
    data: (communityIds) async {
      if (communityIds.isEmpty) return [];

      final communitiesAsync = await ref.watch(communitiesStreamProvider.future);

      return communitiesAsync.fold(
        (failure) => [],
        (communities) {
          // Filter to only communities user is member of
          return communities
              .where((c) => communityIds.contains(c.id))
              .toList();
        },
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
});