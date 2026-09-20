// Lokal Supabase (admin repo, contracts.lock dagi commit) bilan integratsiya
// testlari uchun umumiy muhit. Kalitlar — `make integration`
// (`supabase status -o env`) yoki CI env'idan.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

final Map<String, String> _env = Platform.environment;
final String supabaseUrl = _env['SUPABASE_URL'] ?? 'http://127.0.0.1:54321';
final String publishableKey = _env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
final String secretKey = _env['SUPABASE_SECRET_KEY'] ?? '';
final String mailpitUrl = _env['MAILPIT_URL'] ?? 'http://127.0.0.1:54324';

/// Kalitlar yo'q bo'lsa — aniq xato (`setUpAll` da).
void requireLocalSupabase() {
  if (publishableKey.isEmpty || secretKey.isEmpty) {
    fail(
      'SUPABASE_PUBLISHABLE_KEY va SUPABASE_SECRET_KEY kerak '
      '(make integration)',
    );
  }
}

/// Har test uchun yangi manzil — testlar bir-biriga tegmaydi.
String uniqueEmail() =>
    'it-${DateTime.now().microsecondsSinceEpoch}@example.test';

SupabaseClient newClient() => SupabaseClient(
  supabaseUrl,
  publishableKey,
  // Ilovada bu xotirani `Supabase.initialize` beradi (PKCE — email kodi).
  authOptions: AuthClientOptions(
    autoRefreshToken: false,
    pkceAsyncStorage: _MemoryAsyncStorage(),
  ),
);

final class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final _values = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _values[key];

  @override
  Future<void> setItem({required String key, required String value}) async =>
      _values[key] = value;

  @override
  Future<void> removeItem({required String key}) async => _values.remove(key);
}

/// Tasdiqlangan foydalanuvchi (GoTrue admin API) → (email, parol).
Future<(String, String)> createUser() async {
  final email = uniqueEmail();
  final password = base64Url.encode(
    List.generate(18, (i) => (i * 37 + 11) % 256),
  );
  final response = await http.post(
    Uri.parse('$supabaseUrl/auth/v1/admin/users'),
    headers: {'apikey': secretKey, 'content-type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
      'email_confirm': true,
    }),
  );
  if (response.statusCode >= 300) {
    throw StateError(
      'Foydalanuvchi yaratilmadi: ${response.statusCode} ${response.body}',
    );
  }
  return (email, password);
}

/// Mailpit'dan [email] ga kelgan oxirgi xatning matni.
Future<String> lastEmailText(String email) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    final search = await http.get(
      Uri.parse('$mailpitUrl/api/v1/search?query=to:$email'),
    );
    final messages = (jsonDecode(search.body) as Map)['messages'] as List;
    if (messages.isNotEmpty) {
      final id = (messages.first as Map)['ID'];
      final message = await http.get(
        Uri.parse('$mailpitUrl/api/v1/message/$id'),
      );
      return (jsonDecode(message.body) as Map)['Text'] as String;
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  throw StateError('Xat kelmadi: $email');
}
