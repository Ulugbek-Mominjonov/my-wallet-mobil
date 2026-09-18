import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/value_objects/currency.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

part 'household.freezed.dart';

/// BR-010: byudjet — barcha ma'lumotlar egasi.
@freezed
abstract class Household with _$Household {
  const factory({
    required String id,
    required String name,
    required PersonalFundRule personalFund,
    @Default(Currency.uzs) Currency baseCurrency,
    @Default('Asia/Tashkent') String timezone,
    @Default(true) bool autoOpenMonth,
    @Default(false) bool strictMonthLock,
    @Default(0) int rowVersion,
  }) = _Household;
}

/// BR-060: 👤 shaxsiy fond qoidasi. Foiz — bazis punktlarda (10% = 1000;
/// serverda `numeric(5, 2)`), kasrli son ishlatilmaydi.
@freezed
abstract class PersonalFundRule with _$PersonalFundRule {
  const factory({
    @Default(PersonalFundMode.percent) PersonalFundMode mode,
    @Default(1000) int percentBasisPoints,
    @Default(Money.zero) Money fixedAmount,
    @Default(5) int day,
    String? sourceAccountId,
  }) = _PersonalFundRule;
}

/// BR-011: byudjet a'zosi va roli.
@freezed
abstract class Member with _$Member {
  const factory({
    required String householdId,
    required String userId,
    required MemberRole role,
  }) = _Member;
}
