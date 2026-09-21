import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show FutureProviderFamily, StreamProviderFamily;
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/outbox_writer.dart';
import 'package:my_wallet/data/receipts/receipt_compression.dart';
import 'package:my_wallet/data/receipts/receipt_platform.dart';
import 'package:my_wallet/data/receipts/receipt_queue.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Rasm tanlash va siqish (BR-201); `null` — bekor qilindi yoki 1 MB ga
/// sig'madi. Testda soxta funksiya bilan almashtiriladi.
typedef ReceiptPicker = Future<CompressedImage?> Function({
  required bool camera,
});

final Provider<ReceiptPicker> receiptPickerProvider = Provider(
  (ref) => ({required camera}) async {
    final source = await pickReceiptImage(camera: camera);
    if (source == null) return null;
    return await compressToLimit(source, nativeJpeg);
  },
);

final Provider<ReceiptStorage> receiptStorageProvider = Provider(
  (ref) => SupabaseReceiptStorage(Supabase.instance.client),
);

/// BR-201: chek rasmlari navbati (fayllar — ilova hujjatlari/receipts).
final Provider<ReceiptQueue> receiptQueueProvider = Provider((ref) {
  final db = ref.watch(appDatabaseProvider);
  const ids = UuidV7Ids();
  DateTime now() => DateTime.now().toUtc();
  return ReceiptQueue(
    db,
    ref.watch(receiptStorageProvider),
    OutboxWriter(db, newId: ids.newId, now: now),
    directory: () async {
      final base = await getApplicationDocumentsDirectory();
      return await Directory('${base.path}/receipts').create(recursive: true);
    },
    newId: ids.newId,
    now: now,
  );
});

/// Amalning yuklangan cheklari (`attachments`, o'chirilmagan).
final StreamProviderFamily<List<AttachmentRow>, String>
attachmentsForTransactionProvider = StreamProvider.autoDispose.family((
  ref,
  transactionId,
) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.attachments)..where(
        (a) => a.transactionId.equals(transactionId) & a.deletedAt.isNull(),
      ))
      .watch();
});

/// Amalning hali yuklanmagan cheklari (qurilmada).
final StreamProviderFamily<List<PendingUploadRow>, String>
pendingReceiptsProvider = StreamProvider.autoDispose.family((
  ref,
  transactionId,
) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.pendingUploads,
  )..where((p) => p.transactionId.equals(transactionId))).watch();
});

/// Yuklangan chek uchun vaqtinchalik havola (tarmoq kerak).
final FutureProviderFamily<String, String> receiptUrlProvider = FutureProvider
    .autoDispose
    .family(
      (ref, path) async =>
          await ref.watch(receiptStorageProvider).signedUrl(path),
    );
