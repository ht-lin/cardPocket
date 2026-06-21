// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CardModel {

 String get id; String get name; String get barcodeType; String get barcodeContent; bool get isOwner; String? get shareId; String? get viewerNickname; String? get ownerUsername; DateTime? get expiresAt; String? get color; DateTime get updatedAt;
/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardModelCopyWith<CardModel> get copyWith => _$CardModelCopyWithImpl<CardModel>(this as CardModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.barcodeType, barcodeType) || other.barcodeType == barcodeType)&&(identical(other.barcodeContent, barcodeContent) || other.barcodeContent == barcodeContent)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.viewerNickname, viewerNickname) || other.viewerNickname == viewerNickname)&&(identical(other.ownerUsername, ownerUsername) || other.ownerUsername == ownerUsername)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.color, color) || other.color == color)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,barcodeType,barcodeContent,isOwner,shareId,viewerNickname,ownerUsername,expiresAt,color,updatedAt);

@override
String toString() {
  return 'CardModel(id: $id, name: $name, barcodeType: $barcodeType, barcodeContent: $barcodeContent, isOwner: $isOwner, shareId: $shareId, viewerNickname: $viewerNickname, ownerUsername: $ownerUsername, expiresAt: $expiresAt, color: $color, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CardModelCopyWith<$Res>  {
  factory $CardModelCopyWith(CardModel value, $Res Function(CardModel) _then) = _$CardModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String barcodeType, String barcodeContent, bool isOwner, String? shareId, String? viewerNickname, String? ownerUsername, DateTime? expiresAt, String? color, DateTime updatedAt
});




}
/// @nodoc
class _$CardModelCopyWithImpl<$Res>
    implements $CardModelCopyWith<$Res> {
  _$CardModelCopyWithImpl(this._self, this._then);

  final CardModel _self;
  final $Res Function(CardModel) _then;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? barcodeType = null,Object? barcodeContent = null,Object? isOwner = null,Object? shareId = freezed,Object? viewerNickname = freezed,Object? ownerUsername = freezed,Object? expiresAt = freezed,Object? color = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,barcodeType: null == barcodeType ? _self.barcodeType : barcodeType // ignore: cast_nullable_to_non_nullable
as String,barcodeContent: null == barcodeContent ? _self.barcodeContent : barcodeContent // ignore: cast_nullable_to_non_nullable
as String,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,shareId: freezed == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as String?,viewerNickname: freezed == viewerNickname ? _self.viewerNickname : viewerNickname // ignore: cast_nullable_to_non_nullable
as String?,ownerUsername: freezed == ownerUsername ? _self.ownerUsername : ownerUsername // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CardModel].
extension CardModelPatterns on CardModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardModel value)  $default,){
final _that = this;
switch (_that) {
case _CardModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardModel value)?  $default,){
final _that = this;
switch (_that) {
case _CardModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String barcodeType,  String barcodeContent,  bool isOwner,  String? shareId,  String? viewerNickname,  String? ownerUsername,  DateTime? expiresAt,  String? color,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardModel() when $default != null:
return $default(_that.id,_that.name,_that.barcodeType,_that.barcodeContent,_that.isOwner,_that.shareId,_that.viewerNickname,_that.ownerUsername,_that.expiresAt,_that.color,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String barcodeType,  String barcodeContent,  bool isOwner,  String? shareId,  String? viewerNickname,  String? ownerUsername,  DateTime? expiresAt,  String? color,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CardModel():
return $default(_that.id,_that.name,_that.barcodeType,_that.barcodeContent,_that.isOwner,_that.shareId,_that.viewerNickname,_that.ownerUsername,_that.expiresAt,_that.color,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String barcodeType,  String barcodeContent,  bool isOwner,  String? shareId,  String? viewerNickname,  String? ownerUsername,  DateTime? expiresAt,  String? color,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CardModel() when $default != null:
return $default(_that.id,_that.name,_that.barcodeType,_that.barcodeContent,_that.isOwner,_that.shareId,_that.viewerNickname,_that.ownerUsername,_that.expiresAt,_that.color,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CardModel implements CardModel {
  const _CardModel({required this.id, required this.name, required this.barcodeType, required this.barcodeContent, required this.isOwner, this.shareId, this.viewerNickname, this.ownerUsername, this.expiresAt, this.color, required this.updatedAt});
  

@override final  String id;
@override final  String name;
@override final  String barcodeType;
@override final  String barcodeContent;
@override final  bool isOwner;
@override final  String? shareId;
@override final  String? viewerNickname;
@override final  String? ownerUsername;
@override final  DateTime? expiresAt;
@override final  String? color;
@override final  DateTime updatedAt;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardModelCopyWith<_CardModel> get copyWith => __$CardModelCopyWithImpl<_CardModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.barcodeType, barcodeType) || other.barcodeType == barcodeType)&&(identical(other.barcodeContent, barcodeContent) || other.barcodeContent == barcodeContent)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.viewerNickname, viewerNickname) || other.viewerNickname == viewerNickname)&&(identical(other.ownerUsername, ownerUsername) || other.ownerUsername == ownerUsername)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.color, color) || other.color == color)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,barcodeType,barcodeContent,isOwner,shareId,viewerNickname,ownerUsername,expiresAt,color,updatedAt);

@override
String toString() {
  return 'CardModel(id: $id, name: $name, barcodeType: $barcodeType, barcodeContent: $barcodeContent, isOwner: $isOwner, shareId: $shareId, viewerNickname: $viewerNickname, ownerUsername: $ownerUsername, expiresAt: $expiresAt, color: $color, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CardModelCopyWith<$Res> implements $CardModelCopyWith<$Res> {
  factory _$CardModelCopyWith(_CardModel value, $Res Function(_CardModel) _then) = __$CardModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String barcodeType, String barcodeContent, bool isOwner, String? shareId, String? viewerNickname, String? ownerUsername, DateTime? expiresAt, String? color, DateTime updatedAt
});




}
/// @nodoc
class __$CardModelCopyWithImpl<$Res>
    implements _$CardModelCopyWith<$Res> {
  __$CardModelCopyWithImpl(this._self, this._then);

  final _CardModel _self;
  final $Res Function(_CardModel) _then;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? barcodeType = null,Object? barcodeContent = null,Object? isOwner = null,Object? shareId = freezed,Object? viewerNickname = freezed,Object? ownerUsername = freezed,Object? expiresAt = freezed,Object? color = freezed,Object? updatedAt = null,}) {
  return _then(_CardModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,barcodeType: null == barcodeType ? _self.barcodeType : barcodeType // ignore: cast_nullable_to_non_nullable
as String,barcodeContent: null == barcodeContent ? _self.barcodeContent : barcodeContent // ignore: cast_nullable_to_non_nullable
as String,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,shareId: freezed == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as String?,viewerNickname: freezed == viewerNickname ? _self.viewerNickname : viewerNickname // ignore: cast_nullable_to_non_nullable
as String?,ownerUsername: freezed == ownerUsername ? _self.ownerUsername : ownerUsername // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$CardsListState {

 List<CardModel> get items; bool get isLoadingMore; bool get hasMore;
/// Create a copy of CardsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsListStateCopyWith<CardsListState> get copyWith => _$CardsListStateCopyWithImpl<CardsListState>(this as CardsListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsListState&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),isLoadingMore,hasMore);

@override
String toString() {
  return 'CardsListState(items: $items, isLoadingMore: $isLoadingMore, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $CardsListStateCopyWith<$Res>  {
  factory $CardsListStateCopyWith(CardsListState value, $Res Function(CardsListState) _then) = _$CardsListStateCopyWithImpl;
@useResult
$Res call({
 List<CardModel> items, bool isLoadingMore, bool hasMore
});




}
/// @nodoc
class _$CardsListStateCopyWithImpl<$Res>
    implements $CardsListStateCopyWith<$Res> {
  _$CardsListStateCopyWithImpl(this._self, this._then);

  final CardsListState _self;
  final $Res Function(CardsListState) _then;

/// Create a copy of CardsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? isLoadingMore = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CardModel>,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CardsListState].
extension CardsListStatePatterns on CardsListState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardsListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardsListState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardsListState value)  $default,){
final _that = this;
switch (_that) {
case _CardsListState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardsListState value)?  $default,){
final _that = this;
switch (_that) {
case _CardsListState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CardModel> items,  bool isLoadingMore,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardsListState() when $default != null:
return $default(_that.items,_that.isLoadingMore,_that.hasMore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CardModel> items,  bool isLoadingMore,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _CardsListState():
return $default(_that.items,_that.isLoadingMore,_that.hasMore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CardModel> items,  bool isLoadingMore,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _CardsListState() when $default != null:
return $default(_that.items,_that.isLoadingMore,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc


class _CardsListState implements CardsListState {
  const _CardsListState({final  List<CardModel> items = const [], this.isLoadingMore = false, this.hasMore = true}): _items = items;
  

 final  List<CardModel> _items;
@override@JsonKey() List<CardModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  bool hasMore;

/// Create a copy of CardsListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardsListStateCopyWith<_CardsListState> get copyWith => __$CardsListStateCopyWithImpl<_CardsListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardsListState&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),isLoadingMore,hasMore);

@override
String toString() {
  return 'CardsListState(items: $items, isLoadingMore: $isLoadingMore, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$CardsListStateCopyWith<$Res> implements $CardsListStateCopyWith<$Res> {
  factory _$CardsListStateCopyWith(_CardsListState value, $Res Function(_CardsListState) _then) = __$CardsListStateCopyWithImpl;
@override @useResult
$Res call({
 List<CardModel> items, bool isLoadingMore, bool hasMore
});




}
/// @nodoc
class __$CardsListStateCopyWithImpl<$Res>
    implements _$CardsListStateCopyWith<$Res> {
  __$CardsListStateCopyWithImpl(this._self, this._then);

  final _CardsListState _self;
  final $Res Function(_CardsListState) _then;

/// Create a copy of CardsListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? isLoadingMore = null,Object? hasMore = null,}) {
  return _then(_CardsListState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CardModel>,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$CardsSearchState {

 List<CardModel> get results; bool get fromRemote; String get query;
/// Create a copy of CardsSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsSearchStateCopyWith<CardsSearchState> get copyWith => _$CardsSearchStateCopyWithImpl<CardsSearchState>(this as CardsSearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsSearchState&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.fromRemote, fromRemote) || other.fromRemote == fromRemote)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results),fromRemote,query);

@override
String toString() {
  return 'CardsSearchState(results: $results, fromRemote: $fromRemote, query: $query)';
}


}

/// @nodoc
abstract mixin class $CardsSearchStateCopyWith<$Res>  {
  factory $CardsSearchStateCopyWith(CardsSearchState value, $Res Function(CardsSearchState) _then) = _$CardsSearchStateCopyWithImpl;
@useResult
$Res call({
 List<CardModel> results, bool fromRemote, String query
});




}
/// @nodoc
class _$CardsSearchStateCopyWithImpl<$Res>
    implements $CardsSearchStateCopyWith<$Res> {
  _$CardsSearchStateCopyWithImpl(this._self, this._then);

  final CardsSearchState _self;
  final $Res Function(CardsSearchState) _then;

/// Create a copy of CardsSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? fromRemote = null,Object? query = null,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<CardModel>,fromRemote: null == fromRemote ? _self.fromRemote : fromRemote // ignore: cast_nullable_to_non_nullable
as bool,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CardsSearchState].
extension CardsSearchStatePatterns on CardsSearchState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardsSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardsSearchState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardsSearchState value)  $default,){
final _that = this;
switch (_that) {
case _CardsSearchState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardsSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _CardsSearchState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CardModel> results,  bool fromRemote,  String query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardsSearchState() when $default != null:
return $default(_that.results,_that.fromRemote,_that.query);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CardModel> results,  bool fromRemote,  String query)  $default,) {final _that = this;
switch (_that) {
case _CardsSearchState():
return $default(_that.results,_that.fromRemote,_that.query);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CardModel> results,  bool fromRemote,  String query)?  $default,) {final _that = this;
switch (_that) {
case _CardsSearchState() when $default != null:
return $default(_that.results,_that.fromRemote,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _CardsSearchState implements CardsSearchState {
  const _CardsSearchState({final  List<CardModel> results = const [], this.fromRemote = false, this.query = ''}): _results = results;
  

 final  List<CardModel> _results;
@override@JsonKey() List<CardModel> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  bool fromRemote;
@override@JsonKey() final  String query;

/// Create a copy of CardsSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardsSearchStateCopyWith<_CardsSearchState> get copyWith => __$CardsSearchStateCopyWithImpl<_CardsSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardsSearchState&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.fromRemote, fromRemote) || other.fromRemote == fromRemote)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),fromRemote,query);

@override
String toString() {
  return 'CardsSearchState(results: $results, fromRemote: $fromRemote, query: $query)';
}


}

/// @nodoc
abstract mixin class _$CardsSearchStateCopyWith<$Res> implements $CardsSearchStateCopyWith<$Res> {
  factory _$CardsSearchStateCopyWith(_CardsSearchState value, $Res Function(_CardsSearchState) _then) = __$CardsSearchStateCopyWithImpl;
@override @useResult
$Res call({
 List<CardModel> results, bool fromRemote, String query
});




}
/// @nodoc
class __$CardsSearchStateCopyWithImpl<$Res>
    implements _$CardsSearchStateCopyWith<$Res> {
  __$CardsSearchStateCopyWithImpl(this._self, this._then);

  final _CardsSearchState _self;
  final $Res Function(_CardsSearchState) _then;

/// Create a copy of CardsSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? fromRemote = null,Object? query = null,}) {
  return _then(_CardsSearchState(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<CardModel>,fromRemote: null == fromRemote ? _self.fromRemote : fromRemote // ignore: cast_nullable_to_non_nullable
as bool,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
