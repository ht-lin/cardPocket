import 'package:drift/drift.dart';

// Single-row table. Use the fixed key "default" as the primary key.
class SyncMetaTable extends Table {
  TextColumn get key => text()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
