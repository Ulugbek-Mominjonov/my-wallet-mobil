import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/security/app_lock.dart';
import 'package:my_wallet/features/auth/presentation/sign_out_dialog.dart';
import 'package:my_wallet/features/lock/presentation/pin_pad.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Qulf ekrani (BR-211): PIN yoki biometrika. PIN esidan chiqsa — chiqish
/// (lokal ma'lumot tozalanadi, server nusxasi qoladi).
class LockScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  @override
  void initState() {
    super.initState();
    // Biometrika yoqilgan bo'lsa — darhol so'raladi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(appLockProvider.notifier).unlockWithBiometrics());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(appLockProvider);
    final lock = ref.read(appLockProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.lockEnterPin, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 24,
                  child: state.attempts > 0
                      ? Text(
                          l10n.lockWrongPin,
                          style: TextStyle(color: theme.colorScheme.error),
                        )
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                PinPad(
                  onCompleted: (pin) => unawaited(lock.unlockWithPin(pin)),
                  biometricsLabel: l10n.lockBiometrics,
                  onBiometrics: state.settings.biometrics
                      ? () => unawaited(lock.unlockWithBiometrics())
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextButton(
                  onPressed: () => unawaited(confirmSignOut(context, ref)),
                  child: Text(l10n.lockForgot),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
