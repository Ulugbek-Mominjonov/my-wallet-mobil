import 'dart:io';

import 'package:drift/drift.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/outbox_writer.dart';

/// BR-201: chek fayli ≤ 1 MB (server bucket cheklovi ham shu).
const int maxReceiptBytes = 1024 * 1024;

/// Storage bucket (contracts/api.md).
const receiptsBucket = 'receipts';

/// Storage'ga yuklash va o'qish (Supabase — `SupabaseReceiptStorage`).
abstract interface class ReceiptStorage {
  Future<void> upload(String path, Uint8List bytes, {required String mime});

  /// Vaqtinchalik (1 soat) ko'rish havolasi.
  Future<String> signedUrl(String path);
}

/// Siqilgan rasm (JPEG, ≤ [maxReceiptBytes]).
typedef CompressedImage = ({Uint8List bytes, String mime});

/// BR-201: chek rasmlari navbati — oflaynda qurilmada turadi, tarmoq
/// bo'lganda yuklanadi va `attachments` qatori outbox orqali yuboriladi.
final class ReceiptQueue {
  const new(
    this._db,
    this._storage,
    this._outbox, {
    required this.directory,
    required this.newId,
    required this.now,
  });

  final AppDatabase _db;
  final ReceiptStorage _storage;
  final OutboxWriter _outbox;

  /// Yuklanmagan fayllar papkasi (ilova hujjatlari ichida).
  final Future<Directory> Function() directory;
  final String Function() newId;
  final DateTime Function() now;

  /// Ruxsat etilgan turlar va kengaytmasi (bucket cheklovi bilan bir xil).
  static const Map<String, String> extensions = {
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
  };

  /// Storage yo'li: `{household}/{transaction}/{attachment}.{jpg|png|webp}`.
  static String storagePath(
    String householdId,
    String transactionId,
    String attachmentId, {
    String mime = 'image/jpeg',
  }) => '$householdId/$transactionId/$attachmentId.${extensions[mime]}';

  /// Rasmni navbatga qo'yadi (fayl qurilmada saqlanadi).
  Future<void> enqueue({
    required String householdId,
    required String transactionId,
    required CompressedImage image,
  }) async {
    if (image.bytes.length > maxReceiptBytes) {
      throw ArgumentError.value(image.bytes.length, 'image', '> 1 MB');
    }
    final extension = extensions[image.mime];
    if (extension == null) {
      throw ArgumentError.value(image.mime, 'image', 'jpeg/png/webp');
    }
    final attachmentId = newId();
    final dir = await directory();
    final file = File('${dir.path}/$attachmentId.$extension');
    await file.writeAsBytes(image.bytes, flush: true);
    await _db
        .into(_db.pendingUploads)
        .insert(
          PendingUploadsCompanion.insert(
            householdId: householdId,
            transactionId: transactionId,
            attachmentId: attachmentId,
            localPath: file.path,
            mime: image.mime,
            sizeBytes: image.bytes.length,
            createdAt: now(),
          ),
        );
  }

  /// Navbatdagilarni yuklaydi. Xato bo'lsa — keyingi siklda qayta urinadi
  /// (tarmoq yo'qligi odatiy holat, faqat qayd qilinadi).
  Future<int> flush(String householdId) async {
    final pending =
        await (_db.select(_db.pendingUploads)
              ..where((p) => p.householdId.equals(householdId))
              ..orderBy([(p) => OrderingTerm.asc(p.id)]))
            .get();
    var uploaded = 0;
    for (final item in pending) {
      final file = File(item.localPath);
      if (!file.existsSync()) {
        // Fayl yo'qolgan — navbatda qolishi befoyda.
        AppLog.info('Chek fayli topilmadi: ${item.attachmentId}');
        await _remove(item);
        continue;
      }
      final path = storagePath(
        item.householdId,
        item.transactionId,
        item.attachmentId,
        mime: item.mime,
      );
      try {
        await _storage.upload(path, await file.readAsBytes(), mime: item.mime);
      } on Object catch (error) {
        await (_db.update(
          _db.pendingUploads,
        )..where((p) => p.id.equals(item.id))).write(
          PendingUploadsCompanion(
            attempts: Value(item.attempts + 1),
            lastError: Value('$error'),
          ),
        );
        return uploaded;
      }
      await _db.transaction(() async {
        await _db
            .into(_db.attachments)
            .insert(
              AttachmentsCompanion.insert(
                id: item.attachmentId,
                householdId: item.householdId,
                transactionId: item.transactionId,
                storagePath: path,
                mime: item.mime,
                sizeBytes: item.sizeBytes,
              ),
            );
        await _outbox.enqueue(
          table: 'attachments',
          householdId: item.householdId,
          row: await (_db.select(
            _db.attachments,
          )..where((a) => a.id.equals(item.attachmentId))).getSingle(),
        );
        await (_db.delete(
          _db.pendingUploads,
        )..where((p) => p.id.equals(item.id))).go();
      });
      await file.delete();
      uploaded++;
    }
    return uploaded;
  }

  /// Yuklangan chekni o'chirish (yumshoq — fayllarni server tozalaydi).
  Future<void> removeAttachment(String attachmentId) =>
      _db.transaction(() async {
        final query = _db.select(_db.attachments)
          ..where((a) => a.id.equals(attachmentId));
        final before = await query.getSingle();
        await (_db.update(_db.attachments)
              ..where((a) => a.id.equals(attachmentId)))
            .write(AttachmentsCompanion(deletedAt: Value(now())));
        await _outbox.enqueue(
          table: 'attachments',
          householdId: before.householdId,
          row: await query.getSingle(),
          before: before,
        );
      });

  /// Hali yuklanmagan chekni bekor qilish.
  Future<void> cancelPending(int id) async {
    final item = await (_db.select(
      _db.pendingUploads,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (item != null) await _remove(item);
  }

  Future<void> _remove(PendingUploadRow item) async {
    await (_db.delete(
      _db.pendingUploads,
    )..where((p) => p.id.equals(item.id))).go();
    final file = File(item.localPath);
    if (file.existsSync()) await file.delete();
  }
}
