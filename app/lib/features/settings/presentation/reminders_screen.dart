import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/widgets/actions.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../di/providers.dart';

/// Eslatma sozlamalari.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  ReminderSettings? _draft;

  ReminderSettings get _value =>
      _draft ?? ref.watch(settingsProvider).reminders;

  void _update(ReminderSettings next) => setState(() => _draft = next);

  Future<void> _save() async {
    await runAction(
      context,
      successMessage: '✅ Saqlandi',
      action: () => ref.read(saveSettingsProvider).call(
            ref.read(settingsProvider).copyWith(reminders: _value),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = _value;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(Uz.reminders)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          SwitchListTile(
            title: const Text('Telefon eslatmasi (push)'),
            value: value.pushEnabled,
            onChanged: (next) => _update(value.copyWith(pushEnabled: next)),
          ),
          SwitchListTile(
            title: const Text('Telegram'),
            subtitle: const Text('Bot orqali kunlik eslatma va hisobot'),
            value: value.telegramEnabled,
            onChanged: (next) =>
                _update(value.copyWith(telegramEnabled: next)),
          ),
          SwitchListTile(
            title: const Text('Oylik hisobot'),
            value: value.monthlyEnabled,
            onChanged: (next) =>
                _update(value.copyWith(monthlyEnabled: next)),
          ),
          const SizedBox(height: 8),
          SectionCard(
            title: 'Eslatma vaqti',
            child: Column(
              children: <Widget>[
                _slider(
                  label: 'Necha kun oldin',
                  value: value.daysAhead.toDouble(),
                  max: 14,
                  suffix: 'kun',
                  onChanged: (next) =>
                      _update(value.copyWith(daysAhead: next.round())),
                ),
                _slider(
                  label: 'Soat',
                  value: value.hour.toDouble(),
                  max: 23,
                  suffix: ':00',
                  onChanged: (next) =>
                      _update(value.copyWith(hour: next.round())),
                ),
                _slider(
                  label: 'Hisobot kuni',
                  value: value.reportDay.toDouble(),
                  min: 1,
                  max: 28,
                  suffix: '-sana',
                  onChanged: (next) =>
                      _update(value.copyWith(reportDay: next.round())),
                ),
                Text(
                  "Daromad odatda 20-sanagacha to'liq tushadi — shuning "
                  'uchun hisobot 21-kuni yuboriladi.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text(Uz.save)),
        ],
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double max,
    required String suffix,
    required ValueChanged<double> onChanged,
    double min = 0,
  }) =>
      Row(
        children: <Widget>[
          SizedBox(width: 120, child: Text(label)),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: (max - min).round(),
              label: '${value.round()}$suffix',
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${value.round()}$suffix',
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
}
