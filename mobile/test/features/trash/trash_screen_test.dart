import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:card_pocket/core/connectivity/is_offline_provider.dart';
import 'package:card_pocket/features/trash/application/trash_notifier.dart';
import 'package:card_pocket/features/trash/domain/trash_card_model.dart';
import 'package:card_pocket/features/trash/presentation/trash_screen.dart';

final _trashCard = TrashCard(
  id: 't1',
  name: 'Old Costco',
  barcodeType: 'QR_CODE',
  barcodeContent: '12345',
  deletedAt: DateTime.utc(2026, 6, 10),
);

class _FakeTrashNotifier extends TrashNotifier {
  _FakeTrashNotifier(this._state);
  final TrashListState _state;

  @override
  Future<TrashListState> build() async => _state;
}

Widget _buildTestApp({
  required TrashListState state,
  bool offline = false,
}) {
  return ProviderScope(
    overrides: [
      isOfflineProvider.overrideWith((ref) => Stream.value(offline)),
      trashProvider.overrideWith(() => _FakeTrashNotifier(state)),
    ],
    child: const MaterialApp(home: TrashScreen()),
  );
}

void main() {
  group('TrashScreen', () {
    testWidgets('renders trash card name and deleted date', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        state: TrashListState(items: [_trashCard], hasMore: false),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Old Costco'), findsOneWidget);
      expect(find.text('Deleted on 2026-06-10'), findsOneWidget);
    });

    testWidgets('shows empty state when trash is empty', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        state: const TrashListState(hasMore: false),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Trash is empty'), findsOneWidget);
    });

    testWidgets('shows offline message when offline', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        state: const TrashListState(hasMore: false),
        offline: true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Trash is unavailable offline'), findsOneWidget);
    });

    testWidgets('permanent delete opens a confirmation dialog',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        state: TrashListState(items: [_trashCard], hasMore: false),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete permanently'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('Permanently delete'), findsOneWidget);
    });
  });
}
