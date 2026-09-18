// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecurringRule {

 String get id; String get householdId; PlanKind get kind; String get name;/// 1–31; qisqa oyda oxirgi kunga qisiladi (BR-080).
 int get dayOfMonth; String? get categoryId; String? get accountId;/// null — summa o'zgaruvchan (har oy kiritiladi).
 Money? get amount; bool get autoPay; bool get active; String? get debtId; MonthKey? get startMonth; MonthKey? get endMonth; int get sortOrder; DateTime? get deletedAt; int get rowVersion;
/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringRuleCopyWith<RecurringRule> get copyWith => _$RecurringRuleCopyWithImpl<RecurringRule>(this as RecurringRule, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecurringRule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringRule&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.dayOfMonth, _this.dayOfMonth) || other.dayOfMonth == _this.dayOfMonth)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.autoPay, _this.autoPay) || other.autoPay == _this.autoPay)&&(identical(other.active, _this.active) || other.active == _this.active)&&(identical(other.debtId, _this.debtId) || other.debtId == _this.debtId)&&(identical(other.startMonth, _this.startMonth) || other.startMonth == _this.startMonth)&&(identical(other.endMonth, _this.endMonth) || other.endMonth == _this.endMonth)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as RecurringRule;
  return Object.hash(runtimeType,_this.id,_this.householdId,_this.kind,_this.name,_this.dayOfMonth,_this.categoryId,_this.accountId,_this.amount,_this.autoPay,_this.active,_this.debtId,_this.startMonth,_this.endMonth,_this.sortOrder,_this.deletedAt,_this.rowVersion);
}

@override
String toString() {
  final _this = this as RecurringRule;
  return 'RecurringRule(id: ${_this.id}, householdId: ${_this.householdId}, kind: ${_this.kind}, name: ${_this.name}, dayOfMonth: ${_this.dayOfMonth}, categoryId: ${_this.categoryId}, accountId: ${_this.accountId}, amount: ${_this.amount}, autoPay: ${_this.autoPay}, active: ${_this.active}, debtId: ${_this.debtId}, startMonth: ${_this.startMonth}, endMonth: ${_this.endMonth}, sortOrder: ${_this.sortOrder}, deletedAt: ${_this.deletedAt}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $RecurringRuleCopyWith<$Res>  {
  factory $RecurringRuleCopyWith(RecurringRule value, $Res Function(RecurringRule) _then) = _$RecurringRuleCopyWithImpl;
@useResult
$Res call({
 String id, String householdId, PlanKind kind, String name, int dayOfMonth, String? categoryId, String? accountId, Money? amount, bool autoPay, bool active, String? debtId, MonthKey? startMonth, MonthKey? endMonth, int sortOrder, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class _$RecurringRuleCopyWithImpl<$Res>
    implements $RecurringRuleCopyWith<$Res> {
  _$RecurringRuleCopyWithImpl(this._self, this._then);

  final RecurringRule _self;
  final $Res Function(RecurringRule) _then;

/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? kind = null,Object? name = null,Object? dayOfMonth = null,Object? categoryId = freezed,Object? accountId = freezed,Object? amount = freezed,Object? autoPay = null,Object? active = null,Object? debtId = freezed,Object? startMonth = freezed,Object? endMonth = freezed,Object? sortOrder = null,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(RecurringRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PlanKind,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money?,autoPay: null == autoPay ? _self.autoPay : autoPay // ignore: cast_nullable_to_non_nullable
as bool,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,debtId: freezed == debtId ? _self.debtId : debtId // ignore: cast_nullable_to_non_nullable
as String?,startMonth: freezed == startMonth ? _self.startMonth : startMonth // ignore: cast_nullable_to_non_nullable
as MonthKey?,endMonth: freezed == endMonth ? _self.endMonth : endMonth // ignore: cast_nullable_to_non_nullable
as MonthKey?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringRule].
extension RecurringRulePatterns on RecurringRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringRule value)  $default,){
final _that = this;
switch (_that) {
case _RecurringRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringRule value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String householdId,  PlanKind kind,  String name,  int dayOfMonth,  String? categoryId,  String? accountId,  Money? amount,  bool autoPay,  bool active,  String? debtId,  MonthKey? startMonth,  MonthKey? endMonth,  int sortOrder,  DateTime? deletedAt,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
return $default(_that.id,_that.householdId,_that.kind,_that.name,_that.dayOfMonth,_that.categoryId,_that.accountId,_that.amount,_that.autoPay,_that.active,_that.debtId,_that.startMonth,_that.endMonth,_that.sortOrder,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String householdId,  PlanKind kind,  String name,  int dayOfMonth,  String? categoryId,  String? accountId,  Money? amount,  bool autoPay,  bool active,  String? debtId,  MonthKey? startMonth,  MonthKey? endMonth,  int sortOrder,  DateTime? deletedAt,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _RecurringRule():
return $default(_that.id,_that.householdId,_that.kind,_that.name,_that.dayOfMonth,_that.categoryId,_that.accountId,_that.amount,_that.autoPay,_that.active,_that.debtId,_that.startMonth,_that.endMonth,_that.sortOrder,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String householdId,  PlanKind kind,  String name,  int dayOfMonth,  String? categoryId,  String? accountId,  Money? amount,  bool autoPay,  bool active,  String? debtId,  MonthKey? startMonth,  MonthKey? endMonth,  int sortOrder,  DateTime? deletedAt,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
return $default(_that.id,_that.householdId,_that.kind,_that.name,_that.dayOfMonth,_that.categoryId,_that.accountId,_that.amount,_that.autoPay,_that.active,_that.debtId,_that.startMonth,_that.endMonth,_that.sortOrder,_that.deletedAt,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _RecurringRule extends RecurringRule {
  const _RecurringRule({required this.id, required this.householdId, required this.kind, required this.name, required this.dayOfMonth, this.categoryId, this.accountId, this.amount, this.autoPay = false, this.active = true, this.debtId, this.startMonth, this.endMonth, this.sortOrder = 0, this.deletedAt, this.rowVersion = 0}): super._();
  

@override final  String id;
@override final  String householdId;
@override final  PlanKind kind;
@override final  String name;
/// 1–31; qisqa oyda oxirgi kunga qisiladi (BR-080).
@override final  int dayOfMonth;
@override final  String? categoryId;
@override final  String? accountId;
/// null — summa o'zgaruvchan (har oy kiritiladi).
@override final  Money? amount;
@override@JsonKey() final  bool autoPay;
@override@JsonKey() final  bool active;
@override final  String? debtId;
@override final  MonthKey? startMonth;
@override final  MonthKey? endMonth;
@override@JsonKey() final  int sortOrder;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int rowVersion;

/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringRuleCopyWith<_RecurringRule> get copyWith => __$RecurringRuleCopyWithImpl<_RecurringRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringRule&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.name, name) || other.name == name)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.autoPay, autoPay) || other.autoPay == autoPay)&&(identical(other.active, active) || other.active == active)&&(identical(other.debtId, debtId) || other.debtId == debtId)&&(identical(other.startMonth, startMonth) || other.startMonth == startMonth)&&(identical(other.endMonth, endMonth) || other.endMonth == endMonth)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,householdId,kind,name,dayOfMonth,categoryId,accountId,amount,autoPay,active,debtId,startMonth,endMonth,sortOrder,deletedAt,rowVersion);
}

@override
String toString() {
    return 'RecurringRule(id: $id, householdId: $householdId, kind: $kind, name: $name, dayOfMonth: $dayOfMonth, categoryId: $categoryId, accountId: $accountId, amount: $amount, autoPay: $autoPay, active: $active, debtId: $debtId, startMonth: $startMonth, endMonth: $endMonth, sortOrder: $sortOrder, deletedAt: $deletedAt, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$RecurringRuleCopyWith<$Res> implements $RecurringRuleCopyWith<$Res> {
  factory _$RecurringRuleCopyWith(_RecurringRule value, $Res Function(_RecurringRule) _then) = __$RecurringRuleCopyWithImpl;
@override @useResult
$Res call({
 String id, String householdId, PlanKind kind, String name, int dayOfMonth, String? categoryId, String? accountId, Money? amount, bool autoPay, bool active, String? debtId, MonthKey? startMonth, MonthKey? endMonth, int sortOrder, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class __$RecurringRuleCopyWithImpl<$Res>
    implements _$RecurringRuleCopyWith<$Res> {
  __$RecurringRuleCopyWithImpl(this._self, this._then);

  final _RecurringRule _self;
  final $Res Function(_RecurringRule) _then;

/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? kind = null,Object? name = null,Object? dayOfMonth = null,Object? categoryId = freezed,Object? accountId = freezed,Object? amount = freezed,Object? autoPay = null,Object? active = null,Object? debtId = freezed,Object? startMonth = freezed,Object? endMonth = freezed,Object? sortOrder = null,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(_RecurringRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PlanKind,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money?,autoPay: null == autoPay ? _self.autoPay : autoPay // ignore: cast_nullable_to_non_nullable
as bool,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,debtId: freezed == debtId ? _self.debtId : debtId // ignore: cast_nullable_to_non_nullable
as String?,startMonth: freezed == startMonth ? _self.startMonth : startMonth // ignore: cast_nullable_to_non_nullable
as MonthKey?,endMonth: freezed == endMonth ? _self.endMonth : endMonth // ignore: cast_nullable_to_non_nullable
as MonthKey?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
