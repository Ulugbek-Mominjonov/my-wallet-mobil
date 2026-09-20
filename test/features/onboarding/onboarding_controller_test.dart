import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/onboarding/application/onboarding_controller.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../data/sync/fake_remote.dart';
import '../../support/fake_auth.dart';
import '../../support/fake_startup.dart';

void main() {
  late AppDatabase db;
  late FakeRemote remote;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeRemote();
    await db.batch((batch) {
      batch
        ..insertAll(db.accounts, [
          // Tartib — serverdagi `sort_order` bilan bir xil.
          for (final (id, name, type, order) in const [
            ('a1', 'Naqd', AccountType.cash, 1),
            ('a2', 'Karta', AccountType.card, 2),
            ('a3', 'Shaxsiy fond', AccountType.personalFund, 3),
          ])
            Account(
              id: id,
              householdId: 'h1',
              name: name,
              type: type,
              openingBalance: Money.zero,
              sortOrder: order,
              rowVersion: 1,
            ).toCompanion(),
        ])
        ..insertAll(db.categories, [
          const Category(
            id: 'c1',
            householdId: 'h1',
            kind: CategoryKind.income,
            name: 'Oylik',
            monthShift: -1,
          ).toCompanion(),
          const Category(
            id: 'c2',
            householdId: 'h1',
            kind: CategoryKind.expense,
            name: 'Ijara',
          ).toCompanion(),
          const Category(
            id: 'c3',
            householdId: 'h1',
            kind: CategoryKind.expense,
            name: "O'zim uchun",
            systemCode: SystemCode.personalAllocation,
          ).toCompanion(),
        ]);
    });
  });
  tearDown(() => db.close());

  Future<(ProviderContainer, OnboardingController)> open() async {
    final container = ProviderContainer.test(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        remoteApiProvider.overrideWithValue(remote),
        authGatewayProvider.overrideWithValue(
          FakeAuthGateway(currentUserId: 'user-1'),
        ),
        startupProvider.overrideWith(() => FakeStartupController(readyState())),
        // Rejalashtiruvchi platforma kanallariga tegadi — testda kerak emas.
        syncSchedulerProvider.overrideWith((ref) async => null),
      ],
    );
    container.read(currentHouseholdIdProvider.notifier).select('h1');
    final controller = container.read(onboardingProvider.notifier);
    await pumpEventQueue();
    return (container, controller);
  }

  test(
    'spravochniklar sinxrondan: fond hisobi va tizim kategoriyasisiz',
    () async {
      final (ref, _) = await open();
      final state = ref.read(onboardingProvider);

      expect(state.loaded, isTrue);
      expect([for (final a in state.accounts) a.name], ['Naqd', 'Karta']);
      expect([for (final i in state.incomes) i.name], ['Oylik']);
      expect(state.incomes.single.monthShift, -1);
      expect([for (final r in state.recurring) r.name], ['Ijara']);
      // Fond manbasi — naqd hisob (BR-060 standarti).
      expect(state.fund.account, 'Naqd');
    },
  );

  test("yuk: faqat to'ldirilgan qatorlar (contracts/api.md)", () async {
    final (ref, controller) = await open();
    controller
      ..setAccountBalance('Naqd', const Money(150000000))
      ..updateIncome(
        'Oylik',
        (i) => i.copyWith(
          enabled: true,
          day: 2,
          amount: const Money(800000000),
          account: 'Karta',
        ),
      )
      ..updateRecurring(
        'Ijara',
        (r) => r.copyWith(
          enabled: true,
          amount: const Money(300000000),
          day: 5,
          account: 'Naqd',
        ),
      )
      ..updateFund((f) => f.copyWith(percent: 15));

    final payload = ref.read(onboardingProvider).toPayload();
    expect(payload['accounts'], [
      {'name': 'Naqd', 'type': 'cash', 'opening_balance': 150000000},
    ]);
    expect(payload['income_types'], [
      {
        'name': 'Oylik',
        'month_shift': -1,
        'expected_day': 2,
        'expected_amount': 800000000,
        'account': 'Karta',
      },
    ]);
    expect(payload['recurring'], [
      {
        'kind': 'expense',
        'name': 'Ijara',
        'category': 'Ijara',
        'account': 'Naqd',
        'amount': 300000000,
        'day_of_month': 5,
        'auto_pay': false,
      },
    ]);
    expect(payload['fund'], {
      'mode': 'percent',
      'percent': 15,
      'fixed_amount': 0,
      'day': 5,
      'source_account': 'Naqd',
    });
  });

  test('belgilanmagan qatorlar va summasiz reja yuborilmaydi', () async {
    final (ref, controller) = await open();
    controller.updateRecurring('Ijara', (r) => r.copyWith(enabled: true));

    final payload = ref.read(onboardingProvider).toPayload();
    expect(payload['accounts'], isEmpty);
    expect(payload['income_types'], isEmpty);
    expect(payload['recurring'], isEmpty);
  });

  test('qadamlar: keyingi, orqaga, chegaralar', () async {
    final (ref, controller) = await open();
    expect(ref.read(onboardingProvider).step, OnboardingStep.accounts);

    controller.back();
    expect(ref.read(onboardingProvider).step, OnboardingStep.accounts);

    for (var i = 0; i < 6; i++) {
      controller.next();
    }
    expect(ref.read(onboardingProvider).step, OnboardingStep.done);

    controller.back();
    expect(ref.read(onboardingProvider).step, OnboardingStep.fund);
  });

  test('tayyor: onboarding_apply + joriy oy ochiladi', () async {
    final (ref, controller) = await open();
    expect(await controller.apply(), isA<Ok<void>>());

    expect(remote.appliedPayload, isNotNull);
    expect(remote.openedMonths, hasLength(1));
    expect(ref.read(onboardingProvider).busy, isFalse);
  });

  test('oy ochilmasa ham sozlash saqlanadi', () async {
    final (ref, controller) = await open();
    remote.openMonthResult = const Err(OfflineFailure());
    expect(await controller.apply(), isA<Ok<void>>());
    expect(ref.read(onboardingProvider).failure, isNull);
  });

  test("server rad etsa — xato ko'rsatiladi, oy ochilmaydi", () async {
    final (ref, controller) = await open();
    remote.applyResult = const Err(RejectedFailure('forbidden'));

    expect(await controller.apply(), isA<Err<void>>());
    expect(
      ref.read(onboardingProvider).failure,
      const RejectedFailure('forbidden'),
    );
    expect(remote.openedMonths, isEmpty);
  });
}
