import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/sync/sync_engine.dart';
import 'package:my_wallet/data/sync/sync_issue_actions.dart';
import 'package:my_wallet/data/sync/sync_scheduler.dart';
import 'package:my_wallet/data/sync/sync_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lokal baza — ilova davomida bitta ulanish.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

/// Server (Supabase RPC) — `bootstrap` Supabase'ni ishga tushiradi.
final remoteApiProvider = Provider<RemoteApi>(
  (ref) => RpcRemoteApi(supabaseTransport(Supabase.instance.client)),
);

final deviceIdProvider = FutureProvider<String>(
  (ref) =>
      ref.watch(appDatabaseProvider).deviceId(newId: const UuidV7Ids().newId),
);

/// Tanlangan byudjet (E14: `app_bootstrap` va almashtirgich o'rnatadi).
final currentHouseholdIdProvider = NotifierProvider<CurrentHousehold, String?>(
  CurrentHousehold.new,
);

final class CurrentHousehold extends Notifier<String?> {
  @override
  String? build() {
    // Chiqish yoki boshqa akkaunt — tanlov bekor (sinxron ham to'xtaydi).
    ref.watch(authUserProvider);
    return null;
  }

  // Notifier holati tashqaridan o'rnatiladi (E14 oqimlari).
  // ignore: use_setters_to_change_properties
  void select(String? householdId) => state = householdId;
}

/// Tarmoq holati o'zgarishlari (`true` — ulangan).
final connectivityProvider = StreamProvider<bool>(
  (ref) => Connectivity().onConnectivityChanged.map(
    (results) => results.any((r) => r != ConnectivityResult.none),
  ),
);

final syncEngineProvider = FutureProvider<SyncEngine>(
  (ref) async => SyncEngine(
    ref.watch(appDatabaseProvider),
    ref.watch(remoteApiProvider),
    deviceId: await ref.watch(deviceIdProvider.future),
    now: () => DateTime.now().toUtc(),
  ),
);

/// Joriy byudjet sinxron rejalashtiruvchisi: ochilishda, tarmoq qaytganda,
/// ilova oldinga chiqqanda ishlaydi (ARXITEKTURA 5). Byudjet tanlanmagan —
/// null.
final syncSchedulerProvider = FutureProvider<SyncScheduler?>((ref) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return null;
  final engine = await ref.watch(syncEngineProvider.future);
  final scheduler = SyncScheduler(() => engine.sync(householdId));
  ref
    ..onDispose(scheduler.dispose)
    ..listen(connectivityProvider, (previous, next) {
      final wasOnline = previous?.value ?? true;
      if (next.value == true && !wasOnline) scheduler.onNetworkRestored();
    });
  final lifecycle = AppLifecycleListener(onResume: scheduler.onResume);
  ref.onDispose(lifecycle.dispose);
  scheduler.onStart();
  return scheduler;
});

/// Sinxron holati — navbat, muammolar, kursor va jonli jarayon birlashmasi.
final syncStatusProvider = StreamProvider<SyncStatus?>((ref) async* {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) {
    yield null;
    return;
  }
  final db = ref.watch(appDatabaseProvider);
  final scheduler = await ref.watch(syncSchedulerProvider.future);
  yield* watchSyncStatus(db, householdId, scheduler);
});

final syncIssueActionsProvider = Provider<SyncIssueActions>(
  (ref) => SyncIssueActions(
    ref.watch(appDatabaseProvider),
    newId: const UuidV7Ids().newId,
    now: () => DateTime.now().toUtc(),
  ),
);

/// Lokal jadvallar va rejalashtiruvchi holatidan jonli [SyncStatus].
Stream<SyncStatus> watchSyncStatus(
  AppDatabase db,
  String householdId,
  SyncScheduler? scheduler,
) {
  final controller = StreamController<SyncStatus>();
  var pending = 0;
  var issues = const <SyncIssueRow>[];
  SyncStateRow? state;
  var activity = scheduler?.activity ?? const SyncActivity();

  void emit() => controller.add(
    SyncStatus(
      pendingCount: pending,
      issues: issues,
      lastPullAt: state?.lastPullAt,
      lastPushAt: state?.lastPushAt,
      running: activity.running,
      lastFailure: activity.lastReport?.failure,
    ),
  );

  final count = db.outbox.id.count();
  final subscriptions = [
    (db.selectOnly(db.outbox)
          ..addColumns([count])
          ..where(db.outbox.householdId.equals(householdId)))
        .map((row) => row.read(count) ?? 0)
        .watchSingle()
        .listen((value) {
          pending = value;
          emit();
        }, onError: controller.addError),
    (db.select(db.syncIssues)
          ..where(
            (i) => i.householdId.equals(householdId) & i.resolvedAt.isNull(),
          )
          ..orderBy([(i) => OrderingTerm.desc(i.id)]))
        .watch()
        .listen((value) {
          issues = value;
          emit();
        }, onError: controller.addError),
    (db.select(db.syncState)..where((s) => s.householdId.equals(householdId)))
        .watchSingleOrNull()
        .listen((value) {
          state = value;
          emit();
        }, onError: controller.addError),
    if (scheduler != null)
      scheduler.activityChanges.listen((value) {
        activity = value;
        emit();
      }),
  ];
  controller.onCancel = () async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
  };
  return controller.stream;
}
