import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/security/app_lock.dart';
import 'package:my_wallet/features/lock/presentation/pin_pad.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Ilova qulfi sozlamalari (BR-211): PIN o'rnatish/o'zgartirish, biometrika,
/// avto-qulf vaqti va ilova almashtirgichda yashirish.
class LockSettingsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LockSettingsScreen> createState() => _LockSettingsState();
}

class _LockSettingsState extends ConsumerState<LockSettingsScreen> {
  /// Birinchi kiritilgan PIN (takror so'ralayotganda).
  String? _first;
  var _setting = false;
  var _mismatch = false;

  void _onPin(String pin) {
    final first = _first;
    if (first == null) {
      setState(() {
        _first = pin;
        _mismatch = false;
      });
      return;
    }
    if (first != pin) {
      setState(() {
        _first = null;
        _mismatch = true;
      });
      return;
    }
    unawaited(ref.read(appLockProvider.notifier).setPin(pin));
    setState(() {
      _first = null;
      _setting = false;
      _mismatch = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(appLockProvider);
    final lock = ref.read(appLockProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lockTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (_setting) ...[
            Text(
              _first == null ? l10n.lockNewPin : l10n.lockRepeatPin,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(
              height: 24,
              child: _mismatch
                  ? Text(
                      l10n.lockMismatch,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : null,
            ),
            PinPad(onCompleted: _onPin),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: Text(
                state.settings.pinSet ? l10n.lockChangePin : l10n.lockSetPin,
              ),
              onTap: () => setState(() {
                _setting = true;
                _first = null;
                _mismatch = false;
              }),
            ),
            if (state.settings.pinSet) ...[
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: Text(l10n.lockBiometrics),
                value: state.settings.biometrics,
                onChanged: (value) =>
                    unawaited(lock.setBiometrics(enabled: value)),
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l10n.lockAuto),
                trailing: DropdownButton<int>(
                  value: state.settings.minutes,
                  items: [
                    for (final minutes in autoLockOptions)
                      DropdownMenuItem(
                        value: minutes,
                        child: Text(l10n.lockAutoValue(minutes)),
                      ),
                  ],
                  onChanged: (minutes) {
                    if (minutes != null) unawaited(lock.setMinutes(minutes));
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_open),
                title: Text(l10n.lockDisable),
                onTap: () => unawaited(lock.disable()),
              ),
            ],
            SwitchListTile(
              secondary: const Icon(Icons.visibility_off_outlined),
              title: Text(l10n.lockSecureScreen),
              value: state.settings.secureScreen,
              onChanged: (value) =>
                  unawaited(lock.setSecureScreen(enabled: value)),
            ),
          ],
        ],
      ),
    );
  }
}
