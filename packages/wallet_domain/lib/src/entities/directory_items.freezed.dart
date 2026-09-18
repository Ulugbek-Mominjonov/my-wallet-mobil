// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'directory_items.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryLimit {

 String get id; String get householdId; String get categoryId; Money get amount; bool get alert80; bool get alert100; DateTime? get deletedAt; int get rowVersion;
/// Create a copy of CategoryLimit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryLimitCopyWith<CategoryLimit> get copyWith => _$CategoryLimitCopyWithImpl<CategoryLimit>(this as CategoryLimit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategoryLimit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryLimit&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.alert80, _this.alert80) || other.alert80 == _this.alert80)&&(identical(other.alert100, _this.alert100) || other.alert100 == _this.alert100)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as CategoryLimit;
  return Object.hash(runtimeType,_this.id,_this.householdId,_this.categoryId,_this.amount,_this.alert80,_this.alert100,_this.deletedAt,_this.rowVersion);
}

@override
String toString() {
  final _this = this as CategoryLimit;
  return 'CategoryLimit(id: ${_this.id}, householdId: ${_this.householdId}, categoryId: ${_this.categoryId}, amount: ${_this.amount}, alert80: ${_this.alert80}, alert100: ${_this.alert100}, deletedAt: ${_this.deletedAt}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $CategoryLimitCopyWith<$Res>  {
  factory $CategoryLimitCopyWith(CategoryLimit value, $Res Function(CategoryLimit) _then) = _$CategoryLimitCopyWithImpl;
@useResult
$Res call({
 String id, String householdId, String categoryId, Money amount, bool alert80, bool alert100, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class _$CategoryLimitCopyWithImpl<$Res>
    implements $CategoryLimitCopyWith<$Res> {
  _$CategoryLimitCopyWithImpl(this._self, this._then);

  final CategoryLimit _self;
  final $Res Function(CategoryLimit) _then;

/// Create a copy of CategoryLimit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? categoryId = null,Object? amount = null,Object? alert80 = null,Object? alert100 = null,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(CategoryLimit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,alert80: null == alert80 ? _self.alert80 : alert80 // ignore: cast_nullable_to_non_nullable
as bool,alert100: null == alert100 ? _self.alert100 : alert100 // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryLimit].
extension CategoryLimitPatterns on CategoryLimit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryLimit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryLimit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryLimit value)  $default,){
final _that = this;
switch (_that) {
case _CategoryLimit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryLimit value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryLimit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String householdId,  String categoryId,  Money amount,  bool alert80,  bool alert100,  DateTime? deletedAt,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryLimit() when $default != null:
return $default(_that.id,_that.householdId,_that.categoryId,_that.amount,_that.alert80,_that.alert100,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String householdId,  String categoryId,  Money amount,  bool alert80,  bool alert100,  DateTime? deletedAt,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _CategoryLimit():
return $default(_that.id,_that.householdId,_that.categoryId,_that.amount,_that.alert80,_that.alert100,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String householdId,  String categoryId,  Money amount,  bool alert80,  bool alert100,  DateTime? deletedAt,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _CategoryLimit() when $default != null:
return $default(_that.id,_that.householdId,_that.categoryId,_that.amount,_that.alert80,_that.alert100,_that.deletedAt,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryLimit implements CategoryLimit {
  const _CategoryLimit({required this.id, required this.householdId, required this.categoryId, required this.amount, this.alert80 = true, this.alert100 = true, this.deletedAt, this.rowVersion = 0});
  

@override final  String id;
@override final  String householdId;
@override final  String categoryId;
@override final  Money amount;
@override@JsonKey() final  bool alert80;
@override@JsonKey() final  bool alert100;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int rowVersion;

/// Create a copy of CategoryLimit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryLimitCopyWith<_CategoryLimit> get copyWith => __$CategoryLimitCopyWithImpl<_CategoryLimit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryLimit&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.alert80, alert80) || other.alert80 == alert80)&&(identical(other.alert100, alert100) || other.alert100 == alert100)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,householdId,categoryId,amount,alert80,alert100,deletedAt,rowVersion);
}

@override
String toString() {
    return 'CategoryLimit(id: $id, householdId: $householdId, categoryId: $categoryId, amount: $amount, alert80: $alert80, alert100: $alert100, deletedAt: $deletedAt, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$CategoryLimitCopyWith<$Res> implements $CategoryLimitCopyWith<$Res> {
  factory _$CategoryLimitCopyWith(_CategoryLimit value, $Res Function(_CategoryLimit) _then) = __$CategoryLimitCopyWithImpl;
@override @useResult
$Res call({
 String id, String householdId, String categoryId, Money amount, bool alert80, bool alert100, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class __$CategoryLimitCopyWithImpl<$Res>
    implements _$CategoryLimitCopyWith<$Res> {
  __$CategoryLimitCopyWithImpl(this._self, this._then);

  final _CategoryLimit _self;
  final $Res Function(_CategoryLimit) _then;

/// Create a copy of CategoryLimit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? categoryId = null,Object? amount = null,Object? alert80 = null,Object? alert100 = null,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(_CategoryLimit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,alert80: null == alert80 ? _self.alert80 : alert80 // ignore: cast_nullable_to_non_nullable
as bool,alert100: null == alert100 ? _self.alert100 : alert100 // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$QuickAction {

 String get id; String get householdId; String get name; Money get amount; String get categoryId; String get accountId; String? get payee; int get sortOrder; DateTime? get deletedAt; int get rowVersion;
/// Create a copy of QuickAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuickActionCopyWith<QuickAction> get copyWith => _$QuickActionCopyWithImpl<QuickAction>(this as QuickAction, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as QuickAction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuickAction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.payee, _this.payee) || other.payee == _this.payee)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as QuickAction;
  return Object.hash(runtimeType,_this.id,_this.householdId,_this.name,_this.amount,_this.categoryId,_this.accountId,_this.payee,_this.sortOrder,_this.deletedAt,_this.rowVersion);
}

@override
String toString() {
  final _this = this as QuickAction;
  return 'QuickAction(id: ${_this.id}, householdId: ${_this.householdId}, name: ${_this.name}, amount: ${_this.amount}, categoryId: ${_this.categoryId}, accountId: ${_this.accountId}, payee: ${_this.payee}, sortOrder: ${_this.sortOrder}, deletedAt: ${_this.deletedAt}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $QuickActionCopyWith<$Res>  {
  factory $QuickActionCopyWith(QuickAction value, $Res Function(QuickAction) _then) = _$QuickActionCopyWithImpl;
@useResult
$Res call({
 String id, String householdId, String name, Money amount, String categoryId, String accountId, String? payee, int sortOrder, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class _$QuickActionCopyWithImpl<$Res>
    implements $QuickActionCopyWith<$Res> {
  _$QuickActionCopyWithImpl(this._self, this._then);

  final QuickAction _self;
  final $Res Function(QuickAction) _then;

/// Create a copy of QuickAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? name = null,Object? amount = null,Object? categoryId = null,Object? accountId = null,Object? payee = freezed,Object? sortOrder = null,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(QuickAction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,payee: freezed == payee ? _self.payee : payee // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [QuickAction].
extension QuickActionPatterns on QuickAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuickAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuickAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuickAction value)  $default,){
final _that = this;
switch (_that) {
case _QuickAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuickAction value)?  $default,){
final _that = this;
switch (_that) {
case _QuickAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String householdId,  String name,  Money amount,  String categoryId,  String accountId,  String? payee,  int sortOrder,  DateTime? deletedAt,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuickAction() when $default != null:
return $default(_that.id,_that.householdId,_that.name,_that.amount,_that.categoryId,_that.accountId,_that.payee,_that.sortOrder,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String householdId,  String name,  Money amount,  String categoryId,  String accountId,  String? payee,  int sortOrder,  DateTime? deletedAt,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _QuickAction():
return $default(_that.id,_that.householdId,_that.name,_that.amount,_that.categoryId,_that.accountId,_that.payee,_that.sortOrder,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String householdId,  String name,  Money amount,  String categoryId,  String accountId,  String? payee,  int sortOrder,  DateTime? deletedAt,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _QuickAction() when $default != null:
return $default(_that.id,_that.householdId,_that.name,_that.amount,_that.categoryId,_that.accountId,_that.payee,_that.sortOrder,_that.deletedAt,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _QuickAction implements QuickAction {
  const _QuickAction({required this.id, required this.householdId, required this.name, required this.amount, required this.categoryId, required this.accountId, this.payee, this.sortOrder = 0, this.deletedAt, this.rowVersion = 0});
  

@override final  String id;
@override final  String householdId;
@override final  String name;
@override final  Money amount;
@override final  String categoryId;
@override final  String accountId;
@override final  String? payee;
@override@JsonKey() final  int sortOrder;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int rowVersion;

/// Create a copy of QuickAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuickActionCopyWith<_QuickAction> get copyWith => __$QuickActionCopyWithImpl<_QuickAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuickAction&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.payee, payee) || other.payee == payee)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,householdId,name,amount,categoryId,accountId,payee,sortOrder,deletedAt,rowVersion);
}

@override
String toString() {
    return 'QuickAction(id: $id, householdId: $householdId, name: $name, amount: $amount, categoryId: $categoryId, accountId: $accountId, payee: $payee, sortOrder: $sortOrder, deletedAt: $deletedAt, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$QuickActionCopyWith<$Res> implements $QuickActionCopyWith<$Res> {
  factory _$QuickActionCopyWith(_QuickAction value, $Res Function(_QuickAction) _then) = __$QuickActionCopyWithImpl;
@override @useResult
$Res call({
 String id, String householdId, String name, Money amount, String categoryId, String accountId, String? payee, int sortOrder, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class __$QuickActionCopyWithImpl<$Res>
    implements _$QuickActionCopyWith<$Res> {
  __$QuickActionCopyWithImpl(this._self, this._then);

  final _QuickAction _self;
  final $Res Function(_QuickAction) _then;

/// Create a copy of QuickAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? name = null,Object? amount = null,Object? categoryId = null,Object? accountId = null,Object? payee = freezed,Object? sortOrder = null,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(_QuickAction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,payee: freezed == payee ? _self.payee : payee // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Tag {

 String get id; String get householdId; String get name; String? get color; DateTime? get deletedAt; int get rowVersion;
/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagCopyWith<Tag> get copyWith => _$TagCopyWithImpl<Tag>(this as Tag, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Tag;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tag&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as Tag;
  return Object.hash(runtimeType,_this.id,_this.householdId,_this.name,_this.color,_this.deletedAt,_this.rowVersion);
}

@override
String toString() {
  final _this = this as Tag;
  return 'Tag(id: ${_this.id}, householdId: ${_this.householdId}, name: ${_this.name}, color: ${_this.color}, deletedAt: ${_this.deletedAt}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $TagCopyWith<$Res>  {
  factory $TagCopyWith(Tag value, $Res Function(Tag) _then) = _$TagCopyWithImpl;
@useResult
$Res call({
 String id, String householdId, String name, String? color, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class _$TagCopyWithImpl<$Res>
    implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._self, this._then);

  final Tag _self;
  final $Res Function(Tag) _then;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? name = null,Object? color = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(Tag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Tag].
extension TagPatterns on Tag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tag value)  $default,){
final _that = this;
switch (_that) {
case _Tag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tag value)?  $default,){
final _that = this;
switch (_that) {
case _Tag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String householdId,  String name,  String? color,  DateTime? deletedAt,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tag() when $default != null:
return $default(_that.id,_that.householdId,_that.name,_that.color,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String householdId,  String name,  String? color,  DateTime? deletedAt,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _Tag():
return $default(_that.id,_that.householdId,_that.name,_that.color,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String householdId,  String name,  String? color,  DateTime? deletedAt,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _Tag() when $default != null:
return $default(_that.id,_that.householdId,_that.name,_that.color,_that.deletedAt,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _Tag implements Tag {
  const _Tag({required this.id, required this.householdId, required this.name, this.color, this.deletedAt, this.rowVersion = 0});
  

@override final  String id;
@override final  String householdId;
@override final  String name;
@override final  String? color;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int rowVersion;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagCopyWith<_Tag> get copyWith => __$TagCopyWithImpl<_Tag>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tag&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,householdId,name,color,deletedAt,rowVersion);
}

@override
String toString() {
    return 'Tag(id: $id, householdId: $householdId, name: $name, color: $color, deletedAt: $deletedAt, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$TagCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$TagCopyWith(_Tag value, $Res Function(_Tag) _then) = __$TagCopyWithImpl;
@override @useResult
$Res call({
 String id, String householdId, String name, String? color, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class __$TagCopyWithImpl<$Res>
    implements _$TagCopyWith<$Res> {
  __$TagCopyWithImpl(this._self, this._then);

  final _Tag _self;
  final $Res Function(_Tag) _then;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? name = null,Object? color = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(_Tag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
