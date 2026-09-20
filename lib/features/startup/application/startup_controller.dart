import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Ilova ochilgandagi holat: `app_bootstrap` (ARXITEKTURA 5) → byudjet.
@immutable
sealed class StartupState {
  const new();
}

final class StartupLoading extends StartupState {
  const new();
}

/// Server ham, saqlangan nusxa ham yo'q — qayta urinish yoki chiqish.
final class StartupFailed extends StartupState {
  const new(this.failure);

  final Failure failure;
}

/// Byudjet yo'q (hammasidan chiqib ketilgan) — yaratish yoki qo'shilish.
final class StartupNoHousehold extends StartupState {
  const new();
}

final class StartupReady extends StartupState {
  const new(this.household, this.boot);

  final BootstrapHousehold household;
  final AppBootstrap boot;

  /// Onboarding tugamagan — sozlash oynasi (E14-T03).
  bool get needsOnboarding => !household.onboarded;

  Currency get currency => boot.currencies
      .firstWhere(
        (c) => c.code == household.baseCurrency,
        orElse: () => throw StateError('valyuta topilmadi'),
      )
      .toCurrency();
}

final NotifierProvider<StartupController, StartupState> startupProvider =
    NotifierProvider(StartupController.new);

/// `app_bootstrap` → byudjet tanlovi. Oflaynda oxirgi javob nusxasi bilan
/// ishga tushadi (BR-007) — ilova tarmoqsiz ham ochiladi.
///
/// `base` — vidjet testlari holatni tayyor berish uchun meros oladi.
base class StartupController extends Notifier<StartupState> {
  static const bootstrapKey = 'bootstrap';
  static const householdKey = 'household_id';

  @override
  StartupState build() {
    final userId = ref.watch(authUserProvider);
    if (userId != null) unawaited(_load(userId));
    return const StartupLoading();
  }

  AppDatabase get _db => ref.read(appDatabaseProvider);
  RemoteApi get _api => ref.read(remoteApiProvider);

  /// Qayta urinish (xato ekranidan) yoki byudjet ro'yxatini yangilash.
  Future<void> reload() async {
    final userId = ref.read(authUserProvider);
    if (userId == null) return;
    state = const StartupLoading();
    await _load(userId);
  }

  Future<Result<void>> createHousehold(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Err(ValidationFailure('name', 'required'));
    }
    return await _afterJoin(await _api.createHousehold(trimmed));
  }

  /// [code] — 8 belgili taklif kodi yoki `mywallet://invite/<kod>` havolasi.
  Future<Result<void>> joinHousehold(String code) async {
    final parsed = parseInviteCode(code);
    if (parsed == null) {
      return const Err(ValidationFailure('code', 'invalid_code'));
    }
    return await _afterJoin(await _api.acceptInvite(parsed));
  }

  Future<Result<void>> _afterJoin(Result<String> result) async {
    switch (result) {
      case Ok(:final value):
        await _db.setSetting(householdKey, value);
        await reload();
        return const Ok(null);
      case Err(:final failure):
        return Err(failure);
    }
  }

  Future<void> _load(String userId) async {
    // Boshqa akkaunt kirgan bo'lsa — eski ma'lumot o'chadi.
    await _db.claimForUser(userId);
    final boot = await _bootstrap();
    if (boot == null) return;

    if (boot.households.isEmpty) {
      state = const StartupNoHousehold();
      return;
    }
    final saved = await _db.setting(householdKey);
    final household = _select(boot, saved);
    await _db.setSetting(householdKey, household.id);
    ref.read(currentHouseholdIdProvider.notifier).select(household.id);
    state = StartupReady(household, boot);
  }

  /// Serverdan; tarmoq yo'q bo'lsa — saqlangan nusxadan.
  Future<AppBootstrap?> _bootstrap() async {
    final result = await _api.bootstrap();
    switch (result) {
      case Ok(:final value):
        await _db.setSetting(bootstrapKey, jsonEncode(value.raw));
        return value;
      case Err(failure: OfflineFailure()):
        final cached = await _db.setting(bootstrapKey);
        if (cached == null) {
          state = const StartupFailed(OfflineFailure());
          return null;
        }
        return AppBootstrap.fromJson(
          jsonDecode(cached) as Map<String, Object?>,
        );
      case Err(:final failure):
        state = StartupFailed(failure);
        return null;
    }
  }

  /// Oxirgi tanlov → serverdagi oxirgi byudjet → birinchisi.
  BootstrapHousehold _select(AppBootstrap boot, String? saved) {
    for (final id in [saved, boot.lastHouseholdId]) {
      for (final household in boot.households) {
        if (household.id == id) return household;
      }
    }
    return boot.households.first;
  }
}

/// Byudjet vaqt zonasidagi soat (BR-002) — byudjet tanlangach aniq bo'ladi.
final clockProvider = Provider<Clock>((ref) {
  final state = ref.watch(startupProvider);
  return TzClock(
    state is StartupReady ? state.household.timezone : 'Asia/Tashkent',
  );
});

/// Taklif kodi: 8 belgi (adashtiradigan harflarsiz — serverdagi alifbo),
/// kod, `mywallet://invite/<kod>` yoki havola ichidan.
String? parseInviteCode(String input) {
  final normalized = input.trim().toUpperCase();
  final candidate = normalized.contains('/')
      ? normalized.split('/').where((part) => part.isNotEmpty).last
      : normalized;
  final code = candidate.split('?').first;
  return RegExp(r'^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$').hasMatch(code)
      ? code
      : null;
}
