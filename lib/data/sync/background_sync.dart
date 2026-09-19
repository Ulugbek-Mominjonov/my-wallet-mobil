import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/sync/sync_engine.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Fon sinxronining yadrosi (platformasiz): qurilmadagi har byudjet uchun
/// bitta sikl. `true` — tugadi (yoki qayta urinish befoyda: sessiya yo'q),
/// `false` — WorkManager keyinroq qayta ursin (tarmoq xatosi).
Future<bool> runBackgroundSync(AppDatabase db, SyncEngine engine) async {
  final households = await db.select(db.households).get();
  var retry = false;
  for (final household in households) {
    final report = await engine.sync(household.id);
    switch (report.failure) {
      // Qayta kirish — faqat ilova ochilganda (foydalanuvchi bilan).
      case UnauthorizedFailure():
        return true;
      case OfflineFailure():
        retry = true;
      case _:
        break;
    }
  }
  return !retry;
}
