import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/cards_table.dart';
import 'tables/sync_meta_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CardsTable, SyncMetaTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'cardpocket');
  }

  Future<void> upsertCards(List<CardsTableCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(cardsTable, rows));
  }

  Future<void> deleteCardsByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    await (delete(cardsTable)..where((t) => t.id.isIn(ids))).go();
  }

  Future<List<CardsTableData>> getOwnedCards({
    required int offset,
    int limit = 20,
  }) {
    return (select(cardsTable)
          ..where((t) => t.isOwner.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<CardsTableData>> getViewedCards({
    required int offset,
    int limit = 20,
  }) {
    return (select(cardsTable)
          ..where((t) => t.isOwner.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<DateTime?> getLastSyncAt() async {
    final row = await (select(syncMetaTable)
          ..where((t) => t.key.equals('default')))
        .getSingleOrNull();
    return row?.lastSyncAt;
  }

  Future<void> setLastSyncAt(DateTime dt) {
    return into(syncMetaTable).insertOnConflictUpdate(
      SyncMetaTableCompanion.insert(
        key: 'default',
        lastSyncAt: Value(dt),
      ),
    );
  }
}
