import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

export 'package:share_plus/share_plus.dart' show XFile;

/// Faylni tizim "Ulashish" oynasiga beradi (hisobot rasmi, eksport).
/// [fileName] — aniq (xotiradagi `XFile` nomini saqlamaydi). Testda soxta
/// funksiya bilan almashtiriladi.
typedef FileSharer = Future<void> Function(
  XFile file, {
  required String fileName,
  required String text,
});

final Provider<FileSharer> fileSharerProvider = Provider(
  (ref) => (file, {required fileName, required text}) async {
    await SharePlus.instance.share(
      ShareParams(files: [file], fileNameOverrides: [fileName], text: text),
    );
  },
);

/// Matnni tizim "Ulashish" oynasiga beradi (taklif kodi va havolasi —
/// BR-012). Testda soxta funksiya bilan almashtiriladi.
typedef TextSharer = Future<void> Function(String text);

final Provider<TextSharer> textSharerProvider = Provider((ref) {
  return (text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  };
});
