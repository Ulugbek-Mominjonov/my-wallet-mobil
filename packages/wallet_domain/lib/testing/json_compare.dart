/// Golden fixture solishtiruvi — admin'dagi `scripts/contract/run.mjs` bilan
/// aynan bir xil qoida (contracts/fixtures/README.md):
///
/// * obyektda faqat kutilgan kalitlar tekshiriladi;
/// * kutilgan obyekt, javob esa `name` maydonli obyektlar massivi bo'lsa —
///   nom bo'yicha lug'at, nomlar to'plami aynan mos bo'lishi shart;
/// * boshqa massivlar — uzunligi va tartibi bilan; raqamlar — aniq teng.
List<String> compareJson(
  Object? expected,
  Object? actual, [
  String path = r'$',
]) {
  final errors = <String>[];
  _compare(expected, actual, path, errors);
  return errors;
}

void _compare(
  Object? expected,
  Object? actual,
  String path,
  List<String> errors,
) {
  if (expected is Map && actual is List && _namedRows(actual)) {
    final byName = {
      for (final row in actual.cast<Map<String, Object?>>()) row['name']: row,
    };
    final want = expected.keys.map((key) => '$key').toList()..sort();
    final got = byName.keys.map((key) => '$key').toList()..sort();
    if (want.join('|') != got.join('|')) {
      errors.add('$path: nomlar $want kutilgan, $got keldi');
      return;
    }
    for (final name in want) {
      _compare(expected[name], byName[name], '$path[$name]', errors);
    }
    return;
  }
  if (expected is Map) {
    if (actual is! Map) {
      errors.add('$path: obyekt kutilgan, $actual keldi');
      return;
    }
    for (final MapEntry(:key, :value) in expected.entries) {
      _compare(value, actual[key], '$path.$key', errors);
    }
    return;
  }
  if (expected is List) {
    if (actual is! List || actual.length != expected.length) {
      errors.add(
        '$path: ${expected.length} ta element kutilgan, $actual keldi',
      );
      return;
    }
    for (var i = 0; i < expected.length; i++) {
      _compare(expected[i], actual[i], '$path[$i]', errors);
    }
    return;
  }
  if (expected != actual) {
    errors.add('$path: $expected kutilgan, $actual keldi');
  }
}

bool _namedRows(List<Object?> rows) =>
    rows.every((row) => row is Map && row.containsKey('name'));
