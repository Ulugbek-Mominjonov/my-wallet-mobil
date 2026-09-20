import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fake_auth.dart';
import '../../support/pump_app.dart';

void main() {
  Finder field(String label) => find.widgetWithText(TextField, label);

  Future<void> requestCode(
    WidgetTester tester, {
    String email = 'ali@b.uz',
  }) async {
    await tester.enterText(field('Email'), email);
    await tester.tap(find.text('Kod olish'));
    await tester.pumpAndSettle();
  }

  testWidgets('kirilmagan — kirish ekrani; sessiya eskirsa — qaytadi', (
    tester,
  ) async {
    final auth = FakeAuthGateway();
    final router = await pumpApp(tester, auth: auth);
    expect(find.text('Pulingiz qayerga ketayotganini biling'), findsOneWidget);

    router.go('/wallet');
    await tester.pumpAndSettle();
    expect(find.text('Kod olish'), findsOneWidget);

    auth.emitUser('user-1');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Uy'), findsOneWidget);

    auth.emitUser(null);
    await tester.pumpAndSettle();
    expect(find.text('Kod olish'), findsOneWidget);
  });

  testWidgets('email → kod (6 raqam — avtomatik) → bosh sahifa', (
    tester,
  ) async {
    final auth = FakeAuthGateway();
    await pumpApp(tester, auth: auth);

    await requestCode(tester, email: ' Ali@B.uz ');
    expect(find.text('Pochtangizni tekshiring'), findsOneWidget);
    expect(
      find.text('ali@b.uz manziliga 6 xonali kod yubordik'),
      findsOneWidget,
    );

    await tester.enterText(field('Kod'), '12a3456');
    await tester.pumpAndSettle();
    expect(auth.calls, ['send: Ali@B.uz ', 'verify:ali@b.uz:123456']);
    expect(find.widgetWithText(AppBar, 'Uy'), findsOneWidget);
  });

  testWidgets('xatolar maydon ostida: email, kod, tarmoq', (tester) async {
    final auth = FakeAuthGateway()
      ..results.addAll([
        const Err(ValidationFailure('email', AuthCodes.invalidEmail)),
        const Err(OfflineFailure()),
        const Ok(null),
        const Err(RejectedFailure('otp_expired')),
        const Err(ValidationFailure('code', AuthCodes.invalidCode)),
        const Err(RejectedFailure('over_email_send_rate_limit')),
      ]);
    await pumpApp(tester, auth: auth);

    await requestCode(tester, email: 'x');
    expect(find.text('Email manzilni tekshiring'), findsOneWidget);
    await requestCode(tester);
    expect(find.text("Internet yo'q — ulanishni tekshiring"), findsOneWidget);
    await requestCode(tester);

    await tester.enterText(field('Kod'), '000000');
    await tester.pumpAndSettle();
    expect(find.text("Kod noto'g'ri yoki eskirgan"), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Kirish'));
    await tester.pumpAndSettle();
    expect(find.text('6 xonali kodni kiriting'), findsOneWidget);

    await tester.pump(const Duration(seconds: 30));
    await tester.tap(find.text('Kodni qayta yuborish'));
    await tester.pumpAndSettle();
    expect(
      find.text("Juda ko'p urinish — birozdan keyin qayta urinib ko'ring"),
      findsOneWidget,
    );
  });

  testWidgets('qayta yuborish — 30 s dan keyin; boshqa email', (tester) async {
    final auth = FakeAuthGateway();
    await pumpApp(tester, auth: auth);
    await requestCode(tester);

    expect(find.text('Qayta yuborish — 30 s'), findsOneWidget);
    await tester.pump(const Duration(seconds: 29));
    expect(find.text('Qayta yuborish — 1 s'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Kodni qayta yuborish'));
    await tester.pumpAndSettle();
    expect(auth.calls, ['send:ali@b.uz', 'send:ali@b.uz']);
    expect(find.text('Qayta yuborish — 30 s'), findsOneWidget);

    await tester.tap(find.text('Boshqa email'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'ali@b.uz'), findsOneWidget);
  });

  testWidgets("Google: sozlanmagan — tugma yo'q", (tester) async {
    await pumpApp(tester, auth: FakeAuthGateway());
    expect(find.text('Google bilan kirish'), findsNothing);
  });

  testWidgets('Google: bekor qilish jim, xato — matn, muvaffaqiyat — kirish', (
    tester,
  ) async {
    final auth = FakeAuthGateway(googleAvailable: true)
      ..results.addAll([
        const Ok(false),
        const Err(RejectedFailure(AuthCodes.googleFailed)),
      ]);
    await pumpApp(tester, auth: auth);

    await tester.tap(find.text('Google bilan kirish'));
    await tester.pumpAndSettle();
    expect(find.text('yoki'), findsOneWidget);
    expect(find.textContaining('Google bilan kirib'), findsNothing);

    await tester.tap(find.text('Google bilan kirish'));
    await tester.pumpAndSettle();
    expect(
      find.text("Google bilan kirib bo'lmadi — email orqali kiring"),
      findsOneWidget,
    );

    await tester.tap(find.text('Google bilan kirish'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Uy'), findsOneWidget);
    expect(auth.calls, ['google', 'google', 'google']);
  });
}
