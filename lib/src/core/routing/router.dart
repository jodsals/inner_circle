import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/pages/auth_page.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../admin/presentation/pages/communities_page.dart';
import '../../admin/presentation/pages/forums_page.dart';
import '../../community/domain/entities/community.dart';
import '../../community/presentation/pages/user_communities_page.dart';
import '../../community/presentation/pages/community_detail_page.dart';
import '../../community/presentation/pages/community_detail_loader.dart';
import '../../forum/domain/entities/forum.dart';
import '../../post/domain/entities/post.dart';
import '../../post/presentation/pages/forum_posts_page.dart';
import '../../post/presentation/pages/post_detail_page.dart';
import '../../post/presentation/pages/create_post_page.dart';
import '../../post/presentation/pages/posts_debug_page.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  // Create a notifier to trigger router refresh when auth state changes
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/auth',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final isAuthPage = state.matchedLocation == '/auth';

      // Not logged in -> redirect to auth
      if (user == null) {
        return isAuthPage ? null : '/auth';
      }

      // Logged in but on auth page -> redirect based on role
      if (isAuthPage) {
        return user.role.isAdmin ? '/admin' : '/home';
      }

      // Check admin routes
      if (state.matchedLocation.startsWith('/admin')) {
        if (!user.role.isAdmin) {
          return '/home'; // Non-admin trying to access admin -> redirect to home
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth route
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'communities',
            name: 'admin-communities',
            builder: (context, state) => const CommunitiesPage(),
          ),
          GoRoute(
            path: 'forums',
            name: 'admin-forums',
            builder: (context, state) => const ForumsPage(),
          ),
        ],
      ),

      // User home route - redirects to communities
      GoRoute(
        path: '/home',
        name: 'home',
        redirect: (context, state) => '/communities',
      ),

      // Communities routes (user-facing)
      GoRoute(
        path: '/communities',
        name: 'communities',
        builder: (context, state) => const UserCommunitiesPage(),
        routes: [
          // Community detail
          GoRoute(
            path: ':communityId',
            name: 'community-detail',
            builder: (context, state) {
              final communityId = state.pathParameters['communityId']!;
              final community = state.extra as Community?;

              // If extra is null (e.g., page refresh), show a loading page that fetches the community
              if (community == null) {
                return CommunityDetailLoader(communityId: communityId);
              }

              return CommunityDetailPage(community: community);
            },
            routes: [
              // Forums
              GoRoute(
                path: 'forums/:forumId',
                name: 'forum-posts',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  return ForumPostsPage(
                    community: extra['community'] as Community,
                    forum: extra['forum'] as Forum,
                  );
                },
                routes: [
                  // Debug page for direct Firestore access
                  GoRoute(
                    path: 'debug',
                    name: 'forum-posts-debug',
                    builder: (context, state) {
                      final communityId = state.pathParameters['communityId']!;
                      final forumId = state.pathParameters['forumId']!;
                      return PostsDebugPage(
                        communityId: communityId,
                        forumId: forumId,
                      );
                    },
                  ),
                  // Create post
                  GoRoute(
                    path: 'posts/create',
                    name: 'create-post',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return CreatePostPage(
                        community: extra['community'] as Community,
                        forum: extra['forum'] as Forum,
                      );
                    },
                  ),
                  // Post detail
                  GoRoute(
                    path: 'posts/:postId',
                    name: 'post-detail',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return PostDetailPage(
                        community: extra['community'] as Community,
                        forum: extra['forum'] as Forum,
                        post: extra['post'] as Post,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});

/// Notifier to trigger router refresh when auth state changes
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(
      authControllerProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }

  final Ref _ref;
}