// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Account {

 String get id; String get householdId; String get name; AccountType get type; Money get openingBalance; LocalDate? get openingDate; String? get icon; String? get color; int get sortOrder; DateTime? get archivedAt; DateTime? get deletedAt; int get rowVersion;
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountCopyWith<Account> get copyWith => _$AccountCopyWithImpl<Account>(this as Account, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Account;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Account&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.openingBalance, _this.openingBalance) || other.openingBalance == _this.openingBalance)&&(identical(other.openingDate, _this.openingDate) || other.openingDate == _this.openingDate)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.archivedAt, _this.archivedAt) || other.archivedAt == _this.archivedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as Account;
  return Object.hash(runtimeType,_this.id,_this.householdId,_this.name,_this.type,_this.openingBalance,_this.openingDate,_this.icon,_this.color,_this.sortOrder,_this.archivedAt,_this.deletedAt,_this.rowVersion);
}

@override
String toString() {
  final _this = this as Account;
  return 'Account(id: ${_this.id}, householdId: ${_this.householdId}, name: ${_this.name}, type: ${_this.type}, openingBalance: ${_this.openingBalance}, openingDate: ${_this.openingDate}, icon: ${_this.icon}, color: ${_this.color}, sortOrder: ${_this.sortOrder}, archivedAt: ${_this.archivedAt}, deletedAt: ${_this.deletedAt}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res>  {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) = _$AccountCopyWithImpl;
@useResult
$Res call({
 String id, String householdId, String name, AccountType type, Money openingBalance, LocalDate? openingDate, String? icon, String? color, int sortOrder, DateTime? archivedAt, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class _$AccountCopyWithImpl<$Res>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? name = null,Object? type = null,Object? openingBalance = null,Object? openingDate = freezed,Object? icon = freezed,Object? color = freezed,Object? sortOrder = null,Object? archivedAt = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(Account(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,openingBalance: null == openingBalance ? _self.openingBalance : openingBalance // ignore: cast_nullable_to_non_nullable
as Money,openingDate: freezed == openingDate ? _self.openingDate : openingDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Account value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Account value)  $default,){
final _that = this;
switch (_that) {
case _Account():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Account value)?  $default,){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String householdId,  String name,  AccountType type,  Money openingBalance,  LocalDate? openingDate,  String? icon,  String? color,  int sortOrder,  DateTime? archivedAt,  DateTime? deletedAt,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.householdId,_that.name,_that.type,_that.openingBalance,_that.openingDate,_that.icon,_that.color,_that.sortOrder,_that.archivedAt,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String householdId,  String name,  AccountType type,  Money openingBalance,  LocalDate? openingDate,  String? icon,  String? color,  int sortOrder,  DateTime? archivedAt,  DateTime? deletedAt,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _Account():
return $default(_that.id,_that.householdId,_that.name,_that.type,_that.openingBalance,_that.openingDate,_that.icon,_that.color,_that.sortOrder,_that.archivedAt,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String householdId,  String name,  AccountType type,  Money openingBalance,  LocalDate? openingDate,  String? icon,  String? color,  int sortOrder,  DateTime? archivedAt,  DateTime? deletedAt,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.householdId,_that.name,_that.type,_that.openingBalance,_that.openingDate,_that.icon,_that.color,_that.sortOrder,_that.archivedAt,_that.deletedAt,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _Account extends Account {
  const _Account({required this.id, required this.householdId, required this.name, required this.type, required this.openingBalance, this.openingDate, this.icon, this.color, this.sortOrder = 0, this.archivedAt, this.deletedAt, this.rowVersion = 0}): super._();
  

@override final  String id;
@override final  String householdId;
@override final  String name;
@override final  AccountType type;
@override final  Money openingBalance;
@override final  LocalDate? openingDate;
@override final  String? icon;
@override final  String? color;
@override@JsonKey() final  int sortOrder;
@override final  DateTime? archivedAt;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int rowVersion;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountCopyWith<_Account> get copyWith => __$AccountCopyWithImpl<_Account>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Account&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.openingBalance, openingBalance) || other.openingBalance == openingBalance)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,householdId,name,type,openingBalance,openingDate,icon,color,sortOrder,archivedAt,deletedAt,rowVersion);
}

@override
String toString() {
    return 'Account(id: $id, householdId: $householdId, name: $name, type: $type, openingBalance: $openingBalance, openingDate: $openingDate, icon: $icon, color: $color, sortOrder: $sortOrder, archivedAt: $archivedAt, deletedAt: $deletedAt, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) = __$AccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String householdId, String name, AccountType type, Money openingBalance, LocalDate? openingDate, String? icon, String? color, int sortOrder, DateTime? archivedAt, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class __$AccountCopyWithImpl<$Res>
    implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? name = null,Object? type = null,Object? openingBalance = null,Object? openingDate = freezed,Object? icon = freezed,Object? color = freezed,Object? sortOrder = null,Object? archivedAt = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(_Account(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,openingBalance: null == openingBalance ? _self.openingBalance : openingBalance // ignore: cast_nullable_to_non_nullable
as Money,openingDate: freezed == openingDate ? _self.openingDate : openingDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
