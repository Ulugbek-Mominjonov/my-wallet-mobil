// E14-T03: sozlash ustasi yuki — haqiqiy `onboarding_apply` va `open_month`
// (BR-010, BR-031, BR-060, BR-080, BR-081).
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/features/onboarding/application/onboarding_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../support/local_supabase.dart';

void main() {
  setUpAll(requireLocalSupabase);

  test('usta yuki qabul qilinadi va joriy oy ochiladi', () async {
    final (email, password) = await createUser();
    final client = newClient();
    addTearDown(client.dispose);
    await client.auth.signInWithPassword(email: email, password: password);
    final api = RpcRemoteApi(supabaseTransport(client));

    final boot = switch (await api.bootstrap()) {
      Ok(:final value) => value,
      Err(:final failure) => fail('bootstrap: $failure'),
    };
    final household = boot.households.single;
    expect(household.onboarded, isFalse);

    // Ustadagi holat bilan bir xil yuk (standart spravochnik nomlari).
    const state = OnboardingState(
      accounts: [
        AccountDraft(
          name: 'Naqd',
          type: AccountType.cash,
          balance: Money(150000000),
        ),
      ],
      incomes: [
        IncomeDraft(
          name: 'Oylik',
          monthShift: -1,
          enabled: true,
          day: 2,
          amount: Money(800000000),
          account: 'Naqd',
        ),
      ],
      recurring: [
        RecurringDraft(
          name: 'Ijara',
          enabled: true,
          amount: Money(300000000),
          account: 'Naqd',
        ),
      ],
      fund: FundDraft(account: 'Naqd'),
    );

    final applied = await api.onboardingApply(household.id, state.toPayload());
    expect(applied, isA<Ok<bool>>().having((r) => r.value, 'applied', isTrue));

    // Bir marta (BR: qayta chaqirilsa ustiga yozilmaydi).
    final again = await api.onboardingApply(household.id, state.toPayload());
    expect(again, isA<Ok<bool>>().having((r) => r.value, 'applied', isFalse));

    final month = MonthKey.ofDate(TzClock(household.timezone).today());
    final opened = switch (await api.openMonth(household.id, month)) {
      Ok(:final value) => value,
      Err(:final failure) => fail('open_month: $failure'),
    };
    // Ijara rejasi va 👤 fond ajratmasi (BR-060, BR-080).
    expect(opened.created, greaterThanOrEqualTo(2));

    final after = switch (await api.bootstrap()) {
      Ok(:final value) => value,
      Err(:final failure) => fail('bootstrap: $failure'),
    };
    expect(after.households.single.onboarded, isTrue);
  });
}
