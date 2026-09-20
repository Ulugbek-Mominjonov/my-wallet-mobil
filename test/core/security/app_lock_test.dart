import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_wallet/core/security/app_lock.dart';
import 'package:my_wallet/core/security/pin_store.dart';
import 'package:my_wallet/core/security/secure_screen.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';

final class _MockAuth extends Mock implements LocalAuthentication;

final class _FakeSecureScreen implements SecureScreen {
  final calls = <bool>[];

  @override
  Future<void> setSecure({required bool enabled}) async => calls.add(enabled);
}

void main() {
  late AppDatabase db;
  late _MockAuth auth;
  late _FakeSecureScreen secureScreen;
  var now = DateTime.utc(2026, 10, 5, 12);

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    auth = _MockAuth();
    secureScreen = _FakeSecureScreen();
    now = DateTime.utc(2026, 10, 5, 12);
  });
  tearDown(() => db.close());

  ProviderContainer container() => ProviderContainer.test(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      localAuthProvider.overrideWithValue(auth),
      secureScreenProvider.overrideWithValue(secureScreen),
    ],
  );

  Future<LockState> settled(ProviderContainer ref) async {
    ref.read(appLockProvider.notifier).useClock(() => now);
    await pumpEventQueue();
    return await Future.value(ref.read(appLockProvider));
  }

  group('PIN saqlash', () {
    test('tuz + PBKDF2: bir xil PIN — har safar boshqa hash', () async {
      const store = PinStore(FlutterSecureStorage());
      expect(await store.isSet, isFalse);

      await store.setPin('1234', random: Random(1));
      final first = await const FlutterSecureStorage().read(
        key: 'my_wallet.pin',
      );
      expect(first, isNot(contains('1234')));

      expect(await store.verify('1234'), isTrue);
      expect(await store.verify('4321'), isFalse);
      expect(await store.isSet, isTrue);

      await store.setPin('1234', random: Random(2));
      final second = await const FlutterSecureStorage().read(
        key: 'my_wallet.pin',
      );
      expect(second, isNot(first));
      expect(await store.verify('1234'), isTrue);

      await store.clear();
      expect(await store.isSet, isFalse);
      expect(await store.verify('1234'), isFalse);
    });
  });

  test(
    "PIN o'rnatilmagan — qulf yo'q; o'rnatilgach ochilishda qulflanadi",
    () async {
      final ref = container();
      expect((await settled(ref)).settings.pinSet, isFalse);
      expect(ref.read(appLockProvider).locked, isFalse);
      expect(secureScreen.calls, [true]);

      await ref.read(appLockProvider.notifier).setPin('1234');
      expect(ref.read(appLockProvider).locked, isFalse);

      // Yangi ishga tushirish — PIN bor, demak qulflangan.
      final restarted = container();
      expect((await settled(restarted)).locked, isTrue);
    },
  );

  test("noto'g'ri PIN — urinishlar; to'g'risi ochadi", () async {
    final ref = container();
    await settled(ref);
    final lock = ref.read(appLockProvider.notifier);
    await lock.setPin('1234');
    lock.lock();

    expect(await lock.unlockWithPin('0000'), isFalse);
    expect(ref.read(appLockProvider).attempts, 1);
    expect(await lock.unlockWithPin('1111'), isFalse);
    expect(ref.read(appLockProvider).attempts, 2);

    expect(await lock.unlockWithPin('1234'), isTrue);
    expect(ref.read(appLockProvider).locked, isFalse);
    expect(ref.read(appLockProvider).attempts, 0);
  });

  test("biometrika: yoqilmagan — so'ralmaydi; xato — qulf qoladi", () async {
    final ref = container();
    await settled(ref);
    final lock = ref.read(appLockProvider.notifier);
    await lock.setPin('1234');
    lock.lock();

    expect(await lock.unlockWithBiometrics(), isFalse);
    verifyNever(
      () => auth.authenticate(localizedReason: any(named: 'localizedReason')),
    );

    await lock.setBiometrics(enabled: true);
    when(
      () => auth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
      ),
    ).thenThrow(Exception("sensor yo'q"));
    expect(await lock.unlockWithBiometrics(), isFalse);
    expect(ref.read(appLockProvider).locked, isTrue);

    when(
      () => auth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
      ),
    ).thenAnswer((_) async => true);
    expect(await lock.unlockWithBiometrics(), isTrue);
    expect(ref.read(appLockProvider).locked, isFalse);
  });

  test('sozlamalar saqlanadi: biometrika, daqiqa, ekranni yashirish', () async {
    final ref = container();
    await settled(ref);
    final lock = ref.read(appLockProvider.notifier);
    await lock.setPin('1234');
    await lock.setBiometrics(enabled: true);
    await lock.setMinutes(15);
    await lock.setSecureScreen(enabled: false);
    expect(secureScreen.calls.last, isFalse);

    final restarted = container();
    final state = await settled(restarted);
    expect(state.settings.biometrics, isTrue);
    expect(state.settings.minutes, 15);
    expect(state.settings.secureScreen, isFalse);

    await restarted.read(appLockProvider.notifier).disable();
    expect(restarted.read(appLockProvider).settings.pinSet, isFalse);
    expect(restarted.read(appLockProvider).settings.biometrics, isFalse);
  });
}
