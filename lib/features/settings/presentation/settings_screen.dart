import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/core/security/privacy_mode.dart';
import 'package:my_wallet/core/settings/app_settings.dart';
import 'package:my_wallet/core/share/file_sharer.dart';
import 'package:my_wallet/data/remote/settings_api.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/auth/application/sign_out.dart';
import 'package:my_wallet/features/auth/presentation/sign_out_dialog.dart';
import 'package:my_wallet/features/household/presentation/members_screen.dart';
import 'package:my_wallet/features/settings/application/data_export.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/transactions/presentation/add_transaction_screen.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Eksport fayli papkasi (testda — vaqtinchalik papka).
final Provider<Future<Directory> Function()> exportDirectoryProvider = Provider(
  (ref) => getTemporaryDirectory,
);

/// E19-T04: profil, byudjet, tema va til, xavfsizlik (qulf, maxfiylik),
/// bildirishnomalar, sinxron, eksport, chiqish va akkauntni o'chirish
/// (BR-015, ikki bosqichli tasdiq), ilova haqida.
class SettingsScreen extends ConsumerWidget {
  const new({super.key});

  /// Til tanlovi — har til o'z nomi bilan (tarjima qilinmaydi).
  static const Map<String, String> _languageNames = {
    'uz': "O'zbekcha",
    'ru': 'Русский',
    'en': 'English',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final startup = ref.watch(startupProvider);
    final ready = startup is StartupReady ? startup : null;
    final version = ref.watch(appVersionProvider).value;

    Widget header(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(title, style: theme.textTheme.titleSmall),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          if (ready != null) ...[
            header(l10n.settingsProfile),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(ready.boot.displayName),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(ready.household.name),
              subtitle: Text(l10n.settingsHousehold),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(joinPath),
            ),
            // BR-011..014: a'zolar, rollar va taklif.
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: Text(l10n.membersTitle),
              subtitle: Text(roleLabel(l10n, ready.household.role)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(membersPath),
            ),
          ],
          header(l10n.settingsAppearance),
          ListTile(
            title: Text(l10n.settingsTheme),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.themeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.themeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.themeDark),
                  ),
                ],
                selected: {ref.watch(themeModeProvider)},
                onSelectionChanged: (selection) => unawaited(
                  ref.read(themeModeProvider.notifier).select(selection.first),
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(l10n.settingsLanguage),
            trailing: DropdownButton<String?>(
              value: ref.watch(languageProvider)?.languageCode,
              items: [
                DropdownMenuItem(child: Text(l10n.languageSystem)),
                for (final MapEntry(key: code, value: name)
                    in _languageNames.entries)
                  DropdownMenuItem(value: code, child: Text(name)),
              ],
              onChanged: (code) => unawaited(
                ref
                    .read(languageProvider.notifier)
                    .select(code == null ? null : Locale(code)),
              ),
            ),
          ),
          header(l10n.settingsSecurity),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.lockTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(lockSettingsPath),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_off_outlined),
            title: Text(l10n.privacyMode),
            value: ref.watch(privacyModeProvider),
            onChanged: (_) => ref.read(privacyModeProvider.notifier).toggle(),
          ),
          header(l10n.notifTitle),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.notifTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(notificationSettingsPath),
          ),
          header(l10n.settingsData),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(l10n.syncStatusTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/sync'),
          ),
          if (ready != null)
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: Text(l10n.settingsExport),
              onTap: () => unawaited(_export(context, ref, ready.household.id)),
            ),
          header(l10n.settingsAccount),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.signOut),
            onTap: () => unawaited(confirmSignOut(context, ref)),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              l10n.deleteAccount,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => unawaited(_deleteAccount(context, ref)),
          ),
          header(l10n.settingsAbout),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appName),
            subtitle: version == null
                ? null
                : Text(l10n.settingsVersion(version)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.settingsLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appName,
              applicationVersion: version,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    String householdId,
  ) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await DataExport(ref.read(appDatabaseProvider)).write(
        householdId,
        directory: await ref.read(exportDirectoryProvider)(),
        now: DateTime.now(),
      );
      await ref.read(fileSharerProvider)(
        XFile(file.path, mimeType: 'application/json'),
        fileName: file.uri.pathSegments.last,
        text: l10n.settingsExportText,
      );
    } on Object catch (error, stackTrace) {
      AppLog.error('Eksport xatosi', error, stackTrace);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsExportFailed)),
      );
    }
  }

  /// BR-015: 1) oqibat tushuntiriladi, 2) tasdiq so'zi yoziladi — keyin
  /// server; muvaffaqiyatda qurilmadagi ma'lumot ham o'chadi.
  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionNext),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _TypeToConfirmDialog(),
    );
    if (confirmed != true) return;
    switch (await ref.read(settingsApiProvider).deleteAccount()) {
      case Ok():
        await ref.read(signOutProvider)();
      case Err(failure: RejectedFailure(code: 'last_owner')):
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.deleteAccountLastOwner)),
        );
      case Err(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(transactionErrorText(l10n, failure))),
        );
    }
  }
}

/// Ikkinchi bosqich: tasdiq so'zini yozish (tasodifiy bosishdan himoya).
class _TypeToConfirmDialog extends StatefulWidget {
  const new();

  @override
  State<_TypeToConfirmDialog> createState() => _TypeToConfirmDialogState();
}

class _TypeToConfirmDialogState extends State<_TypeToConfirmDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final word = l10n.deleteAccountWord;
    final matches = _controller.text.trim().toUpperCase() == word;
    return AlertDialog(
      title: Text(l10n.deleteAccount),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.deleteAccountConfirm(word)),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: matches ? () => Navigator.pop(context, true) : null,
          child: Text(l10n.deleteAccount),
        ),
      ],
    );
  }
}
