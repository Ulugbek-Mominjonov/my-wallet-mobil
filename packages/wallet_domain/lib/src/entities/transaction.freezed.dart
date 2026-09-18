// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Transaction {

 String get id; String get householdId; TransactionKind get kind; String get accountId; Money get amount; Money get amountBase; LocalDate get occurredOn;/// BR-040..046: qaysi oyning byudjeti.
 MonthKey get budgetMonth; BudgetMonthSource get budgetMonthSource;/// BR-053: o'tkazma manzili va manzil hisob valyutasidagi summa (BR-193).
 String? get toAccountId; Money? get toAmount;/// Qo'lda kurs (kasr — aniq qiymat matn ko'rinishida, E29).
 String? get fxRate; String? get categoryId; String? get payee; String? get note; String? get plannedItemId; String? get debtId; TransactionSource get source; String? get createdBy; DateTime? get deletedAt; int get rowVersion;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Transaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.amountBase, _this.amountBase) || other.amountBase == _this.amountBase)&&(identical(other.occurredOn, _this.occurredOn) || other.occurredOn == _this.occurredOn)&&(identical(other.budgetMonth, _this.budgetMonth) || other.budgetMonth == _this.budgetMonth)&&(identical(other.budgetMonthSource, _this.budgetMonthSource) || other.budgetMonthSource == _this.budgetMonthSource)&&(identical(other.toAccountId, _this.toAccountId) || other.toAccountId == _this.toAccountId)&&(identical(other.toAmount, _this.toAmount) || other.toAmount == _this.toAmount)&&(identical(other.fxRate, _this.fxRate) || other.fxRate == _this.fxRate)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.payee, _this.payee) || other.payee == _this.payee)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.plannedItemId, _this.plannedItemId) || other.plannedItemId == _this.plannedItemId)&&(identical(other.debtId, _this.debtId) || other.debtId == _this.debtId)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as Transaction;
  return Object.hashAll([runtimeType,_this.id,_this.householdId,_this.kind,_this.accountId,_this.amount,_this.amountBase,_this.occurredOn,_this.budgetMonth,_this.budgetMonthSource,_this.toAccountId,_this.toAmount,_this.fxRate,_this.categoryId,_this.payee,_this.note,_this.plannedItemId,_this.debtId,_this.source,_this.createdBy,_this.deletedAt,_this.rowVersion]);
}

@override
String toString() {
  final _this = this as Transaction;
  return 'Transaction(id: ${_this.id}, householdId: ${_this.householdId}, kind: ${_this.kind}, accountId: ${_this.accountId}, amount: ${_this.amount}, amountBase: ${_this.amountBase}, occurredOn: ${_this.occurredOn}, budgetMonth: ${_this.budgetMonth}, budgetMonthSource: ${_this.budgetMonthSource}, toAccountId: ${_this.toAccountId}, toAmount: ${_this.toAmount}, fxRate: ${_this.fxRate}, categoryId: ${_this.categoryId}, payee: ${_this.payee}, note: ${_this.note}, plannedItemId: ${_this.plannedItemId}, debtId: ${_this.debtId}, source: ${_this.source}, createdBy: ${_this.createdBy}, deletedAt: ${_this.deletedAt}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 String id, String householdId, TransactionKind kind, String accountId, Money amount, Money amountBase, LocalDate occurredOn, MonthKey budgetMonth, BudgetMonthSource budgetMonthSource, String? toAccountId, Money? toAmount, String? fxRate, String? categoryId, String? payee, String? note, String? plannedItemId, String? debtId, TransactionSource source, String? createdBy, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? kind = null,Object? accountId = null,Object? amount = null,Object? amountBase = null,Object? occurredOn = null,Object? budgetMonth = null,Object? budgetMonthSource = null,Object? toAccountId = freezed,Object? toAmount = freezed,Object? fxRate = freezed,Object? categoryId = freezed,Object? payee = freezed,Object? note = freezed,Object? plannedItemId = freezed,Object? debtId = freezed,Object? source = null,Object? createdBy = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TransactionKind,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,amountBase: null == amountBase ? _self.amountBase : amountBase // ignore: cast_nullable_to_non_nullable
as Money,occurredOn: null == occurredOn ? _self.occurredOn : occurredOn // ignore: cast_nullable_to_non_nullable
as LocalDate,budgetMonth: null == budgetMonth ? _self.budgetMonth : budgetMonth // ignore: cast_nullable_to_non_nullable
as MonthKey,budgetMonthSource: null == budgetMonthSource ? _self.budgetMonthSource : budgetMonthSource // ignore: cast_nullable_to_non_nullable
as BudgetMonthSource,toAccountId: freezed == toAccountId ? _self.toAccountId : toAccountId // ignore: cast_nullable_to_non_nullable
as String?,toAmount: freezed == toAmount ? _self.toAmount : toAmount // ignore: cast_nullable_to_non_nullable
as Money?,fxRate: freezed == fxRate ? _self.fxRate : fxRate // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,payee: freezed == payee ? _self.payee : payee // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,plannedItemId: freezed == plannedItemId ? _self.plannedItemId : plannedItemId // ignore: cast_nullable_to_non_nullable
as String?,debtId: freezed == debtId ? _self.debtId : debtId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String householdId,  TransactionKind kind,  String accountId,  Money amount,  Money amountBase,  LocalDate occurredOn,  MonthKey budgetMonth,  BudgetMonthSource budgetMonthSource,  String? toAccountId,  Money? toAmount,  String? fxRate,  String? categoryId,  String? payee,  String? note,  String? plannedItemId,  String? debtId,  TransactionSource source,  String? createdBy,  DateTime? deletedAt,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.householdId,_that.kind,_that.accountId,_that.amount,_that.amountBase,_that.occurredOn,_that.budgetMonth,_that.budgetMonthSource,_that.toAccountId,_that.toAmount,_that.fxRate,_that.categoryId,_that.payee,_that.note,_that.plannedItemId,_that.debtId,_that.source,_that.createdBy,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String householdId,  TransactionKind kind,  String accountId,  Money amount,  Money amountBase,  LocalDate occurredOn,  MonthKey budgetMonth,  BudgetMonthSource budgetMonthSource,  String? toAccountId,  Money? toAmount,  String? fxRate,  String? categoryId,  String? payee,  String? note,  String? plannedItemId,  String? debtId,  TransactionSource source,  String? createdBy,  DateTime? deletedAt,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.householdId,_that.kind,_that.accountId,_that.amount,_that.amountBase,_that.occurredOn,_that.budgetMonth,_that.budgetMonthSource,_that.toAccountId,_that.toAmount,_that.fxRate,_that.categoryId,_that.payee,_that.note,_that.plannedItemId,_that.debtId,_that.source,_that.createdBy,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String householdId,  TransactionKind kind,  String accountId,  Money amount,  Money amountBase,  LocalDate occurredOn,  MonthKey budgetMonth,  BudgetMonthSource budgetMonthSource,  String? toAccountId,  Money? toAmount,  String? fxRate,  String? categoryId,  String? payee,  String? note,  String? plannedItemId,  String? debtId,  TransactionSource source,  String? createdBy,  DateTime? deletedAt,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.householdId,_that.kind,_that.accountId,_that.amount,_that.amountBase,_that.occurredOn,_that.budgetMonth,_that.budgetMonthSource,_that.toAccountId,_that.toAmount,_that.fxRate,_that.categoryId,_that.payee,_that.note,_that.plannedItemId,_that.debtId,_that.source,_that.createdBy,_that.deletedAt,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _Transaction extends Transaction {
  const _Transaction({required this.id, required this.householdId, required this.kind, required this.accountId, required this.amount, required this.amountBase, required this.occurredOn, required this.budgetMonth, this.budgetMonthSource = BudgetMonthSource.auto, this.toAccountId, this.toAmount, this.fxRate, this.categoryId, this.payee, this.note, this.plannedItemId, this.debtId, this.source = TransactionSource.manual, this.createdBy, this.deletedAt, this.rowVersion = 0}): super._();
  

@override final  String id;
@override final  String householdId;
@override final  TransactionKind kind;
@override final  String accountId;
@override final  Money amount;
@override final  Money amountBase;
@override final  LocalDate occurredOn;
/// BR-040..046: qaysi oyning byudjeti.
@override final  MonthKey budgetMonth;
@override@JsonKey() final  BudgetMonthSource budgetMonthSource;
/// BR-053: o'tkazma manzili va manzil hisob valyutasidagi summa (BR-193).
@override final  String? toAccountId;
@override final  Money? toAmount;
/// Qo'lda kurs (kasr — aniq qiymat matn ko'rinishida, E29).
@override final  String? fxRate;
@override final  String? categoryId;
@override final  String? payee;
@override final  String? note;
@override final  String? plannedItemId;
@override final  String? debtId;
@override@JsonKey() final  TransactionSource source;
@override final  String? createdBy;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int rowVersion;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountBase, amountBase) || other.amountBase == amountBase)&&(identical(other.occurredOn, occurredOn) || other.occurredOn == occurredOn)&&(identical(other.budgetMonth, budgetMonth) || other.budgetMonth == budgetMonth)&&(identical(other.budgetMonthSource, budgetMonthSource) || other.budgetMonthSource == budgetMonthSource)&&(identical(other.toAccountId, toAccountId) || other.toAccountId == toAccountId)&&(identical(other.toAmount, toAmount) || other.toAmount == toAmount)&&(identical(other.fxRate, fxRate) || other.fxRate == fxRate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.payee, payee) || other.payee == payee)&&(identical(other.note, note) || other.note == note)&&(identical(other.plannedItemId, plannedItemId) || other.plannedItemId == plannedItemId)&&(identical(other.debtId, debtId) || other.debtId == debtId)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,householdId,kind,accountId,amount,amountBase,occurredOn,budgetMonth,budgetMonthSource,toAccountId,toAmount,fxRate,categoryId,payee,note,plannedItemId,debtId,source,createdBy,deletedAt,rowVersion]);
}

@override
String toString() {
    return 'Transaction(id: $id, householdId: $householdId, kind: $kind, accountId: $accountId, amount: $amount, amountBase: $amountBase, occurredOn: $occurredOn, budgetMonth: $budgetMonth, budgetMonthSource: $budgetMonthSource, toAccountId: $toAccountId, toAmount: $toAmount, fxRate: $fxRate, categoryId: $categoryId, payee: $payee, note: $note, plannedItemId: $plannedItemId, debtId: $debtId, source: $source, createdBy: $createdBy, deletedAt: $deletedAt, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String householdId, TransactionKind kind, String accountId, Money amount, Money amountBase, LocalDate occurredOn, MonthKey budgetMonth, BudgetMonthSource budgetMonthSource, String? toAccountId, Money? toAmount, String? fxRate, String? categoryId, String? payee, String? note, String? plannedItemId, String? debtId, TransactionSource source, String? createdBy, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? kind = null,Object? accountId = null,Object? amount = null,Object? amountBase = null,Object? occurredOn = null,Object? budgetMonth = null,Object? budgetMonthSource = null,Object? toAccountId = freezed,Object? toAmount = freezed,Object? fxRate = freezed,Object? categoryId = freezed,Object? payee = freezed,Object? note = freezed,Object? plannedItemId = freezed,Object? debtId = freezed,Object? source = null,Object? createdBy = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TransactionKind,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,amountBase: null == amountBase ? _self.amountBase : amountBase // ignore: cast_nullable_to_non_nullable
as Money,occurredOn: null == occurredOn ? _self.occurredOn : occurredOn // ignore: cast_nullable_to_non_nullable
as LocalDate,budgetMonth: null == budgetMonth ? _self.budgetMonth : budgetMonth // ignore: cast_nullable_to_non_nullable
as MonthKey,budgetMonthSource: null == budgetMonthSource ? _self.budgetMonthSource : budgetMonthSource // ignore: cast_nullable_to_non_nullable
as BudgetMonthSource,toAccountId: freezed == toAccountId ? _self.toAccountId : toAccountId // ignore: cast_nullable_to_non_nullable
as String?,toAmount: freezed == toAmount ? _self.toAmount : toAmount // ignore: cast_nullable_to_non_nullable
as Money?,fxRate: freezed == fxRate ? _self.fxRate : fxRate // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,payee: freezed == payee ? _self.payee : payee // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,plannedItemId: freezed == plannedItemId ? _self.plannedItemId : plannedItemId // ignore: cast_nullable_to_non_nullable
as String?,debtId: freezed == debtId ? _self.debtId : debtId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
