import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/features/payments/application/payments_controller.dart';
import 'package:my_wallet/features/payments/presentation/plan_action_runner.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// BR-081, BR-084: "Oy hali ochilmagan" → preview varag'i (yaratiladigan
/// rejalar, allaqachon borlar) → tasdiq → server (tarmoq kerak; oflaynda
/// tushunarli xabar).
class OpenMonthCard extends ConsumerWidget {
  const new({required this.month, super.key});

  final MonthKey month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      // Matn va tugma ustma-ust: tor ekran/katta shriftda matn siqilmaydi.
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(Icons.event_available_outlined),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(l10n.dashNotOpened)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () => unawaited(_open(context, ref)),
              child: Text(l10n.dashOpenMonth),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(planActionsProvider);
    final preview = await runPlanAction(
      context,
      ({required confirmClosedMonth}) => actions.preview(month),
    );
    final startup = ref.read(startupProvider);
    if (preview == null || startup is! StartupReady || !context.mounted) {
      return;
    }
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _PreviewSheet(preview: preview, currency: startup.currency),
    );
    if (confirmed != true || !context.mounted) return;
    await runPlanAction(
      context,
      ({required confirmClosedMonth}) => actions.open(month),
      success: AppL10n.of(context).saved,
    );
  }
}

class _PreviewSheet extends StatelessWidget {
  const new({required this.preview, required this.currency});

  final OpenMonthPreview preview;

  /// Reja summalari — byudjetning asosiy valyutasida.
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final created = [
      for (final item in preview.items)
        if (!item.exists) item,
    ];
    final existing = preview.items.length - created.length;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.dashOpenMonth, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                created.isEmpty
                    ? l10n.openMonthNothing
                    : l10n.openMonthCreates(created.length),
              ),
              if (existing > 0)
                Text(
                  l10n.openMonthExisting(existing),
                  style: theme.textTheme.bodySmall,
                ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final item in created)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Icon(
                          item.kind == PlanKind.income
                              ? Icons.south_west
                              : Icons.north_east,
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.dueDate.day}.'
                          '${item.dueDate.month.toString().padLeft(2, '0')}',
                        ),
                        trailing: switch (item.plannedAmount) {
                          final amount? => MoneyText(
                            amount,
                            currency: currency.code,
                          ),
                          null => const Text('?'),
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Tor ekranda tugmalar ustma-ust tushadi (dialoglardagi kabi).
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: AppSpacing.sm,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.actionCancel),
                  ),
                  FilledButton(
                    onPressed: created.isEmpty
                        ? null
                        : () => Navigator.pop(context, true),
                    child: Text(l10n.dashOpenMonth),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
