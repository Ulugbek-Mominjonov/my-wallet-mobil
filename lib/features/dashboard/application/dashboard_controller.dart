import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/dashboard/application/month_report.dart';
import 'package:my_wallet/features/household/application/members_controller.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Dashboard'da tanlangan oy (standart — joriy oy, byudjet vaqt zonasida).
final NotifierProvider<SelectedMonth, MonthKey> dashboardMonthProvider =
    NotifierProvider(SelectedMonth.new);

/// Ekranda tanlangan oy (Xulosa, To'lovlar): ‹ › yoki tanlash.
final class SelectedMonth extends Notifier<MonthKey> {
  @override
  MonthKey build() => ref.watch(clockProvider).today().monthKey;

  void shift(int months) => state = state.shift(months);

  // Notifier holati tashqaridan o'rnatiladi (oy tanlash).
  // ignore: use_setters_to_change_properties
  void select(MonthKey month) => state = month;
}

/// Tanlangan oy hisobi — lokal bazadan; amallar, rejalar, hisoblar va
/// spravochniklar o'zgarsa (sinxron ham) qayta hisoblanadi.
final StreamProvider<MonthReport?> monthReportProvider = StreamProvider((
  ref,
) async* {
  final householdId = ref.watch(currentHouseholdIdProvider);
  final startup = ref.watch(startupProvider);
  if (householdId == null || startup is! StartupReady) {
    yield null;
    return;
  }
  final db = ref.watch(appDatabaseProvider);
  final loader = MonthReportLoader(
    db,
    householdId,
    base: startup.currency,
    today: ref.watch(clockProvider).today(),
  );
  final month = ref.watch(dashboardMonthProvider);
  yield await loader.load(month);
  await for (final _ in db.tableUpdates(
    TableUpdateQuery.onAllTables([
      db.transactions,
      db.plannedItems,
      db.accounts,
      db.categories,
      db.categoryLimits,
      db.months,
      db.debts,
      db.goals,
    ]),
  )) {
    yield await loader.load(month);
  }
});

/// E30-T05: a'zolar kesimi — tanlangan oyda kim qancha sarfladi (lokal).
/// Ismlar — a'zolar keshidan; bitta a'zoda blok ko'rsatilmaydi.
final FutureProvider<List<({String name, Money spent})>>
memberSpendingProvider = FutureProvider((ref) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  final startup = ref.watch(startupProvider);
  final members = ref.watch(cachedMembersProvider).value ?? const [];
  if (householdId == null || startup is! StartupReady || members.length < 2) {
    return const [];
  }
  final spending = await ref
      .watch(appDatabaseProvider)
      .ledgerDao
      .spendingByMember(
        householdId,
        ref.watch(dashboardMonthProvider),
        base: startup.currency,
      );
  final lines = [
    for (final member in members)
      (
        name: member.name,
        spent: spending[member.userId] ?? Money(0, startup.currency),
      ),
  ]..sort((a, b) => b.spent.minor.compareTo(a.spent.minor));
  return [
    for (final line in lines)
      if (line.spent.isPositive) line,
  ];
});
