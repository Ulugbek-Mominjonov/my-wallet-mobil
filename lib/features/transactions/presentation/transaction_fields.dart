import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/name_dialog.dart';
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/features/transactions/application/add_transaction_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Hisob chiplari (fond hisobi ham — BR-062 bo'yicha fonddan sarf).
class AccountChips extends ConsumerWidget {
  const new({
    required this.selectedId,
    required this.onSelected,
    this.label,
    this.excludeId,
    this.excludeFund = false,
    super.key,
  });

  final String? selectedId;
  final ValueChanged<String> onSelected;
  final String? label;

  /// O'tkazmada manba hisob ro'yxatdan chiqariladi.
  final String? excludeId;

  /// BR-063: fondga daromad yozilmaydi.
  final bool excludeFund;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final visible = [
      for (final account in accounts)
        if (account.id != excludeId &&
            !(excludeFund && account.type == AccountType.personalFund))
          account,
    ];
    return _Section(
      label: label,
      child: Wrap(
        spacing: AppSpacing.sm,
        children: [
          for (final account in visible)
            ChoiceChip(
              label: Text(account.name),
              selected: account.id == selectedId,
              onSelected: (_) => onSelected(account.id),
            ),
        ],
      ),
    );
  }
}

/// Kategoriya to'ri: oxirgi ishlatilganlari oldinda (BR-140), qidiruv bilan.
class CategoryGrid extends ConsumerStatefulWidget {
  const new({
    required this.kind,
    required this.selectedId,
    required this.onSelected,
    this.onCreate,
    super.key,
  });

  final CategoryKind kind;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  /// BR-035: joyida yangi kategoriya (nom — dialogdan).
  final Future<void> Function(String name)? onCreate;

  @override
  ConsumerState<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends ConsumerState<CategoryGrid> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final all =
        ref.watch(categoriesProvider(widget.kind)).value ?? const <Category>[];
    final recent =
        ref.watch(recentCategoriesProvider(widget.kind)).value ?? const [];
    final query = _query.trim().toLowerCase();
    final matching = [
      for (final category in all)
        if (query.isEmpty || category.name.toLowerCase().contains(query))
          category,
    ]..sort((a, b) => _rank(recent, a).compareTo(_rank(recent, b)));

    return _Section(
      label: l10n.fieldCategory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (all.length > 8)
            TextField(
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.categorySearch,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final category in matching)
                ChoiceChip(
                  label: Text(category.name),
                  selected: category.id == widget.selectedId,
                  onSelected: (selected) =>
                      widget.onSelected(selected ? category.id : null),
                ),
              if (widget.onCreate != null)
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(l10n.categoryNew),
                  onPressed: () => unawaited(_create(context)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final l10n = AppL10n.of(context);
    final name = await showNameDialog(
      context,
      title: l10n.categoryNew,
      label: l10n.fieldCategory,
      initial: _query.trim(),
    );
    if (name == null) return;
    await widget.onCreate!(name);
    if (mounted) setState(() => _query = '');
  }

  /// Oxirgi ishlatilganlar oldinda, qolganlari — o'z tartibida.
  int _rank(List<String> recent, Category category) {
    final index = recent.indexOf(category.id);
    return index >= 0 ? index : recent.length + category.sortOrder;
  }
}

/// Sana chiplari: Bugun / Kecha / kalendar (BR-140).
class DateChips extends StatelessWidget {
  const new({
    required this.today,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final LocalDate today;
  final LocalDate? selected;
  final ValueChanged<LocalDate> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final yesterday = today.addDays(-1);
    final current = selected ?? today;
    final custom = current != today && current != yesterday;
    return _Section(
      child: Wrap(
        spacing: AppSpacing.sm,
        children: [
          ChoiceChip(
            label: Text(l10n.dateToday),
            selected: current == today,
            onSelected: (_) => onSelected(today),
          ),
          ChoiceChip(
            label: Text(l10n.dateYesterday),
            selected: current == yesterday,
            onSelected: (_) => onSelected(yesterday),
          ),
          ChoiceChip(
            avatar: const Icon(Icons.calendar_today, size: 16),
            label: Text(custom ? _format(current) : l10n.dateChoose),
            selected: custom,
            onSelected: (_) async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(current.year, current.month, current.day),
                firstDate: DateTime(today.year - 5),
                lastDate: DateTime(today.year, today.month, today.day),
              );
              if (picked != null) {
                onSelected(LocalDate(picked.year, picked.month, picked.day));
              }
            },
          ),
        ],
      ),
    );
  }

  String _format(LocalDate date) =>
      '${date.day}.${date.month.toString().padLeft(2, '0')}';
}

/// BR-056: joy nomi tarixdan to'ldiriladi; tanlanganda oxirgi
/// kategoriya va hisob ham taklif qilinadi.
class PayeeField extends ConsumerWidget {
  const new({required this.state, super.key});

  final AddTransactionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final controller = ref.read(addTransactionProvider.notifier);
    return _Section(
      child: Autocomplete<PayeeSuggestion>(
        displayStringForOption: (option) => option.payee,
        optionsBuilder: (value) async {
          if (value.text.isEmpty) return const <PayeeSuggestion>[];
          return await ref.read(payeeSuggestionsProvider(value.text).future);
        },
        onSelected: (option) => controller.setPayee(
          option.payee,
          categoryId: option.categoryId,
          accountId: option.accountId,
        ),
        fieldViewBuilder: (context, textController, focusNode, onSubmitted) =>
            TextField(
              controller: textController,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.fieldPayee),
              onChanged: controller.setPayee,
            ),
      ),
    );
  }
}

/// 👤 fond bilan bog'liq izoh (BR-061, BR-062): ajratma, qaytish yoki
/// fonddan sarf — oy qoldig'iga ta'siri tushunarli bo'lsin.
class FundHint extends ConsumerWidget {
  const new({required this.state, super.key});

  final AddTransactionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    bool isFund(String? id) =>
        accounts.any((a) => a.id == id && a.type == AccountType.personalFund);
    final text = switch (state.kind) {
      TransactionKind.transfer when isFund(state.toAccountId) =>
        l10n.fundAllocationHint,
      TransactionKind.transfer when isFund(state.accountId) =>
        l10n.fundReturnHint,
      TransactionKind.expense when isFund(state.accountId) =>
        l10n.fundSpendHint,
      _ => null,
    };
    if (text == null) return const SizedBox.shrink();
    return _Section(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.tertiary),
      ),
    );
  }
}

/// Teglar (bir nechta) — bo'lmasa ko'rinmaydi.
class TagChips extends ConsumerWidget {
  const new({required this.selected, super.key});

  final Set<String> selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    if (tags.isEmpty) return const SizedBox.shrink();
    final controller = ref.read(addTransactionProvider.notifier);
    return _Section(
      label: AppL10n.of(context).fieldTags,
      child: Wrap(
        spacing: AppSpacing.sm,
        children: [
          for (final tag in tags)
            FilterChip(
              label: Text(tag.name),
              selected: selected.contains(tag.id),
              onSelected: (_) => controller.toggleTag(tag.id),
            ),
        ],
      ),
    );
  }
}

/// BR-112: amalni qarzga bog'lash (qarz bo'lmasa — ko'rinmaydi).
class DebtChips extends ConsumerWidget {
  const new({required this.selectedId, super.key});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtsProvider).value ?? const <Debt>[];
    if (debts.isEmpty) return const SizedBox.shrink();
    final controller = ref.read(addTransactionProvider.notifier);
    return _Section(
      label: AppL10n.of(context).fieldDebt,
      child: Wrap(
        spacing: AppSpacing.sm,
        children: [
          for (final debt in debts)
            ChoiceChip(
              label: Text(debt.name),
              selected: debt.id == selectedId,
              onSelected: (selected) =>
                  controller.selectDebt(selected ? debt.id : null),
            ),
        ],
      ),
    );
  }
}

class NoteField extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _Section(
    child: TextField(
      decoration: InputDecoration(labelText: AppL10n.of(context).fieldNote),
      textCapitalization: TextCapitalization.sentences,
      onChanged: ref.read(addTransactionProvider.notifier).setNote,
    ),
  );
}

class _Section extends StatelessWidget {
  const new({required this.child, this.label});

  final Widget child;
  final String? label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
        ],
        child,
      ],
    ),
  );
}
