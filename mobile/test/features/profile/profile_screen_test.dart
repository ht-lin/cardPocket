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
    GoRoute(path: '/', builder: (_, _) => const ProfileScreen()),
    GoRoute(path: '/profile/edit-name', builder: (_, _) => const SizedBox()),
    GoRoute(
      path: '/profile/change-password',
      builder: (_, _) => const SizedBox(),
    ),
    GoRoute(path: '/login', builder: (_, _) => const SizedBox()),
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

/// Pump the profile screen on a tall surface so every settings tile is laid out
/// (the screen has more entries than the default 600px test viewport fits).
Future<void> _pumpProfile(WidgetTester tester, {required User user}) async {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_buildTestApp(user: user));
  await tester.pumpAndSettle();
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
      await _pumpProfile(tester, user: _testUser);

      expect(find.text('alice'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
    });

    testWidgets('shows Edit Username list tile', (tester) async {
      await _pumpProfile(tester, user: _testUser);

      expect(find.text('Edit Username'), findsOneWidget);
    });

    testWidgets('shows Change Password list tile', (tester) async {
      await _pumpProfile(tester, user: _testUser);

      expect(find.text('Change Password'), findsOneWidget);
    });

    testWidgets('expiry policy switch is off for KEEP', (tester) async {
      await _pumpProfile(tester, user: _testUser);

      expect(find.text('Auto-move expired cards to trash'), findsOneWidget);
      final sw = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Auto-move expired cards to trash'),
      );
      expect(sw.value, false);
    });

    testWidgets('expiry policy switch is on for AUTO_TRASH', (tester) async {
      await _pumpProfile(
        tester,
        user: _testUser.copyWith(expiryPolicy: ExpiryPolicy.autoTrash),
      );

      final sw = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Auto-move expired cards to trash'),
      );
      expect(sw.value, true);
    });

    testWidgets('discoverable switch reflects the user flag', (tester) async {
      await _pumpProfile(
        tester,
        user: _testUser.copyWith(discoverable: false),
      );

      final sw = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Allow others to find me'),
      );
      expect(sw.value, false);
    });

    testWidgets('shows Export my data list tile', (tester) async {
      await _pumpProfile(tester, user: _testUser);

      expect(find.text('Export my data'), findsOneWidget);
    });

    testWidgets('shows Sign Out list tile', (tester) async {
      await _pumpProfile(tester, user: _testUser);

      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('shows Delete Account list tile', (tester) async {
      await _pumpProfile(tester, user: _testUser);

      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('tapping Delete Account shows confirmation dialog',
        (tester) async {
      await _pumpProfile(tester, user: _testUser);

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
      await _pumpProfile(tester, user: _testUser);

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
