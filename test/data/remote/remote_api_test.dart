import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show ClientException;
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Lokal Supabase'dagi haqiqiy `app_bootstrap()` javobi (ru tilidagi
/// yangi foydalanuvchi).
const Map<String, Object?> bootstrapJson = {
  'profile': {
    'locale': 'ru',
    'user_id': 'cb020fb4-2b9f-4e1a-89ea-d98e6f469ea9',
    'display_name': 'boot',
    'last_household_id': '01a0b75f-3982-783d-bce1-ee339e5945de',
  },
  'app_config': {'maintenance': null, 'min_android_version': '0.1.0'},
  'currencies': [
    {
      'code': 'UZS',
      'name': {'en': 'Uzbek som', 'ru': 'Узбекский сум', 'uz': "O'zbek so'mi"},
      'symbol': "so'm",
      'exponent': 2,
    },
  ],
  'households': [
    {
      'id': '01a0b75f-3982-783d-bce1-ee339e5945de',
      'name': 'Личный бюджет',
      'role': 'owner',
      'timezone': 'Asia/Tashkent',
      'onboarded': false,
      'base_currency': 'UZS',
    },
  ],
  'schema_version': 1,
  'is_platform_admin': false,
};

final class FakeTransport {
  final calls = <(String, Map<String, Object?>)>[];
  Object? Function(String function) respond = (_) => null;

  Future<Object?> call(String function, Map<String, Object?> params) async {
    calls.add((function, params));
    return respond(function);
  }
}

T ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail('Ok kutilgan, $failure keldi'),
};

Failure err<T>(Result<T> result) => switch (result) {
  Ok(:final value) => fail('Err kutilgan, $value keldi'),
  Err(:final failure) => failure,
};

void main() {
  late FakeTransport transport;
  late RpcRemoteApi api;
  setUp(() {
    transport = FakeTransport();
    api = RpcRemoteApi(transport.call);
  });

  test('app_bootstrap — profil, byudjetlar, valyutalar, sozlama', () async {
    transport.respond = (_) => bootstrapJson;
    final boot = ok(await api.bootstrap());
    expect(transport.calls.single.$1, 'app_bootstrap');
    expect(transport.calls.single.$2, isEmpty);
    expect(boot.schemaVersion, 1);
    expect(boot.locale, 'ru');
    expect(boot.lastHouseholdId, '01a0b75f-3982-783d-bce1-ee339e5945de');
    expect(boot.households.single.role, MemberRole.owner);
    expect(boot.households.single.onboarded, isFalse);
    expect(boot.currencies.single.names['uz'], "O'zbek so'mi");
    expect(boot.minAndroidVersion, '0.1.0');
    expect(boot.maintenance, isNull);
    expect(boot.isPlatformAdmin, isFalse);
  });

  test('sync_pull — parametrlar va sahifa', () async {
    transport.respond = (_) => {
      'changes': [
        {
          't': 'transactions',
          'row': {'id': 't1', 'row_version': 1042},
        },
      ],
      'next_cursor': 1042,
      'has_more': false,
      'resync_required': false,
    };
    final page = ok(await api.syncPull('h', 1000));
    expect(transport.calls.single.$2, {
      'p_household': 'h',
      'p_cursor': 1000,
      'p_limit': 500,
    });
    expect(page.changes.single.table, 'transactions');
    expect(page.changes.single.row['row_version'], 1042);
    expect(
      (page.nextCursor, page.hasMore, page.resyncRequired),
      (1042, false, false),
    );
  });

  test('sync_push — mutatsiyalar JSON va natijalar', () async {
    transport.respond = (_) => {
      'results': [
        {
          'mutation_id': 'm1',
          'status': 'ok',
          'row': {'id': 't1', 'row_version': 5},
        },
        {
          'mutation_id': 'm2',
          'status': 'conflict',
          'row': {'id': 't2'},
        },
        {
          'mutation_id': 'm3',
          'status': 'rejected',
          'code': 'invalid_account',
          'message': 'hisob',
        },
      ],
    };
    const mutation = SyncMutation(
      mutationId: 'm1',
      table: 'transactions',
      op: 'upsert',
      id: 't1',
      baseVersion: 4,
      data: {'amount': 150000000},
    );
    final results = ok(await api.syncPush('h', 'phone-1', [mutation]));
    expect(transport.calls.single.$2, {
      'p_household': 'h',
      'p_device': 'phone-1',
      'p_mutations': [
        {
          'mutation_id': 'm1',
          'table': 'transactions',
          'op': 'upsert',
          'id': 't1',
          'base_version': 4,
          'data': {'amount': 150000000},
        },
      ],
    });
    expect(
      [for (final r in results) r.status],
      [SyncPushStatus.ok, SyncPushStatus.conflict, SyncPushStatus.rejected],
    );
    expect(results.first.row!['row_version'], 5);
    expect(
      (results.last.code, results.last.message),
      ('invalid_account', 'hisob'),
    );
  });

  test('oyni ochish, preview, onboarding, taklif, Telegram, qurilma', () async {
    transport.respond = (function) => switch (function) {
      'open_month_preview' => {
        'month': '2026-10-01',
        'closed': false,
        'new': 1,
        'existing': 0,
        'items': [
          {
            'kind': 'expense',
            'name': 'Ijara',
            'planned_amount': null,
            'due_date': '2026-10-05',
            'recurring_rule_id': 'r',
            'system_code': null,
            'exists': false,
          },
        ],
      },
      'open_month' => {
        'month': '2026-10-01',
        'created': 3,
        'skipped': 1,
        'items': <Object?>[],
      },
      'onboarding_apply' => {'applied': true, 'accounts': 3},
      'accept_invite' => 'h2',
      'telegram_link_token' => {
        'token': 'abc',
        'expires_at': '2026-09-19T10:15:00+00:00',
      },
      _ => null,
    };
    final preview = ok(await api.openMonthPreview('h', MonthKey(2026, 10)));
    expect(preview.items.single.plannedAmount, isNull);
    expect(preview.items.single.dueDate, LocalDate(2026, 10, 5));
    expect(preview.closed, isFalse);
    final opened = ok(await api.openMonth('h', MonthKey(2026, 10)));
    expect(
      (opened.month, opened.created, opened.skipped),
      (MonthKey(2026, 10), 3, 1),
    );
    expect(
      ok(await api.onboardingApply('h', const {'accounts': <Object?>[]})),
      isTrue,
    );
    expect(ok(await api.acceptInvite('  AB12CD34 ')), 'h2');
    final token = ok(await api.telegramLinkToken());
    expect(token.expiresAt, DateTime.utc(2026, 9, 19, 10, 15));
    ok(await api.registerDevice('fcm-token', appVersion: '0.2.0'));
    expect(
      [for (final call in transport.calls) call.$1],
      [
        'open_month_preview',
        'open_month',
        'onboarding_apply',
        'accept_invite',
        'telegram_link_token',
        'register_device',
      ],
    );
    expect(transport.calls[1].$2, {
      'p_household': 'h',
      'p_month': '2026-10-01',
    });
    expect(transport.calls[3].$2, {'p_code': 'AB12CD34'});
    expect(transport.calls.last.$2, {
      'p_token': 'fcm-token',
      'p_platform': 'android',
      'p_app_version': '0.2.0',
    });
  });

  group('xatolar → Failure', () {
    Future<Failure> failureFor(Exception error) async {
      transport.respond = (_) => throw error;
      return err(await api.acceptInvite('X'));
    }

    test('P0001 — biznes kod', () async {
      expect(
        await failureFor(
          const PostgrestException(message: 'invite_expired', code: 'P0001'),
        ),
        const RejectedFailure('invite_expired'),
      );
    });

    test("SQLSTATE va noma'lum kod", () async {
      expect(
        await failureFor(
          const PostgrestException(message: 'dup', code: '23505'),
        ),
        const RejectedFailure('23505'),
      );
      expect(
        await failureFor(const PostgrestException(message: 'x')),
        const RejectedFailure('unknown'),
      );
    });

    test('JWT eskirgan / auth — qayta kirish', () async {
      expect(
        await failureFor(
          const PostgrestException(message: 'JWT expired', code: 'PGRST303'),
        ),
        isA<UnauthorizedFailure>(),
      );
      expect(
        await failureFor(const AuthException('expired')),
        isA<UnauthorizedFailure>(),
      );
    });

    test('tarmoq — oflayn', () async {
      expect(
        await failureFor(const SocketException('no route')),
        isA<OfflineFailure>(),
      );
      expect(await failureFor(ClientException('reset')), isA<OfflineFailure>());
      expect(await failureFor(TimeoutException('slow')), isA<OfflineFailure>());
    });

    test('sekin javob — belgilangan vaqtdan keyin oflayn', () async {
      final slow = RpcRemoteApi(
        (_, _) => Completer<Object?>().future,
        timeout: const Duration(milliseconds: 10),
      );
      expect(err(await slow.bootstrap()), isA<OfflineFailure>());
    });

    test(
      'shartnomaga mos kelmagan javob — invalid_response (yashirilmaydi)',
      () async {
        transport.respond = (_) => {'schema_version': '1'};
        expect(
          err(await api.bootstrap()),
          isA<RejectedFailure>().having(
            (f) => f.code,
            'code',
            'invalid_response',
          ),
        );
        transport.respond = (_) => 42;
        expect(
          err(await api.acceptInvite('X')),
          const RejectedFailure('invalid_response'),
        );
      },
    );

    test('kutilmagan xato — yutilmaydi', () async {
      transport.respond = (_) => throw StateError('bug');
      await expectLater(api.bootstrap(), throwsStateError);
    });
  });
}
