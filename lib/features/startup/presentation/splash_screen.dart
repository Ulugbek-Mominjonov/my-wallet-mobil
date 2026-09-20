import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/features/auth/presentation/sign_out_dialog.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Ilova ochilganda: `app_bootstrap` kutilmoqda yoki xato (oflayn va
/// saqlangan nusxa yo'q) — qayta urinish yoki chiqish.
class SplashScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(startupProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: switch (state) {
            StartupFailed(:final failure) => _Failed(failure: failure),
            _ => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.startupLoading),
              ],
            ),
          },
        ),
      ),
    );
  }
}

class _Failed extends ConsumerWidget {
  const new({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          failure is OfflineFailure ? Icons.wifi_off : Icons.error_outline,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.startupFailed, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          startupErrorText(l10n, failure),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: () =>
              unawaited(ref.read(startupProvider.notifier).reload()),
          icon: const Icon(Icons.refresh),
          label: Text(l10n.actionRetry),
        ),
        TextButton(
          onPressed: () => unawaited(confirmSignOut(context, ref)),
          child: Text(l10n.signOut),
        ),
      ],
    );
  }
}

String startupErrorText(AppL10n l10n, Failure failure) => switch (failure) {
  OfflineFailure() => l10n.errorOffline,
  UnauthorizedFailure() => l10n.syncSignedOut,
  _ => l10n.errorUnexpected,
};
