import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/remote/settings_api.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/notifications/application/local_reminders.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Sozlamalar holati: yuklanmoqda (`prefs` va `failure` null), yuklangan
/// yoki xato (masalan oflayn — qayta urinish mumkin).
typedef NotificationSettingsState = ({
  NotificationPrefs? prefs,
  Failure? failure,
  bool? telegramLinked,
});

/// E19-T03: a'zoning bildirishnoma sozlamalari (server, tarmoq kerak).
final NotifierProvider<NotificationSettings, NotificationSettingsState>
notificationSettingsProvider = NotifierProvider.autoDispose(
  NotificationSettings.new,
);

final class NotificationSettings extends Notifier<NotificationSettingsState> {
  static const NotificationSettingsState _loading = (
    prefs: null,
    failure: null,
    telegramLinked: null,
  );

  SettingsApi get _api => ref.read(settingsApiProvider);

  @override
  NotificationSettingsState build() {
    ref.watch(currentHouseholdIdProvider);
    unawaited(Future.microtask(load));
    return _loading;
  }

  Future<void> load() async {
    final householdId = ref.read(currentHouseholdIdProvider);
    if (householdId == null) return;
    state = _loading;
    final prefs = await _api.notificationPrefs(householdId);
    final linked = await _api.telegramLinked();
    if (!ref.mounted) return;
    switch (prefs) {
      case Ok(:final value):
        state = (
          prefs: value,
          failure: null,
          telegramLinked: switch (linked) {
            Ok(:final value) => value,
            Err() => null,
          },
        );
        // Lokal eslatmalar soati — oflaynda ham (BR-168).
        await ref.read(reminderHourProvider.notifier).set(value.reminderHour);
      case Err(:final failure):
        state = (prefs: null, failure: failure, telegramLinked: null);
    }
  }

  /// Darhol ko'rsatiladi; server rad etsa — oldingi qiymat qaytadi va xato
  /// qaytariladi.
  Future<Failure?> save(NotificationPrefs next) async {
    final householdId = ref.read(currentHouseholdIdProvider);
    final previous = state.prefs;
    if (householdId == null || previous == null) return null;
    state = (prefs: next, failure: null, telegramLinked: state.telegramLinked);
    final result = await _api.saveNotificationPrefs(householdId, next);
    if (!ref.mounted) return null;
    switch (result) {
      case Ok():
        await ref.read(reminderHourProvider.notifier).set(next.reminderHour);
        return null;
      case Err(:final failure):
        state = (
          prefs: previous,
          failure: null,
          telegramLinked: state.telegramLinked,
        );
        return failure;
    }
  }

  /// BR-163: bot havolasi uchun bir martalik token.
  Future<Result<TelegramLinkToken>> telegramToken() =>
      ref.read(remoteApiProvider).telegramLinkToken();

  Future<Failure?> telegramUnlink() async {
    final result = await _api.telegramUnlink();
    if (!ref.mounted) return null;
    if (result case Err(:final failure)) return failure;
    state = (prefs: state.prefs, failure: null, telegramLinked: false);
    return null;
  }

  Future<Result<List<ChannelResult>>> testNotification() async {
    final householdId = ref.read(currentHouseholdIdProvider);
    if (householdId == null) return const Err(UnauthorizedFailure());
    return await _api.testNotification(householdId);
  }
}
