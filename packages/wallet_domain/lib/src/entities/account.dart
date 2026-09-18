import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/value_objects/currency.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

part 'account.freezed.dart';

/// BR-020..026: hisob (hamyon). Summalar — hisob valyutasida.
@freezed
abstract class Account with _$Account {
  const factory({
    required String id,
    required String householdId,
    required String name,
    required AccountType type,
    required Money openingBalance,
    LocalDate? openingDate,
    String? icon,
    String? color,
    @Default(0) int sortOrder,
    DateTime? archivedAt,
    DateTime? deletedAt,
    @Default(0) int rowVersion,
  }) = _Account;

  const new _();

  /// Valyuta — boshlang'ich qoldiqniki (BR-026: amaldan keyin o'zgarmaydi).
  Currency get currency => openingBalance.currency;

  bool get isPersonalFund => type == AccountType.personalFund;

  /// Yangi amal uchun tanlanadigan (arxivlanmagan, o'chirilmagan).
  bool get isActive => archivedAt == null && deletedAt == null;
}
