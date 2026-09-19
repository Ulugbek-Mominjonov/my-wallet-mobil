import 'package:meta/meta.dart';
import 'package:my_wallet/data/remote/json_read.dart';
import 'package:wallet_domain/wallet_domain.dart';

// RPC javoblari (contracts/api.md). Sinxron qatorlari — xom JSON (jadvalga
// to'g'ridan-to'g'ri yoziladi, E13-T05).

/// `app_bootstrap()` — ilova ochilganda bitta so'rov (ARXITEKTURA 5).
@immutable
final class AppBootstrap {
  factory fromJson(Json json) {
    final profile = readObject(json, 'profile');
    final config = readObject(json, 'app_config');
    return AppBootstrap._(
      schemaVersion: read<int>(json, 'schema_version'),
      isPlatformAdmin: read<bool>(json, 'is_platform_admin'),
      userId: read<String>(profile, 'user_id'),
      displayName: read<String>(profile, 'display_name'),
      locale: read<String>(profile, 'locale'),
      lastHouseholdId: read<String?>(profile, 'last_household_id'),
      households: [
        for (final h in readObjects(json, 'households'))
          BootstrapHousehold.fromJson(h),
      ],
      currencies: [
        for (final c in readObjects(json, 'currencies'))
          BootstrapCurrency.fromJson(c),
      ],
      minAndroidVersion: read<String?>(config, 'min_android_version'),
      maintenance: config['maintenance'],
    );
  }

  const new _({
    required this.schemaVersion,
    required this.isPlatformAdmin,
    required this.userId,
    required this.displayName,
    required this.locale,
    required this.lastHouseholdId,
    required this.households,
    required this.currencies,
    required this.minAndroidVersion,
    required this.maintenance,
  });

  /// Shartnoma versiyasi — ilova bilganidan katta bo'lsa yangilash kerak.
  final int schemaVersion;
  final bool isPlatformAdmin;
  final String userId;
  final String displayName;
  final String locale;
  final String? lastHouseholdId;
  final List<BootstrapHousehold> households;
  final List<BootstrapCurrency> currencies;

  /// BR-214: majburiy yangilash chegarasi.
  final String? minAndroidVersion;

  /// Texnik ishlar banneri (E26-T02).
  final Object? maintenance;
}

@immutable
final class BootstrapHousehold {
  factory fromJson(Json json) => BootstrapHousehold._(
    id: read<String>(json, 'id'),
    name: read<String>(json, 'name'),
    role: MemberRole.fromWire(read<String>(json, 'role')),
    baseCurrency: read<String>(json, 'base_currency'),
    timezone: read<String>(json, 'timezone'),
    onboarded: read<bool>(json, 'onboarded'),
  );

  const new _({
    required this.id,
    required this.name,
    required this.role,
    required this.baseCurrency,
    required this.timezone,
    required this.onboarded,
  });

  final String id;
  final String name;
  final MemberRole role;
  final String baseCurrency;
  final String timezone;
  final bool onboarded;
}

@immutable
final class BootstrapCurrency {
  factory fromJson(Json json) => BootstrapCurrency._(
    code: read<String>(json, 'code'),
    names: readObject(
      json,
      'name',
    ).map((locale, value) => MapEntry(locale, '$value')),
    symbol: read<String>(json, 'symbol'),
    exponent: read<int>(json, 'exponent'),
  );

  const new _({
    required this.code,
    required this.names,
    required this.symbol,
    required this.exponent,
  });

  final String code;

  /// Til → nom (`uz`, `ru`, `en`).
  final Map<String, String> names;
  final String symbol;
  final int exponent;
}

/// `sync_pull` qatori: jadval nomi va serverdagi to'liq qator.
typedef SyncChange = ({String table, Json row});

@immutable
final class SyncPullPage {
  factory fromJson(Json json) => SyncPullPage._(
    changes: [
      for (final change in readObjects(json, 'changes'))
        (table: read<String>(change, 't'), row: readObject(change, 'row')),
    ],
    nextCursor: read<int>(json, 'next_cursor'),
    hasMore: read<bool>(json, 'has_more'),
    resyncRequired: read<bool>(json, 'resync_required'),
  );

  const new _({
    required this.changes,
    required this.nextCursor,
    required this.hasMore,
    required this.resyncRequired,
  });

  final List<SyncChange> changes;
  final int nextCursor;
  final bool hasMore;

  /// Kursor tozalangan versiyadan eski — lokal byudjet to'liq qayta yuklanadi.
  final bool resyncRequired;
}

/// `sync_push` mutatsiyasi.
@immutable
final class SyncMutation {
  const new({
    required this.mutationId,
    required this.table,
    required this.op,
    required this.id,
    required this.data,
    this.baseVersion,
  });

  final String mutationId;
  final String table;

  /// `upsert` | `delete`.
  final String op;
  final String id;
  final int? baseVersion;
  final Json data;

  Json toJson() => {
    'mutation_id': mutationId,
    'table': table,
    'op': op,
    'id': id,
    'base_version': baseVersion,
    'data': data,
  };
}

enum SyncPushStatus { ok, conflict, rejected }

@immutable
final class SyncPushResult {
  factory fromJson(Json json) => SyncPushResult._(
    mutationId: read<String>(json, 'mutation_id'),
    status: SyncPushStatus.values.byName(read<String>(json, 'status')),
    row: read<Map<String, Object?>?>(json, 'row'),
    code: read<String?>(json, 'code'),
    message: read<String?>(json, 'message'),
  );

  const new _({
    required this.mutationId,
    required this.status,
    required this.row,
    required this.code,
    required this.message,
  });

  final String mutationId;
  final SyncPushStatus status;

  /// `ok` — kanonik qator, `conflict` — serverdagi qator.
  final Json? row;

  /// `rejected` — biznes kod yoki SQLSTATE.
  final String? code;
  final String? message;
}

/// `open_month` natijasi (BR-081, BR-082); rejalar sinxron bilan keladi.
typedef OpenMonthResult = ({MonthKey month, int created, int skipped});

/// `open_month_preview` — yaratiladigan rejalar.
@immutable
final class OpenMonthPreview {
  factory fromJson(Json json) => OpenMonthPreview._(
    month: MonthKey.parse(read<String>(json, 'month')),
    closed: read<bool>(json, 'closed'),
    items: [
      for (final item in readObjects(json, 'items'))
        (
          kind: PlanKind.fromWire(read<String>(item, 'kind')),
          name: read<String>(item, 'name'),
          plannedAmount: read<int?>(item, 'planned_amount'),
          dueDate: LocalDate.parse(read<String>(item, 'due_date')),
          exists: read<bool>(item, 'exists'),
        ),
    ],
  );

  const new _({required this.month, required this.closed, required this.items});

  final MonthKey month;
  final bool closed;
  final List<
    ({
      PlanKind kind,
      String name,
      int? plannedAmount,
      LocalDate dueDate,
      bool exists,
    })
  >
  items;
}

/// BR-163: Telegram'ni ulash havolasi uchun bir martalik token.
typedef TelegramLinkToken = ({String token, DateTime expiresAt});
