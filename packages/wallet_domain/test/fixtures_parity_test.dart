// E12-T05: golden fixture pariteti — contracts/fixtures dagi har holat
// (server `make contract-test` bilan tekshiriladigan xuddi shu fayllar)
// domen qoidalari bilan hisoblanib, kutilgan natija bilan solishtiriladi.
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:wallet_domain/testing.dart';

/// Mobil repo ildizidagi shartnoma nusxasi (tool/sync_contracts.sh).
const _fixturesDir = '../../contracts/fixtures';

void main() {
  final files =
      Directory(_fixturesDir)
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('fixture fayllari topildi', () {
    expect(files, isNotEmpty, reason: 'make contracts-sync — contracts/ kerak');
  });

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final cases =
        ((jsonDecode(file.readAsStringSync()) as Map<String, Object?>)['cases']!
                as List<Object?>)
            .cast<Map<String, Object?>>();
    group(name, () {
      for (final testCase in cases) {
        final rules = (testCase['rules']! as List<Object?>).join(', ');
        test('${testCase['name']} [$rules]', () {
          final ledger = FixtureLedger.load(testCase);
          final errors = <String>[];
          final steps = (testCase['expect']! as List<Object?>)
              .cast<Map<String, Object?>>();
          for (final (index, step) in steps.indexed) {
            final rpc = step['rpc']! as String;
            final actual = ledger(
              rpc,
              (step['args'] as Map<String, Object?>?) ?? const {},
            );
            errors.addAll(
              compareJson(step['result'], actual, 'expect[$index].$rpc'),
            );
          }
          expect(errors, isEmpty, reason: errors.join('\n'));
        });
      }
    });
  }
}
