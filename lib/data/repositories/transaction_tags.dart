import 'package:drift/drift.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/outbox_writer.dart';

/// Amal teglari (`transaction_tags` — sinxron jadvali). Bog'lanish qatori
/// qo'shiladi yoki yumshoq o'chiriladi; har biri outbox'ga tushadi.
final class TransactionTagWriter {
  const new(
    this._db,
    this._householdId,
    this._outbox, {
    required this.newId,
    required this.now,
  });

  final AppDatabase _db;
  final String _householdId;
  final OutboxWriter _outbox;
  final String Function() newId;
  final DateTime Function() now;

  /// Amalning teglari [tagIds] ga teng bo'ladi (bitta tranzaksiyada).
  Future<void> setTags(String transactionId, Set<String> tagIds) =>
      _db.transaction(() async {
        final links = _db.transactionTags;
        final current =
            await (_db.select(links)..where(
                  (l) =>
                      l.transactionId.equals(transactionId) &
                      l.deletedAt.isNull(),
                ))
                .get();
        final existing = {for (final link in current) link.tagId};

        for (final link in current) {
          if (tagIds.contains(link.tagId)) continue;
          final query = _db.select(links)..where((l) => l.id.equals(link.id));
          await (_db.update(links)..where((l) => l.id.equals(link.id))).write(
            TransactionTagsCompanion(deletedAt: Value(now())),
          );
          await _outbox.enqueue(
            table: 'transaction_tags',
            householdId: _householdId,
            row: await query.getSingle(),
            before: link,
          );
        }

        for (final tagId in tagIds.difference(existing)) {
          final id = newId();
          await _db
              .into(links)
              .insert(
                TransactionTagsCompanion.insert(
                  id: id,
                  householdId: _householdId,
                  transactionId: transactionId,
                  tagId: tagId,
                ),
              );
          await _outbox.enqueue(
            table: 'transaction_tags',
            householdId: _householdId,
            row: await (_db.select(
              links,
            )..where((l) => l.id.equals(id))).getSingle(),
          );
        }
      });
}
