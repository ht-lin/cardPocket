// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_share_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CardShareModel {

 String get id; String get viewerUserId; String get viewerUserName; String? get viewerNickname; DateTime get createdAt;
/// Create a copy of CardShareModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardShareModelCopyWith<CardShareModel> get copyWith => _$CardShareModelCopyWithImpl<CardShareModel>(this as CardShareModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardShareModel&&(identical(other.id, id) || other.id == id)&&(identical(other.viewerUserId, viewerUserId) || other.viewerUserId == viewerUserId)&&(identical(other.viewerUserName, viewerUserName) || other.viewerUserName == viewerUserName)&&(identical(other.viewerNickname, viewerNickname) || other.viewerNickname == viewerNickname)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,viewerUserId,viewerUserName,viewerNickname,createdAt);

@override
String toString() {
  return 'CardShareModel(id: $id, viewerUserId: $viewerUserId, viewerUserName: $viewerUserName, viewerNickname: $viewerNickname, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CardShareModelCopyWith<$Res>  {
  factory $CardShareModelCopyWith(CardShareModel value, $Res Function(CardShareModel) _then) = _$CardShareModelCopyWithImpl;
@useResult
$Res call({
 String id, String viewerUserId, String viewerUserName, String? viewerNickname, DateTime createdAt
});




}
/// @nodoc
class _$CardShareModelCopyWithImpl<$Res>
    implements $CardShareModelCopyWith<$Res> {
  _$CardShareModelCopyWithImpl(this._self, this._then);

  final CardShareModel _self;
  final $Res Function(CardShareModel) _then;

/// Create a copy of CardShareModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? viewerUserId = null,Object? viewerUserName = null,Object? viewerNickname = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,viewerUserId: null == viewerUserId ? _self.viewerUserId : viewerUserId // ignore: cast_nullable_to_non_nullable
as String,viewerUserName: null == viewerUserName ? _self.viewerUserName : viewerUserName // ignore: cast_nullable_to_non_nullable
as String,viewerNickname: freezed == viewerNickname ? _self.viewerNickname : viewerNickname // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CardShareModel].
extension CardShareModelPatterns on CardShareModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardShareModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardShareModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardShareModel value)  $default,){
final _that = this;
switch (_that) {
case _CardShareModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardShareModel value)?  $default,){
final _that = this;
switch (_that) {
case _CardShareModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String viewerUserId,  String viewerUserName,  String? viewerNickname,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardShareModel() when $default != null:
return $default(_that.id,_that.viewerUserId,_that.viewerUserName,_that.viewerNickname,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String viewerUserId,  String viewerUserName,  String? viewerNickname,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CardShareModel():
return $default(_that.id,_that.viewerUserId,_that.viewerUserName,_that.viewerNickname,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String viewerUserId,  String viewerUserName,  String? viewerNickname,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CardShareModel() when $default != null:
return $default(_that.id,_that.viewerUserId,_that.viewerUserName,_that.viewerNickname,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _CardShareModel implements CardShareModel {
  const _CardShareModel({required this.id, required this.viewerUserId, required this.viewerUserName, this.viewerNickname, required this.createdAt});
  

@override final  String id;
@override final  String viewerUserId;
@override final  String viewerUserName;
@override final  String? viewerNickname;
@override final  DateTime createdAt;

/// Create a copy of CardShareModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardShareModelCopyWith<_CardShareModel> get copyWith => __$CardShareModelCopyWithImpl<_CardShareModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardShareModel&&(identical(other.id, id) || other.id == id)&&(identical(other.viewerUserId, viewerUserId) || other.viewerUserId == viewerUserId)&&(identical(other.viewerUserName, viewerUserName) || other.viewerUserName == viewerUserName)&&(identical(other.viewerNickname, viewerNickname) || other.viewerNickname == viewerNickname)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,viewerUserId,viewerUserName,viewerNickname,createdAt);

@override
String toString() {
  return 'CardShareModel(id: $id, viewerUserId: $viewerUserId, viewerUserName: $viewerUserName, viewerNickname: $viewerNickname, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CardShareModelCopyWith<$Res> implements $CardShareModelCopyWith<$Res> {
  factory _$CardShareModelCopyWith(_CardShareModel value, $Res Function(_CardShareModel) _then) = __$CardShareModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String viewerUserId, String viewerUserName, String? viewerNickname, DateTime createdAt
});




}
/// @nodoc
class __$CardShareModelCopyWithImpl<$Res>
    implements _$CardShareModelCopyWith<$Res> {
  __$CardShareModelCopyWithImpl(this._self, this._then);

  final _CardShareModel _self;
  final $Res Function(_CardShareModel) _then;

/// Create a copy of CardShareModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? viewerUserId = null,Object? viewerUserName = null,Object? viewerNickname = freezed,Object? createdAt = null,}) {
  return _then(_CardShareModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,viewerUserId: null == viewerUserId ? _self.viewerUserId : viewerUserId // ignore: cast_nullable_to_non_nullable
as String,viewerUserName: null == viewerUserName ? _self.viewerUserName : viewerUserName // ignore: cast_nullable_to_non_nullable
as String,viewerNickname: freezed == viewerNickname ? _self.viewerNickname : viewerNickname // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
