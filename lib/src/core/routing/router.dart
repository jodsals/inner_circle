import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/pages/account_settings_page.dart';
import '../../auth/presentation/pages/auth_page.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../admin/presentation/pages/admin_reviews_page.dart';
import '../../admin/presentation/pages/communities_page.dart';
import '../../admin/presentation/pages/forums_page.dart';
import '../presentation/pages/app_shell.dart';
import '../../community/domain/entities/community.dart';
import '../../community/presentation/pages/user_communities_page.dart';
import '../../community/presentation/pages/community_detail_page_new.dart';
import '../../community/presentation/pages/community_detail_loader.dart';
import '../../forum/domain/entities/forum.dart';
import '../../post/domain/entities/post.dart';
import '../../post/presentation/pages/forum_posts_page.dart';
import '../../post/presentation/pages/post_detail_page.dart';
import '../../post/presentation/pages/post_detail_loader.dart';
import '../../post/presentation/pages/create_post_page.dart';
import '../../search/presentation/pages/search_page.dart';
import '../../survey/domain/entities/survey_response.dart';
import '../../survey/presentation/pages/survey_intro_page.dart';
import '../../survey/presentation/pages/survey_page.dart';

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
      final isSurveyPage = state.matchedLocation.startsWith('/survey');

      // Not logged in -> redirect to auth
      if (user == null) {
        return isAuthPage ? null : '/auth';
      }

      // Check if user needs to complete initial survey
      if (!user.hasCompletedInitialSurvey && !isSurveyPage) {
        // Redirect to survey intro page - survey page will load progress if available
        return '/survey/intro/baseline';
      }

      // Logged in but on auth page -> redirect based on role/survey status
      if (isAuthPage) {
        // If survey not completed, go to survey
        if (!user.hasCompletedInitialSurvey) {
          return '/survey/intro/baseline';
        }
        // Otherwise redirect based on role
        return user.role.isAdmin ? '/admin' : '/app';
      }

      // Check admin routes
      if (state.matchedLocation.startsWith('/admin')) {
        if (!user.role.isAdmin) {
          return '/app'; // Non-admin trying to access admin -> redirect to app
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
            path: 'reviews',
            name: 'admin-reviews',
            builder: (context, state) => const AdminReviewsPage(),
          ),
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

      // Main app shell (user-facing)
      GoRoute(
        path: '/app',
        name: 'app',
        builder: (context, state) => const AppShell(),
      ),

      // Search route
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),

      // Account settings route
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const AccountSettingsPage(),
      ),

      // Survey routes
      GoRoute(
        path: '/survey/intro/:type',
        name: 'survey-intro',
        builder: (context, state) {
          final typeStr = state.pathParameters['type']!;
          final surveyType = typeStr == 'baseline'
              ? SurveyType.baseline
              : SurveyType.followup;
          return SurveyIntroPage(surveyType: surveyType);
        },
      ),
      GoRoute(
        path: '/survey/:type',
        name: 'survey',
        builder: (context, state) {
          final typeStr = state.pathParameters['type']!;
          final surveyType = typeStr == 'baseline'
              ? SurveyType.baseline
              : SurveyType.followup;
          return SurveyPage(surveyType: surveyType);
        },
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

              return CommunityDetailPageNew(community: community);
            },
            routes: [
              // Forums
              GoRoute(
                path: 'forums/:forumId',
                name: 'forum-posts',
                builder: (context, state) {
                  final communityId = state.pathParameters['communityId']!;
                  final forumId = state.pathParameters['forumId']!;
                  final extra = state.extra as Map<String, dynamic>?;

                  // If extra is null (e.g., page refresh), return error or loader
                  if (extra == null) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Forum')),
                      body: const Center(
                        child: Text('Please navigate from the community page'),
                      ),
                    );
                  }

                  return ForumPostsPage(
                    community: extra['community'] as Community,
                    forum: extra['forum'] as Forum,
                  );
                },
                routes: [
                  // Create post
                  GoRoute(
                    path: 'posts/create',
                    name: 'create-post',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;

                      // If extra is null (e.g., page refresh), return error or loader
                      if (extra == null) {
                        return Scaffold(
                          appBar: AppBar(title: const Text('Create Post')),
                          body: const Center(
                            child: Text('Please navigate from the forum page'),
                          ),
                        );
                      }

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
                      final communityId = state.pathParameters['communityId']!;
                      final forumId = state.pathParameters['forumId']!;
                      final postId = state.pathParameters['postId']!;
                      final extra = state.extra as Map<String, dynamic>?;

                      // Wenn extra null ist, verwende den Loader
                      if (extra == null) {
                        return PostDetailLoader(
                          communityId: communityId,
                          forumId: forumId,
                          postId: postId,
                        );
                      }

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