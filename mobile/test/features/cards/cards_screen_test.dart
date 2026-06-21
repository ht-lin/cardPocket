import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:card_pocket/features/cards/application/cards_search_notifier.dart';
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

final _expiredCard = CardModel(
  id: 'c3',
  name: 'Expired Card',
  barcodeType: 'QR_CODE',
  barcodeContent: '999',
  isOwner: true,
  expiresAt: DateTime(2020, 1, 1),
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

final _coloredCard = CardModel(
  id: 'c4',
  name: 'Colored Card',
  barcodeType: 'QR_CODE',
  barcodeContent: '777',
  isOwner: true,
  color: '#FF5733',
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

class _FakeSearchNotifier extends CardsSearchNotifier {
  _FakeSearchNotifier(this._state);
  final CardsSearchState _state;

  @override
  Future<CardsSearchState> build() async => _state;

  @override
  Future<void> search(String query) async {}
}

Widget _buildSearchTestApp({required CardsSearchState searchState}) {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => const CardsScreen()),
    GoRoute(path: '/cards/scan', builder: (_, _) => const SizedBox()),
    GoRoute(path: '/cards/:id/barcode', builder: (_, _) => const SizedBox()),
  ]);

  return ProviderScope(
    overrides: [
      ownedCardsProvider
          .overrideWith(() => _FakeOwnedNotifier(const CardsListState())),
      viewedCardsProvider
          .overrideWith(() => _FakeViewedNotifier(const CardsListState())),
      cardsSearchProvider.overrideWith(() => _FakeSearchNotifier(searchState)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
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

    testWidgets('shows Expired badge for an expired card', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        ownedState: CardsListState(items: [_expiredCard], hasMore: false),
        viewedState: const CardsListState(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Expired Card'), findsOneWidget);
      expect(find.text('Expired'), findsOneWidget);
    });

    testWidgets('shows no Expired badge for a non-expired card',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        ownedState: CardsListState(items: [_card1], hasMore: false),
        viewedState: const CardsListState(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Expired'), findsNothing);
    });

    testWidgets('applies custom color as the tile background', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        ownedState: CardsListState(items: [_coloredCard], hasMore: false),
        viewedState: const CardsListState(),
      ));
      await tester.pumpAndSettle();

      final tile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('Colored Card'),
          matching: find.byType(ListTile),
        ),
      );
      expect(tile.tileColor, const Color(0xFFFF5733));
    });

    testWidgets('leaves tile background unset when card has no color',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        ownedState: CardsListState(items: [_card1], hasMore: false),
        viewedState: const CardsListState(),
      ));
      await tester.pumpAndSettle();

      final tile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('Costco'),
          matching: find.byType(ListTile),
        ),
      );
      expect(tile.tileColor, isNull);
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

  group('CardsScreen search', () {
    testWidgets('typing a query shows merged results and hides sections',
        (tester) async {
      await tester.pumpWidget(_buildSearchTestApp(
        searchState: CardsSearchState(results: [_card1, _card2], query: 'c'),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'c');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Costco'), findsOneWidget);
      expect(find.text('My Starbucks (alice)'), findsOneWidget);
      expect(find.text('My Cards'), findsNothing);
      expect(find.text('Shared with Me'), findsNothing);
    });

    testWidgets('shows empty state when no cards match', (tester) async {
      await tester.pumpWidget(_buildSearchTestApp(
        searchState: const CardsSearchState(query: 'zzz'),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.textContaining('No cards match'), findsOneWidget);
    });

    testWidgets('clearing the query restores the browse sections',
        (tester) async {
      await tester.pumpWidget(_buildSearchTestApp(
        searchState: CardsSearchState(results: [_card1], query: 'c'),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'c');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('My Cards'), findsNothing);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('My Cards'), findsOneWidget);
      expect(find.text('Shared with Me'), findsOneWidget);
    });
  });
}
