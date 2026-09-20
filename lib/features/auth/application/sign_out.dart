import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';

final signOutProvider = Provider<SignOut>(
  (ref) =>
      SignOut(ref.watch(authGatewayProvider), ref.watch(appDatabaseProvider)),
);

/// Chiqish: sessiya va qurilmadagi ma'lumot. Qayta kirilganda byudjet
/// serverdan qayta yuklanadi.
final class SignOut {
  const new(this._gateway, this._db);

  final AuthGateway _gateway;
  final AppDatabase _db;

  /// Serverga hali yetmagan o'zgarishlar — chiqishdan oldin ogohlantirish.
  Future<int> unsentChanges() {
    final count = _db.outbox.id.count();
    return (_db.selectOnly(
      _db.outbox,
    )..addColumns([count])).map((row) => row.read(count) ?? 0).getSingle();
  }

  Future<void> call() async {
    await _gateway.signOut();
    await _db.clearUserData();
  }
}
