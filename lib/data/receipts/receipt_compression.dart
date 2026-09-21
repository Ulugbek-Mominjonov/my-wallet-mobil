import 'dart:typed_data';

import 'package:my_wallet/data/receipts/receipt_queue.dart';

/// JPEG siqish funksiyasi (native — `nativeJpeg`, testda soxta).
typedef JpegEncoder = Future<Uint8List> Function(
  Uint8List source, {
  required int quality,
  required int maxSide,
});

/// BR-201: ≤ 1 MB bo'lguncha sifat va o'lcham pasaytiriladi. Juda katta
/// rasm eng past sifatda ham sig'masa — `null` (foydalanuvchiga xabar).
Future<CompressedImage?> compressToLimit(
  Uint8List source,
  JpegEncoder encode, {
  int limit = maxReceiptBytes,
}) async {
  for (final (quality, maxSide) in const [
    (85, 1600),
    (75, 1600),
    (65, 1280),
    (55, 1024),
  ]) {
    final bytes = await encode(source, quality: quality, maxSide: maxSide);
    if (bytes.length <= limit) return (bytes: bytes, mime: 'image/jpeg');
  }
  return null;
}
