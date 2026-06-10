// Widget tests for LoginScreen.
// Requires generated code — run `flutter pub run build_runner build` first.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:card_pocket/core/api/api_exception.dart';
import 'package:card_pocket/core/auth/auth_state.dart';
import 'package:card_pocket/features/auth/application/auth_notifier.dart';
import 'package:card_pocket/features/auth/presentation/login_screen.dart';
import 'package:card_pocket/l10n/app_localizations.dart';

// Extend AuthNotifier (not the private _$AuthNotifier) so the subclass is
// visible outside the library and satisfies overrideWith's type constraint.
class _SuccessAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async => const AuthState.unauthenticated();

  @override
  Future<void> login(String email, String password) async {
    state = const AsyncData(AuthState.authenticated(userId: 'test@test.com'));
  }
}

class _FailAuthNotifier extends AuthNotifier {
  _FailAuthNotifier(this._exception);
  final Exception _exception;

  @override
  Future<AuthState> build() async => const AuthState.unauthenticated();

  @override
  Future<void> login(String email, String password) async {
    state = AsyncError(_exception, StackTrace.empty);
  }
}

MaterialApp _i18nApp(Widget home) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  group('LoginScreen — form validation', () {
    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(() => _SuccessAuthNotifier())],
          child: _i18nApp(const LoginScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(() => _SuccessAuthNotifier())],
          child: _i18nApp(const LoginScreen()),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });

  group('LoginScreen — submission', () {
    testWidgets('no validation errors when form is complete', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(() => _SuccessAuthNotifier())],
          child: _i18nApp(const LoginScreen()),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('shows inline error for 422 email field', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _FailAuthNotifier(
                const UnprocessableException({'email': ['Email not found']}),
              ),
            ),
          ],
          child: _i18nApp(const LoginScreen()),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Email not found'), findsOneWidget);
    });

    testWidgets('shows SnackBar for 401 wrong credentials', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () =>
                  _FailAuthNotifier(const UnauthorizedException()),
            ),
          ],
          child: _i18nApp(const LoginScreen()),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Incorrect email or password'), findsOneWidget);
    });
  });
}
