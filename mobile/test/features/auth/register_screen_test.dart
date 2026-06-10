// Widget tests for RegisterScreen.
// Requires generated code — run `flutter pub run build_runner build` first.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:card_pocket/core/api/api_exception.dart';
import 'package:card_pocket/features/auth/data/auth_repository.dart';
import 'package:card_pocket/features/auth/domain/auth_models.dart';
import 'package:card_pocket/features/auth/presentation/register_screen.dart';
import 'package:card_pocket/l10n/app_localizations.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

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
  late _MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = _MockAuthRepository();
    registerFallbackValue(
      const RegisterRequest(
        email: '',
        password: '',
        userName: '',
        gdprConsent: false,
      ),
    );
  });

  group('RegisterScreen — form validation', () {
    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: _i18nApp(const RegisterScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error when GDPR not accepted', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: _i18nApp(const RegisterScreen()),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'myuser',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'password123',
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('You must agree to continue'), findsOneWidget);
    });
  });

  group('RegisterScreen — submission', () {
    testWidgets('shows 422 inline error on username', (tester) async {
      when(() => mockRepo.register(any())).thenThrow(
        const UnprocessableException({'userName': ['Username already taken']}),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: _i18nApp(const RegisterScreen()),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'myuser',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'password123',
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Username already taken'), findsOneWidget);
    });
  });
}
