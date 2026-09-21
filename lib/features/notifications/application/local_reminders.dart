import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/format/money_format.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/core/notifications/local_notifier.dart';
import 'package:my_wallet/core/settings/app_settings.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:wallet_domain/wallet_domain.dart';

/// BR-168: qurilmada oldinga rejalashtiriladigan kunlar va eng ko'p soni
/// (Android'da rejali bildirishnomalar cheklangan).
const int localReminderDays = 14;
const int maxLocalReminders = 30;

/// Eslatma bosilganda — to'lovlar ro'yxati.
const String _reminderRoute = '/payments';

/// Rejalar → qurilmadagi eslatmalar: to'lanmagan xarajat/ajratma rejalari
/// to'lov kuni soat [hour] da (byudjet vaqt zonasi — [now] ning zonasi),
/// hozirdan keyingilari, eng yaqin [maxLocalReminders] tasi.
List<LocalReminder> planLocalReminders(
  Iterable<PlannedItem> plans, {
  required tz.TZDateTime now,
  required int hour,
  required String title,
  required String Function(PlannedItem plan) body,
}) {
  final reminders = <LocalReminder>[
    for (final plan in plans)
      if (plan.kind != PlanKind.income &&
          plan.deletedAt == null &&
          plan.skippedAt == null &&
          plan.settledAt == null)
        if (tz.TZDateTime(
              now.location,
              plan.dueDate.year,
              plan.dueDate.month,
              plan.dueDate.day,
              hour,
            )
            case final at when at.isAfter(now))
          LocalReminder(
            at: at,
            title: title,
            body: body(plan),
            payload: _reminderRoute,
          ),
  ]..sort((a, b) => a.at.compareTo(b.at));
  return reminders.take(maxLocalReminders).toList();
}

/// Eslatma soati — `notification_prefs.reminder_hour` (E19-T03 keshlaydi);
/// standart 09:00 (BR-160).
final NotifierProvider<ReminderHour, int> reminderHourProvider =
    NotifierProvider(ReminderHour.new);

final class ReminderHour extends Notifier<int> {
  static const _key = 'reminder_hour';
  static const defaultHour = 9;

  @override
  int build() =>
      ref.watch(sharedPreferencesProvider).getInt(_key) ?? defaultHour;

  Future<void> set(int hour) async {
    state = hour;
    await ref.read(sharedPreferencesProvider).setInt(_key, hour);
  }
}

/// Rejalar yoki sozlama o'zgarsa — eslatmalar qayta rejalashtiriladi
/// (sinxron paketini kutib, bir marta).
final Provider<void> localRemindersProvider = Provider((ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  final startup = ref.watch(startupProvider);
  if (householdId == null || startup is! StartupReady) return;
  final db = ref.watch(appDatabaseProvider);
  final notifier = ref.watch(localNotifierProvider);
  final hour = ref.watch(reminderHourProvider);
  final l10n = ref.watch(appL10nProvider);
  final locale =
      AppLocale.values.asNameMap()[ref.watch(appLocaleProvider).languageCode] ??
      AppLocale.uz;
  // Byudjet vaqt zonasidagi soat (testda — qotirilgan vaqt).
  final clock = switch (ref.watch(clockProvider)) {
    final TzClock clock => clock,
    _ => TzClock(startup.household.timezone),
  };
  final base = startup.currency;

  Future<void> reschedule() async {
    try {
      final today = clock.today();
      final rows = await db.ledgerDao.openPlansDue(
        householdId,
        today,
        today.addDays(localReminderDays),
      );
      await notifier.replaceScheduled(
        planLocalReminders(
          [for (final row in rows) row.toDomain(base)],
          now: clock.localNow(),
          hour: hour,
          title: l10n.reminderTitle,
          body: (plan) => _body(l10n, plan, locale),
        ),
      );
    } on Object catch (error, stackTrace) {
      AppLog.error('Lokal eslatmalar rejalashtirilmadi', error, stackTrace);
    }
  }

  Timer? debounce;
  void schedule() {
    debounce?.cancel();
    debounce = Timer(const Duration(seconds: 2), () => unawaited(reschedule()));
  }

  unawaited(reschedule());
  final subscription = db
      .tableUpdates(TableUpdateQuery.onTable(db.plannedItems))
      .listen((_) => schedule());
  ref.onDispose(() {
    debounce?.cancel();
    unawaited(subscription.cancel());
  });
});

String _body(AppL10n l10n, PlannedItem plan, AppLocale locale) =>
    switch (plan.remaining) {
      final amount? => l10n.reminderBody(
        plan.name,
        formatMoney(
          amount.minor,
          currency: amount.currency.code,
          locale: locale,
        ),
      ),
      null => l10n.reminderBodyUnknown(plan.name),
    };
