// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trash_card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrashCard {

 String get id; String get name; String get barcodeType; String get barcodeContent; DateTime get deletedAt; DateTime? get expiresAt;
/// Create a copy of TrashCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrashCardCopyWith<TrashCard> get copyWith => _$TrashCardCopyWithImpl<TrashCard>(this as TrashCard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrashCard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.barcodeType, barcodeType) || other.barcodeType == barcodeType)&&(identical(other.barcodeContent, barcodeContent) || other.barcodeContent == barcodeContent)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,barcodeType,barcodeContent,deletedAt,expiresAt);

@override
String toString() {
  return 'TrashCard(id: $id, name: $name, barcodeType: $barcodeType, barcodeContent: $barcodeContent, deletedAt: $deletedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $TrashCardCopyWith<$Res>  {
  factory $TrashCardCopyWith(TrashCard value, $Res Function(TrashCard) _then) = _$TrashCardCopyWithImpl;
@useResult
$Res call({
 String id, String name, String barcodeType, String barcodeContent, DateTime deletedAt, DateTime? expiresAt
});




}
/// @nodoc
class _$TrashCardCopyWithImpl<$Res>
    implements $TrashCardCopyWith<$Res> {
  _$TrashCardCopyWithImpl(this._self, this._then);

  final TrashCard _self;
  final $Res Function(TrashCard) _then;

/// Create a copy of TrashCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? barcodeType = null,Object? barcodeContent = null,Object? deletedAt = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,barcodeType: null == barcodeType ? _self.barcodeType : barcodeType // ignore: cast_nullable_to_non_nullable
as String,barcodeContent: null == barcodeContent ? _self.barcodeContent : barcodeContent // ignore: cast_nullable_to_non_nullable
as String,deletedAt: null == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrashCard].
extension TrashCardPatterns on TrashCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrashCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrashCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrashCard value)  $default,){
final _that = this;
switch (_that) {
case _TrashCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrashCard value)?  $default,){
final _that = this;
switch (_that) {
case _TrashCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String barcodeType,  String barcodeContent,  DateTime deletedAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrashCard() when $default != null:
return $default(_that.id,_that.name,_that.barcodeType,_that.barcodeContent,_that.deletedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String barcodeType,  String barcodeContent,  DateTime deletedAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _TrashCard():
return $default(_that.id,_that.name,_that.barcodeType,_that.barcodeContent,_that.deletedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String barcodeType,  String barcodeContent,  DateTime deletedAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _TrashCard() when $default != null:
return $default(_that.id,_that.name,_that.barcodeType,_that.barcodeContent,_that.deletedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _TrashCard implements TrashCard {
  const _TrashCard({required this.id, required this.name, required this.barcodeType, required this.barcodeContent, required this.deletedAt, this.expiresAt});
  

@override final  String id;
@override final  String name;
@override final  String barcodeType;
@override final  String barcodeContent;
@override final  DateTime deletedAt;
@override final  DateTime? expiresAt;

/// Create a copy of TrashCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrashCardCopyWith<_TrashCard> get copyWith => __$TrashCardCopyWithImpl<_TrashCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrashCard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.barcodeType, barcodeType) || other.barcodeType == barcodeType)&&(identical(other.barcodeContent, barcodeContent) || other.barcodeContent == barcodeContent)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,barcodeType,barcodeContent,deletedAt,expiresAt);

@override
String toString() {
  return 'TrashCard(id: $id, name: $name, barcodeType: $barcodeType, barcodeContent: $barcodeContent, deletedAt: $deletedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$TrashCardCopyWith<$Res> implements $TrashCardCopyWith<$Res> {
  factory _$TrashCardCopyWith(_TrashCard value, $Res Function(_TrashCard) _then) = __$TrashCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String barcodeType, String barcodeContent, DateTime deletedAt, DateTime? expiresAt
});




}
/// @nodoc
class __$TrashCardCopyWithImpl<$Res>
    implements _$TrashCardCopyWith<$Res> {
  __$TrashCardCopyWithImpl(this._self, this._then);

  final _TrashCard _self;
  final $Res Function(_TrashCard) _then;

/// Create a copy of TrashCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? barcodeType = null,Object? barcodeContent = null,Object? deletedAt = null,Object? expiresAt = freezed,}) {
  return _then(_TrashCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,barcodeType: null == barcodeType ? _self.barcodeType : barcodeType // ignore: cast_nullable_to_non_nullable
as String,barcodeContent: null == barcodeContent ? _self.barcodeContent : barcodeContent // ignore: cast_nullable_to_non_nullable
as String,deletedAt: null == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$TrashListState {

 List<TrashCard> get items; bool get isLoadingMore; bool get hasMore;
/// Create a copy of TrashListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrashListStateCopyWith<TrashListState> get copyWith => _$TrashListStateCopyWithImpl<TrashListState>(this as TrashListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrashListState&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),isLoadingMore,hasMore);

@override
String toString() {
  return 'TrashListState(items: $items, isLoadingMore: $isLoadingMore, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $TrashListStateCopyWith<$Res>  {
  factory $TrashListStateCopyWith(TrashListState value, $Res Function(TrashListState) _then) = _$TrashListStateCopyWithImpl;
@useResult
$Res call({
 List<TrashCard> items, bool isLoadingMore, bool hasMore
});




}
/// @nodoc
class _$TrashListStateCopyWithImpl<$Res>
    implements $TrashListStateCopyWith<$Res> {
  _$TrashListStateCopyWithImpl(this._self, this._then);

  final TrashListState _self;
  final $Res Function(TrashListState) _then;

/// Create a copy of TrashListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? isLoadingMore = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TrashCard>,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrashListState].
extension TrashListStatePatterns on TrashListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrashListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrashListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrashListState value)  $default,){
final _that = this;
switch (_that) {
case _TrashListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrashListState value)?  $default,){
final _that = this;
switch (_that) {
case _TrashListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TrashCard> items,  bool isLoadingMore,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrashListState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TrashCard> items,  bool isLoadingMore,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _TrashListState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TrashCard> items,  bool isLoadingMore,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _TrashListState() when $default != null:
return $default(_that.items,_that.isLoadingMore,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc


class _TrashListState implements TrashListState {
  const _TrashListState({final  List<TrashCard> items = const [], this.isLoadingMore = false, this.hasMore = true}): _items = items;
  

 final  List<TrashCard> _items;
@override@JsonKey() List<TrashCard> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  bool hasMore;

/// Create a copy of TrashListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrashListStateCopyWith<_TrashListState> get copyWith => __$TrashListStateCopyWithImpl<_TrashListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrashListState&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),isLoadingMore,hasMore);

@override
String toString() {
  return 'TrashListState(items: $items, isLoadingMore: $isLoadingMore, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$TrashListStateCopyWith<$Res> implements $TrashListStateCopyWith<$Res> {
  factory _$TrashListStateCopyWith(_TrashListState value, $Res Function(_TrashListState) _then) = __$TrashListStateCopyWithImpl;
@override @useResult
$Res call({
 List<TrashCard> items, bool isLoadingMore, bool hasMore
});




}
/// @nodoc
class __$TrashListStateCopyWithImpl<$Res>
    implements _$TrashListStateCopyWith<$Res> {
  __$TrashListStateCopyWithImpl(this._self, this._then);

  final _TrashListState _self;
  final $Res Function(_TrashListState) _then;

/// Create a copy of TrashListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? isLoadingMore = null,Object? hasMore = null,}) {
  return _then(_TrashListState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TrashCard>,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
