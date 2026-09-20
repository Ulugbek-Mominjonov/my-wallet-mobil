import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fake_startup.dart';
import '../../support/pump_app.dart';

void main() {
  Finder field(String label) => find.widgetWithText(TextField, label);

  testWidgets("byudjet yo'q — nom bilan yoki standart nom bilan yaratish", (
    tester,
  ) async {
    final controller = FakeStartupController(const StartupNoHousehold());
    await pumpApp(tester, startupController: controller);
    expect(find.text('Byudjetni boshlang'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Yaratish'));
    await tester.pumpAndSettle();
    expect(controller.calls, ['create:Mening byudjetim']);

    await tester.enterText(field('Byudjet nomi'), ' Oila ');
    await tester.tap(find.widgetWithText(FilledButton, 'Yaratish'));
    await tester.pumpAndSettle();
    expect(controller.calls.last, 'create: Oila ');
  });

  testWidgets("taklif kodi: katta harfga o'tadi, xato kod ostida", (
    tester,
  ) async {
    final controller = FakeStartupController(const StartupNoHousehold())
      ..result = const Err(RejectedFailure('invite_expired'));
    await pumpApp(tester, startupController: controller);

    await tester.enterText(field('Taklif kodi'), 'abcd2345');
    await tester.pumpAndSettle();
    expect(find.text('ABCD2345'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, "Qo'shilish"));
    await tester.pumpAndSettle();
    expect(controller.calls, ['join:ABCD2345']);
    expect(find.text('Kod muddati tugagan (7 kun)'), findsOneWidget);
  });

  testWidgets('nom xatosi — nom maydoni ostida', (tester) async {
    final controller = FakeStartupController(const StartupNoHousehold())
      ..result = const Err(ValidationFailure('name', 'required'));
    await pumpApp(tester, startupController: controller);

    await tester.tap(find.widgetWithText(FilledButton, 'Yaratish'));
    await tester.pumpAndSettle();
    final nameField = tester.widget<TextField>(field('Byudjet nomi'));
    expect(nameField.decoration?.errorText, 'Byudjet nomini kiriting');
    final codeField = tester.widget<TextField>(field('Taklif kodi'));
    expect(codeField.decoration?.errorText, isNull);
  });

  testWidgets("taklif havolasi ochilsa — qo'shilish ekrani, kod tayyor", (
    tester,
  ) async {
    final controller = FakeStartupController(readyState());
    await pumpApp(
      tester,
      startupController: controller,
      inviteLinks: Stream.value('ABCD2345'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Byudjetni boshlang'), findsOneWidget);
    expect(find.text('ABCD2345'), findsOneWidget);

    controller.result = const Ok(null);
    await tester.tap(find.widgetWithText(FilledButton, "Qo'shilish"));
    await tester.pumpAndSettle();
    expect(controller.calls, ['join:ABCD2345']);
    // Kod ishlatildi — ilovaga qaytadi.
    expect(find.widgetWithText(AppBar, 'Uy'), findsOneWidget);
  });
}
