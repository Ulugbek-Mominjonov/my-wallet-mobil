import 'package:flutter/material.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Oy almashtirgich: ‹ oy nomi › — ixtiyoriy belgi (masalan 🔒) va
/// qo'shimcha amallar bilan. Tor ekranda nom qisqaradi, toshib ketmaydi.
class MonthSwitcher extends StatelessWidget {
  const new({
    required this.month,
    required this.onShift,
    this.badge,
    this.actions = const [],
    super.key,
  });

  final MonthKey month;
  final ValueChanged<int> onShift;
  final Widget? badge;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: l10n.monthPrevious,
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onShift(-1),
        ),
        Flexible(
          child: Text(
            formatMonthTitle(l10n, year: month.year, month: month.month),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (badge case final badge?) ...[
          const SizedBox(width: AppSpacing.sm),
          badge,
        ],
        IconButton(
          tooltip: l10n.monthNext,
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onShift(1),
        ),
        ...actions,
      ],
    );
  }
}
