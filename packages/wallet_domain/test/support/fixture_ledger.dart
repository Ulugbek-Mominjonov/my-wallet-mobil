// Golden fixture holatini xotiradagi byudjetga aylantiradi va serverdagi
// hisobot RPC'lari javobini domen qoidalari bilan qayta quradi (E12-T05).
//
// Yozuv yo'li admin'dagi `scripts/contract/load_fixture.sql` + triggerlar
// bilan bir xil: standart to'plam (kategoriyalar, Naqd/Karta/fond, 10%),
// amalning tegishli oyi, "O'zim uchun", rejaning qarzi, to'langan summa,
// fond rejasi qayta hisobi, `settle`. Formulalar — faqat `wallet_domain` da;
// bu fayl ularni chaqiradi va javobni server JSON ko'rinishida yig'adi.
import 'package:wallet_domain/wallet_domain.dart';

typedef Json = Map<String, Object?>;

/// Shablondagi standart kategoriyalar (serverdagi `category_templates`, uz).
const _templates = <(CategoryKind, String, int, SystemCode?, int)>[
  (CategoryKind.income, 'Avans', 0, null, 1),
  (CategoryKind.income, 'Oylik', -1, null, 2),
  (CategoryKind.income, 'KPI', -1, null, 3),
  (CategoryKind.income, "Qo'shimcha", -1, null, 4),
  (CategoryKind.expense, 'Ijara', 0, null, 10),
  (CategoryKind.expense, 'Kommunal', 0, null, 11),
  (CategoryKind.expense, 'Internet/Aloqa', 0, null, 12),
  (CategoryKind.expense, 'Oziq-ovqat', 0, null, 13),
  (CategoryKind.expense, 'Transport', 0, null, 14),
  (CategoryKind.expense, 'Kredit/Qarz', 0, null, 15),
  (CategoryKind.expense, "Sog'liq", 0, null, 16),
  (CategoryKind.expense, "Ta'lim", 0, null, 17),
  (CategoryKind.expense, 'Kiyim', 0, null, 18),
  (CategoryKind.expense, "Ko'ngilochar", 0, null, 19),
  (CategoryKind.expense, "Sovg'a", 0, null, 20),
  (CategoryKind.expense, "Uy-ro'zg'or", 0, null, 21),
  (CategoryKind.expense, "O'zim uchun", 0, SystemCode.personalAllocation, 22),
  (CategoryKind.expense, 'Boshqa', 0, null, 99),
];

/// `settle` va `closed_at` uchun vaqt (qiymati ahamiyatsiz — faqat bor/yo'q).
final _now = DateTime.utc(2000);

final class FixtureLedger {
  new _(this.today);

  /// Bitta fixture holati (`cases[i]`) bo'yicha.
  factory load(Json testCase) {
    final ledger = FixtureLedger._(
      LocalDate.parse(testCase['today']! as String),
    ).._seedDefaults();
    final setup = (testCase['setup'] as Json?) ?? const {};
    ledger
      .._applyHousehold(setup['household'] as Json?)
      .._applyCategories(_list(setup['categories']))
      .._applyAccounts(_list(setup['accounts']))
      .._applyOpeningBalances(setup['opening_balances'] as Json?)
      .._applyLimits(_list(setup['limits']))
      .._applyDebts(_list(setup['debts']))
      .._applyGoals(_list(setup['goals']))
      .._applyPlans(_list(setup['plans']));
    _list(setup['transactions']).forEach(ledger._addTransaction);
    ledger._settlePlans();
    return ledger;
  }

  final LocalDate today;
  late Household household;
  final accounts = <String, Account>{};
  final categories = <String, Category>{};
  final limits = <CategoryLimit>[];
  final debts = <String, Debt>{};
  final goals = <Goal>[];
  final plans = <String, PlannedItem>{};
  final transactions = <Transaction>[];

  MonthKey get currentMonth => today.monthKey;

  // ─── Yozuv yo'li ─────────────────────────────────────────────────────────
  void _seedDefaults() {
    for (final (kind, name, shift, system, order) in _templates) {
      categories[name] = Category(
        id: 'category:$name',
        householdId: 'h',
        kind: kind,
        name: name,
        monthShift: shift,
        systemCode: system,
        sortOrder: order,
      );
    }
    for (final (key, name, type) in const [
      ('cash', 'Naqd', AccountType.cash),
      ('card', 'Karta', AccountType.card),
      ('fund', 'Shaxsiy fond', AccountType.personalFund),
    ]) {
      accounts[key] = Account(
        id: 'account:$key',
        householdId: 'h',
        name: name,
        type: type,
        openingBalance: Money.zero,
      );
    }
    household = const Household(
      id: 'h',
      name: 'Fixture',
      personalFund: PersonalFundRule(sourceAccountId: 'account:cash'),
    );
  }

  void _applyHousehold(Json? json) {
    final fund = json?['fund'] as Json?;
    if (fund == null) return;
    final rule = household.personalFund;
    household = household.copyWith(
      personalFund: rule.copyWith(
        mode: fund['mode'] == null
            ? rule.mode
            : PersonalFundMode.fromWire(fund['mode']! as String),
        percentBasisPoints: fund['percent'] == null
            ? rule.percentBasisPoints
            : ((fund['percent']! as num) * 100).round(),
        fixedAmount: fund['fixed_amount'] == null
            ? rule.fixedAmount
            : Money(fund['fixed_amount']! as int),
        day: (fund['day'] as int?) ?? rule.day,
      ),
    );
  }

  void _applyCategories(List<Json> items) {
    for (final item in items) {
      final name = item['name']! as String;
      categories[name] = Category(
        id: 'category:$name',
        householdId: 'h',
        kind: CategoryKind.fromWire(item['kind']! as String),
        name: name,
        monthShift: (item['month_shift'] as int?) ?? 0,
        parentId: item['parent'] == null
            ? null
            : categories[item['parent']]!.id,
      );
    }
  }

  void _applyAccounts(List<Json> items) {
    for (final item in items) {
      final key = item['key']! as String;
      final currency = Currency((item['currency'] as String?) ?? 'UZS');
      accounts[key] = Account(
        id: 'account:$key',
        householdId: 'h',
        name: item['name']! as String,
        type: AccountType.fromWire(item['type']! as String),
        openingBalance: Money((item['opening_balance'] as int?) ?? 0, currency),
      );
    }
  }

  void _applyOpeningBalances(Json? json) {
    json?.forEach((key, value) {
      final account = accounts[key]!;
      accounts[key] = account.copyWith(
        openingBalance: Money(value! as int, account.currency),
      );
    });
  }

  void _applyLimits(List<Json> items) {
    for (final (index, item) in items.indexed) {
      limits.add(
        CategoryLimit(
          id: 'limit:$index',
          householdId: 'h',
          categoryId: categories[item['category']]!.id,
          amount: Money(item['amount']! as int),
        ),
      );
    }
  }

  void _applyDebts(List<Json> items) {
    for (final item in items) {
      final key = item['key']! as String;
      debts[key] = Debt(
        id: 'debt:$key',
        householdId: 'h',
        name: item['name']! as String,
        direction: DebtDirection.fromWire(item['direction']! as String),
        total: Money(item['total']! as int),
        paidBefore: Money((item['paid_before'] as int?) ?? 0),
        monthlyPayment: item['monthly_payment'] == null
            ? null
            : Money(item['monthly_payment']! as int),
      );
    }
  }

  void _applyGoals(List<Json> items) {
    for (final (index, item) in items.indexed) {
      goals.add(
        Goal(
          id: 'goal:$index',
          householdId: 'h',
          name: item['name']! as String,
          target: Money(item['target']! as int),
          savedManual: Money((item['saved'] as int?) ?? 0),
          monthlyContribution: item['monthly'] == null
              ? null
              : Money(item['monthly']! as int),
          deadline: item['deadline'] == null
              ? null
              : MonthKey.parse(item['deadline']! as String),
          accountId: item['account'] == null
              ? null
              : accounts[item['account']]!.id,
        ),
      );
    }
  }

  void _applyPlans(List<Json> items) {
    for (final (index, item) in items.indexed) {
      final key = (item['key'] as String?) ?? '#$index';
      plans[key] = PlannedItem(
        id: 'plan:$key',
        householdId: 'h',
        kind: PlanKind.fromWire(item['kind']! as String),
        name: item['name']! as String,
        categoryId: item['category'] == null
            ? null
            : categories[item['category']]!.id,
        accountId: item['account'] == null
            ? null
            : accounts[item['account']]!.id,
        plannedAmount: item['planned'] == null
            ? null
            : Money(item['planned']! as int),
        dueDate: LocalDate.parse(item['due']! as String),
        budgetMonth: MonthKey.parse(item['month']! as String),
        debtId: item['debt'] == null ? null : debts[item['debt']]!.id,
        systemCode: item['system'] == true
            ? SystemCode.personalAllocation
            : null,
      );
    }
  }

  /// Serverdagi `validate_transaction` + statement triggerlari.
  void _addTransaction(Json item) {
    final kind = TransactionKind.fromWire(item['kind']! as String);
    final account = accounts[item['account']]!;
    final toAccount = item['to'] == null ? null : accounts[item['to']]!;
    if (account.currency != household.baseCurrency) {
      throw UnsupportedError("Ko'p valyuta — E29 (kurs bilan amount_base)");
    }
    final planKey = item['plan'] as String?;
    final plan = planKey == null ? null : plans[planKey]!;
    var category = item['category'] == null
        ? null
        : categories[item['category']]!;
    // BR-062: fonddan kategoriyasiz xarajat — "O'zim uchun".
    if (kind == TransactionKind.expense &&
        category == null &&
        account.isPersonalFund) {
      category = _allocationCategory;
    }
    final amount = Money(item['amount']! as int);
    final occurredOn = LocalDate.parse(item['date']! as String);
    final manual = item.containsKey('month');
    final tx = Transaction(
      id: 'tx:${transactions.length}',
      householdId: 'h',
      kind: kind,
      accountId: account.id,
      toAccountId: toAccount?.id,
      amount: amount,
      amountBase: amount,
      toAmount: item['to_amount'] == null
          ? (kind == TransactionKind.transfer ? amount : null)
          : Money(item['to_amount']! as int),
      categoryId: category?.id,
      occurredOn: occurredOn,
      budgetMonth: manual
          ? MonthKey.parse(item['month']! as String)
          : attributeBudgetMonth(
              kind: kind,
              occurredOn: occurredOn,
              plannedMonth: plan?.budgetMonth,
              incomeShift: category?.monthShift ?? 0,
            ),
      budgetMonthSource: manual
          ? BudgetMonthSource.manual
          : BudgetMonthSource.auto,
      plannedItemId: plan?.id,
      // BR-111: qarzga bog'langan rejaning to'lovi — o'sha qarz.
      debtId: item['debt'] == null ? plan?.debtId : debts[item['debt']]!.id,
      payee: item['payee'] as String?,
    );
    transactions.add(tx);

    if (planKey != null) {
      plans[planKey] = plans[planKey]!.copyWith(paidAmount: _paidFor(plan!.id));
      if (item['settle'] == true) {
        plans[planKey] = plans[planKey]!.copyWith(closedAt: _now);
      }
    }
    if (kind == TransactionKind.income) _recalcFundPlans(tx.budgetMonth);
  }

  Money _paidFor(String planId) => Money.sum(
    transactions
        .where((tx) => tx.plannedItemId == planId && !tx.isDeleted)
        .map((tx) => tx.amountBase),
  );

  /// BR-060: daromadi o'zgargan oyning fond rejasi (faqat foiz rejimi).
  void _recalcFundPlans(MonthKey month) {
    if (household.personalFund.mode != PersonalFundMode.percent) return;
    final income = Money.sum(
      transactions
          .where(
            (tx) =>
                tx.kind == TransactionKind.income &&
                tx.budgetMonth == month &&
                !tx.isDeleted,
          )
          .map((tx) => tx.amountBase),
    );
    plans.updateAll(
      (_, plan) => plan.isFundAllocation && plan.budgetMonth == month
          ? plan.copyWith(
              plannedAmount: personalAllocation(
                income: income,
                rule: household.personalFund,
              ),
            )
          : plan,
    );
  }

  /// BR-071, BR-073: to'langanlik — domen qoidasi (`settlePlan`).
  void _settlePlans() =>
      plans.updateAll((_, plan) => settlePlan(plan, now: _now));

  Category get _allocationCategory =>
      categories.values.firstWhere((category) => category.isSystem);

  // ─── O'qish yordamchilari ────────────────────────────────────────────────
  Account _account(String id) =>
      accounts.values.firstWhere((account) => account.id == id);

  Account get _fund => accounts.values.firstWhere((a) => a.isPersonalFund);

  Iterable<BudgetLine> get _lines sync* {
    for (final tx in transactions) {
      final line = BudgetLine.of(
        tx,
        accountType: _account(tx.accountId).type,
        toAccountType: tx.toAccountId == null
            ? null
            : _account(tx.toAccountId!).type,
        allocationCategoryId: _allocationCategory.id,
      );
      if (line != null) yield line;
    }
  }

  /// BR-021 (serverdagi `private.account_balance`).
  Money balanceOf(Account account) {
    var balance = account.openingBalance;
    for (final tx in transactions.where((tx) => !tx.isDeleted)) {
      if (tx.accountId == account.id) {
        balance += tx.kind == TransactionKind.income ? tx.amount : -tx.amount;
      }
      if (tx.toAccountId == account.id && tx.toAmount != null) {
        balance += tx.toAmount!;
      }
    }
    return balance;
  }

  MonthKey? get _firstRecordMonth {
    final months = [
      for (final tx in transactions)
        if (!tx.isDeleted) tx.budgetMonth,
      for (final plan in plans.values)
        if (plan.deletedAt == null) plan.budgetMonth,
    ]..sort();
    return months.isEmpty ? null : months.first;
  }

  List<MonthFacts> _facts(MonthKey from, MonthKey to) {
    final lines = _lines.toList();
    return [
      for (var month = from; !month.isAfter(to); month = month.shift(1))
        monthFactsOf(month, lines, plans.values),
    ];
  }

  List<MonthFacts> get _toCurrent {
    final first = _firstRecordMonth ?? currentMonth;
    return _facts(first, currentMonth);
  }

  // ─── Hisobotlar (server JSON ko'rinishida) ───────────────────────────────
  Json reportMonth(MonthKey month) {
    final first = _firstRecordMonth ?? month;
    final history = _facts(
      first.isBefore(month) ? first : month,
      month.isAfter(currentMonth) ? month : currentMonth,
    );
    final facts = history.firstWhere((item) => item.month == month);
    final incomePlans = plans.values.where(
      (p) =>
          p.budgetMonth == month &&
          p.kind == PlanKind.income &&
          p.deletedAt == null &&
          p.skippedAt == null,
    );
    final forecast = MonthForecast.of(
      month: facts,
      today: today,
      history: history,
      incomePlanCount: incomePlans.length,
      incomePlansPending: Money.sum([
        for (final plan in incomePlans)
          if (plan.settledAt == null && plan.plannedAmount != null)
            plan.plannedAmount! - plan.paidAmount,
      ]),
    );
    final summary = MonthSummary.of(facts);
    final savings = MonthSavings.of(history, month);
    final lines = _lines.where((line) => line.month == month).toList();

    return {
      'month': month.toIsoDate(),
      'closed': false,
      'is_current': month == currentMonth,
      'totals': {
        'income': facts.income.minor,
        'income_card': facts.incomeCard.minor,
        'income_cash': facts.incomeCash.minor,
        'expense': facts.expense.minor,
        'expense_card': facts.expenseCard.minor,
        'expense_cash': facts.expenseCash.minor,
        'planned': facts.planned.minor,
        'unpaid': facts.unpaid.minor,
        'unknown_count': facts.unknownCount,
        'allocated': facts.allocated.minor,
        'fund_spent': facts.fundSpent.minor,
      },
      'derived': {
        ..._derived(summary),
        'card': summary.card.minor,
        'cash': summary.cash.minor,
      },
      'projection': {
        'days_in_month': forecast.daysInMonth,
        'days_elapsed': forecast.daysElapsed,
        'daily_spend': forecast.dailySpend.minor,
        'month_end_spend': forecast.monthEndSpend.minor,
        'income_received': forecast.incomeReceived.minor,
        'income_expected': forecast.incomeExpected.minor,
        'income_pending': forecast.incomePending,
        'month_end_balance': forecast.monthEndBalance.minor,
        'per_day_available': forecast.perDayAvailable?.minor,
      },
      'by_type': _byType(lines),
      'by_category': _byCategory(month, lines),
      'unpaid': [
        for (final plan in plans.values.where(
          (p) =>
              p.budgetMonth == month &&
              p.deletedAt == null &&
              p.skippedAt == null &&
              p.settledAt == null,
        ))
          {
            'name': plan.name,
            'kind': plan.kind.wire,
            'planned_amount': plan.plannedAmount?.minor,
            'paid_amount': plan.paidAmount.minor,
            'due_date': plan.dueDate.toString(),
            'status': PlannedStatus.of(plan, today).name,
          },
      ],
      'fund': {
        'allocated': facts.allocated.minor,
        'spent': facts.fundSpent.minor,
        'balance': balanceOf(_fund).minor,
      },
      'savings': {
        'before': savings.before.minor,
        'this_month': savings.thisMonth.minor,
        'total': savings.total.minor,
      },
    };
  }

  List<Json> _byType(List<BudgetLine> lines) {
    final byCategory = <String?, (Money, Money)>{};
    for (final line in lines.where((l) => l.kind == BudgetLineKind.income)) {
      final (card, cash) =
          byCategory[line.categoryId] ?? (Money.zero, Money.zero);
      byCategory[line.categoryId] = line.method == PaymentMethod.cash
          ? (card, cash + line.amount)
          : (card + line.amount, cash);
    }
    return [
      for (final MapEntry(key: id, value: (card, cash)) in byCategory.entries)
        {
          'name': categories.values.firstWhere((c) => c.id == id).name,
          'card': card.minor,
          'cash': cash.minor,
        },
    ];
  }

  List<Json> _byCategory(MonthKey month, List<BudgetLine> lines) {
    final actual = <String?, Money>{};
    for (final line in lines.where((l) => l.isSpending)) {
      actual[line.categoryId] =
          (actual[line.categoryId] ?? Money.zero) + line.amount;
    }
    final planned = <String?, Money>{};
    for (final plan in plans.values.where(
      (p) =>
          p.budgetMonth == month &&
          p.deletedAt == null &&
          p.skippedAt == null &&
          p.kind != PlanKind.income,
    )) {
      final id =
          plan.categoryId ??
          (plan.kind == PlanKind.allocation ? _allocationCategory.id : null);
      planned[id] =
          (planned[id] ?? Money.zero) + (plan.plannedAmount ?? Money.zero);
    }
    final expenseCategories = categories.values.where(
      (c) => c.kind == CategoryKind.expense && c.deletedAt == null,
    );
    return [
      for (final category in expenseCategories)
        ?_categoryRow(category, expenseCategories, actual, planned),
    ];
  }

  Json? _categoryRow(
    Category category,
    Iterable<Category> all,
    Map<String?, Money> actual,
    Map<String?, Money> planned,
  ) {
    final own = actual[category.id] ?? Money.zero;
    final total =
        own +
        Money.sum([
          for (final child in all.where((c) => c.parentId == category.id))
            actual[child.id] ?? Money.zero,
        ]);
    final limit = limits
        .where((l) => l.categoryId == category.id && l.deletedAt == null)
        .map((l) => l.amount)
        .firstOrNull;
    final plannedAmount = planned[category.id] ?? Money.zero;
    if (plannedAmount.isZero && total.isZero && limit == null) return null;
    return {
      'name': category.name,
      'parent_id': category.parentId,
      'planned': plannedAmount.minor,
      'actual': own.minor,
      'actual_total': total.minor,
      'limit': limit?.minor,
      'limit_ratio': limitRatio(total, limit),
      'limit_status': limitStatus(total, limit)?.name,
    };
  }

  Json reportYear(int year) {
    final months = _facts(MonthKey(year, 1), MonthKey(year, 12));
    Money sum(Money Function(MonthFacts) of) => Money.sum(months.map(of));
    final income = sum((m) => m.income);
    final expense = sum((m) => m.expense);
    final allocated = sum((m) => m.allocated);
    final fundSpent = sum((m) => m.fundSpent);
    return {
      'year': year,
      'months': [
        for (final m in months)
          {
            'month': m.month.toIsoDate(),
            'income': m.income.minor,
            'expense': m.expense.minor,
            'allocated': m.allocated.minor,
            'fund_spent': m.fundSpent.minor,
            'closed': false,
            'has_records': m.hasRecords,
            ..._derived(MonthSummary.of(m)),
          },
      ],
      'totals': {
        'income': income.minor,
        'expense': expense.minor,
        'allocated': allocated.minor,
        'fund_spent': fundSpent.minor,
        ..._derived(
          MonthSummary.fromTotals(
            income: income,
            expense: expense,
            unpaid: sum((m) => m.unpaid),
            allocated: allocated,
            fundSpent: fundSpent,
            planned: sum((m) => m.planned),
          ),
        ),
      },
    };
  }

  Json reportSavings() {
    final months = _toCurrent;
    final totals = OverallTotals.of(months);
    return {
      'months': [
        for (final row in savingsTable(months, current: currentMonth))
          {
            'month': row.month.toIsoDate(),
            'income': row.income.minor,
            'expense': row.expense.minor,
            'balance': row.balance.minor,
            'accumulated': row.accumulated.minor,
            'is_current': row.isCurrent,
          },
      ],
      'summary': {
        'months_count': totals.monthsCount,
        'total_income': totals.totalIncome.minor,
        'total_expense': totals.totalExpense.minor,
        'total_balance': totals.totalBalance.minor,
        'total_saved': totals.totalSaved.minor,
        'avg_monthly_saved': totals.avgMonthlySaved.minor,
        'avg_monthly_expense': totals.avgMonthlyExpense.minor,
      },
    };
  }

  Json reportPersonalFund(MonthKey from, MonthKey to) {
    final lines = _lines.toList();
    Money total(BudgetLineKind kind) =>
        Money.sum(lines.where((l) => l.kind == kind).map((l) => l.amount));
    return {
      'balance': balanceOf(_fund).minor,
      'total_allocated': total(BudgetLineKind.allocation).minor,
      'total_spent': total(BudgetLineKind.fundSpent).minor,
      'months': [
        for (final m in _facts(from, to))
          {
            'month': m.month.toIsoDate(),
            'allocated': m.allocated.minor,
            'spent': m.fundSpent.minor,
          },
      ],
    };
  }

  Json reportDebts() {
    final live = transactions.where((tx) => !tx.isDeleted);
    final rows = <(Debt, DebtProgress)>[];
    for (final debt in debts.values) {
      final payments = live.where((tx) => tx.debtId == debt.id).toList();
      final pending = plans.values
          .where(
            (p) =>
                p.debtId == debt.id &&
                p.deletedAt == null &&
                p.settledAt == null &&
                p.skippedAt == null,
          )
          .toList();
      rows.add((
        debt,
        DebtProgress.of(
          debt,
          paidInApp: Money.sum(payments.map((tx) => tx.amount)),
          paymentCount: payments.length,
          pendingAmount: Money.sum([
            for (final plan in pending) ?plan.remaining,
          ]),
          pendingCount: pending.length,
          currentMonth: currentMonth,
        ),
      ));
    }
    final totals = DebtTotals.of(
      rows,
      baseCurrency: household.baseCurrency,
      paidThisMonth: Money.sum(
        live
            .where((tx) => tx.debtId != null && tx.budgetMonth == currentMonth)
            .map((tx) => tx.amountBase),
      ),
    );
    return {
      'debts': [
        for (final (debt, p) in rows)
          {
            'name': debt.name,
            'direction': debt.direction.wire,
            'total': debt.total.minor,
            'paid_before': debt.paidBefore.minor,
            'monthly_payment': debt.monthlyPayment?.minor,
            'archived': debt.archivedAt != null,
            'paid_in_app': p.paidInApp.minor,
            'pending_amount': p.pendingAmount.minor,
            'pending_count': p.pendingCount,
            'remaining': p.remaining.minor,
            'progress': p.progress,
            'months_left': p.monthsLeft,
            'end_month': p.endMonth?.toIsoDate(),
            'status': p.status.name,
          },
      ],
      'totals': {
        'i_owe': totals.iOwe.minor,
        'owed_to_me': totals.owedToMe.minor,
        'monthly_obligation': totals.monthlyObligation.minor,
        'net': totals.net.minor,
        'paid_this_month': totals.paidThisMonth.minor,
      },
    };
  }

  Json reportGoals() {
    final average = OverallTotals.of(_toCurrent).avgMonthlySaved;
    return {
      'avg_monthly_saved': average.minor,
      'goals': [
        for (final goal in goals)
          if (GoalProgress.of(
                goal,
                avgMonthlySaved: average,
                currentMonth: currentMonth,
                accountBalance: goal.accountId == null
                    ? null
                    : balanceOf(_account(goal.accountId!)),
              )
              case final p)
            {
              'name': goal.name,
              'target': goal.target.minor,
              'saved': p.saved.minor,
              'remaining': p.remaining.minor,
              'progress': p.progress,
              'monthly': p.monthly?.minor,
              'monthly_source': p.monthlySource?.name,
              'months_left': p.monthsLeft,
              'end_month': p.endMonth?.toIsoDate(),
              'deadline': goal.deadline?.toIsoDate(),
              'on_track': p.onTrack,
            },
      ],
    };
  }

  /// Fixture `expect[i]` qadamini bajaradi.
  Json call(String rpc, Json args) => switch (rpc) {
    'report_month' => reportMonth(MonthKey.parse(args['month']! as String)),
    'report_year' => reportYear(args['year']! as int),
    'report_savings' => reportSavings(),
    'report_personal_fund' => reportPersonalFund(
      MonthKey.parse(args['from']! as String),
      MonthKey.parse(args['to']! as String),
    ),
    'report_debts' => reportDebts(),
    'report_goals' => reportGoals(),
    _ => throw UnsupportedError("Mobil hisobotida yo'q RPC: $rpc"),
  };
}

Json _derived(MonthSummary summary) => {
  'balance': summary.balance.minor,
  'forecast': summary.forecast.minor,
  'saved': summary.saved.minor,
  'saved_ratio': summary.savedRatio,
  'spent_ratio': summary.spentRatio,
  'plan_ratio': summary.planRatio,
};

List<Json> _list(Object? value) =>
    ((value as List<Object?>?) ?? const []).cast<Json>();
