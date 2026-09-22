// CI: yiqilgan testlarni GitHub annotatsiyalari sifatida chiqaradi — PR va
// commit sahifasida (loglarsiz ham) qaysi test va nima uchun ko'rinadi.
//
//   flutter test --file-reporter json:build/test-report.json
//   dart run tool/test_annotations.dart build/test-report.json
//
// Kirish — `package:test` JSON reporter hodisalari (qatorma-qator).
import 'dart:convert';
import 'dart:io';

/// Annotatsiya xabari uzunligi (GitHub cheklovi ichida, o'qiladigan).
const _maxMessage = 1500;

/// Bitta qadamda ko'rsatiladigan annotatsiyalar (GitHub — 10 tagacha).
const _maxAnnotations = 10;

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Foydalanish: test_annotations.dart <test-report.json>');
    exit(2);
  }
  final report = File(args.single);
  if (!report.existsSync()) {
    stderr.writeln('Hisobot yo\'q: ${report.path}');
    exit(2);
  }

  final names = <int, String>{};
  final locations = <int, (String?, int?)>{};
  final errors = <int, StringBuffer>{};
  final failed = <int>[];

  for (final line in report.readAsLinesSync()) {
    if (line.trim().isEmpty) continue;
    final event = jsonDecode(line) as Map<String, Object?>;
    switch (event['type']) {
      case 'testStart':
        final test = event['test']! as Map<String, Object?>;
        final id = test['id']! as int;
        names[id] = test['name']! as String;
        locations[id] = (
          _relative(test['root_url'] as String? ?? test['url'] as String?),
          test['root_line'] as int? ?? test['line'] as int?,
        );
      case 'error':
        final id = event['testID']! as int;
        (errors[id] ??= StringBuffer()).writeln(event['error']);
      case 'testDone':
        if (event['result'] != 'success' && event['hidden'] != true) {
          failed.add(event['testID']! as int);
        }
    }
  }

  for (final id in failed.take(_maxAnnotations)) {
    final (file, line) = locations[id] ?? (null, null);
    final message = (errors[id]?.toString() ?? '').trim();
    final location = [
      if (file != null) 'file=$file',
      if (line != null) 'line=$line',
      'title=${_escapeProperty(names[id] ?? 'test $id')}',
    ].join(',');
    stdout.writeln('::error $location::${_escapeData(_truncate(message))}');
  }
  stdout.writeln('Yiqilgan testlar: ${failed.length}');
}

String? _relative(String? url) {
  if (url == null || !url.startsWith('file://')) return null;
  final path = Uri.parse(url).toFilePath();
  final root = '${Directory.current.path}/';
  return path.startsWith(root) ? path.substring(root.length) : path;
}

String _truncate(String text) =>
    text.length <= _maxMessage ? text : '${text.substring(0, _maxMessage)}…';

/// GitHub workflow buyrug'i qiymatini ekranlash (ma'lumot qismi).
String _escapeData(String value) => value
    .replaceAll('%', '%25')
    .replaceAll('\r', '%0D')
    .replaceAll('\n', '%0A');

/// Xossa qiymati — qo'shimcha `:` va `,` ham ekranlanadi.
String _escapeProperty(String value) =>
    _escapeData(value).replaceAll(':', '%3A').replaceAll(',', '%2C');
