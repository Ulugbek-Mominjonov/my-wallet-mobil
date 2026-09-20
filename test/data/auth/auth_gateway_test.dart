import 'dart:async';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:my_wallet/data/auth/secure_session_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wallet_domain/wallet_domain.dart';

final class _MockAuth extends Mock implements GoTrueClient;

final class _FakeGoogle implements GoogleIdTokenSource {
  new({this.available = true});

  @override
  final bool available;

  /// `null` — bekor qilindi; exception — tashlanadi.
  Object? next = (idToken: 'id-token', rawNonce: 'raw');

  @override
  Future<GoogleIdToken?> obtain() async {
    final value = next;
    if (value is Exception) throw value;
    return value as GoogleIdToken?;
  }
}

User _user(String id) => User(
  id: id,
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  createdAt: '2026-10-01T00:00:00Z',
);

void main() {
  late _MockAuth auth;
  late _FakeGoogle google;
  late SupabaseAuthGateway gateway;

  setUp(() {
    auth = _MockAuth();
    google = _FakeGoogle();
    gateway = SupabaseAuthGateway(auth, google);
  });

  group('email kodi', () {
    test('email tekshiriladi va normallashtiriladi', () async {
      when(() => auth.signInWithOtp(email: any(named: 'email')))
          .thenAnswer((_) async {});

      expect(
        await gateway.sendEmailCode('noto‘g‘ri'),
        isA<Err<void>>().having(
          (e) => e.failure,
          'failure',
          const ValidationFailure('email', AuthCodes.invalidEmail),
        ),
      );
      expect(await gateway.sendEmailCode('  Ali@Example.UZ '), isA<Ok<void>>());
      verify(() => auth.signInWithOtp(email: 'ali@example.uz')).called(1);
    });

    test('kod — 6 raqam; server javobi Result ga', () async {
      when(
        () => auth.verifyOTP(
          email: any(named: 'email'),
          token: any(named: 'token'),
          type: OtpType.email,
        ),
      ).thenAnswer((_) async => AuthResponse());

      expect(
        await gateway.verifyEmailCode('a@b.uz', '12a45'),
        isA<Err<void>>().having(
          (e) => e.failure,
          'failure',
          const ValidationFailure('code', AuthCodes.invalidCode),
        ),
      );
      expect(
        await gateway.verifyEmailCode('A@b.uz', ' 123456 '),
        isA<Ok<void>>(),
      );
      verify(
        () => auth.verifyOTP(
          email: 'a@b.uz',
          token: '123456',
          type: OtpType.email,
        ),
      ).called(1);
    });

    test('xatolar: tarmoq/timeout — oflayn, GoTrue kodi — rad etish', () async {
      final failures = <Failure>[];
      for (final error in <Object>[
        AuthRetryableFetchException(message: 'SocketException'),
        const AuthApiException('Token has expired', code: 'otp_expired'),
        const AuthApiException('boom', statusCode: '422'),
      ]) {
        when(() => auth.signInWithOtp(email: any(named: 'email')))
            .thenThrow(error);
        final result = await gateway.sendEmailCode('a@b.uz');
        failures.add((result as Err<void>).failure);
      }
      expect(failures, [
        isA<OfflineFailure>(),
        const RejectedFailure('otp_expired'),
        const RejectedFailure('auth_422'),
      ]);

      final slow = SupabaseAuthGateway(
        auth,
        google,
        timeout: const Duration(milliseconds: 10),
      );
      when(() => auth.signInWithOtp(email: any(named: 'email')))
          .thenAnswer((_) => Completer<void>().future);
      expect(
        await slow.sendEmailCode('a@b.uz'),
        isA<Err<void>>().having((e) => e.failure, 'f', isA<OfflineFailure>()),
      );
    });
  });

  group('Google', () {
    void stubIdToken() => when(
      () => auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: any(named: 'idToken'),
        nonce: any(named: 'nonce'),
      ),
    ).thenAnswer((_) async => AuthResponse());

    test('ID token va xom nonce Supabase ga', () async {
      stubIdToken();
      expect(
        await gateway.signInWithGoogle(),
        isA<Ok<bool>>().having((r) => r.value, 'v', isTrue),
      );
      verify(
        () => auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: 'id-token',
          nonce: 'raw',
        ),
      ).called(1);
    });

    test('bekor qilish — xato emas', () async {
      google.next = null;
      expect(
        await gateway.signInWithGoogle(),
        isA<Ok<bool>>().having((r) => r.value, 'v', isFalse),
      );
      verifyNever(
        () => auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: any(named: 'idToken'),
          nonce: any(named: 'nonce'),
        ),
      );
    });

    test('sozlama xatosi va sozlanmagan Google', () async {
      google.next = const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
      );
      expect(
        await gateway.signInWithGoogle(),
        isA<Err<bool>>().having(
          (e) => e.failure,
          'f',
          const RejectedFailure(AuthCodes.googleFailed),
        ),
      );

      final off = SupabaseAuthGateway(auth, _FakeGoogle(available: false));
      expect(off.googleAvailable, isFalse);
      expect(
        await off.signInWithGoogle(),
        isA<Err<bool>>().having(
          (e) => e.failure,
          'f',
          const RejectedFailure(AuthCodes.googleUnavailable),
        ),
      );
    });

    test('server rad etsa — xato qaytadi', () async {
      when(
        () => auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: any(named: 'idToken'),
          nonce: any(named: 'nonce'),
        ),
      ).thenThrow(const AuthApiException('nonce', code: 'bad_jwt'));
      expect(
        await gateway.signInWithGoogle(),
        isA<Err<bool>>().having(
          (e) => e.failure,
          'f',
          const RejectedFailure('bad_jwt'),
        ),
      );
    });

    test('nonce: tasodifiy, sha256 — hex', () {
      final nonce = randomNonce(Random(1));
      expect(nonce, hasLength(44));
      expect(randomNonce(), isNot(randomNonce()));
      expect(
        sha256Hex('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });
  });

  group('sessiya', () {
    test("foydalanuvchi va uning o'zgarishlari (takrorsiz)", () async {
      when(() => auth.currentUser).thenReturn(_user('u1'));
      final session = Session(
        accessToken: 'a',
        tokenType: 'bearer',
        user: _user('u1'),
      );
      when(() => auth.onAuthStateChange).thenAnswer(
        (_) => Stream.fromIterable([
          AuthState(AuthChangeEvent.signedIn, session),
          AuthState(AuthChangeEvent.tokenRefreshed, session),
          const AuthState(AuthChangeEvent.signedOut, null),
        ]),
      );
      expect(gateway.currentUserId, 'u1');
      expect(await gateway.userChanges.toList(), ['u1', null]);
    });

    test('chiqish serverga yetmasa ham lokal chiqiladi (xato — log)', () async {
      when(() => auth.signOut())
          .thenThrow(AuthRetryableFetchException(message: 'offline'));
      await gateway.signOut();
      verify(() => auth.signOut()).called(1);
    });

    test('sessiya shifrlangan xotirada', () async {
      FlutterSecureStorage.setMockInitialValues({});
      const storage = SecureSessionStorage(FlutterSecureStorage());
      await storage.initialize();
      expect(await storage.hasAccessToken(), isFalse);
      await storage.persistSession('{"access_token":"x"}');
      expect(await storage.hasAccessToken(), isTrue);
      expect(await storage.accessToken(), '{"access_token":"x"}');
      await storage.removePersistedSession();
      expect(await storage.accessToken(), isNull);
    });
  });
}
