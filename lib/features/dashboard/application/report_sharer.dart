import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Tayyor rasmni (PNG) tizim "Ulashish" oynasiga beradi. Testda soxta
/// funksiya bilan almashtiriladi.
typedef ReportSharer = Future<void> Function(
  Uint8List png, {
  required String fileName,
  required String text,
});

final Provider<ReportSharer> reportSharerProvider = Provider(
  (ref) => (png, {required fileName, required text}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(png, mimeType: 'image/png', name: fileName)],
        fileNameOverrides: [fileName],
        text: text,
      ),
    );
  },
);
