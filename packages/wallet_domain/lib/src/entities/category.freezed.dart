// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Category {

 String get id; String get householdId; CategoryKind get kind; String get name; String? get parentId;/// BR-040: daromad oy siljishi (−1, 0, 1); xarajatda doim 0.
 int get monthShift; String? get icon; String? get color; int get sortOrder; SystemCode? get systemCode; DateTime? get archivedAt; DateTime? get deletedAt; int get rowVersion;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Category;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.monthShift, _this.monthShift) || other.monthShift == _this.monthShift)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.systemCode, _this.systemCode) || other.systemCode == _this.systemCode)&&(identical(other.archivedAt, _this.archivedAt) || other.archivedAt == _this.archivedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as Category;
  return Object.hash(runtimeType,_this.id,_this.householdId,_this.kind,_this.name,_this.parentId,_this.monthShift,_this.icon,_this.color,_this.sortOrder,_this.systemCode,_this.archivedAt,_this.deletedAt,_this.rowVersion);
}

@override
String toString() {
  final _this = this as Category;
  return 'Category(id: ${_this.id}, householdId: ${_this.householdId}, kind: ${_this.kind}, name: ${_this.name}, parentId: ${_this.parentId}, monthShift: ${_this.monthShift}, icon: ${_this.icon}, color: ${_this.color}, sortOrder: ${_this.sortOrder}, systemCode: ${_this.systemCode}, archivedAt: ${_this.archivedAt}, deletedAt: ${_this.deletedAt}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 String id, String householdId, CategoryKind kind, String name, String? parentId, int monthShift, String? icon, String? color, int sortOrder, SystemCode? systemCode, DateTime? archivedAt, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? kind = null,Object? name = null,Object? parentId = freezed,Object? monthShift = null,Object? icon = freezed,Object? color = freezed,Object? sortOrder = null,Object? systemCode = freezed,Object? archivedAt = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CategoryKind,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,monthShift: null == monthShift ? _self.monthShift : monthShift // ignore: cast_nullable_to_non_nullable
as int,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,systemCode: freezed == systemCode ? _self.systemCode : systemCode // ignore: cast_nullable_to_non_nullable
as SystemCode?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String householdId,  CategoryKind kind,  String name,  String? parentId,  int monthShift,  String? icon,  String? color,  int sortOrder,  SystemCode? systemCode,  DateTime? archivedAt,  DateTime? deletedAt,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.householdId,_that.kind,_that.name,_that.parentId,_that.monthShift,_that.icon,_that.color,_that.sortOrder,_that.systemCode,_that.archivedAt,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String householdId,  CategoryKind kind,  String name,  String? parentId,  int monthShift,  String? icon,  String? color,  int sortOrder,  SystemCode? systemCode,  DateTime? archivedAt,  DateTime? deletedAt,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _Category():
return $default(_that.id,_that.householdId,_that.kind,_that.name,_that.parentId,_that.monthShift,_that.icon,_that.color,_that.sortOrder,_that.systemCode,_that.archivedAt,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String householdId,  CategoryKind kind,  String name,  String? parentId,  int monthShift,  String? icon,  String? color,  int sortOrder,  SystemCode? systemCode,  DateTime? archivedAt,  DateTime? deletedAt,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.householdId,_that.kind,_that.name,_that.parentId,_that.monthShift,_that.icon,_that.color,_that.sortOrder,_that.systemCode,_that.archivedAt,_that.deletedAt,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _Category extends Category {
  const _Category({required this.id, required this.householdId, required this.kind, required this.name, this.parentId, this.monthShift = 0, this.icon, this.color, this.sortOrder = 0, this.systemCode, this.archivedAt, this.deletedAt, this.rowVersion = 0}): super._();
  

@override final  String id;
@override final  String householdId;
@override final  CategoryKind kind;
@override final  String name;
@override final  String? parentId;
/// BR-040: daromad oy siljishi (−1, 0, 1); xarajatda doim 0.
@override@JsonKey() final  int monthShift;
@override final  String? icon;
@override final  String? color;
@override@JsonKey() final  int sortOrder;
@override final  SystemCode? systemCode;
@override final  DateTime? archivedAt;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int rowVersion;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.monthShift, monthShift) || other.monthShift == monthShift)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.systemCode, systemCode) || other.systemCode == systemCode)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,householdId,kind,name,parentId,monthShift,icon,color,sortOrder,systemCode,archivedAt,deletedAt,rowVersion);
}

@override
String toString() {
    return 'Category(id: $id, householdId: $householdId, kind: $kind, name: $name, parentId: $parentId, monthShift: $monthShift, icon: $icon, color: $color, sortOrder: $sortOrder, systemCode: $systemCode, archivedAt: $archivedAt, deletedAt: $deletedAt, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String householdId, CategoryKind kind, String name, String? parentId, int monthShift, String? icon, String? color, int sortOrder, SystemCode? systemCode, DateTime? archivedAt, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? kind = null,Object? name = null,Object? parentId = freezed,Object? monthShift = null,Object? icon = freezed,Object? color = freezed,Object? sortOrder = null,Object? systemCode = freezed,Object? archivedAt = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(_Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CategoryKind,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,monthShift: null == monthShift ? _self.monthShift : monthShift // ignore: cast_nullable_to_non_nullable
as int,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,systemCode: freezed == systemCode ? _self.systemCode : systemCode // ignore: cast_nullable_to_non_nullable
as SystemCode?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
