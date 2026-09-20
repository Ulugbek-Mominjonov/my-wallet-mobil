import 'dart:async';

import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Test uchun kirish: natijalar navbatdan, chaqiruvlar yozib boriladi.
final class FakeAuthGateway implements AuthGateway {
  new({this.currentUserId, this.googleAvailable = false});

  @override
  String? currentUserId;
  final _changes = StreamController<String?>.broadcast();
  final calls = <String>[];

  /// Keyingi javoblar (bo'sh — muvaffaqiyat).
  final results = <Result<Object?>>[];

  @override
  final bool googleAvailable;

  @override
  Stream<String?> get userChanges => _changes.stream;

  /// Sessiya o'zgarishi (kirish/chiqish yoki eskirish).
  void emitUser(String? userId) {
    currentUserId = userId;
    _changes.add(userId);
  }

  Result<T> _next<T>(T success) {
    if (results.isEmpty) return Ok(success);
    return switch (results.removeAt(0)) {
      Ok(:final value) => Ok(value as T),
      Err(:final failure) => Err(failure),
    };
  }

  @override
  Future<Result<void>> sendEmailCode(String email) async {
    calls.add('send:$email');
    return _next<void>(null);
  }

  @override
  Future<Result<void>> verifyEmailCode(String email, String code) async {
    calls.add('verify:$email:$code');
    final result = _next<void>(null);
    if (result is Ok) emitUser('user-1');
    return result;
  }

  @override
  Future<Result<bool>> signInWithGoogle() async {
    calls.add('google');
    final result = _next(true);
    if (result case Ok(value: true)) emitUser('user-1');
    return result;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    emitUser(null);
  }
}
