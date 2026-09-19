// E13-T07: sinxron — haqiqiy lokal Supabase bilan (admin repo, contracts.lock
// dagi commit). Ikki "qurilma" (alohida lokal baza va klient) bitta
// foydalanuvchi bilan. Qurilmasiz — host'da ishlaydi:
//
//   make integration   (admin repoda `supabase start` ishlab turishi kerak)
//
// `integration_test/` emas: u qurilma talab qiladi, bu testlar esa host'da
// (emulyatorsiz) ishlaydi — CI arzon va tez.
//
// Muhit: SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, SUPABASE_SECRET_KEY
// (standart — lokal Supabase manzili; kalitlar `supabase status -o env`).
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/sync/sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wallet_domain/wallet_domain.dart';

final Map<String, String> _env = Platform.environment;
final String _url = _env['SUPABASE_URL'] ?? 'http://127.0.0.1:54321';
final String _publishableKey = _env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
final String _secretKey = _env['SUPABASE_SECRET_KEY'] ?? '';

/// Bitta "qurilma": o'z lokal bazasi, klienti va sinxron dvigateli.
final class Device {
  new _(this.name, this.db, this.client, this.api, this.engine);

  final String name;
  final AppDatabase db;
  final SupabaseClient client;
  final RpcRemoteApi api;
  final SyncEngine engine;
  late final String householdId;

  static Future<Device> signIn(
    String name,
    String email,
    String password,
  ) async {
    final client = SupabaseClient(
      _url,
      _publishableKey,
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    await client.auth.signInWithPassword(email: email, password: password);
    final db = AppDatabase(NativeDatabase.memory());
    final api = RpcRemoteApi(supabaseTransport(client));
    final device = Device._(
      name,
      db,
      client,
      api,
      SyncEngine(
        db,
        api,
        deviceId: 'it-$name',
        now: () => DateTime.now().toUtc(),
      ),
    );
    final boot = await api.bootstrap();
    device.householdId = switch (boot) {
      Ok(:final value) => value.lastHouseholdId!,
      Err(:final failure) => throw StateError('bootstrap: $failure'),
    };
    return device;
  }

  DomainDeps get deps => localDomainDeps(
    db,
    householdId: householdId,
    clock: TzClock('Asia/Tashkent'),
  );

  Future<SyncReport> sync() async {
    final report = await engine.sync(householdId);
    expect(report.failure, isNull, reason: '$name sinxroni: ${report.failure}');
    return report;
  }

  Future<String> accountId(String type) async => (await (db.select(
    db.accounts,
  )..where((a) => a.type.equals(type))).getSingle()).id;

  Future<String> categoryId(String name) async => (await (db.select(
    db.categories,
  )..where((c) => c.name.equals(name))).getSingle()).id;

  Future<TransactionRow?> transaction(String id) => (db.select(
    db.transactions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> dispose() async {
    await db.close();
    await client.dispose();
  }
}

T ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail('Ok kutilgan, $failure keldi'),
};

Future<(String, String)> createUser() async {
  final email = 'it-${DateTime.now().microsecondsSinceEpoch}@example.test';
  final password = base64Url.encode(
    List.generate(18, (i) => (i * 37 + 11) % 256),
  );
  final response = await http.post(
    Uri.parse('$_url/auth/v1/admin/users'),
    headers: {'apikey': _secretKey, 'content-type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
      'email_confirm': true,
    }),
  );
  if (response.statusCode >= 300) {
    throw StateError(
      'Foydalanuvchi yaratilmadi: ${response.statusCode} ${response.body}',
    );
  }
  return (email, password);
}

void main() {
  setUpAll(() {
    // Ikki qurilma — ikki alohida xotiradagi baza (umumiy executor yo'q).
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    if (_publishableKey.isEmpty || _secretKey.isEmpty) {
      fail(
        'SUPABASE_PUBLISHABLE_KEY va SUPABASE_SECRET_KEY kerak '
        '(make integration)',
      );
    }
  });

  late Device a;
  late Device b;
  setUp(() async {
    final (email, password) = await createUser();
    a = await Device.signIn('a', email, password);
    b = await Device.signIn('b', email, password);
    await a.sync();
    await b.sync();
  });
  tearDown(() async {
    await a.dispose();
    await b.dispose();
  });

  Future<Transaction> addExpense(
    Device device, {
    String account = 'card',
    String? note,
  }) async => ok<Transaction>(
    await AddTransaction(device.deps)(
      TransactionInput(
        kind: TransactionKind.expense,
        accountId: await device.accountId(account),
        amount: const Money(4500000),
        categoryId: await device.categoryId('Oziq-ovqat'),
        payee: note,
      ),
    ),
  );

  test(
    'oflayn yozuv → push → boshqa qurilmada (server maydonlari bilan)',
    () async {
      final tx = await addExpense(a, note: 'Korzinka');
      expect((await a.transaction(tx.id))!.rowVersion, 0);

      final report = await a.sync();
      expect(report.pushed, 1);
      final synced = (await a.transaction(tx.id))!;
      expect(synced.rowVersion, greaterThan(0));
      expect(synced.createdAt, isNotNull);

      await b.sync();
      final onB = (await b.transaction(tx.id))!;
      expect(
        (onB.payee, onB.amount, onB.budgetMonth),
        ('Korzinka', 4500000, synced.budgetMonth),
      );
      expect(await a.db.select(a.db.outbox).get(), isEmpty);
    },
  );

  test(
    'BR-006: bir qator ikki qurilmada — conflict, server versiyasi va muammo',
    () async {
      final tx = await addExpense(a);
      await a.sync();
      await b.sync();

      ok(
        await EditTransaction(a.deps)(
          tx.id,
          (t) => t.copyWith(note: 'A qurilma'),
        ),
      );
      ok(
        await EditTransaction(b.deps)(
          tx.id,
          (t) => t.copyWith(note: 'B qurilma'),
        ),
      );
      expect((await b.sync()).pushed, 1);

      final report = await a.sync();
      expect(report.conflicts, 1);
      expect((await a.transaction(tx.id))!.note, 'B qurilma');
      final issue = await a.db.select(a.db.syncIssues).getSingle();
      expect(issue.status, 'conflict');
      expect(jsonDecode(issue.localData), containsPair('note', 'A qurilma'));
    },
  );

  test(
    "server rad etadi (hisob boshqa qurilmada o'chirilgan) — yozuv qaytariladi",
    () async {
      final card = await b.accountId('card');
      final deleted = await b.api.syncPush(b.householdId, 'it-b', [
        SyncMutation(
          mutationId: const UuidV7Ids().newId(),
          table: 'accounts',
          op: 'delete',
          id: card,
          data: const {},
        ),
      ]);
      expect(ok(deleted).single.status, SyncPushStatus.ok);

      // A hali bilmaydi — o'chirilgan hisobga yozadi.
      final tx = await addExpense(a);
      final report = await a.engine.push(a.householdId);
      expect(report.rejected, 1);
      expect(await a.transaction(tx.id), isNull);
      final issue = await a.db.select(a.db.syncIssues).getSingle();
      expect((issue.status, issue.code), ('rejected', 'account_deleted'));

      // Keyingi pull o'chirilgan hisobni ham olib keladi.
      await a.sync();
      final account = await (a.db.select(
        a.db.accounts,
      )..where((x) => x.id.equals(card))).getSingle();
      expect(account.deletedAt, isNotNull);
    },
  );

  test(
    "o'chirish — tombstone boshqa qurilmaga yetadi, qaytarish ham",
    () async {
      final tx = await addExpense(a);
      await a.sync();
      await b.sync();

      final snapshot = ok(await DeleteTransaction(a.deps)(tx.id));
      await a.sync();
      await b.sync();
      expect((await b.transaction(tx.id))!.deletedAt, isNotNull);

      // Qaytarish deleted_at'ni NULL ga qaytaradi — pull buni ham yozishi
      // kerak (toCompanion(false), sync_tables.dart).
      ok(await UndoDeleteTransaction(a.deps)(snapshot));
      await a.sync();
      expect(await a.db.select(a.db.syncIssues).get(), isEmpty);
      expect((await a.transaction(tx.id))!.deletedAt, isNull);
      await b.sync();
      expect((await b.transaction(tx.id))!.deletedAt, isNull);
    },
  );
}
