// Platforma qismi: Storage (Supabase), kamera/galereya va siqish (native) —
// mantiq `ReceiptQueue` va `compressToLimit` da testlanadi.
// coverage:ignore-file
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_wallet/data/receipts/receipt_queue.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseReceiptStorage implements ReceiptStorage {
  const new(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upload(
    String path,
    Uint8List bytes, {
    required String mime,
  }) async {
    await _client.storage
        .from(receiptsBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mime, upsert: true),
        );
  }

  @override
  Future<String> signedUrl(String path) => _client.storage
      .from(receiptsBucket)
      .createSignedUrl(path, receiptUrlTtl.inSeconds);
}

/// Kamera yoki galereyadan rasm; bekor qilinsa — `null`.
Future<Uint8List?> pickReceiptImage({required bool camera}) async {
  final file = await ImagePicker().pickImage(
    source: camera ? ImageSource.camera : ImageSource.gallery,
    // Katta rasmni darhol kichraytiradi (siqishdan oldin).
    maxWidth: 2000,
    maxHeight: 2000,
  );
  return file == null ? null : await file.readAsBytes();
}

/// JPEG'ga siqish (native).
Future<Uint8List> nativeJpeg(
  Uint8List source, {
  required int quality,
  required int maxSide,
}) => FlutterImageCompress.compressWithList(
  source,
  quality: quality,
  minWidth: maxSide,
  minHeight: maxSide,
);
