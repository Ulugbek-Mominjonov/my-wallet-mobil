import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:my_wallet/data/remote/json_read.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// E19: a'zoning bildirishnoma sozlamalari (`notification_prefs`,
/// contracts/api.md — standartlar server bilan bir xil).
@immutable
final class NotificationPrefs {
  const new({
    this.push = true,
    this.telegram = false,
    this.email = false,
    this.reminderHour = 9,
    this.daysAhead = 3,
    this.monthlyReport = true,
    this.reportDay = 21,
    this.limitAlerts = true,
    this.incomeMissing = true,
  });

  factory fromJson(Json json) => NotificationPrefs(
    push: read<bool>(json, 'push'),
    telegram: read<bool>(json, 'telegram'),
    email: read<bool>(json, 'email'),
    reminderHour: read<int>(json, 'reminder_hour'),
    daysAhead: read<int>(json, 'days_ahead'),
    monthlyReport: read<bool>(json, 'monthly_report'),
    reportDay: read<int>(json, 'report_day'),
    limitAlerts: read<bool>(json, 'limit_alerts'),
    incomeMissing: read<bool>(json, 'income_missing'),
  );

  /// Chegaralar (server CHECK bilan bir xil).
  static const int maxHour = 23;
  static const int maxDaysAhead = 14;
  static const int maxReportDay = 28;

  final bool push;
  final bool telegram;
  final bool email;
  final int reminderHour;
  final int daysAhead;
  final bool monthlyReport;
  final int reportDay;
  final bool limitAlerts;
  final bool incomeMissing;

  static const String columns =
      'push, telegram, email, reminder_hour, days_ahead, monthly_report, '
      'report_day, limit_alerts, income_missing';

  Json toJson() => {
    'push': push,
    'telegram': telegram,
    'email': email,
    'reminder_hour': reminderHour,
    'days_ahead': daysAhead,
    'monthly_report': monthlyReport,
    'report_day': reportDay,
    'limit_alerts': limitAlerts,
    'income_missing': incomeMissing,
  };

  NotificationPrefs copyWith({
    bool? push,
    bool? telegram,
    bool? email,
    int? reminderHour,
    int? daysAhead,
    bool? monthlyReport,
    int? reportDay,
    bool? limitAlerts,
    bool? incomeMissing,
  }) => NotificationPrefs(
    push: push ?? this.push,
    telegram: telegram ?? this.telegram,
    email: email ?? this.email,
    reminderHour: reminderHour ?? this.reminderHour,
    daysAhead: daysAhead ?? this.daysAhead,
    monthlyReport: monthlyReport ?? this.monthlyReport,
    reportDay: reportDay ?? this.reportDay,
    limitAlerts: limitAlerts ?? this.limitAlerts,
    incomeMissing: incomeMissing ?? this.incomeMissing,
  );

  @override
  bool operator ==(Object other) =>
      other is NotificationPrefs && _equality(other);

  bool _equality(NotificationPrefs other) =>
      other.push == push &&
      other.telegram == telegram &&
      other.email == email &&
      other.reminderHour == reminderHour &&
      other.daysAhead == daysAhead &&
      other.monthlyReport == monthlyReport &&
      other.reportDay == reportDay &&
      other.limitAlerts == limitAlerts &&
      other.incomeMissing == incomeMissing;

  @override
  int get hashCode => Object.hash(
    push,
    telegram,
    email,
    reminderHour,
    daysAhead,
    monthlyReport,
    reportDay,
    limitAlerts,
    incomeMissing,
  );
}

/// `test_notification` natijasi — kanal va sabab (`disabled`, `no_device`,
/// `not_linked`, `not_configured`).
typedef ChannelResult = ({String channel, bool queued, String? reason});

/// Sozlamalar va akkaunt (RPC'dan tashqari: PostgREST jadvali va Edge
/// Function). Testda soxtasi bilan almashtiriladi.
abstract interface class SettingsApi {
  Future<Result<NotificationPrefs>> notificationPrefs(String householdId);
  Future<Result<void>> saveNotificationPrefs(
    String householdId,
    NotificationPrefs prefs,
  );

  /// BR-163: Telegram ulanganmi (o'z `telegram_links` qatori).
  Future<Result<bool>> telegramLinked();
  Future<Result<void>> telegramUnlink();

  /// BR-164: har kanalga sinov xabari.
  Future<Result<List<ChannelResult>>> testNotification(String householdId);

  /// BR-015: akkauntni o'chirish (`delete-account`); o'chirilgan yolg'iz
  /// byudjetlar soni. `last_owner` — `RejectedFailure`.
  Future<Result<int>> deleteAccount();
}

final Provider<SettingsApi> settingsApiProvider = Provider(
  (ref) => SupabaseSettingsApi(Supabase.instance.client),
);

final class SupabaseSettingsApi implements SettingsApi {
  const new(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<NotificationPrefs>> notificationPrefs(String householdId) =>
      guardRemote(
        'notification_prefs',
        () async => NotificationPrefs.fromJson(
          await _client
              .from('notification_prefs')
              .select(NotificationPrefs.columns)
              .eq('household_id', householdId)
              .single(),
        ),
      );

  @override
  Future<Result<void>> saveNotificationPrefs(
    String householdId,
    NotificationPrefs prefs,
  ) => guardRemote(
    'notification_prefs',
    () => _client
        .from('notification_prefs')
        .update(prefs.toJson())
        .eq('household_id', householdId),
  );

  @override
  Future<Result<bool>> telegramLinked() => guardRemote(
    'telegram_links',
    () async =>
        await _client
            .from('telegram_links')
            .select('linked_at')
            .maybeSingle() !=
        null,
  );

  @override
  Future<Result<void>> telegramUnlink() => guardRemote(
    'telegram_unlink',
    () => _client.rpc<void>('telegram_unlink'),
  );

  @override
  Future<Result<List<ChannelResult>>> testNotification(String householdId) =>
      guardRemote('test_notification', () async {
        final json = await _client.rpc<Object?>(
          'test_notification',
          params: {'p_household': householdId},
        );
        return [
          for (final item in asObjects(json))
            (
              channel: read<String>(item, 'channel'),
              queued: read<bool>(item, 'queued'),
              reason: read<String?>(item, 'reason'),
            ),
        ];
      });

  @override
  Future<Result<int>> deleteAccount() async {
    final result = await guardRemote('delete-account', () async {
      try {
        final response = await _client.functions.invoke('delete-account');
        return Ok<int>(
          read<int>(asObject(response.data), 'deleted_households'),
        );
      } on FunctionException catch (error) {
        if (error.status == _unauthorized) {
          return const Err<int>(UnauthorizedFailure());
        }
        // 409 `last_owner` (BR-014) va boshqalar — server kodi bilan.
        final code = switch (error.details) {
          {'error': final String code} => code,
          _ => 'delete_failed',
        };
        return Err<int>(RejectedFailure(code));
      }
    });
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => Err(failure),
    };
  }

  static const int _unauthorized = 401;
}
