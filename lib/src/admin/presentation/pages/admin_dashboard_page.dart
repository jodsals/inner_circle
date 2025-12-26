import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../community/presentation/providers/community_providers.dart';
import '../../../moderation/presentation/providers/moderation_providers.dart';

/// Admin dashboard page
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final communityState = ref.watch(communityControllerProvider);
    final reviewsAsync = ref.watch(watchPendingReviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings),
            const SizedBox(width: 12),
            const Text('Admin Dashboard'),
          ],
        ),
        actions: [
          // User info chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  user?.email?.split('@')[0] ?? 'Admin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Logout button
          IconButton(
            onPressed: () async {
              // Get the controller before any async operations
              final authController = ref.read(authControllerProvider.notifier);

              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Ausloggen'),
                  content: const Text('Möchten Sie sich wirklich ausloggen?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Abbrechen'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Ausloggen'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Ausloggen...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                await authController.logout();

                if (context.mounted) {
                  context.go('/auth');
                }
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Ausloggen',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _AdminDrawer(currentUser: user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Willkommen, ${user?.email ?? 'Admin'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),

            // Stats cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(
                  title: 'Communities',
                  count: communityState.communities.length,
                  icon: Icons.group,
                  color: Colors.blue,
                  onTap: () => context.go('/admin/communities'),
                ),
                _StatCard(
                  title: 'Foren',
                  count: 0, // Will be calculated from all communities
                  icon: Icons.forum,
                  color: Colors.green,
                  onTap: () => context.go('/admin/forums'),
                ),
                reviewsAsync.when(
                  data: (reviews) => _StatCard(
                    title: 'Ausstehende Reviews',
                    count: reviews.length,
                    icon: Icons.flag,
                    color: reviews.isEmpty ? Colors.green : Colors.orange,
                    onTap: () => context.go('/admin/reviews'),
                  ),
                  loading: () => _StatCard(
                    title: 'Ausstehende Reviews',
                    count: 0,
                    icon: Icons.flag,
                    color: Colors.grey,
                    onTap: () => context.go('/admin/reviews'),
                  ),
                  error: (_, __) => _StatCard(
                    title: 'Ausstehende Reviews',
                    count: 0,
                    icon: Icons.flag,
                    color: Colors.red,
                    onTap: () => context.go('/admin/reviews'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick actions
            Text(
              'Schnellzugriff',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _QuickActionButton(
                  label: 'Inhalte überprüfen',
                  icon: Icons.flag,
                  onPressed: () => context.go('/admin/reviews'),
                ),
                _QuickActionButton(
                  label: 'Communities verwalten',
                  icon: Icons.group,
                  onPressed: () => context.go('/admin/communities'),
                ),
                _QuickActionButton(
                  label: 'Foren verwalten',
                  icon: Icons.forum,
                  onPressed: () => context.go('/admin/forums'),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Admin navigation drawer
class _AdminDrawer extends ConsumerWidget {
  final dynamic currentUser;

  const _AdminDrawer({this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Overview'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Inhalte überprüfen'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/reviews');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Communities'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/communities');
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text('Foren'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/forums');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Ausloggen',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              // Get the controller before any async operations
              final authController = ref.read(authControllerProvider.notifier);

              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Ausloggen'),
                  content: const Text('Möchten Sie sich wirklich ausloggen?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Abbrechen'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Ausloggen'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (loadingContext) => const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Ausloggen...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                await authController.logout();

                if (context.mounted) {
                  context.go('/auth');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 16),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action button
class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }
}