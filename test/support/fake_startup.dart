import 'dart:async';

import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/remote/json_read.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// `app_bootstrap` javobi (contracts/api.md) — testlar uchun.
Json bootstrapJson({
  List<Json>? households,
  String? lastHouseholdId = 'h1',
  bool onboarded = true,
  Json config = const {},
}) => {
  'schema_version': 1,
  'is_platform_admin': false,
  'profile': {
    'user_id': 'user-1',
    'display_name': 'Ali',
    'locale': 'uz',
    'last_household_id': lastHouseholdId,
  },
  'households': households ?? [householdJson(id: 'h1', onboarded: onboarded)],
  'currencies': [
    {
      'code': 'UZS',
      'name': {'uz': "So'm", 'ru': 'Сум', 'en': 'Som'},
      'symbol': "so'm",
      'exponent': 2,
      'allocation_rounding': 100000,
    },
  ],
  'app_config': config,
};

Json householdJson({
  required String id,
  String name = 'Uy',
  String role = 'owner',
  bool onboarded = true,
}) => {
  'id': id,
  'name': name,
  'role': role,
  'base_currency': 'UZS',
  'timezone': 'Asia/Tashkent',
  'onboarded': onboarded,
};

AppBootstrap bootstrapFixture({bool onboarded = true}) =>
    AppBootstrap.fromJson(bootstrapJson(onboarded: onboarded));

StartupState readyState({bool onboarded = true}) {
  final boot = bootstrapFixture(onboarded: onboarded);
  return StartupReady(boot.households.first, boot);
}

/// Yuklashsiz boshlanadigan boshqaruvchi (holat testdan beriladi).
final class FakeStartupController extends StartupController {
  new(this.initial);

  final StartupState initial;
  final calls = <String>[];

  /// Keyingi `createHousehold` / `joinHousehold` javobi.
  Result<void> result = const Ok(null);

  @override
  StartupState build() {
    // Haqiqiy boshqaruvchi kabi — byudjetni tanlaydi (build'dan keyin).
    if (initial case StartupReady(:final household)) {
      unawaited(
        Future.microtask(
          () => ref
              .read(currentHouseholdIdProvider.notifier)
              .select(household.id),
        ),
      );
    }
    return initial;
  }

  @override
  Future<void> reload() async => calls.add('reload');

  @override
  Future<Result<void>> createHousehold(String name) async {
    calls.add('create:$name');
    return result;
  }

  @override
  Future<Result<void>> joinHousehold(String code) async {
    calls.add('join:$code');
    return result;
  }
}
