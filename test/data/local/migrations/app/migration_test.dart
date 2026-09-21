// Lokal baza migratsiyalari: har versiya juftligi sxemaga mos keladi va
// mavjud ma'lumot saqlanadi (drift SchemaVerifier; snapshot'lar —
// `drift_schemas/`, `make gen` yangilaydi).
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  const versions = GeneratedHelper.versions;
  for (final (i, from) in versions.indexed) {
    for (final to in versions.skip(i + 1)) {
      test('sxema: v$from → v$to', () async {
        final schema = await verifier.schemaAt(from);
        final db = AppDatabase(schema.newConnection());
        await verifier.migrateAndValidate(db, to);
        await db.close();
      });
    }
  }

  test(
    "v1 → v2: sinxron nusxa va navbat saqlanadi, chek navbati bo'sh",
    () async {
      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(
            oldDb.appSettings,
            v1.AppSettingsCompanion.insert(key: 'device_id', value: 'd-1'),
          );
        },
        validateItems: (newDb) async {
          final settings = await newDb.select(newDb.appSettings).get();
          expect(
            [for (final s in settings) (s.key, s.value)],
            [('device_id', 'd-1')],
          );
          expect(await newDb.select(newDb.pendingUploads).get(), isEmpty);
        },
      );
    },
  );
}
