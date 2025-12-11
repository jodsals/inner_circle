import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/pages/auth_page.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../admin/presentation/pages/communities_page.dart';
import '../../admin/presentation/pages/forums_page.dart';

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

      // User home route (placeholder for now)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const _HomePage(),
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

/// Placeholder home page for normal users
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('User Home - Coming Soon'),
      ),
    );
  }
}