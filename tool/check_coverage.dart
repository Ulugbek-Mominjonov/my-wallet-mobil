// Qoplama chegarasi: lcov.info dan yo'l prefiksi bo'yicha foizni hisoblaydi.
//
//   dart run tool/check_coverage.dart coverage/lcov.info lib=60 lib/core=80
//
// Generatsiya qilingan kod (l10n, *.g.dart, *.freezed.dart) hisobga olinmaydi.
import 'dart:io';

const _generated = ['lib/l10n/gen/', '.g.dart', '.freezed.dart'];

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln(
      'Foydalanish: check_coverage.dart <lcov.info> <prefiks=foiz>...',
    );
    exit(2);
  }
  final files = _parseLcov(File(args.first).readAsLinesSync());
  var failed = false;

  for (final rule in args.skip(1)) {
    final [prefix, minimum] = rule.split('=');
    final threshold = double.parse(minimum);
    final matched = files.entries.where(
      (entry) => entry.key.startsWith(prefix),
    );
    final found = matched.fold(0, (sum, entry) => sum + entry.value.found);
    final hit = matched.fold(0, (sum, entry) => sum + entry.value.hit);
    final percent = found == 0 ? 0.0 : hit * 100 / found;
    final ok = found > 0 && percent >= threshold;
    failed = failed || !ok;
    stdout.writeln(
      '${ok ? '✅' : '❌'} $prefix: ${percent.toStringAsFixed(1)}% '
      '($hit/$found qator, chegara $threshold%)',
    );
  }
  if (failed) exit(1);
}

Map<String, ({int found, int hit})> _parseLcov(List<String> lines) {
  final result = <String, ({int found, int hit})>{};
  String? current;
  var found = 0;
  var hit = 0;
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      current = line.substring(3);
      found = 0;
      hit = 0;
    } else if (line.startsWith('LF:')) {
      found = int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hit = int.parse(line.substring(3));
    } else if (line == 'end_of_record' && current != null) {
      if (!_generated.any(current.contains)) {
        result[current] = (found: found, hit: hit);
      }
      current = null;
    }
  }
  return result;
}
