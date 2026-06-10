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

  // driftDatabase() resolves the platform path automatically and opens the
  // database in a background isolate on native platforms.
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'cardpocket');
  }
}
