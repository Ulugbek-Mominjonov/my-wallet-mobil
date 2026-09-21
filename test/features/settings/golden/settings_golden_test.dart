@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/data/remote/settings_api.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';

import '../../../data/sync/fake_remote.dart';
import '../../../support/fake_settings_api.dart';
import '../../../support/pump_app.dart';

/// E19: sozlamalar va bildirishnoma sozlamalari — Pixel o'lchami (360×780).
/// Yangilash: `flutter test --update-goldens --tags golden`.
void main() {
  for (final (name, path) in const [
    ('settings', settingsPath),
    ('notifications', notificationSettingsPath),
  ]) {
    testWidgets(name, (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final router = await pumpApp(
        tester,
        overrides: [
          settingsApiProvider.overrideWithValue(FakeSettingsApi()),
          remoteApiProvider.overrideWithValue(FakeRemote()),
          syncSchedulerProvider.overrideWith((ref) async => null),
        ],
      );
      router.go(path);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }
}
