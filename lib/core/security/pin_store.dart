import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// PIN uzunligi (BR-211).
const pinLength = 4;

/// PIN — ochiq saqlanmaydi: tasodifiy tuz + PBKDF2-HMAC-SHA256.
/// Hash Android Keystore bilan shifrlangan xotirada (`flutter_secure_storage`),
/// shuning uchun iteratsiyalar soni mo''tadil — himoya asosan Keystore'da.
final class PinStore {
  const new(this._storage);

  static const _key = 'my_wallet.pin';
  static const _iterations = 10000;

  final FlutterSecureStorage _storage;

  Future<bool> get isSet => _storage.containsKey(key: _key);

  Future<void> setPin(String pin, {Random? random}) async {
    final salt = _salt(random ?? Random.secure());
    final hash = _hash(pin, salt);
    await _storage.write(
      key: _key,
      value: '${base64.encode(salt)}:${base64.encode(hash)}',
    );
  }

  /// PIN to'g'ri bo'lsa `true`; o'rnatilmagan bo'lsa `false`.
  Future<bool> verify(String pin) async {
    final stored = await _storage.read(key: _key);
    if (stored == null) return false;
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    final salt = base64.decode(parts[0]);
    final expected = base64.decode(parts[1]);
    final actual = _hash(pin, salt);
    // Doimiy vaqtli solishtirish.
    if (actual.length != expected.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual[i] ^ expected[i];
    }
    return diff == 0;
  }

  Future<void> clear() => _storage.delete(key: _key);

  static Uint8List _salt(Random random) =>
      Uint8List.fromList([for (var i = 0; i < 16; i++) random.nextInt(256)]);

  /// PBKDF2-HMAC-SHA256 (RFC 8018), bitta blok — 32 bayt.
  static Uint8List _hash(String pin, List<int> salt) {
    final hmac = Hmac(sha256, utf8.encode(pin));
    var block = Uint8List.fromList(hmac.convert([...salt, 0, 0, 0, 1]).bytes);
    final result = Uint8List.fromList(block);
    for (var i = 1; i < _iterations; i++) {
      block = Uint8List.fromList(hmac.convert(block).bytes);
      for (var j = 0; j < result.length; j++) {
        result[j] ^= block[j];
      }
    }
    return result;
  }
}
