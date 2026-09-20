import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// BR-214: server talab qilgan versiyadan eski ilova — Play Market'ga
/// yo'naltiriladi; yangilangach "Tekshirish" bilan davom etadi.
class UpdateRequiredScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(startupProvider);
    final minVersion = state is StartupUpdateRequired ? state.minVersion : '';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.system_update,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.updateRequiredTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.updateRequiredBody(minVersion),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () =>
                    unawaited(ref.read(startupProvider.notifier).reload()),
                child: Text(l10n.actionRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
