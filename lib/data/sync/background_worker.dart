// Platforma ulanishi (Android WorkManager, fon isolate'i) — mantiq
// `runBackgroundSync` da va o'sha yerda testlanadi.
// coverage:ignore-file
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/data/auth/secure_session_storage.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/sync/background_sync.dart';
import 'package:my_wallet/data/sync/sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

/// ARXITEKTURA 5: fon sinxroni — har 6 soatda, faqat tarmoq bo'lsa.
const backgroundSyncTask = 'my_wallet.background_sync';
const backgroundSyncFrequency = Duration(hours: 6);

Future<void> registerBackgroundSync() async {
  await Workmanager().initialize(backgroundSyncDispatcher);
  await Workmanager().registerPeriodicTask(
    backgroundSyncTask,
    backgroundSyncTask,
    frequency: backgroundSyncFrequency,
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final env = AppEnv.values.byName(const String.fromEnvironment('APP_ENV'));
      final config = AppConfig.fromEnvironment(expected: env);
      await initSupabase(config);
      final client = Supabase.instance.client;
      if (client.auth.currentSession == null) return true;
      final db = AppDatabase.open();
      try {
        final engine = SyncEngine(
          db,
          RpcRemoteApi(supabaseTransport(client)),
          deviceId: await db.deviceId(newId: const UuidV7Ids().newId),
          now: () => DateTime.now().toUtc(),
        );
        return await runBackgroundSync(db, engine);
      } finally {
        await db.close();
      }
    } on Object catch (error, stackTrace) {
      AppLog.error('Fon sinxroni', error, stackTrace);
      return false;
    }
  });
}
