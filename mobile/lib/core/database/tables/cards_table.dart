import 'package:drift/drift.dart';

class CardsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get barcodeType => text()();
  TextColumn get barcodeContent => text()();
  BoolColumn get isOwner => boolean()();
  TextColumn get shareId => text().nullable()();
  TextColumn get viewerNickname => text().nullable()();
  TextColumn get ownerUsername => text().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
