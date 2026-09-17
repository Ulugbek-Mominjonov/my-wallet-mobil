import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/actions.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../di/providers.dart';
import '../../../di/state_providers.dart';

/// 🩺 Tekshirish va tuzatish — Sheets'dagi `tashxisSkan_` + `tamirla_`
/// falsafasining davomi: **avtomatik aniqla → avtomatik tuzat → hisobot**.
///
/// Klientdagi tekshiruv joriy va oldingi oy bilan cheklanadi (≈60 hujjat) —
/// butun tarix kechasi serverdagi cron tomonidan tekshiriladi (§5.5).
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  List<ReconcileResult>? _results;
  bool _busy = false;

  Future<void> _check() async {
    setState(() => _busy = true);
    final month = ref.read(selectedMonthProvider);
    final months = <MonthKey>[month, month.previous];
    final reconcile = ref.read(reconcileMonthProvider);
    final monthRepository = ref.read(monthRepositoryProvider);
    final expenses = ref.read(expenseRepositoryProvider);
    final incomes = ref.read(incomeRepositoryProvider);
    final spends = ref.read(personalSpendRepositoryProvider);

    final results = <ReconcileResult>[];
    for (final key in months) {
      final stored = await monthRepository.fetch(key);
      final monthExpenses = await expenses.fetchMonthAll(key);
      final monthIncomes = await incomes.fetchMonth(key, limit: 200);
      final monthSpends = await spends.fetchRecent(limit: 200);
      results.add(
        reconcile.check(
          stored: stored,
          incomes: monthIncomes.items,
          expenses: monthExpenses,
          personalSpends: monthSpends.items
              .where((item) => item.monthKey == key)
              .toList(),
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _results = results;
      _busy = false;
    });
  }

  Future<void> _fix() async {
    final results = _results;
    if (results == null) return;
    await runAction(
      context,
      successMessage: '✅ Agregat tuzatildi',
      action: () => ref.read(reconcileMonthProvider).fix(results),
    );
    if (mounted) await _check();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final report = ref.watch(healthProvider).value;
    final results = _results;
    final drifted = results
            ?.where((item) => !item.isClean)
            .expand((item) => item.drift.fields)
            .toList() ??
        const <FieldDrift>[];

    return Scaffold(
      appBar: AppBar(title: const Text(Uz.health)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          if (report != null)
            SectionCard(
              title: 'Serverdagi oxirgi tekshiruv',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    report.lastRun == null
                        ? 'Hali ishga tushmagan'
                        : Fmt.day(report.lastRun!),
                  ),
                  Text(
                    report.isHealthy
                        ? '✅ Farq topilmadi'
                        : '⚠️ ${report.driftCount} ta farq, '
                            '${report.fixedCount} ta tuzatildi',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: report.isHealthy
                          ? AppTheme.positive
                          : AppTheme.warning,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _check,
            icon: const Icon(Icons.health_and_safety),
            label: Text(_busy ? 'Tekshirilmoqda…' : 'Hozir tekshirish'),
          ),
          const SizedBox(height: 12),
          if (results != null)
            SectionCard(
              title: 'Natija',
              child: drifted.isEmpty
                  ? const Text("✅ Agregat xom yozuvlarga to'liq mos")
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (final result in results)
                          if (!result.isClean)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    Fmt.monthTitle(result.drift.monthKey),
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  for (final field in result.drift.fields)
                                    Text(
                                      '${field.field}: ${field.stored} → '
                                      '${field.computed}',
                                      style: theme.textTheme.labelSmall,
                                    ),
                                ],
                              ),
                            ),
                        const SizedBox(height: 8),
                        FilledButton.tonalIcon(
                          onPressed: _fix,
                          icon: const Icon(Icons.build),
                          label: const Text('Tuzatish'),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
