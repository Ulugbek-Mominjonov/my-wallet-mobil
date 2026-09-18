// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'household.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Household {

 String get id; String get name; PersonalFundRule get personalFund; Currency get baseCurrency; String get timezone; bool get autoOpenMonth; bool get strictMonthLock; int get rowVersion;
/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdCopyWith<Household> get copyWith => _$HouseholdCopyWithImpl<Household>(this as Household, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Household;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Household&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.personalFund, _this.personalFund) || other.personalFund == _this.personalFund)&&(identical(other.baseCurrency, _this.baseCurrency) || other.baseCurrency == _this.baseCurrency)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.autoOpenMonth, _this.autoOpenMonth) || other.autoOpenMonth == _this.autoOpenMonth)&&(identical(other.strictMonthLock, _this.strictMonthLock) || other.strictMonthLock == _this.strictMonthLock)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}


@override
int get hashCode {
  final _this = this as Household;
  return Object.hash(runtimeType,_this.id,_this.name,_this.personalFund,_this.baseCurrency,_this.timezone,_this.autoOpenMonth,_this.strictMonthLock,_this.rowVersion);
}

@override
String toString() {
  final _this = this as Household;
  return 'Household(id: ${_this.id}, name: ${_this.name}, personalFund: ${_this.personalFund}, baseCurrency: ${_this.baseCurrency}, timezone: ${_this.timezone}, autoOpenMonth: ${_this.autoOpenMonth}, strictMonthLock: ${_this.strictMonthLock}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $HouseholdCopyWith<$Res>  {
  factory $HouseholdCopyWith(Household value, $Res Function(Household) _then) = _$HouseholdCopyWithImpl;
@useResult
$Res call({
 String id, String name, PersonalFundRule personalFund, Currency baseCurrency, String timezone, bool autoOpenMonth, bool strictMonthLock, int rowVersion
});


$PersonalFundRuleCopyWith<$Res> get personalFund;

}
/// @nodoc
class _$HouseholdCopyWithImpl<$Res>
    implements $HouseholdCopyWith<$Res> {
  _$HouseholdCopyWithImpl(this._self, this._then);

  final Household _self;
  final $Res Function(Household) _then;

/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? personalFund = null,Object? baseCurrency = null,Object? timezone = null,Object? autoOpenMonth = null,Object? strictMonthLock = null,Object? rowVersion = null,}) {
  return _then(Household(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,personalFund: null == personalFund ? _self.personalFund : personalFund // ignore: cast_nullable_to_non_nullable
as PersonalFundRule,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as Currency,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,autoOpenMonth: null == autoOpenMonth ? _self.autoOpenMonth : autoOpenMonth // ignore: cast_nullable_to_non_nullable
as bool,strictMonthLock: null == strictMonthLock ? _self.strictMonthLock : strictMonthLock // ignore: cast_nullable_to_non_nullable
as bool,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonalFundRuleCopyWith<$Res> get personalFund {
  
  return $PersonalFundRuleCopyWith<$Res>(_self.personalFund, (value) {
    return _then(_self.copyWith(personalFund: value));
  });
}
}


/// Adds pattern-matching-related methods to [Household].
extension HouseholdPatterns on Household {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Household value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Household() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Household value)  $default,){
final _that = this;
switch (_that) {
case _Household():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Household value)?  $default,){
final _that = this;
switch (_that) {
case _Household() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  PersonalFundRule personalFund,  Currency baseCurrency,  String timezone,  bool autoOpenMonth,  bool strictMonthLock,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Household() when $default != null:
return $default(_that.id,_that.name,_that.personalFund,_that.baseCurrency,_that.timezone,_that.autoOpenMonth,_that.strictMonthLock,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  PersonalFundRule personalFund,  Currency baseCurrency,  String timezone,  bool autoOpenMonth,  bool strictMonthLock,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _Household():
return $default(_that.id,_that.name,_that.personalFund,_that.baseCurrency,_that.timezone,_that.autoOpenMonth,_that.strictMonthLock,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  PersonalFundRule personalFund,  Currency baseCurrency,  String timezone,  bool autoOpenMonth,  bool strictMonthLock,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _Household() when $default != null:
return $default(_that.id,_that.name,_that.personalFund,_that.baseCurrency,_that.timezone,_that.autoOpenMonth,_that.strictMonthLock,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc


class _Household implements Household {
  const _Household({required this.id, required this.name, required this.personalFund, this.baseCurrency = Currency.uzs, this.timezone = 'Asia/Tashkent', this.autoOpenMonth = true, this.strictMonthLock = false, this.rowVersion = 0});
  

@override final  String id;
@override final  String name;
@override final  PersonalFundRule personalFund;
@override@JsonKey() final  Currency baseCurrency;
@override@JsonKey() final  String timezone;
@override@JsonKey() final  bool autoOpenMonth;
@override@JsonKey() final  bool strictMonthLock;
@override@JsonKey() final  int rowVersion;

/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdCopyWith<_Household> get copyWith => __$HouseholdCopyWithImpl<_Household>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Household&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.personalFund, personalFund) || other.personalFund == personalFund)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.autoOpenMonth, autoOpenMonth) || other.autoOpenMonth == autoOpenMonth)&&(identical(other.strictMonthLock, strictMonthLock) || other.strictMonthLock == strictMonthLock)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,personalFund,baseCurrency,timezone,autoOpenMonth,strictMonthLock,rowVersion);
}

@override
String toString() {
    return 'Household(id: $id, name: $name, personalFund: $personalFund, baseCurrency: $baseCurrency, timezone: $timezone, autoOpenMonth: $autoOpenMonth, strictMonthLock: $strictMonthLock, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$HouseholdCopyWith<$Res> implements $HouseholdCopyWith<$Res> {
  factory _$HouseholdCopyWith(_Household value, $Res Function(_Household) _then) = __$HouseholdCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, PersonalFundRule personalFund, Currency baseCurrency, String timezone, bool autoOpenMonth, bool strictMonthLock, int rowVersion
});


@override $PersonalFundRuleCopyWith<$Res> get personalFund;

}
/// @nodoc
class __$HouseholdCopyWithImpl<$Res>
    implements _$HouseholdCopyWith<$Res> {
  __$HouseholdCopyWithImpl(this._self, this._then);

  final _Household _self;
  final $Res Function(_Household) _then;

/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? personalFund = null,Object? baseCurrency = null,Object? timezone = null,Object? autoOpenMonth = null,Object? strictMonthLock = null,Object? rowVersion = null,}) {
  return _then(_Household(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,personalFund: null == personalFund ? _self.personalFund : personalFund // ignore: cast_nullable_to_non_nullable
as PersonalFundRule,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as Currency,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,autoOpenMonth: null == autoOpenMonth ? _self.autoOpenMonth : autoOpenMonth // ignore: cast_nullable_to_non_nullable
as bool,strictMonthLock: null == strictMonthLock ? _self.strictMonthLock : strictMonthLock // ignore: cast_nullable_to_non_nullable
as bool,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonalFundRuleCopyWith<$Res> get personalFund {
  
  return $PersonalFundRuleCopyWith<$Res>(_self.personalFund, (value) {
    return _then(_self.copyWith(personalFund: value));
  });
}
}

/// @nodoc
mixin _$PersonalFundRule {

 PersonalFundMode get mode; int get percentBasisPoints; Money get fixedAmount; int get day; String? get sourceAccountId;
/// Create a copy of PersonalFundRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalFundRuleCopyWith<PersonalFundRule> get copyWith => _$PersonalFundRuleCopyWithImpl<PersonalFundRule>(this as PersonalFundRule, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PersonalFundRule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalFundRule&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.percentBasisPoints, _this.percentBasisPoints) || other.percentBasisPoints == _this.percentBasisPoints)&&(identical(other.fixedAmount, _this.fixedAmount) || other.fixedAmount == _this.fixedAmount)&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.sourceAccountId, _this.sourceAccountId) || other.sourceAccountId == _this.sourceAccountId));
}


@override
int get hashCode {
  final _this = this as PersonalFundRule;
  return Object.hash(runtimeType,_this.mode,_this.percentBasisPoints,_this.fixedAmount,_this.day,_this.sourceAccountId);
}

@override
String toString() {
  final _this = this as PersonalFundRule;
  return 'PersonalFundRule(mode: ${_this.mode}, percentBasisPoints: ${_this.percentBasisPoints}, fixedAmount: ${_this.fixedAmount}, day: ${_this.day}, sourceAccountId: ${_this.sourceAccountId})';
}


}

/// @nodoc
abstract mixin class $PersonalFundRuleCopyWith<$Res>  {
  factory $PersonalFundRuleCopyWith(PersonalFundRule value, $Res Function(PersonalFundRule) _then) = _$PersonalFundRuleCopyWithImpl;
@useResult
$Res call({
 PersonalFundMode mode, int percentBasisPoints, Money fixedAmount, int day, String? sourceAccountId
});




}
/// @nodoc
class _$PersonalFundRuleCopyWithImpl<$Res>
    implements $PersonalFundRuleCopyWith<$Res> {
  _$PersonalFundRuleCopyWithImpl(this._self, this._then);

  final PersonalFundRule _self;
  final $Res Function(PersonalFundRule) _then;

/// Create a copy of PersonalFundRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? percentBasisPoints = null,Object? fixedAmount = null,Object? day = null,Object? sourceAccountId = freezed,}) {
  return _then(PersonalFundRule(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PersonalFundMode,percentBasisPoints: null == percentBasisPoints ? _self.percentBasisPoints : percentBasisPoints // ignore: cast_nullable_to_non_nullable
as int,fixedAmount: null == fixedAmount ? _self.fixedAmount : fixedAmount // ignore: cast_nullable_to_non_nullable
as Money,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,sourceAccountId: freezed == sourceAccountId ? _self.sourceAccountId : sourceAccountId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalFundRule].
extension PersonalFundRulePatterns on PersonalFundRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalFundRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalFundRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalFundRule value)  $default,){
final _that = this;
switch (_that) {
case _PersonalFundRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalFundRule value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalFundRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PersonalFundMode mode,  int percentBasisPoints,  Money fixedAmount,  int day,  String? sourceAccountId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalFundRule() when $default != null:
return $default(_that.mode,_that.percentBasisPoints,_that.fixedAmount,_that.day,_that.sourceAccountId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PersonalFundMode mode,  int percentBasisPoints,  Money fixedAmount,  int day,  String? sourceAccountId)  $default,) {final _that = this;
switch (_that) {
case _PersonalFundRule():
return $default(_that.mode,_that.percentBasisPoints,_that.fixedAmount,_that.day,_that.sourceAccountId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PersonalFundMode mode,  int percentBasisPoints,  Money fixedAmount,  int day,  String? sourceAccountId)?  $default,) {final _that = this;
switch (_that) {
case _PersonalFundRule() when $default != null:
return $default(_that.mode,_that.percentBasisPoints,_that.fixedAmount,_that.day,_that.sourceAccountId);case _:
  return null;

}
}

}

/// @nodoc


class _PersonalFundRule implements PersonalFundRule {
  const _PersonalFundRule({this.mode = PersonalFundMode.percent, this.percentBasisPoints = 1000, this.fixedAmount = Money.zero, this.day = 5, this.sourceAccountId});
  

@override@JsonKey() final  PersonalFundMode mode;
@override@JsonKey() final  int percentBasisPoints;
@override@JsonKey() final  Money fixedAmount;
@override@JsonKey() final  int day;
@override final  String? sourceAccountId;

/// Create a copy of PersonalFundRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalFundRuleCopyWith<_PersonalFundRule> get copyWith => __$PersonalFundRuleCopyWithImpl<_PersonalFundRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalFundRule&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.percentBasisPoints, percentBasisPoints) || other.percentBasisPoints == percentBasisPoints)&&(identical(other.fixedAmount, fixedAmount) || other.fixedAmount == fixedAmount)&&(identical(other.day, day) || other.day == day)&&(identical(other.sourceAccountId, sourceAccountId) || other.sourceAccountId == sourceAccountId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mode,percentBasisPoints,fixedAmount,day,sourceAccountId);
}

@override
String toString() {
    return 'PersonalFundRule(mode: $mode, percentBasisPoints: $percentBasisPoints, fixedAmount: $fixedAmount, day: $day, sourceAccountId: $sourceAccountId)';
}


}

/// @nodoc
abstract mixin class _$PersonalFundRuleCopyWith<$Res> implements $PersonalFundRuleCopyWith<$Res> {
  factory _$PersonalFundRuleCopyWith(_PersonalFundRule value, $Res Function(_PersonalFundRule) _then) = __$PersonalFundRuleCopyWithImpl;
@override @useResult
$Res call({
 PersonalFundMode mode, int percentBasisPoints, Money fixedAmount, int day, String? sourceAccountId
});




}
/// @nodoc
class __$PersonalFundRuleCopyWithImpl<$Res>
    implements _$PersonalFundRuleCopyWith<$Res> {
  __$PersonalFundRuleCopyWithImpl(this._self, this._then);

  final _PersonalFundRule _self;
  final $Res Function(_PersonalFundRule) _then;

/// Create a copy of PersonalFundRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? percentBasisPoints = null,Object? fixedAmount = null,Object? day = null,Object? sourceAccountId = freezed,}) {
  return _then(_PersonalFundRule(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PersonalFundMode,percentBasisPoints: null == percentBasisPoints ? _self.percentBasisPoints : percentBasisPoints // ignore: cast_nullable_to_non_nullable
as int,fixedAmount: null == fixedAmount ? _self.fixedAmount : fixedAmount // ignore: cast_nullable_to_non_nullable
as Money,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,sourceAccountId: freezed == sourceAccountId ? _self.sourceAccountId : sourceAccountId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Member {

 String get householdId; String get userId; MemberRole get role;
/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCopyWith<Member> get copyWith => _$MemberCopyWithImpl<Member>(this as Member, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Member;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Member&&(identical(other.householdId, _this.householdId) || other.householdId == _this.householdId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.role, _this.role) || other.role == _this.role));
}


@override
int get hashCode {
  final _this = this as Member;
  return Object.hash(runtimeType,_this.householdId,_this.userId,_this.role);
}

@override
String toString() {
  final _this = this as Member;
  return 'Member(householdId: ${_this.householdId}, userId: ${_this.userId}, role: ${_this.role})';
}


}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res>  {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) = _$MemberCopyWithImpl;
@useResult
$Res call({
 String householdId, String userId, MemberRole role
});




}
/// @nodoc
class _$MemberCopyWithImpl<$Res>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._self, this._then);

  final Member _self;
  final $Res Function(Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? householdId = null,Object? userId = null,Object? role = null,}) {
  return _then(Member(
householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,
  ));
}

}


/// Adds pattern-matching-related methods to [Member].
extension MemberPatterns on Member {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Member value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Member() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Member value)  $default,){
final _that = this;
switch (_that) {
case _Member():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Member value)?  $default,){
final _that = this;
switch (_that) {
case _Member() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String householdId,  String userId,  MemberRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.householdId,_that.userId,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String householdId,  String userId,  MemberRole role)  $default,) {final _that = this;
switch (_that) {
case _Member():
return $default(_that.householdId,_that.userId,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String householdId,  String userId,  MemberRole role)?  $default,) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.householdId,_that.userId,_that.role);case _:
  return null;

}
}

}

/// @nodoc


class _Member implements Member {
  const _Member({required this.householdId, required this.userId, required this.role});
  

@override final  String householdId;
@override final  String userId;
@override final  MemberRole role;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberCopyWith<_Member> get copyWith => __$MemberCopyWithImpl<_Member>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Member&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode {
    return Object.hash(runtimeType,householdId,userId,role);
}

@override
String toString() {
    return 'Member(householdId: $householdId, userId: $userId, role: $role)';
}


}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) = __$MemberCopyWithImpl;
@override @useResult
$Res call({
 String householdId, String userId, MemberRole role
});




}
/// @nodoc
class __$MemberCopyWithImpl<$Res>
    implements _$MemberCopyWith<$Res> {
  __$MemberCopyWithImpl(this._self, this._then);

  final _Member _self;
  final $Res Function(_Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? householdId = null,Object? userId = null,Object? role = null,}) {
  return _then(_Member(
householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,
  ));
}


}

// dart format on
