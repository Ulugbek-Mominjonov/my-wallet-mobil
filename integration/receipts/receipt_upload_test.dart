// E15-T07 (BR-201): chek — haqiqiy Storage'ga yuklanadi va `attachments`
// qatori sinxron orqali serverga yetadi.
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/outbox_writer.dart';
import 'package:my_wallet/data/receipts/receipt_platform.dart';
import 'package:my_wallet/data/receipts/receipt_queue.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/sync/sync_engine.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../support/local_supabase.dart';

void main() {
  setUpAll(requireLocalSupabase);

  test("chek yuklanadi, attachments serverda, fayl o'qiladi", () async {
    final (email, password) = await createUser();
    final client = newClient();
    addTearDown(client.dispose);
    await client.auth.signInWithPassword(email: email, password: password);
    final api = RpcRemoteApi(supabaseTransport(client));
    final householdId = switch (await api.bootstrap()) {
      Ok(:final value) => value.households.single.id,
      Err(:final failure) => fail('bootstrap: $failure'),
    };

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final engine = SyncEngine(
      db,
      api,
      deviceId: 'it-receipt',
      now: () => DateTime.now().toUtc(),
    );
    expect((await engine.sync(householdId)).failure, isNull);

    final deps = localDomainDeps(
      db,
      householdId: householdId,
      clock: TzClock('Asia/Tashkent'),
    );
    final account = await (db.select(
      db.accounts,
    )..where((a) => a.type.equals('cash'))).getSingle();
    final category = await (db.select(
      db.categories,
    )..where((c) => c.kind.equals('expense'))).get();
    final tx = switch (await AddTransaction(deps)(
      TransactionInput(
        kind: TransactionKind.expense,
        accountId: account.id,
        amount: const Money(1000000),
        categoryId: category.first.id,
      ),
    )) {
      Ok(:final value) => value,
      Err(:final failure) => fail('amal: $failure'),
    };

    final dir = await Directory.systemTemp.createTemp('it-receipts');
    addTearDown(() => dir.delete(recursive: true));
    const ids = UuidV7Ids();
    final queue = ReceiptQueue(
      db,
      SupabaseReceiptStorage(client),
      OutboxWriter(db, newId: ids.newId, now: DateTime.now),
      directory: () async => dir,
      newId: ids.newId,
      now: DateTime.now,
    );
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
      '60e6kgAAAABJRU5ErkJggg==',
    );
    await queue.enqueue(
      householdId: householdId,
      transactionId: tx.id,
      image: (bytes: png, mime: 'image/png'),
    );

    // Tartib ilovadagidek: avval yuklash, keyin push (amal + biriktirma).
    expect(await queue.flush(householdId), 1);
    final report = await engine.sync(householdId);
    expect(report.failure, isNull);

    final rows = await client
        .from('attachments')
        .select('id, transaction_id, storage_path, mime, size_bytes')
        .eq('transaction_id', tx.id);
    expect(rows, hasLength(1));
    final path = rows.single['storage_path'] as String;
    expect(path, startsWith('$householdId/${tx.id}/'));
    expect(path, endsWith('.png'));
    expect(rows.single['size_bytes'], png.length);

    final downloaded = await client.storage.from(receiptsBucket).download(path);
    expect(downloaded, png);
  });
}
