import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:card_pocket/features/cards/application/owned_cards_notifier.dart';
import 'package:card_pocket/features/cards/application/viewed_cards_notifier.dart';
import 'package:card_pocket/features/cards/domain/card_model.dart';
import 'package:card_pocket/features/cards/presentation/cards_screen.dart';

final _card1 = CardModel(
  id: 'c1',
  name: 'Costco',
  barcodeType: 'QR_CODE',
  barcodeContent: '12345',
  isOwner: true,
  updatedAt: DateTime(2026, 6, 1),
);

final _card2 = CardModel(
  id: 'c2',
  name: 'Shared Card',
  barcodeType: 'CODE_128',
  barcodeContent: 'xyz',
  isOwner: false,
  viewerNickname: 'My Starbucks',
  ownerUsername: 'alice',
  updatedAt: DateTime(2026, 6, 1),
);

Widget _buildTestApp({
  required CardsListState ownedState,
  required CardsListState viewedState,
}) {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const CardsScreen(),
    ),
    GoRoute(path: '/cards/scan', builder: (_, _) => const SizedBox()),
    GoRoute(
      path: '/cards/:id/barcode',
      builder: (_, _) => const SizedBox(),
    ),
  ]);

  return ProviderScope(
    overrides: [
      ownedCardsProvider.overrideWith(() => _FakeOwnedNotifier(ownedState)),
      viewedCardsProvider.overrideWith(() => _FakeViewedNotifier(viewedState)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _FakeOwnedNotifier extends OwnedCardsNotifier {
  _FakeOwnedNotifier(this._state);
  final CardsListState _state;

  @override
  Future<CardsListState> build() async => _state;
}

class _FakeViewedNotifier extends ViewedCardsNotifier {
  _FakeViewedNotifier(this._state);
  final CardsListState _state;

  @override
  Future<CardsListState> build() async => _state;
}

void main() {
  group('CardsScreen', () {
    testWidgets('shows section headers', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        ownedState: const CardsListState(),
        viewedState: const CardsListState(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Cards'), findsOneWidget);
      expect(find.text('Shared with Me'), findsOneWidget);
    });

    testWidgets('shows empty state when no owned cards', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        ownedState: const CardsListState(),
        viewedState: const CardsListState(),
      ));
      await tester.pumpAndSettle();

      expect(
        find.text('No cards yet, tap + to add your first'),
        findsOneWidget,
      );
    });

    testWidgets('renders owned card name in list', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        ownedState: CardsListState(
          items: [_card1],
          hasMore: false,
        ),
        viewedState: const CardsListState(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Costco'), findsOneWidget);
    });

    testWidgets('renders viewer nickname for shared card', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        ownedState: const CardsListState(hasMore: false),
        viewedState: CardsListState(
          items: [_card2],
          hasMore: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Starbucks (alice)'), findsOneWidget);
    });

    testWidgets('shows FAB', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        ownedState: const CardsListState(),
        viewedState: const CardsListState(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
