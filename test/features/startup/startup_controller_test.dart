import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../data/sync/fake_remote.dart';
import '../../support/fake_auth.dart';
import '../../support/fake_startup.dart';

void main() {
  late AppDatabase db;
  late FakeRemote remote;
  late FakeAuthGateway auth;
  var version = '9.9.9';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeRemote();
    auth = FakeAuthGateway(currentUserId: 'user-1');
    version = '9.9.9';
  });
  tearDown(() => db.close());

  ProviderContainer container() => ProviderContainer.test(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      remoteApiProvider.overrideWithValue(remote),
      authGatewayProvider.overrideWithValue(auth),
      appVersionProvider.overrideWith((ref) async => version),
    ],
  );

  /// Holat `Loading` dan chiqguncha kutadi.
  Future<StartupState> settled(ProviderContainer ref) async {
    for (var i = 0; i < 50; i++) {
      final state = ref.read(startupProvider);
      if (state is! StartupLoading) return state;
      await pumpEventQueue();
    }
    return await Future.value(ref.read(startupProvider));
  }

  test('byudjet tanlanadi: saqlangan → serverdagi oxirgi → birinchi', () async {
    remote.boot = Ok(
      AppBootstrap.fromJson(
        bootstrapJson(
          households: [
            householdJson(id: 'h1'),
            householdJson(id: 'h2', name: 'Oila'),
          ],
          lastHouseholdId: 'h2',
        ),
      ),
    );
    final ref = container();

    var state = await settled(ref);
    expect((state as StartupReady).household.id, 'h2');
    expect(state.currency.allocationUnit, 100000);
    expect(ref.read(currentHouseholdIdProvider), 'h2');
    expect(await db.setting(StartupController.householdKey), 'h2');

    await db.setSetting(StartupController.householdKey, 'h1');
    await ref.read(startupProvider.notifier).reload();
    state = await settled(ref);
    expect((state as StartupReady).household.id, 'h1');
  });

  test("oflayn — saqlangan nusxa bilan ochiladi; nusxa yo'q — xato", () async {
    final ref = container();
    remote.boot = const Err(OfflineFailure());
    expect(await settled(ref), isA<StartupFailed>());

    await db.setSetting(
      StartupController.bootstrapKey,
      jsonEncode(bootstrapJson()),
    );
    await ref.read(startupProvider.notifier).reload();
    final state = await settled(ref);
    expect((state as StartupReady).household.name, 'Uy');
  });

  test('server xatosi — qayta urinish mumkin', () async {
    final ref = container();
    remote.boot = const Err(RejectedFailure('forbidden'));
    expect(
      (await settled(ref) as StartupFailed).failure,
      const RejectedFailure('forbidden'),
    );

    remote.boot = Ok(bootstrapFixture());
    await ref.read(startupProvider.notifier).reload();
    expect(await settled(ref), isA<StartupReady>());
  });

  test('BR-214: eski versiya — boshqa hech narsa yuklanmaydi', () async {
    version = '0.0.9';
    remote.boot = Ok(bootstrapFixture());
    final ref = container();

    final state = await settled(ref);
    expect(state, isA<StartupUpdateRequired>());
    expect((state as StartupUpdateRequired).minVersion, '0.1.0');
    expect(ref.read(currentHouseholdIdProvider), isNull);
  });

  test("byudjet yo'q — yaratish yoki qo'shilish holati", () async {
    remote.boot = Ok(AppBootstrap.fromJson(bootstrapJson(households: [])));
    final ref = container();
    expect(await settled(ref), isA<StartupNoHousehold>());
  });

  test('yangi byudjet: nom tekshiriladi, yaratilgani tanlanadi', () async {
    remote
      ..boot = Ok(AppBootstrap.fromJson(bootstrapJson(households: [])))
      ..created = const Ok('h9');
    final ref = container();
    await settled(ref);
    final controller = ref.read(startupProvider.notifier);

    expect(
      await controller.createHousehold('  '),
      isA<Err<void>>().having(
        (e) => e.failure,
        'f',
        const ValidationFailure('name', 'required'),
      ),
    );

    remote.boot = Ok(
      AppBootstrap.fromJson(
        bootstrapJson(
          households: [householdJson(id: 'h9', name: 'Oila')],
          lastHouseholdId: null,
        ),
      ),
    );
    expect(await controller.createHousehold(' Oila '), isA<Ok<void>>());
    expect(remote.households, ['create:Oila']);
    expect((await settled(ref) as StartupReady).household.id, 'h9');
  });

  test('taklif kodi: havoladan ajratiladi, server xatosi qaytadi', () async {
    remote
      ..boot = Ok(AppBootstrap.fromJson(bootstrapJson(households: [])))
      ..accepted = const Err(RejectedFailure('invite_expired'));
    final ref = container();
    await settled(ref);
    final controller = ref.read(startupProvider.notifier);

    expect(
      await controller.joinHousehold('qisqa'),
      isA<Err<void>>().having(
        (e) => e.failure,
        'f',
        const ValidationFailure('code', 'invalid_code'),
      ),
    );
    expect(
      await controller.joinHousehold('mywallet://invite/abcd2345'),
      isA<Err<void>>().having(
        (e) => e.failure,
        'f',
        const RejectedFailure('invite_expired'),
      ),
    );
    expect(remote.households, ['join:ABCD2345']);
  });

  test("boshqa akkaunt kirsa — lokal ma'lumot tozalanadi", () async {
    await db
        .into(db.households)
        .insert(
          const Household(
            id: 'old',
            name: 'Eski',
            personalFund: PersonalFundRule(),
          ).toRow(),
        );
    await db.claimForUser('user-0');
    remote.boot = Ok(bootstrapFixture());

    final ref = container();
    await settled(ref);
    expect(await db.select(db.households).get(), isEmpty);
    expect(await db.setting(StartupController.householdKey), 'h1');
  });

  test('kirilmagan — yuklanmaydi', () async {
    final ref = ProviderContainer.test(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        remoteApiProvider.overrideWithValue(remote),
        authGatewayProvider.overrideWithValue(FakeAuthGateway()),
      ],
    );
    expect(ref.read(startupProvider), isA<StartupLoading>());
    await ref.read(startupProvider.notifier).reload();
    expect(ref.read(startupProvider), isA<StartupLoading>());
  });

  group('taklif kodi havolasi', () {
    test("kod, deep link va havola ichidan; noto'g'ri — null", () {
      expect(parseInviteCode(' abcd2345 '), 'ABCD2345');
      expect(parseInviteCode('mywallet://invite/ABCD2345'), 'ABCD2345');
      expect(
        parseInviteCode('https://mywallet.uz/invite/abcd2345?ref=tg'),
        'ABCD2345',
      );
      expect(parseInviteCode('ABCD234'), isNull);
      // Adashtiradigan belgilar alifboda yo'q (0, 1, I, O).
      expect(parseInviteCode('ABCD2340'), isNull);
      expect(parseInviteCode(''), isNull);
    });
  });
}
