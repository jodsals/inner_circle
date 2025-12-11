import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../community/presentation/providers/community_providers.dart';
import '../../../forum/presentation/providers/forum_providers.dart';
import '../widgets/forum_form_dialog.dart';

/// Forums management page
class ForumsPage extends ConsumerStatefulWidget {
  const ForumsPage({super.key});

  @override
  ConsumerState<ForumsPage> createState() => _ForumsPageState();
}

class _ForumsPageState extends ConsumerState<ForumsPage> {
  String? _selectedCommunityId;

  @override
  void initState() {
    super.initState();
    // Load communities on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityControllerProvider.notifier).loadCommunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(communityControllerProvider);
    final forumState = ref.watch(forumControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foren verwalten'),
      ),
      body: Column(
        children: [
          // Community selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: communityState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : communityState.communities.isEmpty
                    ? const Center(
                        child: Text('Keine Communities vorhanden'),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedCommunityId,
                        decoration: const InputDecoration(
                          labelText: 'Community auswählen',
                          border: OutlineInputBorder(),
                        ),
                        items: communityState.communities
                            .map(
                              (community) => DropdownMenuItem(
                                value: community.id,
                                child: Text(community.title),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCommunityId = value;
                          });
                          if (value != null) {
                            ref
                                .read(forumControllerProvider.notifier)
                                .loadForums(value);
                          }
                        },
                      ),
          ),

          // Forums list
          Expanded(
            child: _selectedCommunityId == null
                ? const Center(
                    child: Text('Bitte wählen Sie eine Community aus'),
                  )
                : forumState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : forumState.errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Fehler: ${forumState.errorMessage}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(forumControllerProvider.notifier)
                                        .loadForums(_selectedCommunityId!);
                                  },
                                  child: const Text('Erneut versuchen'),
                                ),
                              ],
                            ),
                          )
                        : forumState.forums.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.forum_outlined,
                                        size: 64, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    const Text('Keine Foren vorhanden'),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _showCreateDialog(context),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Forum erstellen'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: forumState.forums.length,
                                itemBuilder: (context, index) {
                                  final forum = forumState.forums[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      leading: const Icon(Icons.forum),
                                      title: Text(
                                        forum.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Erstellt: ${_formatDate(forum.createdAt)}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _showEditDialog(
                                                context, forum.id),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => _showDeleteDialog(
                                                context, forum.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
      floatingActionButton: _selectedCommunityId != null &&
              forumState.forums.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Forum erstellen'),
            )
          : null,
    );
  }

  void _showCreateDialog(BuildContext context) {
    if (_selectedCommunityId == null) return;

    showDialog(
      context: context,
      builder: (context) => ForumFormDialog(
        onSave: (title) async {
          final success =
              await ref.read(forumControllerProvider.notifier).createForum(
                    communityId: _selectedCommunityId!,
                    title: title,
                  );

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Forum erfolgreich erstellt')),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Fehler: ${ref.read(forumControllerProvider).errorMessage}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, String forumId) {
    if (_selectedCommunityId == null) return;

    final forum = ref
        .read(forumControllerProvider)
        .forums
        .firstWhere((f) => f.id == forumId);

    showDialog(
      context: context,
      builder: (context) => ForumFormDialog(
        initialTitle: forum.title,
        onSave: (title) async {
          final success =
              await ref.read(forumControllerProvider.notifier).updateForum(
                    communityId: _selectedCommunityId!,
                    forumId: forumId,
                    title: title,
                  );

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Forum erfolgreich aktualisiert')),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Fehler: ${ref.read(forumControllerProvider).errorMessage}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String forumId) {
    if (_selectedCommunityId == null) return;

    final forum = ref
        .read(forumControllerProvider)
        .forums
        .firstWhere((f) => f.id == forumId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forum löschen'),
        content: Text(
          'Möchten Sie das Forum "${forum.title}" wirklich löschen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () async {
              final success =
                  await ref.read(forumControllerProvider.notifier).deleteForum(
                        _selectedCommunityId!,
                        forumId,
                      );

              if (success && context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Forum erfolgreich gelöscht')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Fehler: ${ref.read(forumControllerProvider).errorMessage}',
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

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}