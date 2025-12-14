import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/community_providers.dart';
import 'community_detail_page.dart';

/// Loader widget that fetches community data and displays the detail page
class CommunityDetailLoader extends ConsumerWidget {
  final String communityId;

  const CommunityDetailLoader({super.key, required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the communities stream
    final communitiesAsync = ref.watch(communitiesStreamProvider);

    return communitiesAsync.when(
      data: (either) => either.fold(
        (failure) => Scaffold(
          appBar: AppBar(title: const Text('Fehler')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Fehler beim Laden: ${failure.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(communitiesStreamProvider),
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        ),
        (communities) {
          // Find the community by ID
          final community = communities.firstWhere(
            (c) => c.id == communityId,
            orElse: () => throw Exception('Community not found'),
          );

          return CommunityDetailPage(community: community);
        },
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Lädt...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Fehler')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler: $error'),
            ],
          ),
        ),
      ),
    );
  }
}
