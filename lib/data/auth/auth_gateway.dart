import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Email kodi uzunligi — admin `config.toml` dagi `otp_length` bilan bir xil.
const emailCodeLength = 6;

/// Auth xato kodlari (GoTrue `error_code` dan tashqari — ilovaning o'zi).
abstract final class AuthCodes {
  static const invalidEmail = 'invalid_email';
  static const invalidCode = 'invalid_code';
  static const googleUnavailable = 'google_unavailable';
  static const googleFailed = 'google_failed';
}

/// Google ID token va uning xom nonce'i (serverga — `sha256` emas, xomi).
typedef GoogleIdToken = ({String idToken, String rawNonce});

/// Native Google hisob tanlash oynasi.
abstract interface class GoogleIdTokenSource {
  bool get available;

  /// `null` — foydalanuvchi oynani yopdi.
  Future<GoogleIdToken?> obtain();
}

/// Kirish (E14-T01): email kodi va Google. Xatolar — `Result`.
abstract interface class AuthGateway {
  /// Kirgan foydalanuvchi ID si yoki `null`.
  String? get currentUserId;

  /// Kirish/chiqish (sessiya eskirishi ham) — foydalanuvchi ID si.
  Stream<String?> get userChanges;

  bool get googleAvailable;

  /// Kodni emailga yuboradi (yangi foydalanuvchi — ro'yxatdan o'tadi).
  Future<Result<void>> sendEmailCode(String email);

  Future<Result<void>> verifyEmailCode(String email, String code);

  /// `Ok(false)` — foydalanuvchi Google oynasini yopdi (xato emas).
  Future<Result<bool>> signInWithGoogle();

  /// Qurilmadagi sessiya har doim o'chadi; serverga xabar yetmasa — log.
  Future<void> signOut();
}

final class SupabaseAuthGateway implements AuthGateway {
  const new(
    this._auth,
    this._google, {
    this.timeout = RpcRemoteApi.defaultTimeout,
  });

  final GoTrueClient _auth;
  final GoogleIdTokenSource _google;
  final Duration timeout;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _code = RegExp('^\\d{$emailCodeLength}\$');

  @override
  String? get currentUserId => _auth.currentUser?.id;

  @override
  Stream<String?> get userChanges =>
      _auth.onAuthStateChange.map((state) => state.session?.user.id).distinct();

  @override
  bool get googleAvailable => _google.available;

  @override
  Future<Result<void>> sendEmailCode(String email) async {
    final normalized = normalizeEmail(email);
    if (!_email.hasMatch(normalized)) {
      return const Err(ValidationFailure('email', AuthCodes.invalidEmail));
    }
    return await _guard(() => _auth.signInWithOtp(email: normalized));
  }

  @override
  Future<Result<void>> verifyEmailCode(String email, String code) async {
    final token = code.trim();
    if (!_code.hasMatch(token)) {
      return const Err(ValidationFailure('code', AuthCodes.invalidCode));
    }
    return await _guard(
      () => _auth.verifyOTP(
        email: normalizeEmail(email),
        token: token,
        type: OtpType.email,
      ),
    );
  }

  @override
  Future<Result<bool>> signInWithGoogle() async {
    if (!_google.available) {
      return const Err(RejectedFailure(AuthCodes.googleUnavailable));
    }
    final GoogleIdToken? token;
    try {
      token = await _google.obtain();
    } on GoogleSignInException catch (error, stackTrace) {
      // Odatda sozlama xatosi (SHA-1, client ID) — kuzatilsin.
      AppLog.error('Google bilan kirish', error, stackTrace);
      return Err(RejectedFailure(AuthCodes.googleFailed, error.code.name));
    }
    if (token == null) return const Ok(false);
    final result = await _guard(
      () => _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: token!.idToken,
        nonce: token.rawNonce,
      ),
    );
    return switch (result) {
      Ok() => const Ok(true),
      Err(:final failure) => Err(failure),
    };
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (error, stackTrace) {
      // Lokal sessiya allaqachon o'chirilgan; server tokenni o'zi eskirtiradi.
      AppLog.error('Chiqish serverga yetmadi', error, stackTrace);
    }
  }

  Future<Result<void>> _guard(Future<Object?> Function() call) async {
    try {
      await call().timeout(timeout);
      return const Ok(null);
    } on AuthRetryableFetchException {
      return const Err(OfflineFailure());
    } on TimeoutException {
      return const Err(OfflineFailure());
    } on AuthException catch (error) {
      return Err(
        RejectedFailure(
          error.code ?? 'auth_${error.statusCode}',
          error.message,
        ),
      );
    }
  }
}

String normalizeEmail(String email) => email.trim().toLowerCase();

/// Google oynasi uchun bir martalik tasodifiy nonce (replay himoyasi):
/// Google'ga `sha256` i, Supabase'ga xomi beriladi.
String randomNonce([Random? random]) {
  final source = random ?? Random.secure();
  return base64Url.encode(List.generate(32, (_) => source.nextInt(256)));
}

String sha256Hex(String value) => sha256.convert(utf8.encode(value)).toString();

// coverage:ignore-start
/// Android Credential Manager orqali (google_sign_in 7). `serverClientId` —
/// Web client ID (DEPLOY.md 3): Supabase tokenni shu bilan tekshiradi.
final class NativeGoogleIdTokens implements GoogleIdTokenSource {
  const new(this.serverClientId);

  final String serverClientId;

  @override
  bool get available => serverClientId.isNotEmpty;

  @override
  Future<GoogleIdToken?> obtain() async {
    final rawNonce = randomNonce();
    final signIn = GoogleSignIn.instance;
    // Android'da `initialize` faqat parametrlarni saqlaydi — har kirishda
    // yangi nonce bilan chaqiriladi.
    await signIn.initialize(
      serverClientId: serverClientId,
      nonce: sha256Hex(rawNonce),
    );
    try {
      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const GoogleSignInException(
          code: GoogleSignInExceptionCode.unknownError,
          description: 'ID token qaytmadi',
        );
      }
      return (idToken: idToken, rawNonce: rawNonce);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }
}

// coverage:ignore-end
