import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/remote/json_read.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Skriptli server: push/pull javoblari testda beriladi, chaqiruvlar yoziladi.
final class FakeRemote implements RemoteApi {
  final pushes = <List<SyncMutation>>[];
  final pulls = <int>[];

  /// Har push paketi uchun javob (standart — hammasi `ok`, versiya 100+).
  Future<Result<List<SyncPushResult>>> Function(List<SyncMutation>)? onPush;

  /// Pull sahifalari (navbat bilan); tugasa — bo'sh sahifa.
  final pages = <Result<SyncPullPage>>[];

  var _version = 100;

  @override
  Future<Result<List<SyncPushResult>>> syncPush(
    String householdId,
    String deviceId,
    List<SyncMutation> mutations,
  ) async {
    pushes.add(mutations);
    final handler = onPush;
    if (handler != null) return await handler(mutations);
    return Ok([for (final m in mutations) okResult(m, version: ++_version)]);
  }

  @override
  Future<Result<SyncPullPage>> syncPull(
    String householdId,
    int cursor, {
    int limit = 500,
  }) async {
    pulls.add(cursor);
    if (pages.isNotEmpty) return pages.removeAt(0);
    return Ok(page(const [], cursor: cursor));
  }

  static SyncPushResult okResult(
    SyncMutation m, {
    required int version,
    Json overrides = const {},
  }) => SyncPushResult.fromJson({
    'mutation_id': m.mutationId,
    'status': 'ok',
    'row': {
      ...m.data,
      'id': m.id,
      'household_id': 'h',
      'row_version': version,
      'created_at': '2026-10-05T04:00:00+00:00',
      ...overrides,
    },
  });

  static SyncPullPage page(
    List<(String, Json)> changes, {
    required int cursor,
    bool hasMore = false,
    bool resync = false,
  }) => SyncPullPage.fromJson({
    'changes': [
      for (final (table, row) in changes) {'t': table, 'row': row},
    ],
    'next_cursor': cursor,
    'has_more': hasMore,
    'resync_required': resync,
  });

  /// `app_bootstrap`, `create_household` va `accept_invite` javoblari
  /// (E14-T02) — testda o'rnatiladi.
  Result<AppBootstrap>? boot;
  Result<String>? created;
  Result<String>? accepted;
  final households = <String>[];

  @override
  Future<Result<AppBootstrap>> bootstrap() async =>
      boot ?? (throw UnimplementedError());

  @override
  Future<Result<String>> createHousehold(String name) async {
    households.add('create:$name');
    return created ?? (throw UnimplementedError());
  }

  @override
  Future<Result<OpenMonthPreview>> openMonthPreview(String h, MonthKey m) =>
      throw UnimplementedError();

  /// Onboarding (E14-T03): yuk va ochilgan oylar yozib boriladi.
  Json? appliedPayload;
  final openedMonths = <MonthKey>[];
  Result<bool> applyResult = const Ok(true);
  Result<OpenMonthResult> openMonthResult = Ok((
    month: MonthKey(2026, 10),
    created: 0,
    skipped: 0,
  ));

  @override
  Future<Result<OpenMonthResult>> openMonth(String h, MonthKey m) async {
    openedMonths.add(m);
    return openMonthResult;
  }

  @override
  Future<Result<bool>> onboardingApply(String h, Json payload) async {
    appliedPayload = payload;
    return applyResult;
  }

  @override
  Future<Result<String>> acceptInvite(String code) async {
    households.add('join:$code');
    return accepted ?? (throw UnimplementedError());
  }

  @override
  Future<Result<TelegramLinkToken>> telegramLinkToken() =>
      throw UnimplementedError();

  @override
  Future<Result<void>> registerDevice(
    String token, {
    String platform = 'android',
    String? appVersion,
  }) => throw UnimplementedError();
}
