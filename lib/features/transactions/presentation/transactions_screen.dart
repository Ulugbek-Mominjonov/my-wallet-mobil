import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/features/transactions/application/transaction_list_controller.dart';
import 'package:my_wallet/features/transactions/presentation/add_transaction_screen.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// "Amallar" bo'limi (E15-T06): oy bo'yicha, kun guruhlari va kunlik jami,
/// qidiruv va filtrlar (BR-202), surib o'chirish + qaytarish (BR-009),
/// bosish — tahrirlash; yopilgan oy banneri (BR-055).
class TransactionsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsState();
}

class _TransactionsState extends ConsumerState<TransactionsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Oxiriga yaqinlashganda keyingi sahifa (keyset — LIMIT oshadi).
  void _onScroll() {
    if (_scroll.position.extentAfter > 400) return;
    final rows = ref.read(transactionRowsProvider).value ?? const [];
    final state = ref.read(transactionListProvider);
    if (rows.length >= state.limit) {
      ref.read(transactionListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final list = ref.watch(transactionListProvider);
    final rows = ref.watch(transactionRowsProvider).value;
    final closed = ref.watch(selectedMonthClosedProvider).value ?? false;
    final groups = rows == null ? const <DayGroup>[] : groupByDay(rows);

    return Column(
      children: [
        _MonthBar(month: list.filter.month),
        _Filters(filter: list.filter),
        if (closed)
          MaterialBanner(
            content: Text(l10n.monthClosedBanner),
            leading: const Icon(Icons.lock_clock),
            actions: const [SizedBox.shrink()],
          ),
        Expanded(
          child: rows == null
              ? const Center(child: CircularProgressIndicator())
              : groups.isEmpty
              ? EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: list.filter.isEmpty
                      ? l10n.transactionsEmpty
                      : l10n.transactionsEmptyFiltered,
                  message: '',
                )
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: groups.length,
                  itemBuilder: (context, index) =>
                      _DaySection(group: groups[index]),
                ),
        ),
      ],
    );
  }
}

class _MonthBar extends ConsumerWidget {
  const new({required this.month});

  final MonthKey? month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = this.month;
    if (month == null) return const SizedBox.shrink();
    final l10n = AppL10n.of(context);
    final controller = ref.read(transactionListProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: l10n.monthPrevious,
          icon: const Icon(Icons.chevron_left),
          onPressed: () => controller.shiftMonth(-1),
        ),
        Text(
          formatMonthTitle(l10n, year: month.year, month: month.month),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => controller.shiftMonth(1),
        ),
      ],
    );
  }
}

/// Qidiruv va filtr chiplari (tur, kategoriya, hisob, teg).
class _Filters extends ConsumerWidget {
  const new({required this.filter});

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final controller = ref.read(transactionListProvider.notifier);
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    final categories = <Category>[
      ...?ref.watch(categoriesProvider(CategoryKind.expense)).value,
      ...?ref.watch(categoriesProvider(CategoryKind.income)).value,
    ];
    void set(TransactionFilter next) => controller.setFilter(next);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.searchHint,
            ),
            onChanged: (value) => set(filter.copyWith(search: value)),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              for (final (kind, label) in [
                (null, l10n.filterAll),
                (TransactionKind.expense, l10n.kindExpense),
                (TransactionKind.income, l10n.kindIncome),
                (TransactionKind.transfer, l10n.kindTransfer),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: filter.kind == kind,
                    onSelected: (_) => set(
                      kind == null
                          ? filter.copyWith(clearKind: true)
                          : filter.copyWith(kind: kind),
                    ),
                  ),
                ),
              _PickerChip<Category>(
                label: l10n.fieldCategory,
                items: categories,
                selectedId: filter.categoryId,
                idOf: (c) => c.id,
                nameOf: (c) => c.name,
                onSelected: (id) => set(
                  id == null
                      ? filter.copyWith(clearCategory: true)
                      : filter.copyWith(categoryId: id),
                ),
              ),
              _PickerChip<Account>(
                label: l10n.fieldAccount,
                items: accounts,
                selectedId: filter.accountId,
                idOf: (a) => a.id,
                nameOf: (a) => a.name,
                onSelected: (id) => set(
                  id == null
                      ? filter.copyWith(clearAccount: true)
                      : filter.copyWith(accountId: id),
                ),
              ),
              if (tags.isNotEmpty)
                _PickerChip<Tag>(
                  label: l10n.fieldTags,
                  items: tags,
                  selectedId: filter.tagId,
                  idOf: (t) => t.id,
                  nameOf: (t) => t.name,
                  onSelected: (id) => set(
                    id == null
                        ? filter.copyWith(clearTag: true)
                        : filter.copyWith(tagId: id),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ro'yxatdan bitta qiymat tanlanadigan filtr chipi.
class _PickerChip<T> extends StatelessWidget {
  const new({
    required this.label,
    required this.items,
    required this.selectedId,
    required this.idOf,
    required this.nameOf,
    required this.onSelected,
  });

  final String label;
  final List<T> items;
  final String? selectedId;
  final String Function(T) idOf;
  final String Function(T) nameOf;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = items.where((i) => idOf(i) == selectedId).firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(selected == null ? label : nameOf(selected)),
        selected: selected != null,
        onSelected: (_) async {
          if (selected != null) {
            onSelected(null);
            return;
          }
          final id = await showModalBottomSheet<String>(
            context: context,
            builder: (context) => SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final item in items)
                    ListTile(
                      title: Text(nameOf(item)),
                      onTap: () => Navigator.pop(context, idOf(item)),
                    ),
                ],
              ),
            ),
          );
          if (id != null) onSelected(id);
        },
      ),
    );
  }
}

class _DaySection extends ConsumerWidget {
  const new({required this.group});

  final DayGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final day = group.day;
    final monthName = l10n.monthName('${day.month}');
    final title = l10n.dayTitle(
      day.day,
      Localizations.localeOf(context).languageCode == 'en'
          ? monthName
          : monthName.toLowerCase(),
      l10n.weekdayName('${day.weekday}'),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.labelLarge)),
              if (group.income > 0) ...[
                MoneyText(
                  group.income,
                  tone: MoneyTone.income,
                  signed: true,
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (group.expense > 0)
                MoneyText(
                  -group.expense,
                  tone: MoneyTone.expense,
                  signed: true,
                  style: theme.textTheme.labelMedium,
                ),
            ],
          ),
        ),
        for (final row in group.rows) _TransactionTile(row: row),
      ],
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  const new({required this.row});

  final TransactionRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final kind = TransactionKind.fromWire(row.kind);
    final accounts = {
      for (final a in ref.watch(accountsProvider).value ?? const <Account>[])
        a.id: a,
    };
    final categories = {
      for (final c in [
        ...ref.watch(categoriesProvider(CategoryKind.expense)).value ??
            const <Category>[],
        ...ref.watch(categoriesProvider(CategoryKind.income)).value ??
            const <Category>[],
      ])
        c.id: c,
    };
    final account = accounts[row.accountId];
    final category = categories[row.categoryId]?.name;
    final title = switch (kind) {
      TransactionKind.transfer =>
        '${account?.name ?? '?'} → ${accounts[row.toAccountId]?.name ?? '?'}',
      _ => row.payee ?? category ?? l10n.kindExpense,
    };
    final subtitle = [
      if (kind != TransactionKind.transfer && row.payee != null) ?category,
      if (kind != TransactionKind.transfer) ?account?.name,
      ?row.note,
    ].join(' · ');
    final currency = account?.openingBalance.currency.code ?? 'UZS';

    return Dismissible(
      key: ValueKey(row.id),
      direction: DismissDirection.endToStart,
      background: ColoredBox(
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: AppSpacing.xl),
            child: Icon(Icons.delete_outline),
          ),
        ),
      ),
      confirmDismiss: (_) => _delete(context, ref),
      child: ListTile(
        leading: Icon(switch (kind) {
          TransactionKind.income => Icons.south_west,
          TransactionKind.expense => Icons.north_east,
          TransactionKind.transfer => Icons.swap_horiz,
        }),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: subtitle.isEmpty
            ? null
            : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: MoneyText(
          switch (kind) {
            TransactionKind.expense => -row.amount,
            _ => row.amount,
          },
          currency: currency,
          signed: kind != TransactionKind.transfer,
          tone: switch (kind) {
            TransactionKind.income => MoneyTone.income,
            TransactionKind.expense => MoneyTone.expense,
            TransactionKind.transfer => MoneyTone.neutral,
          },
        ),
        onTap: () => context.push('/transaction/${row.id}'),
      ),
    );
  }

  /// BR-009: o'chirish + 5 s "Bekor qilish"; yopilgan oy — tasdiq (BR-055).
  Future<bool> _delete(
    BuildContext context,
    WidgetRef ref, {
    bool confirmClosedMonth = false,
  }) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(transactionListProvider.notifier);
    final result = await controller.delete(
      row.id,
      confirmClosedMonth: confirmClosedMonth,
    );
    if (!context.mounted) return false;
    switch (result) {
      case Ok(:final value):
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(l10n.deleted),
            action: SnackBarAction(
              label: l10n.actionUndo,
              onPressed: () => unawaited(controller.undoDelete(value)),
            ),
          ),
        );
        return true;
      case Err(failure: MonthClosedWarning(blocking: false)):
        if (await confirmClosedMonthDialog(context) && context.mounted) {
          return await _delete(context, ref, confirmClosedMonth: true);
        }
        return false;
      case Err(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(transactionErrorText(l10n, failure))),
        );
        return false;
    }
  }
}
