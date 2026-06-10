// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CardsTableTable extends CardsTable
    with TableInfo<$CardsTableTable, CardsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeTypeMeta = const VerificationMeta(
    'barcodeType',
  );
  @override
  late final GeneratedColumn<String> barcodeType = GeneratedColumn<String>(
    'barcode_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeContentMeta = const VerificationMeta(
    'barcodeContent',
  );
  @override
  late final GeneratedColumn<String> barcodeContent = GeneratedColumn<String>(
    'barcode_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOwnerMeta = const VerificationMeta(
    'isOwner',
  );
  @override
  late final GeneratedColumn<bool> isOwner = GeneratedColumn<bool>(
    'is_owner',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_owner" IN (0, 1))',
    ),
  );
  static const VerificationMeta _viewerNicknameMeta = const VerificationMeta(
    'viewerNickname',
  );
  @override
  late final GeneratedColumn<String> viewerNickname = GeneratedColumn<String>(
    'viewer_nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerUsernameMeta = const VerificationMeta(
    'ownerUsername',
  );
  @override
  late final GeneratedColumn<String> ownerUsername = GeneratedColumn<String>(
    'owner_username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    barcodeType,
    barcodeContent,
    isOwner,
    viewerNickname,
    ownerUsername,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('barcode_type')) {
      context.handle(
        _barcodeTypeMeta,
        barcodeType.isAcceptableOrUnknown(
          data['barcode_type']!,
          _barcodeTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_barcodeTypeMeta);
    }
    if (data.containsKey('barcode_content')) {
      context.handle(
        _barcodeContentMeta,
        barcodeContent.isAcceptableOrUnknown(
          data['barcode_content']!,
          _barcodeContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_barcodeContentMeta);
    }
    if (data.containsKey('is_owner')) {
      context.handle(
        _isOwnerMeta,
        isOwner.isAcceptableOrUnknown(data['is_owner']!, _isOwnerMeta),
      );
    } else if (isInserting) {
      context.missing(_isOwnerMeta);
    }
    if (data.containsKey('viewer_nickname')) {
      context.handle(
        _viewerNicknameMeta,
        viewerNickname.isAcceptableOrUnknown(
          data['viewer_nickname']!,
          _viewerNicknameMeta,
        ),
      );
    }
    if (data.containsKey('owner_username')) {
      context.handle(
        _ownerUsernameMeta,
        ownerUsername.isAcceptableOrUnknown(
          data['owner_username']!,
          _ownerUsernameMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      barcodeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode_type'],
      )!,
      barcodeContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode_content'],
      )!,
      isOwner: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_owner'],
      )!,
      viewerNickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}viewer_nickname'],
      ),
      ownerUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_username'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CardsTableTable createAlias(String alias) {
    return $CardsTableTable(attachedDatabase, alias);
  }
}

class CardsTableData extends DataClass implements Insertable<CardsTableData> {
  final String id;
  final String name;
  final String barcodeType;
  final String barcodeContent;
  final bool isOwner;
  final String? viewerNickname;
  final String? ownerUsername;
  final DateTime updatedAt;
  const CardsTableData({
    required this.id,
    required this.name,
    required this.barcodeType,
    required this.barcodeContent,
    required this.isOwner,
    this.viewerNickname,
    this.ownerUsername,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['barcode_type'] = Variable<String>(barcodeType);
    map['barcode_content'] = Variable<String>(barcodeContent);
    map['is_owner'] = Variable<bool>(isOwner);
    if (!nullToAbsent || viewerNickname != null) {
      map['viewer_nickname'] = Variable<String>(viewerNickname);
    }
    if (!nullToAbsent || ownerUsername != null) {
      map['owner_username'] = Variable<String>(ownerUsername);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CardsTableCompanion toCompanion(bool nullToAbsent) {
    return CardsTableCompanion(
      id: Value(id),
      name: Value(name),
      barcodeType: Value(barcodeType),
      barcodeContent: Value(barcodeContent),
      isOwner: Value(isOwner),
      viewerNickname: viewerNickname == null && nullToAbsent
          ? const Value.absent()
          : Value(viewerNickname),
      ownerUsername: ownerUsername == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUsername),
      updatedAt: Value(updatedAt),
    );
  }

  factory CardsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      barcodeType: serializer.fromJson<String>(json['barcodeType']),
      barcodeContent: serializer.fromJson<String>(json['barcodeContent']),
      isOwner: serializer.fromJson<bool>(json['isOwner']),
      viewerNickname: serializer.fromJson<String?>(json['viewerNickname']),
      ownerUsername: serializer.fromJson<String?>(json['ownerUsername']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'barcodeType': serializer.toJson<String>(barcodeType),
      'barcodeContent': serializer.toJson<String>(barcodeContent),
      'isOwner': serializer.toJson<bool>(isOwner),
      'viewerNickname': serializer.toJson<String?>(viewerNickname),
      'ownerUsername': serializer.toJson<String?>(ownerUsername),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CardsTableData copyWith({
    String? id,
    String? name,
    String? barcodeType,
    String? barcodeContent,
    bool? isOwner,
    Value<String?> viewerNickname = const Value.absent(),
    Value<String?> ownerUsername = const Value.absent(),
    DateTime? updatedAt,
  }) => CardsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    barcodeType: barcodeType ?? this.barcodeType,
    barcodeContent: barcodeContent ?? this.barcodeContent,
    isOwner: isOwner ?? this.isOwner,
    viewerNickname: viewerNickname.present
        ? viewerNickname.value
        : this.viewerNickname,
    ownerUsername: ownerUsername.present
        ? ownerUsername.value
        : this.ownerUsername,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CardsTableData copyWithCompanion(CardsTableCompanion data) {
    return CardsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      barcodeType: data.barcodeType.present
          ? data.barcodeType.value
          : this.barcodeType,
      barcodeContent: data.barcodeContent.present
          ? data.barcodeContent.value
          : this.barcodeContent,
      isOwner: data.isOwner.present ? data.isOwner.value : this.isOwner,
      viewerNickname: data.viewerNickname.present
          ? data.viewerNickname.value
          : this.viewerNickname,
      ownerUsername: data.ownerUsername.present
          ? data.ownerUsername.value
          : this.ownerUsername,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcodeType: $barcodeType, ')
          ..write('barcodeContent: $barcodeContent, ')
          ..write('isOwner: $isOwner, ')
          ..write('viewerNickname: $viewerNickname, ')
          ..write('ownerUsername: $ownerUsername, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    barcodeType,
    barcodeContent,
    isOwner,
    viewerNickname,
    ownerUsername,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.barcodeType == this.barcodeType &&
          other.barcodeContent == this.barcodeContent &&
          other.isOwner == this.isOwner &&
          other.viewerNickname == this.viewerNickname &&
          other.ownerUsername == this.ownerUsername &&
          other.updatedAt == this.updatedAt);
}

class CardsTableCompanion extends UpdateCompanion<CardsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> barcodeType;
  final Value<String> barcodeContent;
  final Value<bool> isOwner;
  final Value<String?> viewerNickname;
  final Value<String?> ownerUsername;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CardsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.barcodeType = const Value.absent(),
    this.barcodeContent = const Value.absent(),
    this.isOwner = const Value.absent(),
    this.viewerNickname = const Value.absent(),
    this.ownerUsername = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsTableCompanion.insert({
    required String id,
    required String name,
    required String barcodeType,
    required String barcodeContent,
    required bool isOwner,
    this.viewerNickname = const Value.absent(),
    this.ownerUsername = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       barcodeType = Value(barcodeType),
       barcodeContent = Value(barcodeContent),
       isOwner = Value(isOwner),
       updatedAt = Value(updatedAt);
  static Insertable<CardsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? barcodeType,
    Expression<String>? barcodeContent,
    Expression<bool>? isOwner,
    Expression<String>? viewerNickname,
    Expression<String>? ownerUsername,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (barcodeType != null) 'barcode_type': barcodeType,
      if (barcodeContent != null) 'barcode_content': barcodeContent,
      if (isOwner != null) 'is_owner': isOwner,
      if (viewerNickname != null) 'viewer_nickname': viewerNickname,
      if (ownerUsername != null) 'owner_username': ownerUsername,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? barcodeType,
    Value<String>? barcodeContent,
    Value<bool>? isOwner,
    Value<String?>? viewerNickname,
    Value<String?>? ownerUsername,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CardsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      barcodeType: barcodeType ?? this.barcodeType,
      barcodeContent: barcodeContent ?? this.barcodeContent,
      isOwner: isOwner ?? this.isOwner,
      viewerNickname: viewerNickname ?? this.viewerNickname,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (barcodeType.present) {
      map['barcode_type'] = Variable<String>(barcodeType.value);
    }
    if (barcodeContent.present) {
      map['barcode_content'] = Variable<String>(barcodeContent.value);
    }
    if (isOwner.present) {
      map['is_owner'] = Variable<bool>(isOwner.value);
    }
    if (viewerNickname.present) {
      map['viewer_nickname'] = Variable<String>(viewerNickname.value);
    }
    if (ownerUsername.present) {
      map['owner_username'] = Variable<String>(ownerUsername.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcodeType: $barcodeType, ')
          ..write('barcodeContent: $barcodeContent, ')
          ..write('isOwner: $isOwner, ')
          ..write('viewerNickname: $viewerNickname, ')
          ..write('ownerUsername: $ownerUsername, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTableTable extends SyncMetaTable
    with TableInfo<$SyncMetaTableTable, SyncMetaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, lastSyncAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
    );
  }

  @override
  $SyncMetaTableTable createAlias(String alias) {
    return $SyncMetaTableTable(attachedDatabase, alias);
  }
}

class SyncMetaTableData extends DataClass
    implements Insertable<SyncMetaTableData> {
  final String key;
  final DateTime? lastSyncAt;
  const SyncMetaTableData({required this.key, this.lastSyncAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    return map;
  }

  SyncMetaTableCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaTableCompanion(
      key: Value(key),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
    );
  }

  factory SyncMetaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaTableData(
      key: serializer.fromJson<String>(json['key']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
    };
  }

  SyncMetaTableData copyWith({
    String? key,
    Value<DateTime?> lastSyncAt = const Value.absent(),
  }) => SyncMetaTableData(
    key: key ?? this.key,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
  );
  SyncMetaTableData copyWithCompanion(SyncMetaTableCompanion data) {
    return SyncMetaTableData(
      key: data.key.present ? data.key.value : this.key,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaTableData(')
          ..write('key: $key, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, lastSyncAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaTableData &&
          other.key == this.key &&
          other.lastSyncAt == this.lastSyncAt);
}

class SyncMetaTableCompanion extends UpdateCompanion<SyncMetaTableData> {
  final Value<String> key;
  final Value<DateTime?> lastSyncAt;
  final Value<int> rowid;
  const SyncMetaTableCompanion({
    this.key = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaTableCompanion.insert({
    required String key,
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SyncMetaTableData> custom({
    Expression<String>? key,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaTableCompanion copyWith({
    Value<String>? key,
    Value<DateTime?>? lastSyncAt,
    Value<int>? rowid,
  }) {
    return SyncMetaTableCompanion(
      key: key ?? this.key,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaTableCompanion(')
          ..write('key: $key, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CardsTableTable cardsTable = $CardsTableTable(this);
  late final $SyncMetaTableTable syncMetaTable = $SyncMetaTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cardsTable,
    syncMetaTable,
  ];
}

typedef $$CardsTableTableCreateCompanionBuilder =
    CardsTableCompanion Function({
      required String id,
      required String name,
      required String barcodeType,
      required String barcodeContent,
      required bool isOwner,
      Value<String?> viewerNickname,
      Value<String?> ownerUsername,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CardsTableTableUpdateCompanionBuilder =
    CardsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> barcodeType,
      Value<String> barcodeContent,
      Value<bool> isOwner,
      Value<String?> viewerNickname,
      Value<String?> ownerUsername,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CardsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CardsTableTable> {
  $$CardsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcodeType => $composableBuilder(
    column: $table.barcodeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcodeContent => $composableBuilder(
    column: $table.barcodeContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOwner => $composableBuilder(
    column: $table.isOwner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewerNickname => $composableBuilder(
    column: $table.viewerNickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUsername => $composableBuilder(
    column: $table.ownerUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTableTable> {
  $$CardsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcodeType => $composableBuilder(
    column: $table.barcodeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcodeContent => $composableBuilder(
    column: $table.barcodeContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOwner => $composableBuilder(
    column: $table.isOwner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewerNickname => $composableBuilder(
    column: $table.viewerNickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUsername => $composableBuilder(
    column: $table.ownerUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTableTable> {
  $$CardsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get barcodeType => $composableBuilder(
    column: $table.barcodeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcodeContent => $composableBuilder(
    column: $table.barcodeContent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOwner =>
      $composableBuilder(column: $table.isOwner, builder: (column) => column);

  GeneratedColumn<String> get viewerNickname => $composableBuilder(
    column: $table.viewerNickname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerUsername => $composableBuilder(
    column: $table.ownerUsername,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CardsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTableTable,
          CardsTableData,
          $$CardsTableTableFilterComposer,
          $$CardsTableTableOrderingComposer,
          $$CardsTableTableAnnotationComposer,
          $$CardsTableTableCreateCompanionBuilder,
          $$CardsTableTableUpdateCompanionBuilder,
          (
            CardsTableData,
            BaseReferences<_$AppDatabase, $CardsTableTable, CardsTableData>,
          ),
          CardsTableData,
          PrefetchHooks Function()
        > {
  $$CardsTableTableTableManager(_$AppDatabase db, $CardsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> barcodeType = const Value.absent(),
                Value<String> barcodeContent = const Value.absent(),
                Value<bool> isOwner = const Value.absent(),
                Value<String?> viewerNickname = const Value.absent(),
                Value<String?> ownerUsername = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsTableCompanion(
                id: id,
                name: name,
                barcodeType: barcodeType,
                barcodeContent: barcodeContent,
                isOwner: isOwner,
                viewerNickname: viewerNickname,
                ownerUsername: ownerUsername,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String barcodeType,
                required String barcodeContent,
                required bool isOwner,
                Value<String?> viewerNickname = const Value.absent(),
                Value<String?> ownerUsername = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CardsTableCompanion.insert(
                id: id,
                name: name,
                barcodeType: barcodeType,
                barcodeContent: barcodeContent,
                isOwner: isOwner,
                viewerNickname: viewerNickname,
                ownerUsername: ownerUsername,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTableTable,
      CardsTableData,
      $$CardsTableTableFilterComposer,
      $$CardsTableTableOrderingComposer,
      $$CardsTableTableAnnotationComposer,
      $$CardsTableTableCreateCompanionBuilder,
      $$CardsTableTableUpdateCompanionBuilder,
      (
        CardsTableData,
        BaseReferences<_$AppDatabase, $CardsTableTable, CardsTableData>,
      ),
      CardsTableData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableTableCreateCompanionBuilder =
    SyncMetaTableCompanion Function({
      required String key,
      Value<DateTime?> lastSyncAt,
      Value<int> rowid,
    });
typedef $$SyncMetaTableTableUpdateCompanionBuilder =
    SyncMetaTableCompanion Function({
      Value<String> key,
      Value<DateTime?> lastSyncAt,
      Value<int> rowid,
    });

class $$SyncMetaTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );
}

class $$SyncMetaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTableTable,
          SyncMetaTableData,
          $$SyncMetaTableTableFilterComposer,
          $$SyncMetaTableTableOrderingComposer,
          $$SyncMetaTableTableAnnotationComposer,
          $$SyncMetaTableTableCreateCompanionBuilder,
          $$SyncMetaTableTableUpdateCompanionBuilder,
          (
            SyncMetaTableData,
            BaseReferences<
              _$AppDatabase,
              $SyncMetaTableTable,
              SyncMetaTableData
            >,
          ),
          SyncMetaTableData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableTableManager(_$AppDatabase db, $SyncMetaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaTableCompanion(
                key: key,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaTableCompanion.insert(
                key: key,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTableTable,
      SyncMetaTableData,
      $$SyncMetaTableTableFilterComposer,
      $$SyncMetaTableTableOrderingComposer,
      $$SyncMetaTableTableAnnotationComposer,
      $$SyncMetaTableTableCreateCompanionBuilder,
      $$SyncMetaTableTableUpdateCompanionBuilder,
      (
        SyncMetaTableData,
        BaseReferences<_$AppDatabase, $SyncMetaTableTable, SyncMetaTableData>,
      ),
      SyncMetaTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CardsTableTableTableManager get cardsTable =>
      $$CardsTableTableTableManager(_db, _db.cardsTable);
  $$SyncMetaTableTableTableManager get syncMetaTable =>
      $$SyncMetaTableTableTableManager(_db, _db.syncMetaTable);
}
