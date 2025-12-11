import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../community/presentation/providers/community_providers.dart';
import '../widgets/community_form_dialog.dart';

/// Communities management page
class CommunitiesPage extends ConsumerWidget {
  const CommunitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityState = ref.watch(communityControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities verwalten'),
      ),
      body: communityState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : communityState.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Fehler: ${communityState.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(communityControllerProvider.notifier)
                              .loadCommunities();
                        },
                        child: const Text('Erneut versuchen'),
                      ),
                    ],
                  ),
                )
              : communityState.communities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.group_outlined,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('Keine Communities vorhanden'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateDialog(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('Community erstellen'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: communityState.communities.length,
                      itemBuilder: (context, index) {
                        final community = communityState.communities[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: community.bannerImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      community.bannerImage!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.group, size: 40),
                                    ),
                                  )
                                : const Icon(Icons.group, size: 40),
                            title: Text(
                              community.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  community.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${community.memberCount} Mitglieder',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showEditDialog(context, ref, community.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      _showDeleteDialog(context, ref, community.id),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
      floatingActionButton: communityState.communities.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Community erstellen'),
            )
          : null,
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CommunityFormDialog(
        onSave: (title, description, imagePath) async {
          final success = await ref
              .read(communityControllerProvider.notifier)
              .createCommunity(
                title: title,
                description: description,
                bannerImagePath: imagePath,
              );

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Community erfolgreich erstellt')),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Fehler: ${ref.read(communityControllerProvider).errorMessage}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String communityId) {
    final community = ref
        .read(communityControllerProvider)
        .communities
        .firstWhere((c) => c.id == communityId);

    showDialog(
      context: context,
      builder: (context) => CommunityFormDialog(
        initialTitle: community.title,
        initialDescription: community.description,
        initialBannerImageUrl: community.bannerImage,
        onSave: (title, description, imagePath) async {
          final success = await ref
              .read(communityControllerProvider.notifier)
              .updateCommunity(
                id: communityId,
                title: title,
                description: description,
                bannerImagePath: imagePath,
              );

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Community erfolgreich aktualisiert')),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Fehler: ${ref.read(communityControllerProvider).errorMessage}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String communityId) {
    final community = ref
        .read(communityControllerProvider)
        .communities
        .firstWhere((c) => c.id == communityId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Community löschen'),
        content: Text(
          'Möchten Sie die Community "${community.title}" wirklich löschen? '
          'Alle zugehörigen Foren werden ebenfalls gelöscht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(communityControllerProvider.notifier)
                  .deleteCommunity(communityId);

              if (success && context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Community erfolgreich gelöscht')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Fehler: ${ref.read(communityControllerProvider).errorMessage}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}