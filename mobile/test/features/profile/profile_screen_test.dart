import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:card_pocket/features/auth/domain/auth_models.dart';
import 'package:card_pocket/features/profile/application/profile_notifier.dart';
import 'package:card_pocket/features/profile/presentation/profile_screen.dart';
import 'package:card_pocket/l10n/app_localizations.dart';

final _testUser = User(
  id: 'user-1',
  email: 'alice@example.com',
  userName: 'alice',
  emailVerified: true,
  createdAt: DateTime(2026, 6, 1),
);

Widget _buildTestApp({required User user}) {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/profile/edit-name', builder: (_, __) => const SizedBox()),
    GoRoute(
      path: '/profile/change-password',
      builder: (_, __) => const SizedBox(),
    ),
    GoRoute(path: '/login', builder: (_, __) => const SizedBox()),
  ]);

  return ProviderScope(
    overrides: [
      profileProvider.overrideWith(() => _FakeProfileNotifier(user)),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

class _FakeProfileNotifier extends ProfileNotifier {
  _FakeProfileNotifier(this._user);
  final User _user;

  @override
  Future<User> build() async => _user;
}

void main() {
  group('ProfileScreen', () {
    testWidgets('shows username and email', (tester) async {
      await tester.pumpWidget(_buildTestApp(user: _testUser));
      await tester.pumpAndSettle();

      expect(find.text('alice'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
    });

    testWidgets('shows Edit Username list tile', (tester) async {
      await tester.pumpWidget(_buildTestApp(user: _testUser));
      await tester.pumpAndSettle();

      expect(find.text('Edit Username'), findsOneWidget);
    });

    testWidgets('shows Change Password list tile', (tester) async {
      await tester.pumpWidget(_buildTestApp(user: _testUser));
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsOneWidget);
    });

    testWidgets('shows Sign Out list tile', (tester) async {
      await tester.pumpWidget(_buildTestApp(user: _testUser));
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('shows Delete Account list tile', (tester) async {
      await tester.pumpWidget(_buildTestApp(user: _testUser));
      await tester.pumpAndSettle();

      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('tapping Delete Account shows confirmation dialog',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(user: _testUser));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('cancel button dismisses delete account dialog', (tester) async {
      await tester.pumpWidget(_buildTestApp(user: _testUser));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
        findsNothing,
      );
    });
  });
}
