import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/core/notifications/local_notifier.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/data/remote/settings_api.dart';
import 'package:my_wallet/features/notifications/application/notification_settings.dart';
import 'package:my_wallet/features/transactions/presentation/add_transaction_screen.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// E19-T03 (BR-160..165): kanallar (push, Telegram, email), eslatma soati va
/// necha kun oldin, oylik hisobot kuni, limit va daromad ogohlantirishlari,
/// Telegram ulash, sinov xabari. Server sozlamasi — tarmoq kerak.
class NotificationSettingsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(notificationSettingsProvider);
    final controller = ref.read(notificationSettingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifTitle)),
      body: switch (state) {
        (prefs: final prefs?, failure: _, :final telegramLinked) => _Form(
          prefs: prefs,
          telegramLinked: telegramLinked,
        ),
        (prefs: null, failure: final _?, telegramLinked: _) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.notifOffline,
          action: FilledButton(
            onPressed: () => unawaited(controller.load()),
            child: Text(l10n.actionRetry),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Form extends ConsumerWidget {
  const new({required this.prefs, required this.telegramLinked});

  final NotificationPrefs prefs;
  final bool? telegramLinked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    Future<void> save(NotificationPrefs next) async {
      final messenger = ScaffoldMessenger.of(context);
      final failure = await ref
          .read(notificationSettingsProvider.notifier)
          .save(next);
      if (failure != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(transactionErrorText(l10n, failure))),
        );
      }
    }

    Widget header(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(title, style: theme.textTheme.titleSmall),
    );

    return ListView(
      children: [
        header(l10n.notifChannels),
        SwitchListTile(
          title: Text(l10n.notifPush),
          value: prefs.push,
          onChanged: (value) => unawaited(save(prefs.copyWith(push: value))),
        ),
        ListTile(
          title: Text(l10n.notifPermission),
          trailing: TextButton(
            onPressed: () =>
                unawaited(ref.read(localNotifierProvider).requestPermission()),
            child: Text(l10n.notifPermissionAllow),
          ),
        ),
        SwitchListTile(
          title: Text(l10n.notifTelegram),
          subtitle: Text(
            telegramLinked ?? false
                ? l10n.notifTelegramLinked
                : l10n.notifTelegramNotLinked,
          ),
          value: prefs.telegram,
          onChanged: (value) =>
              unawaited(save(prefs.copyWith(telegram: value))),
        ),
        const _TelegramActions(),
        SwitchListTile(
          title: Text(l10n.notifEmail),
          value: prefs.email,
          onChanged: (value) => unawaited(save(prefs.copyWith(email: value))),
        ),
        header(l10n.notifSchedule),
        _NumberTile(
          title: l10n.notifReminderHour,
          value: prefs.reminderHour,
          min: 0,
          max: NotificationPrefs.maxHour,
          label: (hour) => '${hour.toString().padLeft(2, '0')}:00',
          onChanged: (hour) =>
              unawaited(save(prefs.copyWith(reminderHour: hour))),
        ),
        _NumberTile(
          title: l10n.notifDaysAhead,
          value: prefs.daysAhead,
          min: 0,
          max: NotificationPrefs.maxDaysAhead,
          label: l10n.notifDays,
          onChanged: (days) => unawaited(save(prefs.copyWith(daysAhead: days))),
        ),
        SwitchListTile(
          title: Text(l10n.notifMonthlyReport),
          value: prefs.monthlyReport,
          onChanged: (value) =>
              unawaited(save(prefs.copyWith(monthlyReport: value))),
        ),
        if (prefs.monthlyReport)
          _NumberTile(
            title: l10n.notifReportDay,
            value: prefs.reportDay,
            min: 1,
            max: NotificationPrefs.maxReportDay,
            label: (day) => '$day',
            onChanged: (day) => unawaited(save(prefs.copyWith(reportDay: day))),
          ),
        SwitchListTile(
          title: Text(l10n.notifLimitAlerts),
          value: prefs.limitAlerts,
          onChanged: (value) =>
              unawaited(save(prefs.copyWith(limitAlerts: value))),
        ),
        SwitchListTile(
          title: Text(l10n.notifIncomeMissing),
          value: prefs.incomeMissing,
          onChanged: (value) =>
              unawaited(save(prefs.copyWith(incomeMissing: value))),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.send_outlined),
            label: Text(l10n.notifTest),
            onPressed: () => unawaited(_test(context, ref)),
          ),
        ),
      ],
    );
  }

  /// BR-164: har kanal natijasi dialogda.
  Future<void> _test(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final result = await ref
        .read(notificationSettingsProvider.notifier)
        .testNotification();
    if (!context.mounted) return;
    switch (result) {
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(transactionErrorText(l10n, failure))),
        );
      case Ok(value: final channels):
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.notifTest),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (:channel, :queued, :reason) in channels)
                  Text(
                    '${queued ? '✅' : '—'} $channel: '
                    '${queued ? l10n.notifQueued : _reason(l10n, reason)}',
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.actionBack),
              ),
            ],
          ),
        );
    }
  }

  String _reason(AppL10n l10n, String? reason) => switch (reason) {
    'disabled' => l10n.notifReasonDisabled,
    'no_device' => l10n.notifReasonNoDevice,
    'not_linked' => l10n.notifReasonNotLinked,
    'not_configured' => l10n.notifReasonNotConfigured,
    _ => reason ?? '',
  };
}

/// BR-163: Telegram — bot havolasini ochish (bir martalik token) yoki uzish.
class _TelegramActions extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final linked =
        ref.watch(notificationSettingsProvider).telegramLinked ?? false;
    final bot = ref.watch(appConfigProvider).telegramBotUsername;
    final controller = ref.read(notificationSettingsProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: linked
            ? TextButton(
                onPressed: () => unawaited(_unlink(context, controller)),
                child: Text(l10n.notifTelegramUnlink),
              )
            : TextButton(
                onPressed: bot.isEmpty
                    ? null
                    : () => unawaited(_link(context, controller, bot)),
                child: Text(l10n.notifTelegramLink),
              ),
      ),
    );
  }

  Future<void> _link(
    BuildContext context,
    NotificationSettings controller,
    String bot,
  ) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    switch (await controller.telegramToken()) {
      case Ok(value: (:final token, expiresAt: _)):
        await launchUrl(
          Uri.https('t.me', '/$bot', {'start': token}),
          mode: LaunchMode.externalApplication,
        );
      case Err(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(transactionErrorText(l10n, failure))),
        );
    }
  }

  Future<void> _unlink(
    BuildContext context,
    NotificationSettings controller,
  ) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final failure = await controller.telegramUnlink();
    if (failure != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(transactionErrorText(l10n, failure))),
      );
    }
  }
}

/// Butun son tanlovi (soat, kunlar) — ochiluvchi ro'yxat.
class _NumberTile extends StatelessWidget {
  const new({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final int value;
  final int min;
  final int max;
  final String Function(int value) label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    trailing: DropdownButton<int>(
      value: value.clamp(min, max),
      items: [
        for (var i = min; i <= max; i++)
          DropdownMenuItem(value: i, child: Text(label(i))),
      ],
      onChanged: (next) {
        if (next != null && next != value) onChanged(next);
      },
    ),
  );
}
