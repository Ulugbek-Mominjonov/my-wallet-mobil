import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/core/notifications/local_notifier.dart';
import 'package:my_wallet/core/notifications/push_service.dart';
import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';

final signOutProvider = Provider<SignOut>(
  (ref) => SignOut(
    ref.watch(authGatewayProvider),
    ref.watch(appDatabaseProvider),
    push: ref.watch(pushServiceProvider),
    remote: ref.watch(remoteApiProvider),
    notifier: ref.watch(localNotifierProvider),
  ),
);

/// Chiqish: sessiya va qurilmadagi ma'lumot. Qayta kirilganda byudjet
/// serverdan qayta yuklanadi.
final class SignOut {
  const new(
    this._gateway,
    this._db, {
    required this._push,
    required this._remote,
    required this._notifier,
  });

  final AuthGateway _gateway;
  final AppDatabase _db;
  final PushService _push;
  final RemoteApi _remote;
  final LocalNotifier _notifier;

  /// Serverga hali yetmagan o'zgarishlar — chiqishdan oldin ogohlantirish.
  Future<int> unsentChanges() {
    final count = _db.outbox.id.count();
    return (_db.selectOnly(
      _db.outbox,
    )..addColumns([count])).map((row) => row.read(count) ?? 0).getSingle();
  }

  Future<void> call() async {
    await _forgetDevice();
    await _gateway.signOut();
    await _db.clearUserData();
  }

  /// Qurilma boshqa akkauntga eslatma/push olmasin (E19). Oflaynda ham
  /// chiqish to'xtamaydi — eskirgan tokenni server o'zi tozalaydi.
  Future<void> _forgetDevice() async {
    try {
      await _notifier.replaceScheduled(const []);
      final token = await _push.token();
      if (token != null) {
        await _remote.unregisterDevice(token);
        await _push.deleteToken();
      }
    } on Object catch (error, stackTrace) {
      AppLog.error("Qurilmani chiqarib bo'lmadi", error, stackTrace);
    }
  }
}
