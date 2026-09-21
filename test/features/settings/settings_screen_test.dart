import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/core/share/file_sharer.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/remote/settings_api.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/settings/presentation/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../data/sync/fake_remote.dart';
import '../../support/fake_auth.dart';
import '../../support/fake_settings_api.dart';
import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late FakeSettingsApi api;
  setUp(() => api = FakeSettingsApi());

  Future<void> open(
    WidgetTester tester, {
    AppDatabase? database,
    FakeAuthGateway? auth,
    FileSharer? sharer,
    Directory? exportDir,
  }) async {
    tester.view
      ..physicalSize = const Size(1080, 6000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = await pumpApp(
      tester,
      database: database,
      auth: auth,
      overrides: [
        settingsApiProvider.overrideWithValue(api),
        remoteApiProvider.overrideWithValue(FakeRemote()),
        syncSchedulerProvider.overrideWith((ref) async => null),
        if (sharer != null) fileSharerProvider.overrideWithValue(sharer),
        if (exportDir != null)
          exportDirectoryProvider.overrideWithValue(() async => exportDir),
      ],
    );
    router.go(settingsPath);
    await tester.pumpAndSettle();
  }

  testWidgets("tema — to'q; saqlanadi", (tester) async {
    await open(tester);
    await tester.tap(find.text("To'q"));
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
  });

  testWidgets('til — English; ilova darhol almashadi', (tester) async {
    await open(tester);
    await tester.tap(find.text('Qurilma tili'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('eksport — JSON fayl ulashiladi (byudjet jadvallari)', (
    tester,
  ) async {
    final db = testDatabase();
    addTearDown(db.close);
    await db
        .into(db.accounts)
        .insert(
          const Account(
            id: 'a1',
            householdId: 'h1',
            name: 'Karta',
            type: AccountType.card,
            openingBalance: Money.zero,
          ).toCompanion(),
        );
    final dir = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('export'),
    ))!;
    addTearDown(() => dir.deleteSync(recursive: true));
    String? name;
    String? content;
    await open(
      tester,
      database: db,
      exportDir: dir,
      sharer: (file, {required fileName, required text}) async {
        name = fileName;
        content = await file.readAsString();
      },
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Eksport (JSON)'));
      for (var i = 0; i < 20 && content == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pumpAndSettle();
    expect(name, endsWith('.json'));
    final json = jsonDecode(content!) as Map<String, Object?>;
    expect(json['format'], 'my-wallet-export');
    final tables = json['tables']! as Map<String, Object?>;
    expect((tables['accounts']! as List).single, containsPair('name', 'Karta'));
  });

  group("BR-015: akkauntni o'chirish", () {
    Future<void> confirm(WidgetTester tester, String word) async {
      await tester.tap(find.text("Akkauntni o'chirish"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Davom etish'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), word);
      await tester.pumpAndSettle();
    }

    testWidgets("tasdiq so'zisiz bo'lmaydi; to'g'ri so'z — o'chadi, chiqadi", (
      tester,
    ) async {
      final auth = FakeAuthGateway(currentUserId: 'user-1');
      await open(tester, auth: auth);
      await confirm(tester, "o'chir");
      final delete = find.widgetWithText(FilledButton, "Akkauntni o'chirish");
      expect(tester.widget<FilledButton>(delete).onPressed, isNull);

      await tester.enterText(find.byType(TextField), "o'chirish");
      await tester.pumpAndSettle();
      await tester.tap(delete);
      await tester.pumpAndSettle();
      expect(api.deleteCalls, 1);
      expect(auth.calls, contains('signOut'));
    });

    testWidgets('yagona ega — tushunarli xabar, chiqmaydi', (tester) async {
      api.deleteResult = const Err(RejectedFailure('last_owner'));
      final auth = FakeAuthGateway(currentUserId: 'user-1');
      await open(tester, auth: auth);
      await confirm(tester, "O'CHIRISH");
      await tester.tap(
        find.widgetWithText(FilledButton, "Akkauntni o'chirish"),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('yagona egasisiz'), findsOneWidget);
      expect(auth.calls, isNot(contains('signOut')));
    });
  });
}
