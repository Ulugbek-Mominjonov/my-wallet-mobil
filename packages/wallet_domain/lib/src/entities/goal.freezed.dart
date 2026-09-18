// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Goal {

 String get id; String get householdId; String get name; Money get target; Money get savedManual; Money? get monthlyContribution; MonthKey? get deadline; String? get accountId; int get sortOrder; DateTime? get achievedAt; DateTime? get deletedAt; int get rowVersion;
/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalCopyWith<Goal> get copyWith => _$GoalCopyWithImpl<Goal>(this as Goal, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Goal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Goal&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.savedManual, _this.savedManual) || other.savedManual == _this.savedManual)&&(identical(other.monthlyContribution, _this.monthlyContribution) || other.monthlyContribution == _this.monthlyContribution)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.achievedAt, _this.achievedAt) || other.achievedAt == _this.achievedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as Goal;
  return Object.hash(runtimeType,_this.id,_this.householdId,_this.name,_this.target,_this.savedManual,_this.monthlyContribution,_this.deadline,_this.accountId,_this.sortOrder,_this.achievedAt,_this.deletedAt,_this.rowVersion);
}

@override
String toString() {
  final _this = this as Goal;
  return 'Goal(id: ${_this.id}, householdId: ${_this.householdId}, name: ${_this.name}, target: ${_this.target}, savedManual: ${_this.savedManual}, monthlyContribution: ${_this.monthlyContribution}, deadline: ${_this.deadline}, accountId: ${_this.accountId}, sortOrder: ${_this.sortOrder}, achievedAt: ${_this.achievedAt}, deletedAt: ${_this.deletedAt}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $GoalCopyWith<$Res>  {
  factory $GoalCopyWith(Goal value, $Res Function(Goal) _then) = _$GoalCopyWithImpl;
@useResult
$Res call({
 String id, String householdId, String name, Money target, Money savedManual, Money? monthlyContribution, MonthKey? deadline, String? accountId, int sortOrder, DateTime? achievedAt, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class _$GoalCopyWithImpl<$Res>
    implements $GoalCopyWith<$Res> {
  _$GoalCopyWithImpl(this._self, this._then);

  final Goal _self;
  final $Res Function(Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? name = null,Object? target = null,Object? savedManual = null,Object? monthlyContribution = freezed,Object? deadline = freezed,Object? accountId = freezed,Object? sortOrder = null,Object? achievedAt = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(Goal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Money,savedManual: null == savedManual ? _self.savedManual : savedManual // ignore: cast_nullable_to_non_nullable
as Money,monthlyContribution: freezed == monthlyContribution ? _self.monthlyContribution : monthlyContribution // ignore: cast_nullable_to_non_nullable
as Money?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as MonthKey?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Goal].
extension GoalPatterns on Goal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Goal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Goal value)  $default,){
final _that = this;
switch (_that) {
case _Goal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Goal value)?  $default,){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String householdId,  String name,  Money target,  Money savedManual,  Money? monthlyContribution,  MonthKey? deadline,  String? accountId,  int sortOrder,  DateTime? achievedAt,  DateTime? deletedAt,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.householdId,_that.name,_that.target,_that.savedManual,_that.monthlyContribution,_that.deadline,_that.accountId,_that.sortOrder,_that.achievedAt,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String householdId,  String name,  Money target,  Money savedManual,  Money? monthlyContribution,  MonthKey? deadline,  String? accountId,  int sortOrder,  DateTime? achievedAt,  DateTime? deletedAt,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _Goal():
return $default(_that.id,_that.householdId,_that.name,_that.target,_that.savedManual,_that.monthlyContribution,_that.deadline,_that.accountId,_that.sortOrder,_that.achievedAt,_that.deletedAt,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String householdId,  String name,  Money target,  Money savedManual,  Money? monthlyContribution,  MonthKey? deadline,  String? accountId,  int sortOrder,  DateTime? achievedAt,  DateTime? deletedAt,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.householdId,_that.name,_that.target,_that.savedManual,_that.monthlyContribution,_that.deadline,_that.accountId,_that.sortOrder,_that.achievedAt,_that.deletedAt,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _Goal implements Goal {
  const _Goal({required this.id, required this.householdId, required this.name, required this.target, required this.savedManual, this.monthlyContribution, this.deadline, this.accountId, this.sortOrder = 0, this.achievedAt, this.deletedAt, this.rowVersion = 0});
  

@override final  String id;
@override final  String householdId;
@override final  String name;
@override final  Money target;
@override final  Money savedManual;
@override final  Money? monthlyContribution;
@override final  MonthKey? deadline;
@override final  String? accountId;
@override@JsonKey() final  int sortOrder;
@override final  DateTime? achievedAt;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int rowVersion;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalCopyWith<_Goal> get copyWith => __$GoalCopyWithImpl<_Goal>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.name, name) || other.name == name)&&(identical(other.target, target) || other.target == target)&&(identical(other.savedManual, savedManual) || other.savedManual == savedManual)&&(identical(other.monthlyContribution, monthlyContribution) || other.monthlyContribution == monthlyContribution)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,householdId,name,target,savedManual,monthlyContribution,deadline,accountId,sortOrder,achievedAt,deletedAt,rowVersion);
}

@override
String toString() {
    return 'Goal(id: $id, householdId: $householdId, name: $name, target: $target, savedManual: $savedManual, monthlyContribution: $monthlyContribution, deadline: $deadline, accountId: $accountId, sortOrder: $sortOrder, achievedAt: $achievedAt, deletedAt: $deletedAt, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$GoalCopyWith<$Res> implements $GoalCopyWith<$Res> {
  factory _$GoalCopyWith(_Goal value, $Res Function(_Goal) _then) = __$GoalCopyWithImpl;
@override @useResult
$Res call({
 String id, String householdId, String name, Money target, Money savedManual, Money? monthlyContribution, MonthKey? deadline, String? accountId, int sortOrder, DateTime? achievedAt, DateTime? deletedAt, int rowVersion
});




}
/// @nodoc
class __$GoalCopyWithImpl<$Res>
    implements _$GoalCopyWith<$Res> {
  __$GoalCopyWithImpl(this._self, this._then);

  final _Goal _self;
  final $Res Function(_Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? name = null,Object? target = null,Object? savedManual = null,Object? monthlyContribution = freezed,Object? deadline = freezed,Object? accountId = freezed,Object? sortOrder = null,Object? achievedAt = freezed,Object? deletedAt = freezed,Object? rowVersion = null,}) {
  return _then(_Goal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Money,savedManual: null == savedManual ? _self.savedManual : savedManual // ignore: cast_nullable_to_non_nullable
as Money,monthlyContribution: freezed == monthlyContribution ? _self.monthlyContribution : monthlyContribution // ignore: cast_nullable_to_non_nullable
as Money?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as MonthKey?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
