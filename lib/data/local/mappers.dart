import 'package:drift/drift.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:wallet_domain/wallet_domain.dart';

// Lokal qator ↔ domen entity. Sana va oy — ISO matn, enum — server qiymati,
// pul — eng kichik birlik + valyuta (rejalar va `amount_base` — byudjetning
// asosiy valyutasida, ADR-06, ADR-08).

/// Ma'lum valyutalar (kasr xonalari va fond birligi bilan); qolganlari —
/// standart (2 xona). E14 dan boshlab `app_bootstrap` ro'yxatidan.
Currency currencyOf(String code) => currencyOfCode(code);

/// Valyuta kodi → `Currency` (DAO'lar ham ishlatadi).
Currency currencyOfCode(String code) => switch (code) {
  'UZS' => Currency.uzs,
  'USD' => Currency.usd,
  'EUR' => Currency.eur,
  'RUB' => Currency.rub,
  _ => Currency(code),
};

Money _money(int minor, String currency) => Money(minor, currencyOf(currency));
Money? _optionalMoney(int? minor, Currency currency) =>
    minor == null ? null : Money(minor, currency);
LocalDate? _date(String? iso) => iso == null ? null : LocalDate.parse(iso);
MonthKey? _month(String? iso) => iso == null ? null : MonthKey.parse(iso);

/// Serverda foiz `numeric(5, 2)`; domenda — bazis punkt (kasrsiz).
const _basisPointsPerPercent = 100;

extension HouseholdRowMapper on HouseholdRow {
  Household toDomain() => Household(
    id: id,
    name: name,
    baseCurrency: currencyOf(baseCurrency),
    timezone: timezone,
    autoOpenMonth: autoOpenMonth,
    strictMonthLock: strictMonthLock,
    rowVersion: rowVersion,
    personalFund: PersonalFundRule(
      mode: PersonalFundMode.fromWire(personalFundMode),
      percentBasisPoints: (personalFundPercent * _basisPointsPerPercent)
          .round(),
      fixedAmount: _money(personalFundFixedAmount, baseCurrency),
      day: personalFundDay,
      sourceAccountId: personalFundSourceAccountId,
    ),
  );
}

extension HouseholdMapper on Household {
  HouseholdRow toRow() => HouseholdRow(
    id: id,
    name: name,
    baseCurrency: baseCurrency.code,
    timezone: timezone,
    personalFundMode: personalFund.mode.wire,
    personalFundPercent:
        personalFund.percentBasisPoints / _basisPointsPerPercent,
    personalFundFixedAmount: personalFund.fixedAmount.minor,
    personalFundDay: personalFund.day,
    personalFundSourceAccountId: personalFund.sourceAccountId,
    autoOpenMonth: autoOpenMonth,
    strictMonthLock: strictMonthLock,
    rowVersion: rowVersion,
  );
}

extension AccountRowMapper on AccountRow {
  Account toDomain() => Account(
    id: id,
    householdId: householdId,
    name: name,
    type: AccountType.fromWire(type),
    openingBalance: _money(openingBalance, currency),
    openingDate: _date(openingDate),
    icon: icon,
    color: color,
    sortOrder: sortOrder,
    archivedAt: archivedAt,
    deletedAt: deletedAt,
    rowVersion: rowVersion,
  );
}

extension AccountMapper on Account {
  AccountsCompanion toCompanion() => AccountsCompanion.insert(
    id: id,
    householdId: householdId,
    name: name,
    type: type.wire,
    currency: Value(currency.code),
    openingBalance: Value(openingBalance.minor),
    openingDate: Value(openingDate?.toString()),
    icon: Value(icon),
    color: Value(color),
    sortOrder: Value(sortOrder),
    archivedAt: Value(archivedAt),
    deletedAt: Value(deletedAt),
    rowVersion: Value(rowVersion),
  );
}

extension CategoryRowMapper on CategoryRow {
  Category toDomain() => Category(
    id: id,
    householdId: householdId,
    kind: CategoryKind.fromWire(kind),
    name: name,
    parentId: parentId,
    monthShift: monthShift,
    icon: icon,
    color: color,
    sortOrder: sortOrder,
    systemCode: systemCode == null ? null : SystemCode.fromWire(systemCode!),
    archivedAt: archivedAt,
    deletedAt: deletedAt,
    rowVersion: rowVersion,
  );
}

extension CategoryMapper on Category {
  CategoriesCompanion toCompanion() => CategoriesCompanion.insert(
    id: id,
    householdId: householdId,
    kind: kind.wire,
    name: name,
    parentId: Value(parentId),
    monthShift: Value(monthShift),
    systemCode: Value(systemCode?.wire),
    icon: Value(icon),
    color: Value(color),
    sortOrder: Value(sortOrder),
    archivedAt: Value(archivedAt),
    deletedAt: Value(deletedAt),
    rowVersion: Value(rowVersion),
  );
}

extension PlannedItemRowMapper on PlannedItemRow {
  PlannedItem toDomain(Currency base) => PlannedItem(
    id: id,
    householdId: householdId,
    kind: PlanKind.fromWire(kind),
    name: name,
    dueDate: LocalDate.parse(dueDate),
    budgetMonth: MonthKey.parse(budgetMonth),
    categoryId: categoryId,
    accountId: accountId,
    plannedAmount: _optionalMoney(plannedAmount, base),
    paidAmount: Money(paidAmount, base),
    autoPay: autoPay,
    debtId: debtId,
    recurringRuleId: recurringRuleId,
    systemCode: systemCode == null ? null : SystemCode.fromWire(systemCode!),
    note: note,
    settledAt: settledAt,
    closedAt: closedAt,
    skippedAt: skippedAt,
    deletedAt: deletedAt,
    rowVersion: rowVersion,
  );
}

extension PlannedItemMapper on PlannedItem {
  PlannedItemsCompanion toCompanion() => PlannedItemsCompanion.insert(
    id: id,
    householdId: householdId,
    kind: kind.wire,
    name: name,
    dueDate: dueDate.toString(),
    budgetMonth: budgetMonth.toIsoDate(),
    categoryId: Value(categoryId),
    accountId: Value(accountId),
    plannedAmount: Value(plannedAmount?.minor),
    paidAmount: Value(paidAmount.minor),
    autoPay: Value(autoPay),
    debtId: Value(debtId),
    recurringRuleId: Value(recurringRuleId),
    systemCode: Value(systemCode?.wire),
    note: Value(note),
    settledAt: Value(settledAt),
    closedAt: Value(closedAt),
    skippedAt: Value(skippedAt),
    deletedAt: Value(deletedAt),
    rowVersion: Value(rowVersion),
  );
}

extension TransactionRowMapper on TransactionRow {
  /// [accountCurrency] — hisob valyutasi (`amount`), [base] — asosiy
  /// (`amount_base`), [toCurrency] — manzil hisobniki (`to_amount`).
  Transaction toDomain({
    required Currency accountCurrency,
    required Currency base,
    Currency? toCurrency,
  }) => Transaction(
    id: id,
    householdId: householdId,
    kind: TransactionKind.fromWire(kind),
    accountId: accountId,
    amount: Money(amount, accountCurrency),
    amountBase: Money(amountBase, base),
    occurredOn: LocalDate.parse(occurredOn),
    budgetMonth: MonthKey.parse(budgetMonth),
    budgetMonthSource: BudgetMonthSource.fromWire(budgetMonthSource),
    toAccountId: toAccountId,
    toAmount: _optionalMoney(toAmount, toCurrency ?? accountCurrency),
    fxRate: fxRate?.toString(),
    categoryId: categoryId,
    payee: payee,
    note: note,
    plannedItemId: plannedItemId,
    debtId: debtId,
    source: TransactionSource.fromWire(source),
    createdBy: createdBy,
    deletedAt: deletedAt,
    rowVersion: rowVersion,
  );
}

extension TransactionMapper on Transaction {
  TransactionsCompanion toCompanion() => TransactionsCompanion.insert(
    id: id,
    householdId: householdId,
    kind: kind.wire,
    accountId: accountId,
    amount: amount.minor,
    amountBase: amountBase.minor,
    occurredOn: occurredOn.toString(),
    budgetMonth: budgetMonth.toIsoDate(),
    budgetMonthSource: Value(budgetMonthSource.wire),
    toAccountId: Value(toAccountId),
    toAmount: Value(toAmount?.minor),
    fxRate: Value(fxRate == null ? null : double.parse(fxRate!)),
    categoryId: Value(categoryId),
    payee: Value(payee),
    note: Value(note),
    plannedItemId: Value(plannedItemId),
    debtId: Value(debtId),
    source: Value(source.wire),
    createdBy: Value(createdBy),
    deletedAt: Value(deletedAt),
    rowVersion: Value(rowVersion),
  );
}

extension DebtRowMapper on DebtRow {
  Debt toDomain() => Debt(
    id: id,
    householdId: householdId,
    name: name,
    direction: DebtDirection.fromWire(direction),
    total: _money(total, currency),
    paidBefore: _money(paidBefore, currency),
    monthlyPayment: _optionalMoney(monthlyPayment, currencyOf(currency)),
    dueDate: _date(dueDate),
    note: note,
    archivedAt: archivedAt,
    deletedAt: deletedAt,
    rowVersion: rowVersion,
  );
}

extension DebtMapper on Debt {
  DebtsCompanion toCompanion() => DebtsCompanion.insert(
    id: id,
    householdId: householdId,
    name: name,
    direction: direction.wire,
    currency: Value(total.currency.code),
    total: total.minor,
    paidBefore: Value(paidBefore.minor),
    monthlyPayment: Value(monthlyPayment?.minor),
    dueDate: Value(dueDate?.toString()),
    note: Value(note),
    archivedAt: Value(archivedAt),
    deletedAt: Value(deletedAt),
    rowVersion: Value(rowVersion),
  );
}

extension GoalRowMapper on GoalRow {
  Goal toDomain() => Goal(
    id: id,
    householdId: householdId,
    name: name,
    target: _money(target, currency),
    savedManual: _money(savedManual, currency),
    monthlyContribution: _optionalMoney(
      monthlyContribution,
      currencyOf(currency),
    ),
    deadline: _month(deadline),
    accountId: accountId,
    sortOrder: sortOrder,
    achievedAt: achievedAt,
    deletedAt: deletedAt,
    rowVersion: rowVersion,
  );
}

extension GoalMapper on Goal {
  GoalsCompanion toCompanion() => GoalsCompanion.insert(
    id: id,
    householdId: householdId,
    name: name,
    currency: Value(target.currency.code),
    target: target.minor,
    savedManual: Value(savedManual.minor),
    monthlyContribution: Value(monthlyContribution?.minor),
    deadline: Value(deadline?.toIsoDate()),
    accountId: Value(accountId),
    sortOrder: Value(sortOrder),
    achievedAt: Value(achievedAt),
    deletedAt: Value(deletedAt),
    rowVersion: Value(rowVersion),
  );
}

extension CategoryLimitRowMapper on CategoryLimitRow {
  CategoryLimit toDomain(Currency base) => CategoryLimit(
    id: id,
    householdId: householdId,
    categoryId: categoryId,
    amount: Money(amount, base),
    alert80: alert80,
    alert100: alert100,
    deletedAt: deletedAt,
    rowVersion: rowVersion,
  );
}

extension CategoryLimitMapper on CategoryLimit {
  CategoryLimitsCompanion toCompanion() => CategoryLimitsCompanion.insert(
    id: id,
    householdId: householdId,
    categoryId: categoryId,
    amount: amount.minor,
    alert80: Value(alert80),
    alert100: Value(alert100),
    deletedAt: Value(deletedAt),
    rowVersion: Value(rowVersion),
  );
}

extension QuickActionRowMapper on QuickActionRow {
  QuickAction toDomain(Currency accountCurrency) => QuickAction(
    id: id,
    householdId: householdId,
    name: name,
    amount: Money(amount, accountCurrency),
    categoryId: categoryId,
    accountId: accountId,
    payee: payee,
    sortOrder: sortOrder,
    deletedAt: deletedAt,
    rowVersion: rowVersion,
  );
}

extension QuickActionMapper on QuickAction {
  QuickActionsCompanion toCompanion() => QuickActionsCompanion.insert(
    id: id,
    householdId: householdId,
    name: name,
    amount: amount.minor,
    categoryId: categoryId,
    accountId: accountId,
    payee: Value(payee),
    sortOrder: Value(sortOrder),
    deletedAt: Value(deletedAt),
    rowVersion: Value(rowVersion),
  );
}

extension TagRowMapper on TagRow {
  Tag toDomain() => Tag(
    id: id,
    householdId: householdId,
    name: name,
    color: color,
    deletedAt: deletedAt,
    rowVersion: rowVersion,
  );
}

extension TagMapper on Tag {
  TagsCompanion toCompanion() => TagsCompanion.insert(
    id: id,
    householdId: householdId,
    name: name,
    color: Value(color),
    deletedAt: Value(deletedAt),
    rowVersion: Value(rowVersion),
  );
}

extension RecurringRuleRowMapper on RecurringRuleRow {
  /// Summa — hisob valyutasida ([accountCurrency]; hisobsiz — asosiy).
  RecurringRule toDomain(Currency accountCurrency) => RecurringRule(
    id: id,
    householdId: householdId,
    kind: PlanKind.fromWire(kind),
    name: name,
    dayOfMonth: dayOfMonth,
    categoryId: categoryId,
    accountId: accountId,
    amount: _optionalMoney(amount, accountCurrency),
    autoPay: autoPay,
    active: active,
    debtId: debtId,
    startMonth: _month(startMonth),
    endMonth: _month(endMonth),
    sortOrder: sortOrder,
    deletedAt: deletedAt,
    rowVersion: rowVersion,
  );
}

extension RecurringRuleMapper on RecurringRule {
  RecurringRulesCompanion toCompanion() => RecurringRulesCompanion.insert(
    id: id,
    householdId: householdId,
    kind: kind.wire,
    name: name,
    dayOfMonth: dayOfMonth,
    categoryId: Value(categoryId),
    accountId: Value(accountId),
    amount: Value(amount?.minor),
    autoPay: Value(autoPay),
    active: Value(active),
    debtId: Value(debtId),
    startMonth: Value(startMonth?.toIsoDate()),
    endMonth: Value(endMonth?.toIsoDate()),
    sortOrder: Value(sortOrder),
    deletedAt: Value(deletedAt),
    rowVersion: Value(rowVersion),
  );
}
