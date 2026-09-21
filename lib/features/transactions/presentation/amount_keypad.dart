import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/format_context.dart';
import 'package:my_wallet/core/format/money_format.dart';
import 'package:my_wallet/features/transactions/application/amount_entry.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Kiritilayotgan summa (katta, tabular raqamlar bilan).
class AmountDisplay extends StatelessWidget {
  const new({required this.entry, required this.currency, super.key});

  final AmountEntry entry;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String format(int major) => formatMoney(
      major * currency.minorPerMajor,
      currency: currency.code,
      locale: appLocaleOf(context),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (entry.pending != null) ...[
            Text(
              '${format(entry.left ?? 0)} ${entry.pending}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              format(entry.display),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.displaySmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Summa klaviaturasi (BR-140): `000`, `⌫` va oddiy `+ −`.
class AmountKeypad extends StatelessWidget {
  const new({required this.onKey, super.key});

  final ValueChanged<AmountKey> onKey;

  static const List<List<AmountKey>> _rows = [
    [AmountKey.one, AmountKey.two, AmountKey.three, AmountKey.backspace],
    [AmountKey.four, AmountKey.five, AmountKey.six, AmountKey.minus],
    [AmountKey.seven, AmountKey.eight, AmountKey.nine, AmountKey.plus],
    [AmountKey.tripleZero, AmountKey.zero, AmountKey.equals],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _rows)
          Row(
            children: [
              for (final key in row)
                Expanded(
                  child: _Key(entryKey: key, onKey: onKey),
                ),
            ],
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const new({required this.entryKey, required this.onKey});

  final AmountKey entryKey;
  final ValueChanged<AmountKey> onKey;

  static const Map<AmountKey, String> _labels = {
    AmountKey.tripleZero: '000',
    AmountKey.plus: '+',
    AmountKey.minus: '−',
    AmountKey.equals: '=',
  };

  @override
  Widget build(BuildContext context) {
    final label = _labels[entryKey] ?? '${entryKey.index}';
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: SizedBox(
        height: 56,
        child: entryKey == AmountKey.backspace
            ? IconButton.filledTonal(
                onPressed: _press,
                icon: const Icon(Icons.backspace_outlined),
                tooltip: '⌫',
              )
            : TextButton(
                onPressed: _press,
                child: Text(label, style: theme.textTheme.titleLarge),
              ),
      ),
    );
  }

  void _press() {
    unawaited(HapticFeedback.selectionClick());
    onKey(entryKey);
  }
}
