import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/widgets/actions.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../di/providers.dart';

/// Daromad turi → qaysi oyga tegishli (§2.1).
///
/// Qoida o'zgarsa ESKI YOZUVLAR ham ko'chishi kerak. Shuning uchun avval
/// "nechta yozuv ko'chadi" preview ko'rsatiladi, foydalanuvchi tasdiqlagach
/// batch bilan qo'llanadi (§6.5).
class IncomeRulesScreen extends ConsumerStatefulWidget {
  const IncomeRulesScreen({super.key});

  @override
  ConsumerState<IncomeRulesScreen> createState() => _IncomeRulesScreenState();
}

class _IncomeRulesScreenState extends ConsumerState<IncomeRulesScreen> {
  IncomeRules? _draft;
  bool _busy = false;

  IncomeRules get _rules => _draft ?? ref.watch(incomeRulesProvider);

  void _setShift(IncomeRule rule, int shift) {
    setState(() {
      _draft = _rules.withRule(IncomeRule(type: rule.type, shift: shift));
    });
  }

  Future<void> _apply() async {
    final rules = _rules;
    setState(() => _busy = true);

    // Ko'chadigan yozuvlarni oldindan sanaymiz — yozuvlar bo'lib-bo'lib
    // o'qiladi, hammasi xotiraga yuklanmaydi.
    final recalc = ref.read(recalcMonthKeysProvider);
    final moves = <IncomeMove>[];
    await for (final chunk
        in ref.read(incomeRepositoryProvider).streamAll()) {
      moves.addAll(recalc.preview(chunk, rules));
    }

    if (!mounted) return;
    final confirmed = moves.isEmpty ||
        await confirm(
          context,
          title: "Qoida o'zgartirilsinmi?",
          message: "${moves.length} ta daromad yozuvi boshqa oyga ko'chadi. "
              "Agregatlar avtomatik to'g'rilanadi.",
          confirmLabel: "Ha, ko'chir",
        );

    if (!mounted || !confirmed) {
      setState(() => _busy = false);
      return;
    }

    await runAction(
      context,
      successMessage: moves.isEmpty
          ? '✅ Qoida saqlandi'
          : "✅ Qoida saqlandi, ${moves.length} ta yozuv ko'chdi",
      action: () async {
        await ref.read(saveSettingsProvider).call(
              ref.read(settingsProvider).copyWith(incomeRules: rules),
            );
        await recalc.apply(moves);
      },
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rules = _rules;
    final today = ref.watch(clockProvider).now();

    return Scaffold(
      appBar: AppBar(title: const Text(Uz.incomeRules)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          SectionCard(
            child: Text(
              'Misol: 1-sentabrda olingan "Oylik" — AVGUST oyining puli. '
              'Shuning uchun u avgust byudjetiga tushadi.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          for (final rule in rules.rules)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      rule.type,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const <ButtonSegment<int>>[
                        ButtonSegment<int>(
                          value: -1,
                          label: Text('Oldingi oy'),
                        ),
                        ButtonSegment<int>(value: 0, label: Text('Joriy oy')),
                      ],
                      selected: <int>{rule.shift},
                      onSelectionChanged: (value) =>
                          _setShift(rule, value.first),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bugun kiritilsa → '
                      '${Fmt.monthTitle(MonthKey.of(today).shift(rule.shift))}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _busy ? null : _apply,
            icon: const Icon(Icons.save),
            label: Text(_busy ? 'Hisoblanmoqda…' : 'Saqlash va qayta joylash'),
          ),
        ],
      ),
    );
  }
}
