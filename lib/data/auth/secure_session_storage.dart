import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase sessiyasi (refresh token) — Android Keystore bilan shifrlangan
/// xotirada, SharedPreferences'da emas (ARXITEKTURA 8).
final class SecureSessionStorage extends LocalStorage {
  const new(this._storage, {this.key = sessionKey});

  static const sessionKey = 'my_wallet.supabase_session';

  final FlutterSecureStorage _storage;
  final String key;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: key);

  @override
  Future<String?> accessToken() => _storage.read(key: key);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: key);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: key, value: persistSessionString);
}

/// Supabase'ni ishga tushirish — ilova va fon sinxroni uchun bitta joy
/// (ikkalasi bitta sessiyani ko'rsin).
Future<void> initSupabase(AppConfig config) => Supabase.initialize(
  url: config.supabaseUrl,
  publishableKey: config.supabasePublishableKey,
  authOptions: const FlutterAuthClientOptions(
    localStorage: SecureSessionStorage(FlutterSecureStorage()),
  ),
);
