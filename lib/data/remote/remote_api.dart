import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/remote/json_read.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// RPC chaqiruvi: funksiya nomi va parametrlari → JSON javob.
typedef RpcTransport = Future<Object?> Function(
  String function,
  Map<String, Object?> params,
);

/// Supabase klienti orqali (ishlab chiqarish).
RpcTransport supabaseTransport(SupabaseClient client) =>
    (function, params) async =>
        await client.rpc<Object?>(function, params: params);

/// Server bilan aloqa — faqat RPC (jadvallarga yozuv `sync_push` orqali).
/// Xatolar exception emas — `Result` (contracts/api.md kodlari).
abstract interface class RemoteApi {
  Future<Result<AppBootstrap>> bootstrap();

  Future<Result<SyncPullPage>> syncPull(
    String householdId,
    int cursor, {
    int limit,
  });

  Future<Result<List<SyncPushResult>>> syncPush(
    String householdId,
    String deviceId,
    List<SyncMutation> mutations,
  );

  Future<Result<OpenMonthPreview>> openMonthPreview(
    String householdId,
    MonthKey month,
  );

  Future<Result<OpenMonthResult>> openMonth(String householdId, MonthKey month);

  /// `false` — allaqachon bajarilgan (bir marta — E08-T06).
  Future<Result<bool>> onboardingApply(String householdId, Json payload);

  /// Yangi byudjet (BR-010) → byudjet ID si; chaqiruvchi — `owner`.
  Future<Result<String>> createHousehold(String name);

  /// Taklif kodi (BR-012) → byudjet ID si.
  Future<Result<String>> acceptInvite(String code);

  Future<Result<TelegramLinkToken>> telegramLinkToken();

  Future<Result<void>> registerDevice(
    String token, {
    String platform,
    String? appVersion,
  });

  /// Chiqishda — shu qurilmaga push yuborilmasin.
  Future<Result<void>> unregisterDevice(String token);
}

final class RpcRemoteApi implements RemoteApi {
  const new(this._transport, {this.timeout = defaultTimeout});

  /// Sekin tarmoqda ham kutish chegarasi — keyin oflayn deb hisoblanadi.
  static const defaultTimeout = Duration(seconds: 20);

  final RpcTransport _transport;
  final Duration timeout;

  @override
  Future<Result<AppBootstrap>> bootstrap() => _call(
    'app_bootstrap',
    const {},
    (json) => AppBootstrap.fromJson(asObject(json)),
  );

  @override
  Future<Result<SyncPullPage>> syncPull(
    String householdId,
    int cursor, {
    int limit = 500,
  }) => _call('sync_pull', {
    'p_household': householdId,
    'p_cursor': cursor,
    'p_limit': limit,
  }, (json) => SyncPullPage.fromJson(asObject(json)));

  @override
  Future<Result<List<SyncPushResult>>> syncPush(
    String householdId,
    String deviceId,
    List<SyncMutation> mutations,
  ) => _call(
    'sync_push',
    {
      'p_household': householdId,
      'p_device': deviceId,
      'p_mutations': [for (final m in mutations) m.toJson()],
    },
    (json) => [
      for (final result in readObjects(asObject(json), 'results'))
        SyncPushResult.fromJson(result),
    ],
  );

  @override
  Future<Result<OpenMonthPreview>> openMonthPreview(
    String householdId,
    MonthKey month,
  ) => _call('open_month_preview', {
    'p_household': householdId,
    'p_month': month.toIsoDate(),
  }, (json) => OpenMonthPreview.fromJson(asObject(json)));

  @override
  Future<Result<OpenMonthResult>> openMonth(
    String householdId,
    MonthKey month,
  ) => _call(
    'open_month',
    {'p_household': householdId, 'p_month': month.toIsoDate()},
    (json) {
      final object = asObject(json);
      return (
        month: MonthKey.parse(read<String>(object, 'month')),
        created: read<int>(object, 'created'),
        skipped: read<int>(object, 'skipped'),
      );
    },
  );

  @override
  Future<Result<bool>> onboardingApply(String householdId, Json payload) =>
      _call('onboarding_apply', {
        'p_household': householdId,
        'p_payload': payload,
      }, (json) => read<bool>(asObject(json), 'applied'));

  @override
  Future<Result<String>> createHousehold(String name) =>
      _call('create_household', {'p_name': name.trim()}, _uuid);

  @override
  Future<Result<String>> acceptInvite(String code) =>
      _call('accept_invite', {'p_code': code.trim()}, _uuid);

  static String _uuid(Object? json) =>
      json is String ? json : throw FormatException('uuid kutilgan', json);

  @override
  Future<Result<TelegramLinkToken>> telegramLinkToken() =>
      _call('telegram_link_token', const {}, (json) {
        final object = asObject(json);
        return (
          token: read<String>(object, 'token'),
          expiresAt: DateTime.parse(read<String>(object, 'expires_at')),
        );
      });

  @override
  Future<Result<void>> registerDevice(
    String token, {
    String platform = 'android',
    String? appVersion,
  }) => _call('register_device', {
    'p_token': token,
    'p_platform': platform,
    'p_app_version': appVersion,
  }, (_) {});

  @override
  Future<Result<void>> unregisterDevice(String token) =>
      _call('unregister_device', {'p_token': token}, (_) {});

  Future<Result<T>> _call<T>(
    String function,
    Map<String, Object?> params,
    T Function(Object? json) parse,
  ) => guardRemote(
    function,
    () async => parse(await _transport(function, params)),
    timeout: timeout,
  );
}

/// Server so'rovi → `Result`: tarmoq/vaqt — oflayn, sessiya — ruxsat yo'q,
/// PostgREST — biznes kodi, shartnomaga mos kelmagan javob — log bilan rad
/// etish ([label] — logda qaysi so'rov).
Future<Result<T>> guardRemote<T>(
  String label,
  Future<T> Function() request, {
  Duration timeout = RpcRemoteApi.defaultTimeout,
}) async {
  try {
    return Ok(await request().timeout(timeout));
  } on PostgrestException catch (error) {
    return Err(_postgrestFailure(error));
  } on AuthException {
    return const Err(UnauthorizedFailure());
  } on SocketException {
    return const Err(OfflineFailure());
  } on ClientException {
    return const Err(OfflineFailure());
  } on TimeoutException {
    return const Err(OfflineFailure());
  } on FormatException catch (error, stackTrace) {
    // Server javobi shartnomaga mos emas — xato yashirilmaydi.
    AppLog.error(
      'Server javobi shartnomaga mos emas: $label',
      error,
      stackTrace,
    );
    return Err(RejectedFailure('invalid_response', error.message));
  }
}

/// PostgREST xatosi → domen: `P0001` — biznes kod (`message` da),
/// `PGRST30x` — JWT (sessiya), qolgani — SQLSTATE bilan rad etish.
Failure _postgrestFailure(PostgrestException error) {
  final code = error.code;
  if (code == 'P0001') return RejectedFailure(error.message);
  if (code != null && code.startsWith('PGRST30')) {
    return const UnauthorizedFailure();
  }
  return RejectedFailure(code ?? 'unknown', error.message);
}
