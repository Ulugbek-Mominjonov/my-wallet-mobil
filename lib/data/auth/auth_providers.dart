import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Kirish — `bootstrap` Supabase'ni ishga tushiradi.
final authGatewayProvider = Provider<AuthGateway>(
  (ref) => SupabaseAuthGateway(
    Supabase.instance.client.auth,
    NativeGoogleIdTokens(ref.watch(appConfigProvider).googleWebClientId),
  ),
);

/// Kirgan foydalanuvchi ID si (`null` — kirilmagan). Sessiya eskirsa ham
/// yangilanadi — router va byudjetga bog'liq provider'lar shunga qaraydi.
final authUserProvider = NotifierProvider<AuthUser, String?>(AuthUser.new);

final class AuthUser extends Notifier<String?> {
  @override
  String? build() {
    final gateway = ref.watch(authGatewayProvider);
    final subscription = gateway.userChanges.listen((id) => state = id);
    ref.onDispose(subscription.cancel);
    return gateway.currentUserId;
  }
}
