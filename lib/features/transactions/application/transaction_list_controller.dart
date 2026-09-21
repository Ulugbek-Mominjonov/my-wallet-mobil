import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Amallar ro'yxati holati (E15-T06): filtr va nechta sahifa yuklangan.
@immutable
final class TransactionListState {
  const new({required this.filter, this.pages = 1});

  final TransactionFilter filter;
  final int pages;

  int get limit => LedgerDao.pageSize * pages;

  TransactionListState copyWith({TransactionFilter? filter, int? pages}) =>
      TransactionListState(
        filter: filter ?? this.filter,
        pages: pages ?? this.pages,
      );
}

final NotifierProvider<TransactionListController, TransactionListState>
transactionListProvider = NotifierProvider(TransactionListController.new);

/// Ro'yxat — joriy oy (byudjet vaqt zonasida) bilan boshlanadi.
base class TransactionListController extends Notifier<TransactionListState> {
  @override
  TransactionListState build() {
    ref.watch(currentHouseholdIdProvider);
    final today = ref.watch(clockProvider).today();
    return TransactionListState(
      filter: TransactionFilter(month: today.monthKey),
    );
  }

  /// Filtr o'zgarsa — birinchi sahifadan.
  void setFilter(TransactionFilter filter) =>
      state = TransactionListState(filter: filter);

  void shiftMonth(int months) {
    final month = state.filter.month;
    if (month == null) return;
    setFilter(state.filter.copyWith(month: month.shift(months)));
  }

  /// Keyingi sahifa (ro'yxat oxiriga yetganda).
  void loadMore() => state = state.copyWith(pages: state.pages + 1);

  /// BR-009: o'chirish — qaytarish uchun nusxa qaytadi.
  Future<Result<Transaction>> delete(
    String id, {
    bool confirmClosedMonth = false,
  }) async {
    final deps = ref.read(domainDepsProvider);
    if (deps == null) return const Err(UnauthorizedFailure());
    return await DeleteTransaction(deps)(
      id,
      confirmClosedMonth: confirmClosedMonth,
    );
  }

  Future<Result<Transaction>> undoDelete(Transaction snapshot) async {
    final deps = ref.read(domainDepsProvider);
    if (deps == null) return const Err(UnauthorizedFailure());
    return await UndoDeleteTransaction(deps)(snapshot);
  }
}

/// Joriy filtr bo'yicha amallar (reaktiv; `limit` — yuklangan sahifalar).
final StreamProvider<List<TransactionRow>> transactionRowsProvider =
    StreamProvider((ref) {
      final householdId = ref.watch(currentHouseholdIdProvider);
      if (householdId == null) return const Stream.empty();
      final list = ref.watch(transactionListProvider);
      return ref
          .watch(appDatabaseProvider)
          .ledgerDao
          .watchTransactionPage(
            householdId,
            filter: list.filter,
            limit: list.limit,
          );
    });

/// BR-055: filtrdagi oy yopilganmi (banner uchun).
final FutureProvider<bool> selectedMonthClosedProvider = FutureProvider((
  ref,
) async {
  final month = ref.watch(transactionListProvider).filter.month;
  final deps = ref.watch(domainDepsProvider);
  if (month == null || deps == null) return false;
  // Sinxron `months` jadvalini yangilasa ham qayta hisoblansin.
  ref.watch(transactionRowsProvider);
  return await deps.households.isMonthClosed(month);
});

/// Kun bo'yicha guruh va kunlik jami (asosiy valyutada, BR-090 ma'nosida:
/// daromad va xarajat; o'tkazma jamiga kirmaydi).
typedef DayGroup = ({
  LocalDate day,
  List<TransactionRow> rows,
  int income,
  int expense,
});

List<DayGroup> groupByDay(List<TransactionRow> rows) {
  final groups = <DayGroup>[];
  LocalDate? day;
  var dayRows = <TransactionRow>[];
  var income = 0;
  var expense = 0;

  void flush() {
    if (day == null) return;
    groups.add((day: day, rows: dayRows, income: income, expense: expense));
  }

  // Qatorlar sana bo'yicha tartiblangan — bir o'tishda guruhlanadi.
  for (final row in rows) {
    final rowDay = LocalDate.parse(row.occurredOn);
    if (rowDay != day) {
      flush();
      day = rowDay;
      dayRows = [];
      income = 0;
      expense = 0;
    }
    dayRows.add(row);
    if (row.kind == TransactionKind.income.wire) income += row.amountBase;
    if (row.kind == TransactionKind.expense.wire) expense += row.amountBase;
  }
  flush();
  return groups;
}
