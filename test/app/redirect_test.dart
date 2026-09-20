import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../support/fake_startup.dart';

void main() {
  String? redirect({
    bool signedIn = true,
    StartupState? startup,
    bool hasInvite = false,
    bool locked = false,
    String location = '/wallet',
  }) => appRedirect(
    signedIn: signedIn,
    startup: startup ?? readyState(),
    hasInvite: hasInvite,
    locked: locked,
    location: location,
  );

  test('kirilmagan — faqat kirish ekrani', () {
    expect(redirect(signedIn: false), signInPath);
    expect(redirect(signedIn: false, location: signInPath), isNull);
    expect(redirect(location: signInPath), '/');
  });

  test('yuklanmoqda yoki xato — splash; tayyor — ilovaga qaytadi', () {
    const loading = StartupLoading();
    expect(redirect(startup: loading), splashPath);
    expect(redirect(startup: loading, location: splashPath), isNull);
    expect(
      redirect(startup: const StartupFailed(OfflineFailure())),
      splashPath,
    );
    expect(redirect(location: splashPath), '/');
  });

  test("byudjet yo'q yoki taklif havolasi — qo'shilish ekrani", () {
    expect(redirect(startup: const StartupNoHousehold()), joinPath);
    expect(
      redirect(startup: const StartupNoHousehold(), location: '/join/scan'),
      isNull,
    );
    expect(redirect(hasInvite: true), joinPath);
    // Byudjet bor bo'lsa ham almashtirgichdan ochish mumkin.
    expect(redirect(location: joinPath), isNull);
  });

  test('BR-211: qulflangan — faqat qulf ekrani; ochilgach ilovaga', () {
    expect(redirect(locked: true), lockPath);
    expect(redirect(locked: true, location: lockPath), isNull);
    expect(redirect(location: lockPath), '/');
    // Qulf kirishdan keyin: kirilmagan bo'lsa — kirish ekrani.
    expect(redirect(signedIn: false, locked: true), signInPath);
  });

  test('sozlash tugamagan — onboarding; tugagan — ilova', () {
    final fresh = readyState(onboarded: false);
    expect(redirect(startup: fresh), onboardingPath);
    expect(redirect(startup: fresh, location: onboardingPath), isNull);
    expect(redirect(location: onboardingPath), '/');
    expect(redirect(), isNull);
  });
}
