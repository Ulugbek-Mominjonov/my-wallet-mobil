import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/outbox_writer.dart';
import 'package:my_wallet/data/receipts/receipt_compression.dart';
import 'package:my_wallet/data/receipts/receipt_queue.dart';

final class _FakeStorage implements ReceiptStorage {
  final uploads = <String, Uint8List>{};
  Exception? error;

  @override
  Future<void> upload(
    String path,
    Uint8List bytes, {
    required String mime,
  }) async {
    if (error != null) throw error!;
    uploads[path] = bytes;
  }

  @override
  Future<String> signedUrl(String path) async => 'https://signed/$path';
}

void main() {
  late AppDatabase db;
  late Directory dir;
  late _FakeStorage storage;
  late ReceiptQueue queue;
  var n = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dir = await Directory.systemTemp.createTemp('receipts');
    storage = _FakeStorage();
    n = 0;
    String newId() => 'id-${n++}';
    DateTime now() => DateTime.utc(2026, 10, 5, 4);
    queue = ReceiptQueue(
      db,
      storage,
      OutboxWriter(db, newId: newId, now: now),
      directory: () async => dir,
      newId: newId,
      now: now,
    );
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  final image = (bytes: Uint8List.fromList([1, 2, 3]), mime: 'image/jpeg');

  test('navbat: fayl qurilmada, yuklangach attachments + outbox', () async {
    await queue.enqueue(householdId: 'h', transactionId: 't', image: image);
    final pending = await db.select(db.pendingUploads).getSingle();
    expect(File(pending.localPath).existsSync(), isTrue);
    expect(pending.sizeBytes, 3);

    expect(await queue.flush('h'), 1);
    expect(storage.uploads.keys, ['h/t/id-0.jpg']);
    final attachment = await db.select(db.attachments).getSingle();
    expect(
      (attachment.id, attachment.storagePath, attachment.mime),
      ('id-0', 'h/t/id-0.jpg', 'image/jpeg'),
    );
    final mutation = await db.select(db.outbox).getSingle();
    expect(mutation.targetTable, 'attachments');
    expect(await db.select(db.pendingUploads).get(), isEmpty);
    expect(File(pending.localPath).existsSync(), isFalse);
  });

  test("tarmoq yo'q — navbatda qoladi, urinishlar sanaladi", () async {
    await queue.enqueue(householdId: 'h', transactionId: 't', image: image);
    storage.error = const SocketException('offline');
    expect(await queue.flush('h'), 0);
    final pending = await db.select(db.pendingUploads).getSingle();
    expect(pending.attempts, 1);
    expect(pending.lastError, contains('offline'));
    expect(await db.select(db.attachments).get(), isEmpty);

    storage.error = null;
    expect(await queue.flush('h'), 1);
  });

  test(
    "fayl yo'qolgan — navbatdan chiqadi; boshqa byudjetga tegmaydi",
    () async {
      await queue.enqueue(householdId: 'h', transactionId: 't', image: image);
      await queue.enqueue(householdId: 'x', transactionId: 't2', image: image);
      final first = await (db.select(
        db.pendingUploads,
      )..where((p) => p.householdId.equals('h'))).getSingle();
      await File(first.localPath).delete();

      expect(await queue.flush('h'), 0);
      final left = await db.select(db.pendingUploads).get();
      expect([for (final p in left) p.householdId], ['x']);
    },
  );

  test("bekor qilish va yuklanganini o'chirish (yumshoq, outbox)", () async {
    await queue.enqueue(householdId: 'h', transactionId: 't', image: image);
    final pending = await db.select(db.pendingUploads).getSingle();
    await queue.cancelPending(pending.id);
    expect(await db.select(db.pendingUploads).get(), isEmpty);
    expect(File(pending.localPath).existsSync(), isFalse);

    await queue.enqueue(householdId: 'h', transactionId: 't', image: image);
    await queue.flush('h');
    final attachment = await db.select(db.attachments).getSingle();
    await queue.removeAttachment(attachment.id);
    final removed = await db.select(db.attachments).getSingle();
    expect(removed.deletedAt, isNotNull);
    // Serverga yetmagan qator o'chirildi — yuboradigan narsa yo'q; Storage'dagi
    // faylni server tozalaydi (qatorsiz — 1 kun, E11-T08).
    expect(await db.select(db.outbox).get(), isEmpty);
  });

  test('1 MB dan katta — qabul qilinmaydi', () async {
    expect(
      () => queue.enqueue(
        householdId: 'h',
        transactionId: 't',
        image: (bytes: Uint8List(maxReceiptBytes + 1), mime: 'image/jpeg'),
      ),
      throwsArgumentError,
    );
    expect(ReceiptQueue.storagePath('h', 't', 'a'), 'h/t/a.jpg');
    expect(
      ReceiptQueue.storagePath('h', 't', 'a', mime: 'image/webp'),
      'h/t/a.webp',
    );
    expect(
      () => queue.enqueue(
        householdId: 'h',
        transactionId: 't',
        image: (bytes: Uint8List(1), mime: 'image/gif'),
      ),
      throwsArgumentError,
    );
  });

  group('siqish (BR-201)', () {
    test("sig'guncha sifat pasayadi", () async {
      final calls = <(int, int)>[];
      Future<Uint8List> encoder(
        Uint8List source, {
        required int quality,
        required int maxSide,
      }) async {
        calls.add((quality, maxSide));
        return Uint8List(quality > 70 ? 2000 : 500);
      }

      final result = await compressToLimit(Uint8List(10), encoder, limit: 1000);
      expect(result!.bytes.length, 500);
      expect(result.mime, 'image/jpeg');
      expect(calls, [(85, 1600), (75, 1600), (65, 1280)]);
    });

    test("eng past sifatda ham sig'masa — null", () async {
      Future<Uint8List> encoder(
        Uint8List source, {
        required int quality,
        required int maxSide,
      }) async => Uint8List(5000);
      expect(await compressToLimit(Uint8List(1), encoder, limit: 1000), isNull);
    });
  });
}
