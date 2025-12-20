import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../community/presentation/providers/community_providers.dart';
import '../../../forum/presentation/providers/forum_providers.dart';
import '../providers/post_providers.dart';
import 'post_detail_page.dart';

/// Loader für Post-Details wenn Daten nicht über Navigation übergeben wurden
class PostDetailLoader extends ConsumerWidget {
  final String communityId;
  final String forumId;
  final String postId;

  const PostDetailLoader({
    Key? key,
    required this.communityId,
    required this.forumId,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lade Communities
    final communitiesAsync = ref.watch(communitiesStreamProvider);

    return communitiesAsync.when(
      data: (communitiesEither) => communitiesEither.fold(
        // Fehler beim Laden der Communities
        (failure) => _buildErrorScaffold(
          context,
          'Fehler beim Laden der Community: ${failure.message}',
        ),
        // Communities erfolgreich geladen
        (communities) {
          final community = communities.firstWhere(
            (c) => c.id == communityId,
            orElse: () => throw Exception('Community nicht gefunden'),
          );

          // Lade Foren
          final forumsAsync = ref.watch(watchForumsProvider(communityId));

          return forumsAsync.when(
            data: (forumsEither) => forumsEither.fold(
              // Fehler beim Laden der Foren
              (failure) => _buildErrorScaffold(
                context,
                'Fehler beim Laden des Forums: ${failure.message}',
              ),
              // Foren erfolgreich geladen
              (forums) {
                final forum = forums.firstWhere(
                  (f) => f.id == forumId,
                  orElse: () => throw Exception('Forum nicht gefunden'),
                );

                // Lade Posts
                final postsAsync = ref.watch(
                  watchPostsProvider(ForumParams(
                    communityId,
                    forumId,
                  )),
                );

                return postsAsync.when(
                  data: (posts) {
                    final post = posts.firstWhere(
                      (p) => p.id == postId,
                      orElse: () => throw Exception('Post nicht gefunden'),
                    );

                    // Zeige Post-Detail-Seite
                    return PostDetailPage(
                      community: community,
                      forum: forum,
                      post: post,
                    );
                  },
                  loading: () => _buildLoadingScaffold(),
                  error: (error, stack) => _buildErrorScaffold(
                    context,
                    'Fehler beim Laden des Posts: $error',
                  ),
                );
              },
            ),
            loading: () => _buildLoadingScaffold(),
            error: (error, stack) => _buildErrorScaffold(
              context,
              'Fehler beim Laden des Forums: $error',
            ),
          );
        },
      ),
      loading: () => _buildLoadingScaffold(),
      error: (error, stack) => _buildErrorScaffold(
        context,
        'Fehler beim Laden der Community: $error',
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('Lädt...')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fehler')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Zurück'),
            ),
          ],
        ),
      ),
    );
  }
}
