import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

part 'transaction.freezed.dart';

/// BR-050..058: amal — daromad, xarajat yoki o'tkazma. `amount` — hisob
/// valyutasida, `amountBase` — asosiy valyutada (ADR-08, server muzlatadi).
@freezed
abstract class Transaction with _$Transaction {
  const factory({
    required String id,
    required String householdId,
    required TransactionKind kind,
    required String accountId,
    required Money amount,
    required Money amountBase,
    required LocalDate occurredOn,

    /// BR-040..046: qaysi oyning byudjeti.
    required MonthKey budgetMonth,
    @Default(BudgetMonthSource.auto) BudgetMonthSource budgetMonthSource,

    /// BR-053: o'tkazma manzili va manzil hisob valyutasidagi summa (BR-193).
    String? toAccountId,
    Money? toAmount,

    /// Qo'lda kurs (kasr — aniq qiymat matn ko'rinishida, E29).
    String? fxRate,
    String? categoryId,
    String? payee,
    String? note,
    String? plannedItemId,
    String? debtId,
    @Default(TransactionSource.manual) TransactionSource source,
    String? createdBy,
    DateTime? deletedAt,
    @Default(0) int rowVersion,
  }) = _Transaction;

  const new _();

  bool get isDeleted => deletedAt != null;
}
