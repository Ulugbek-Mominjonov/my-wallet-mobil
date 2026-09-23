import 'package:wallet_domain/src/entities/account.dart';
import 'package:wallet_domain/src/entities/category.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/entities/planned_item.dart';
import 'package:wallet_domain/src/entities/transaction.dart';
import 'package:wallet_domain/src/failures.dart';
import 'package:wallet_domain/src/result.dart';
import 'package:wallet_domain/src/rules/fx.dart';
import 'package:wallet_domain/src/rules/month_attribution.dart';
import 'package:wallet_domain/src/usecases/deps.dart';
import 'package:wallet_domain/src/value_objects/fx_rate.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// BR-003: nom/joy — 1–60 belgi (serverdagi `entity_name`).
const maxNameLength = 60;

/// Amalni tekshiradi va hosila maydonlarni hisoblaydi — serverdagi
/// `validate_transaction` bilan bir xil qoidalar (kodlar — contracts/api.md).
/// Natija — lokal taxmin; sinxronda server qaytargan kanonik qator yoziladi.
///
/// [recomputeMonth] = false — tahrirda kirishlar o'zgarmagan (BR-043: tegishli
/// oy faqat tur, kategoriya, sana yoki reja o'zgarsa qayta hisoblanadi).
Future<Result<Transaction>> prepareTransaction(
  DomainDeps deps,
  Transaction draft, {
  required bool confirmClosedMonth,
  PlannedItem? plan,
  bool recomputeMonth = true,
}) async {
  Err<Transaction> invalid(String field, String code) =>
      Err(ValidationFailure(field, code));

  if (!draft.amount.isPositive) return invalid('amount', 'invalid_amount');
  final household = await deps.households.current();
  final account = await deps.accounts.byId(draft.accountId);
  if (account == null) return invalid('account', 'account_not_found');
  if (account.deletedAt != null) return invalid('account', 'account_deleted');
  // BR-191..193: summa — hisob valyutasida; asosiy valyutadagi ekvivalent
  // qo'lda kurs (bo'lsa) yoki sanadagi kurs bilan. Kurs yo'q — yozilmaydi.
  final amount = Money(draft.amount.minor, account.currency);
  final rate = draft.fxRate == null
      ? await deps.fx.rate(
          account.currency,
          household.baseCurrency,
          draft.occurredOn,
        )
      : FxRate.tryParse(draft.fxRate!);
  if (rate == null) return invalid('amount', 'fx_rate_missing');
  final amountBase = toBaseAmount(
    amount,
    base: household.baseCurrency,
    rate: rate,
  );

  var tx = draft.copyWith(amount: amount);
  Category? category;
  switch (draft.kind) {
    case TransactionKind.income || TransactionKind.expense:
      // BR-063: fondga daromad yozilmaydi; BR-062: fond sarfi rejaga
      // bog'lanmaydi.
      final income = draft.kind == TransactionKind.income;
      if (account.isPersonalFund && (income || draft.plannedItemId != null)) {
        return invalid('account', 'invalid_account');
      }
      if (draft.categoryId == null && account.isPersonalFund) {
        category = await deps.categories.allocationCategory();
      } else if (draft.categoryId == null) {
        return invalid('category', 'category_required');
      } else {
        category = await deps.categories.byId(draft.categoryId!);
      }
      final failure = _checkCategory(category, draft.kind);
      if (failure != null) return Err(failure);
      tx = tx.copyWith(
        categoryId: category!.id,
        toAccountId: null,
        toAmount: null,
      );
    case TransactionKind.transfer:
      final result = await _checkTransfer(deps, draft, account);
      if (result is Err<Transaction>) return result;
      tx = (result as Ok<Transaction>).value;
  }

  final payee = draft.payee?.trim();
  if (payee != null && payee.length > maxNameLength) {
    return invalid('payee', 'invalid_name');
  }

  final budgetMonth =
      draft.budgetMonthSource == BudgetMonthSource.manual || !recomputeMonth
      ? draft.budgetMonth
      : attributeBudgetMonth(
          kind: draft.kind,
          occurredOn: draft.occurredOn,
          plannedMonth: plan?.budgetMonth,
          incomeShift: category?.monthShift ?? 0,
        );
  tx = tx.copyWith(
    payee: payee == null || payee.isEmpty ? null : payee,
    budgetMonth: budgetMonth,
    amountBase: amountBase,
  );

  final lock = await monthLockFailure(
    deps,
    budgetMonth,
    confirmed: confirmClosedMonth,
  );
  return lock == null ? Ok(tx) : Err(lock);
}

/// BR-055: yopilgan oy — qattiq qulfda taqiq, aks holda foydalanuvchi
/// tasdig'i bilan ([confirmed]). Ochiq oy — null.
Future<Failure?> monthLockFailure(
  DomainDeps deps,
  MonthKey month, {
  required bool confirmed,
}) async {
  if (!await deps.households.isMonthClosed(month)) return null;
  final strict = (await deps.households.current()).strictMonthLock;
  return strict || !confirmed
      ? MonthClosedWarning(month, blocking: strict)
      : null;
}

Failure? _checkCategory(Category? category, TransactionKind kind) {
  if (category == null) {
    return const ValidationFailure('category', 'category_not_found');
  }
  if (category.deletedAt != null) {
    return const ValidationFailure('category', 'category_deleted');
  }
  if (category.kind.wire != kind.wire) {
    return const ValidationFailure('category', 'category_kind_mismatch');
  }
  return null;
}

/// BR-053, BR-193: o'tkazma — boshqa hisobga; turli valyutada ikkala summa.
Future<Result<Transaction>> _checkTransfer(
  DomainDeps deps,
  Transaction draft,
  Account from,
) async {
  final toId = draft.toAccountId;
  if (toId == null) {
    return const Err(ValidationFailure('to_account', 'account_required'));
  }
  if (toId == from.id) {
    return const Err(ValidationFailure('to_account', 'invalid_target'));
  }
  final to = await deps.accounts.byId(toId);
  if (to == null) {
    return const Err(ValidationFailure('to_account', 'account_not_found'));
  }
  if (to.deletedAt != null) {
    return const Err(ValidationFailure('to_account', 'account_deleted'));
  }
  var toAmount = draft.toAmount;
  if (to.currency == from.currency) {
    toAmount = draft.amount;
  } else if (toAmount == null) {
    return const Err(ValidationFailure('to_amount', 'to_amount_required'));
  } else if (!toAmount.isPositive) {
    return const Err(ValidationFailure('to_amount', 'invalid_amount'));
  }
  return Ok(draft.copyWith(categoryId: null, toAmount: toAmount));
}
