// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Debt {

 String get id; String get householdId; String get name; DebtDirection get direction; Money get total;/// Ilovadan tashqarida (oldin) to'langan qism.
 Money get paidBefore; Money? get monthlyPayment; LocalDate? get dueDate; String? get note; DateTime? get archivedAt; DateTime? get deletedAt; int get rowVersion;
/// Create a copy of Debt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DebtCopyWith<Debt> get copyWith => _$DebtCopyWithImpl<Debt>(this as Debt, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Debt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Debt&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.paidBefore, _this.paidBefore) || other.paidBefore == _this.paidBefore)&&(identical(other.monthlyPayment, _this.monthlyPayment) || other.monthlyPayment == _this.monthlyPayment)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.archivedAt, _this.archivedAt) || other.archivedAt == _this.archivedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as Debt;
  return Object.hash(runtimeType,_this.id,_this.householdId,_this.name,_this.direction,_this.total,_this.paidBefore,_this.monthlyPayment,_this.dueDate,_this.note,_this.archivedAt,_this.deletedAt,_this.rowVersion);
}

@override
String toString() {
  final _this = this as Debt;
  return 'Debt(id: ${_this.id}, householdId: ${_this.householdId}, name: ${_this.name}, direction: ${_this.direction}, total: ${_this.total}, paidBefore: ${_this.paidBefore}, monthlyPayment: ${_this.monthlyPayment}, dueDate: ${_this.dueDate}, note: ${_this.note}, archivedAt: ${_this.archivedAt}, deletedAt: ${_this.deletedAt}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $DebtCopyWith<$Res>  {
  factory $DebtCopyWith(Debt value, $Res Function(Debt) _then) = _$DebtCopyWithImpl;
@useResult
$Res call({
 String id, String householdId, String name, DebtDirection direction, Money total, Money paidBefore, Money? monthlyPayment, LocalDate? dueDate, String? note, DateTime? archivedAt, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class _$DebtCopyWithImpl<$Res>
    implements $DebtCopyWith<$Res> {
  _$DebtCopyWithImpl(this._self, this._then);

  final Debt _self;
  final $Res Function(Debt) _then;

/// Create a copy of Debt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? name = null,Object? direction = null,Object? total = null,Object? paidBefore = null,Object? monthlyPayment = freezed,Object? dueDate = freezed,Object? note = freezed,Object? archivedAt = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(Debt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as DebtDirection,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,paidBefore: null == paidBefore ? _self.paidBefore : paidBefore // ignore: cast_nullable_to_non_nullable
as Money,monthlyPayment: freezed == monthlyPayment ? _self.monthlyPayment : monthlyPayment // ignore: cast_nullable_to_non_nullable
as Money?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Debt].
extension DebtPatterns on Debt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Debt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Debt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Debt value)  $default,){
final _that = this;
switch (_that) {
case _Debt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Debt value)?  $default,){
final _that = this;
switch (_that) {
case _Debt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String householdId,  String name,  DebtDirection direction,  Money total,  Money paidBefore,  Money? monthlyPayment,  LocalDate? dueDate,  String? note,  DateTime? archivedAt,  DateTime? deletedAt,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Debt() when $default != null:
return $default(_that.id,_that.householdId,_that.name,_that.direction,_that.total,_that.paidBefore,_that.monthlyPayment,_that.dueDate,_that.note,_that.archivedAt,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String householdId,  String name,  DebtDirection direction,  Money total,  Money paidBefore,  Money? monthlyPayment,  LocalDate? dueDate,  String? note,  DateTime? archivedAt,  DateTime? deletedAt,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _Debt():
return $default(_that.id,_that.householdId,_that.name,_that.direction,_that.total,_that.paidBefore,_that.monthlyPayment,_that.dueDate,_that.note,_that.archivedAt,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String householdId,  String name,  DebtDirection direction,  Money total,  Money paidBefore,  Money? monthlyPayment,  LocalDate? dueDate,  String? note,  DateTime? archivedAt,  DateTime? deletedAt,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _Debt() when $default != null:
return $default(_that.id,_that.householdId,_that.name,_that.direction,_that.total,_that.paidBefore,_that.monthlyPayment,_that.dueDate,_that.note,_that.archivedAt,_that.deletedAt,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _Debt implements Debt {
  const _Debt({required this.id, required this.householdId, required this.name, required this.direction, required this.total, required this.paidBefore, this.monthlyPayment, this.dueDate, this.note, this.archivedAt, this.deletedAt, this.rowVersion = 0});
  

@override final  String id;
@override final  String householdId;
@override final  String name;
@override final  DebtDirection direction;
@override final  Money total;
/// Ilovadan tashqarida (oldin) to'langan qism.
@override final  Money paidBefore;
@override final  Money? monthlyPayment;
@override final  LocalDate? dueDate;
@override final  String? note;
@override final  DateTime? archivedAt;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int rowVersion;

/// Create a copy of Debt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DebtCopyWith<_Debt> get copyWith => __$DebtCopyWithImpl<_Debt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Debt&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.name, name) || other.name == name)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.total, total) || other.total == total)&&(identical(other.paidBefore, paidBefore) || other.paidBefore == paidBefore)&&(identical(other.monthlyPayment, monthlyPayment) || other.monthlyPayment == monthlyPayment)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.note, note) || other.note == note)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,householdId,name,direction,total,paidBefore,monthlyPayment,dueDate,note,archivedAt,deletedAt,rowVersion);
}

@override
String toString() {
    return 'Debt(id: $id, householdId: $householdId, name: $name, direction: $direction, total: $total, paidBefore: $paidBefore, monthlyPayment: $monthlyPayment, dueDate: $dueDate, note: $note, archivedAt: $archivedAt, deletedAt: $deletedAt, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$DebtCopyWith<$Res> implements $DebtCopyWith<$Res> {
  factory _$DebtCopyWith(_Debt value, $Res Function(_Debt) _then) = __$DebtCopyWithImpl;
@override @useResult
$Res call({
 String id, String householdId, String name, DebtDirection direction, Money total, Money paidBefore, Money? monthlyPayment, LocalDate? dueDate, String? note, DateTime? archivedAt, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class __$DebtCopyWithImpl<$Res>
    implements _$DebtCopyWith<$Res> {
  __$DebtCopyWithImpl(this._self, this._then);

  final _Debt _self;
  final $Res Function(_Debt) _then;

/// Create a copy of Debt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? name = null,Object? direction = null,Object? total = null,Object? paidBefore = null,Object? monthlyPayment = freezed,Object? dueDate = freezed,Object? note = freezed,Object? archivedAt = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(_Debt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as DebtDirection,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,paidBefore: null == paidBefore ? _self.paidBefore : paidBefore // ignore: cast_nullable_to_non_nullable
as Money,monthlyPayment: freezed == monthlyPayment ? _self.monthlyPayment : monthlyPayment // ignore: cast_nullable_to_non_nullable
as Money?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as LocalDate?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
