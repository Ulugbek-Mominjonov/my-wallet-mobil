import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/core/share/file_sharer.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../data/sync/fake_remote.dart';
import '../../support/fake_startup.dart';
import '../../support/pump_app.dart';

HouseholdMember _member(
  String id,
  String name,
  MemberRole role, {
  bool isMe = false,
}) => (
  userId: id,
  name: name,
  role: role,
  joinedAt: DateTime.utc(2026, 9),
  isMe: isMe,
);

void main() {
  late FakeRemote remote;
  final shared = <String>[];

  setUp(() {
    shared.clear();
    // Buferga nusxalash — testda platforma kanali yo'q.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    remote = FakeRemote()
      ..members = [
        _member('u1', 'Ali', MemberRole.owner, isMe: true),
        _member('u2', 'Vali', MemberRole.member),
      ];
  });

  Future<void> openMembers(WidgetTester tester, {String role = 'owner'}) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = await pumpApp(
      tester,
      overrides: [
        remoteApiProvider.overrideWithValue(remote),
        textSharerProvider.overrideWithValue((text) async => shared.add(text)),
      ],
      startup: switch (AppBootstrap.fromJson(
        bootstrapJson(
          households: [householdJson(id: 'h1', role: role)],
        ),
      )) {
        final boot => StartupReady(boot.households.first, boot),
      },
    );
    router.go(membersPath);
    await tester.pumpAndSettle();
  }

  testWidgets("a'zolar ro'yxati: rol va \"siz\" belgisi", (tester) async {
    await openMembers(tester);

    expect(find.text('Ali (siz)'), findsOneWidget);
    expect(find.text('Egasi'), findsOneWidget);
    expect(find.text('Vali'), findsOneWidget);
    expect(find.text("A'zo"), findsOneWidget);
  });

  testWidgets('BR-012: taklif — kod, QR va nusxalash', (tester) async {
    await openMembers(tester);
    await tester.tap(
      find.widgetWithText(FloatingActionButton, 'Taklif qilish'),
    );
    await tester.pumpAndSettle();

    expect(find.text('ABCD2345'), findsOneWidget);
    // QR — havola bilan (semantik yorliqda).
    expect(
      find.bySemanticsLabel('mywallet-dev://invite/ABCD2345'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Nusxalash'));
    await tester.pumpAndSettle();
    expect(find.text('Nusxalandi'), findsOneWidget);

    // Ulashish — tizim oynasiga kod va havola bilan matn beradi.
    await tester.tap(find.widgetWithText(TextButton, 'Ulashish'));
    await tester.pumpAndSettle();
    expect(shared.single, contains('ABCD2345'));
    expect(shared.single, contains('mywallet-dev://invite/ABCD2345'));
  });

  testWidgets('BR-011: owner rolni o‘zgartiradi va a‘zoni chiqaradi', (
    tester,
  ) async {
    await openMembers(tester);

    await tester.tap(find.byTooltip('Vali: amallar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rol: Kuzatuvchi'));
    await tester.pumpAndSettle();
    expect(remote.roleChanges, [('u2', MemberRole.viewer)]);

    await tester.tap(find.byTooltip('Vali: amallar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Byudjetdan chiqarish'));
    await tester.pumpAndSettle();
    expect(remote.removed, ['u2']);
  });

  testWidgets('member — taklif va rol amallari yo‘q, chiqish bor', (
    tester,
  ) async {
    remote.members = [
      _member('u1', 'Ali', MemberRole.owner),
      _member('u2', 'Vali', MemberRole.member, isMe: true),
    ];
    await openMembers(tester, role: 'member');

    expect(
      find.widgetWithText(FloatingActionButton, 'Taklif qilish'),
      findsNothing,
    );
    expect(find.byTooltip('Ali: amallar'), findsNothing);

    await tester.tap(find.byTooltip('Vali: amallar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Byudjetdan chiqish'));
    await tester.pumpAndSettle();
    expect(remote.left, 1);
  });
}
