import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/cards_table.dart';
import 'tables/sync_meta_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CardsTable, SyncMetaTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(cardsTable, cardsTable.shareId);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'cardpocket');
  }

  Future<void> upsertCards(List<CardsTableCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(cardsTable, rows));
  }

  Future<void> updateViewerNickname(String cardId, String? nickname) =>
      (update(cardsTable)..where((t) => t.id.equals(cardId)))
          .write(CardsTableCompanion(viewerNickname: Value(nickname)));

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

  Future<List<CardsTableData>> searchCards(
    String query, {
    int limit = 200,
  }) {
    // Escape LIKE wildcards so `%` and `_` match literally, mirroring the
    // backend contract (GET /api/cards?q=). Backslash is the escape char.
    final escaped = query
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_')
        .toLowerCase();
    return (select(cardsTable)
          ..where((t) => t.name.lower().like('%$escaped%', escapeChar: r'\'))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit))
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

  Future<void> clearAllData() async {
    await delete(cardsTable).go();
    await delete(syncMetaTable).go();
  }
}
