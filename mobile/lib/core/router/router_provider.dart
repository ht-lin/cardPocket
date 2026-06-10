import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/auth_state.dart';
import '../auth/auth_state_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/verify_pending_screen.dart';
import '../../features/placeholder_screen.dart';
import 'route_names.dart';

part 'router_provider.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final notifier = _RouterNotifier(ref);
  final goRouter = GoRouter(
    refreshListenable: notifier,
    redirect: notifier.redirect,
    initialLocation: '/login',
    routes: _buildRoutes(),
  );
  ref.onDispose(goRouter.dispose);
  return goRouter;
}

// Bridges Riverpod's reactive AuthState with go_router's synchronous
// refreshListenable + redirect pattern.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authStateProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    const authPaths = ['/login', '/register', '/verify-pending'];
    final isAuthPage = authPaths.contains(path);

    return _ref.read(authStateProvider).map(
          loading: (_) => null,
          unauthenticated: (_) => isAuthPage ? null : '/login',
          unverified: (_) => isAuthPage ? '/verify-pending' : null,
          authenticated: (_) => isAuthPage ? '/cards' : null,
        );
  }
}

List<RouteBase> _buildRoutes() => [
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-pending',
        name: RouteNames.verifyPending,
        builder: (context, state) => const VerifyPendingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ScaffoldWithNavBar(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cards',
                name: RouteNames.cards,
                builder: (context, state) =>
                    const PlaceholderScreen(label: 'Cards'),
                routes: [
                  GoRoute(
                    path: 'scan',
                    name: RouteNames.cardsScan,
                    builder: (context, state) =>
                        const PlaceholderScreen(label: 'Scan'),
                  ),
                  GoRoute(
                    path: 'create',
                    name: RouteNames.cardsCreate,
                    builder: (context, state) =>
                        const PlaceholderScreen(label: 'Create Card'),
                  ),
                  GoRoute(
                    path: ':id/barcode',
                    name: RouteNames.cardBarcode,
                    builder: (context, state) =>
                        const PlaceholderScreen(label: 'Barcode'),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/friends',
                name: RouteNames.friends,
                builder: (context, state) =>
                    const PlaceholderScreen(label: 'Friends'),
                routes: [
                  GoRoute(
                    path: 'requests',
                    name: RouteNames.friendsRequests,
                    builder: (context, state) =>
                        const PlaceholderScreen(label: 'Requests'),
                  ),
                  GoRoute(
                    path: 'search',
                    name: RouteNames.friendsSearch,
                    builder: (context, state) =>
                        const PlaceholderScreen(label: 'Search Friends'),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: RouteNames.profile,
                builder: (context, state) =>
                    const PlaceholderScreen(label: 'Profile'),
                routes: [
                  GoRoute(
                    path: 'edit-name',
                    name: RouteNames.profileEditName,
                    builder: (context, state) =>
                        const PlaceholderScreen(label: 'Edit Name'),
                  ),
                  GoRoute(
                    path: 'change-password',
                    name: RouteNames.profileChangePassword,
                    builder: (context, state) =>
                        const PlaceholderScreen(label: 'Change Password'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
