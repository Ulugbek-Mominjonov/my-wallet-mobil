import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';

import '../../support/fake_startup.dart';
import '../../support/pump_app.dart';

void main() {
  test('BR-214: versiya taqqoslash (build raqami hisobga olinmaydi)', () {
    expect(isUpdateRequired('0.1.0', '0.2.0'), isTrue);
    expect(isUpdateRequired('0.9.9', '1.0.0'), isTrue);
    expect(isUpdateRequired('1.2', '1.2.1'), isTrue);
    expect(isUpdateRequired('1.0.0', '1.0.0'), isFalse);
    expect(isUpdateRequired('1.2.3+45', '1.2.3'), isFalse);
    expect(isUpdateRequired('1.10.0', '1.9.0'), isFalse);
    expect(isUpdateRequired('2.0.0', '1.9.9'), isFalse);
  });

  testWidgets('eski versiya — faqat yangilash ekrani', (tester) async {
    final controller = FakeStartupController(
      const StartupUpdateRequired('1.2.0'),
    );
    final router = await pumpApp(tester, startupController: controller);

    expect(find.text('Ilovani yangilang'), findsOneWidget);
    expect(
      find.text("Yangi versiya (1.2.0) kerak — Play Market'dan yangilang."),
      findsOneWidget,
    );

    // Boshqa ekranlarga o'tib bo'lmaydi.
    router.go('/wallet');
    await tester.pumpAndSettle();
    expect(find.text('Ilovani yangilang'), findsOneWidget);

    await tester.tap(find.text('Qayta urinish'));
    await tester.pumpAndSettle();
    expect(controller.calls, ['reload']);
  });
}
