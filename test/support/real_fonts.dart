import 'dart:io';

import 'package:flutter/services.dart';

/// Testlarda Ahem (har belgi — kvadrat) o'rniga haqiqiy Roboto va Material
/// ikonlari: matn kengligi qurilmadagidek (masalan 200% matn tekshiruvi).
/// Shriftlar Flutter SDK keshidan (`FLUTTER_ROOT`, `flutter test` beradi).
Future<void> loadRealFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    throw StateError(
      "FLUTTER_ROOT yo'q — testni `flutter test` bilan ishga tushiring",
    );
  }
  final dir = '$root/bin/cache/artifacts/material_fonts';
  Future<ByteData> font(String name) async =>
      ByteData.sublistView(await File('$dir/$name').readAsBytes());

  final roboto = FontLoader('Roboto');
  for (final name in [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]) {
    roboto.addFont(font(name));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(font('MaterialIcons-Regular.otf'))).load();
}
