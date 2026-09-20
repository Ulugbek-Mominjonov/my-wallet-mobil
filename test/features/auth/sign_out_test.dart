import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/auth/application/sign_out.dart';
import 'package:my_wallet/features/auth/presentation/sign_out_dialog.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fake_auth.dart';

void main() {
  late AppDatabase db;
  late FakeAuthGateway auth;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    auth = FakeAuthGateway(currentUserId: 'user-1');
    await db
        .into(db.households)
        .insert(
          const Household(
            id: 'h',
            name: 'Uy',
            personalFund: PersonalFundRule(),
          ).toRow(),
        );
    await db.deviceId(newId: () => 'device-1');
  });
  tearDown(() => db.close());

  Future<void> addPending(int count) async {
    for (var i = 0; i < count; i++) {
      await db
          .into(db.outbox)
          .insert(
            OutboxCompanion.insert(
              mutationId: 'm$i',
              householdId: 'h',
              targetTable: 'transactions',
              recordId: 'r$i',
              op: 'upsert',
              createdAt: DateTime.utc(2026, 10),
            ),
          );
    }
  }

  test(
    "chiqish: sessiya va foydalanuvchi ma'lumoti; qurilma ID si qoladi",
    () async {
      await addPending(2);
      final signOut = SignOut(auth, db);
      expect(await signOut.unsentChanges(), 2);

      await signOut();
      expect(auth.calls, ['signOut']);
      expect(await db.select(db.households).get(), isEmpty);
      expect(await db.select(db.outbox).get(), isEmpty);
      expect(await db.deviceId(newId: () => 'new'), 'device-1');
    },
  );

  test('chiqish yoki boshqa akkaunt — tanlangan byudjet bekor', () async {
    final container = ProviderContainer.test(
      overrides: [authGatewayProvider.overrideWithValue(auth)],
    );
    container.read(currentHouseholdIdProvider.notifier).select('h');
    expect(container.read(currentHouseholdIdProvider), 'h');

    auth.emitUser(null);
    await pumpEventQueue();
    expect(container.read(authUserProvider), isNull);
    expect(container.read(currentHouseholdIdProvider), isNull);
  });

  group('tasdiq oynasi', () {
    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authGatewayProvider.overrideWithValue(auth),
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            locale: const Locale('uz'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: Consumer(
              builder: (context, ref, _) => TextButton(
                onPressed: () => confirmSignOut(context, ref),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() => tester.tap(find.text('open')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
    }

    testWidgets("bekor qilish — hech narsa o'zgarmaydi", (tester) async {
      await open(tester);
      expect(find.textContaining('serverdan yuklanadi'), findsOneWidget);
      await tester.tap(find.text('Bekor qilish'));
      await tester.pumpAndSettle();
      expect(auth.calls, isEmpty);
    });

    testWidgets("yuborilmagan o'zgarishlar — ogohlantirish; tasdiq — chiqish", (
      tester,
    ) async {
      await tester.runAsync(() => addPending(3));
      await open(tester);
      expect(
        find.text(
          "3 ta o'zgarish hali serverga yetmagan — chiqsangiz ular yo'qoladi.",
        ),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Chiqish'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(auth.calls, ['signOut']);
      final pending = await tester.runAsync(() => db.select(db.outbox).get());
      expect(pending, isEmpty);
    });
  });
}
