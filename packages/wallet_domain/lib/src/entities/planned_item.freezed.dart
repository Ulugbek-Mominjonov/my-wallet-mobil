// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planned_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlannedItem {

 String get id; String get householdId; PlanKind get kind; String get name; LocalDate get dueDate;/// BR-044: reja (va uning to'lovlari) shu oyga tegishli.
 MonthKey get budgetMonth; String? get categoryId; String? get accountId;/// null — summa noma'lum ("summa o'zgaruvchi").
 Money? get plannedAmount; Money get paidAmount; bool get autoPay; String? get debtId; String? get recurringRuleId; SystemCode? get systemCode; String? get note;/// To'langan (server: `paid ≥ planned`, summasiz rejaga to'lov yoki
/// `closedAt`).
 DateTime? get settledAt;/// Qo'lda yopilgan (to'liq to'lanmagan bo'lsa ham) — BR-073.
 DateTime? get closedAt; DateTime? get skippedAt; DateTime? get deletedAt; int get rowVersion;
/// Create a copy of PlannedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlannedItemCopyWith<PlannedItem> get copyWith => _$PlannedItemCopyWithImpl<PlannedItem>(this as PlannedItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlannedItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlannedItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.budgetMonth, _this.budgetMonth) || other.budgetMonth == _this.budgetMonth)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.plannedAmount, _this.plannedAmount) || other.plannedAmount == _this.plannedAmount)&&(identical(other.paidAmount, _this.paidAmount) || other.paidAmount == _this.paidAmount)&&(identical(other.autoPay, _this.autoPay) || other.autoPay == _this.autoPay)&&(identical(other.debtId, _this.debtId) || other.debtId == _this.debtId)&&(identical(other.recurringRuleId, _this.recurringRuleId) || other.recurringRuleId == _this.recurringRuleId)&&(identical(other.systemCode, _this.systemCode) || other.systemCode == _this.systemCode)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.settledAt, _this.settledAt) || other.settledAt == _this.settledAt)&&(identical(other.closedAt, _this.closedAt) || other.closedAt == _this.closedAt)&&(identical(other.skippedAt, _this.skippedAt) || other.skippedAt == _this.skippedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as PlannedItem;
  return Object.hashAll([runtimeType,_this.id,_this.householdId,_this.kind,_this.name,_this.dueDate,_this.budgetMonth,_this.categoryId,_this.accountId,_this.plannedAmount,_this.paidAmount,_this.autoPay,_this.debtId,_this.recurringRuleId,_this.systemCode,_this.note,_this.settledAt,_this.closedAt,_this.skippedAt,_this.deletedAt,_this.rowVersion]);
}

@override
String toString() {
  final _this = this as PlannedItem;
  return 'PlannedItem(id: ${_this.id}, householdId: ${_this.householdId}, kind: ${_this.kind}, name: ${_this.name}, dueDate: ${_this.dueDate}, budgetMonth: ${_this.budgetMonth}, categoryId: ${_this.categoryId}, accountId: ${_this.accountId}, plannedAmount: ${_this.plannedAmount}, paidAmount: ${_this.paidAmount}, autoPay: ${_this.autoPay}, debtId: ${_this.debtId}, recurringRuleId: ${_this.recurringRuleId}, systemCode: ${_this.systemCode}, note: ${_this.note}, settledAt: ${_this.settledAt}, closedAt: ${_this.closedAt}, skippedAt: ${_this.skippedAt}, deletedAt: ${_this.deletedAt}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $PlannedItemCopyWith<$Res>  {
  factory $PlannedItemCopyWith(PlannedItem value, $Res Function(PlannedItem) _then) = _$PlannedItemCopyWithImpl;
@useResult
$Res call({
 String id, String householdId, PlanKind kind, String name, LocalDate dueDate, MonthKey budgetMonth, String? categoryId, String? accountId, Money? plannedAmount, Money paidAmount, bool autoPay, String? debtId, String? recurringRuleId, SystemCode? systemCode, String? note, DateTime? settledAt, DateTime? closedAt, DateTime? skippedAt, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class _$PlannedItemCopyWithImpl<$Res>
    implements $PlannedItemCopyWith<$Res> {
  _$PlannedItemCopyWithImpl(this._self, this._then);

  final PlannedItem _self;
  final $Res Function(PlannedItem) _then;

/// Create a copy of PlannedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? kind = null,Object? name = null,Object? dueDate = null,Object? budgetMonth = null,Object? categoryId = freezed,Object? accountId = freezed,Object? plannedAmount = freezed,Object? paidAmount = null,Object? autoPay = null,Object? debtId = freezed,Object? recurringRuleId = freezed,Object? systemCode = freezed,Object? note = freezed,Object? settledAt = freezed,Object? closedAt = freezed,Object? skippedAt = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(PlannedItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PlanKind,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as LocalDate,budgetMonth: null == budgetMonth ? _self.budgetMonth : budgetMonth // ignore: cast_nullable_to_non_nullable
as MonthKey,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,plannedAmount: freezed == plannedAmount ? _self.plannedAmount : plannedAmount // ignore: cast_nullable_to_non_nullable
as Money?,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as Money,autoPay: null == autoPay ? _self.autoPay : autoPay // ignore: cast_nullable_to_non_nullable
as bool,debtId: freezed == debtId ? _self.debtId : debtId // ignore: cast_nullable_to_non_nullable
as String?,recurringRuleId: freezed == recurringRuleId ? _self.recurringRuleId : recurringRuleId // ignore: cast_nullable_to_non_nullable
as String?,systemCode: freezed == systemCode ? _self.systemCode : systemCode // ignore: cast_nullable_to_non_nullable
as SystemCode?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,settledAt: freezed == settledAt ? _self.settledAt : settledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,skippedAt: freezed == skippedAt ? _self.skippedAt : skippedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlannedItem].
extension PlannedItemPatterns on PlannedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlannedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlannedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlannedItem value)  $default,){
final _that = this;
switch (_that) {
case _PlannedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlannedItem value)?  $default,){
final _that = this;
switch (_that) {
case _PlannedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String householdId,  PlanKind kind,  String name,  LocalDate dueDate,  MonthKey budgetMonth,  String? categoryId,  String? accountId,  Money? plannedAmount,  Money paidAmount,  bool autoPay,  String? debtId,  String? recurringRuleId,  SystemCode? systemCode,  String? note,  DateTime? settledAt,  DateTime? closedAt,  DateTime? skippedAt,  DateTime? deletedAt,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlannedItem() when $default != null:
return $default(_that.id,_that.householdId,_that.kind,_that.name,_that.dueDate,_that.budgetMonth,_that.categoryId,_that.accountId,_that.plannedAmount,_that.paidAmount,_that.autoPay,_that.debtId,_that.recurringRuleId,_that.systemCode,_that.note,_that.settledAt,_that.closedAt,_that.skippedAt,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String householdId,  PlanKind kind,  String name,  LocalDate dueDate,  MonthKey budgetMonth,  String? categoryId,  String? accountId,  Money? plannedAmount,  Money paidAmount,  bool autoPay,  String? debtId,  String? recurringRuleId,  SystemCode? systemCode,  String? note,  DateTime? settledAt,  DateTime? closedAt,  DateTime? skippedAt,  DateTime? deletedAt,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _PlannedItem():
return $default(_that.id,_that.householdId,_that.kind,_that.name,_that.dueDate,_that.budgetMonth,_that.categoryId,_that.accountId,_that.plannedAmount,_that.paidAmount,_that.autoPay,_that.debtId,_that.recurringRuleId,_that.systemCode,_that.note,_that.settledAt,_that.closedAt,_that.skippedAt,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String householdId,  PlanKind kind,  String name,  LocalDate dueDate,  MonthKey budgetMonth,  String? categoryId,  String? accountId,  Money? plannedAmount,  Money paidAmount,  bool autoPay,  String? debtId,  String? recurringRuleId,  SystemCode? systemCode,  String? note,  DateTime? settledAt,  DateTime? closedAt,  DateTime? skippedAt,  DateTime? deletedAt,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _PlannedItem() when $default != null:
return $default(_that.id,_that.householdId,_that.kind,_that.name,_that.dueDate,_that.budgetMonth,_that.categoryId,_that.accountId,_that.plannedAmount,_that.paidAmount,_that.autoPay,_that.debtId,_that.recurringRuleId,_that.systemCode,_that.note,_that.settledAt,_that.closedAt,_that.skippedAt,_that.deletedAt,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _PlannedItem extends PlannedItem {
  const _PlannedItem({required this.id, required this.householdId, required this.kind, required this.name, required this.dueDate, required this.budgetMonth, this.categoryId, this.accountId, this.plannedAmount, this.paidAmount = Money.zero, this.autoPay = false, this.debtId, this.recurringRuleId, this.systemCode, this.note, this.settledAt, this.closedAt, this.skippedAt, this.deletedAt, this.rowVersion = 0}): super._();
  

@override final  String id;
@override final  String householdId;
@override final  PlanKind kind;
@override final  String name;
@override final  LocalDate dueDate;
/// BR-044: reja (va uning to'lovlari) shu oyga tegishli.
@override final  MonthKey budgetMonth;
@override final  String? categoryId;
@override final  String? accountId;
/// null — summa noma'lum ("summa o'zgaruvchi").
@override final  Money? plannedAmount;
@override@JsonKey() final  Money paidAmount;
@override@JsonKey() final  bool autoPay;
@override final  String? debtId;
@override final  String? recurringRuleId;
@override final  SystemCode? systemCode;
@override final  String? note;
/// To'langan (server: `paid ≥ planned`, summasiz rejaga to'lov yoki
/// `closedAt`).
@override final  DateTime? settledAt;
/// Qo'lda yopilgan (to'liq to'lanmagan bo'lsa ham) — BR-073.
@override final  DateTime? closedAt;
@override final  DateTime? skippedAt;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int rowVersion;

/// Create a copy of PlannedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlannedItemCopyWith<_PlannedItem> get copyWith => __$PlannedItemCopyWithImpl<_PlannedItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlannedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.name, name) || other.name == name)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.budgetMonth, budgetMonth) || other.budgetMonth == budgetMonth)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.plannedAmount, plannedAmount) || other.plannedAmount == plannedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.autoPay, autoPay) || other.autoPay == autoPay)&&(identical(other.debtId, debtId) || other.debtId == debtId)&&(identical(other.recurringRuleId, recurringRuleId) || other.recurringRuleId == recurringRuleId)&&(identical(other.systemCode, systemCode) || other.systemCode == systemCode)&&(identical(other.note, note) || other.note == note)&&(identical(other.settledAt, settledAt) || other.settledAt == settledAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.skippedAt, skippedAt) || other.skippedAt == skippedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,householdId,kind,name,dueDate,budgetMonth,categoryId,accountId,plannedAmount,paidAmount,autoPay,debtId,recurringRuleId,systemCode,note,settledAt,closedAt,skippedAt,deletedAt,rowVersion]);
}

@override
String toString() {
    return 'PlannedItem(id: $id, householdId: $householdId, kind: $kind, name: $name, dueDate: $dueDate, budgetMonth: $budgetMonth, categoryId: $categoryId, accountId: $accountId, plannedAmount: $plannedAmount, paidAmount: $paidAmount, autoPay: $autoPay, debtId: $debtId, recurringRuleId: $recurringRuleId, systemCode: $systemCode, note: $note, settledAt: $settledAt, closedAt: $closedAt, skippedAt: $skippedAt, deletedAt: $deletedAt, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$PlannedItemCopyWith<$Res> implements $PlannedItemCopyWith<$Res> {
  factory _$PlannedItemCopyWith(_PlannedItem value, $Res Function(_PlannedItem) _then) = __$PlannedItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String householdId, PlanKind kind, String name, LocalDate dueDate, MonthKey budgetMonth, String? categoryId, String? accountId, Money? plannedAmount, Money paidAmount, bool autoPay, String? debtId, String? recurringRuleId, SystemCode? systemCode, String? note, DateTime? settledAt, DateTime? closedAt, DateTime? skippedAt, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class __$PlannedItemCopyWithImpl<$Res>
    implements _$PlannedItemCopyWith<$Res> {
  __$PlannedItemCopyWithImpl(this._self, this._then);

  final _PlannedItem _self;
  final $Res Function(_PlannedItem) _then;

/// Create a copy of PlannedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? kind = null,Object? name = null,Object? dueDate = null,Object? budgetMonth = null,Object? categoryId = freezed,Object? accountId = freezed,Object? plannedAmount = freezed,Object? paidAmount = null,Object? autoPay = null,Object? debtId = freezed,Object? recurringRuleId = freezed,Object? systemCode = freezed,Object? note = freezed,Object? settledAt = freezed,Object? closedAt = freezed,Object? skippedAt = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(_PlannedItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PlanKind,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as LocalDate,budgetMonth: null == budgetMonth ? _self.budgetMonth : budgetMonth // ignore: cast_nullable_to_non_nullable
as MonthKey,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,plannedAmount: freezed == plannedAmount ? _self.plannedAmount : plannedAmount // ignore: cast_nullable_to_non_nullable
as Money?,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as Money,autoPay: null == autoPay ? _self.autoPay : autoPay // ignore: cast_nullable_to_non_nullable
as bool,debtId: freezed == debtId ? _self.debtId : debtId // ignore: cast_nullable_to_non_nullable
as String?,recurringRuleId: freezed == recurringRuleId ? _self.recurringRuleId : recurringRuleId // ignore: cast_nullable_to_non_nullable
as String?,systemCode: freezed == systemCode ? _self.systemCode : systemCode // ignore: cast_nullable_to_non_nullable
as SystemCode?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,settledAt: freezed == settledAt ? _self.settledAt : settledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,skippedAt: freezed == skippedAt ? _self.skippedAt : skippedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
