// E14-T01: email kodi bilan kirish — haqiqiy GoTrue va xat shabloni
// (admin `supabase/templates/sign-in-code.html`), Mailpit orqali.
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../support/local_supabase.dart';

final class _NoGoogle implements GoogleIdTokenSource {
  @override
  bool get available => false;

  @override
  Future<GoogleIdToken?> obtain() async => null;
}

void main() {
  setUpAll(requireLocalSupabase);

  test(
    'yangi foydalanuvchi: kod xatda → kirish → shaxsiy byudjet (BR-010)',
    () async {
      final client = newClient();
      addTearDown(client.dispose);
      final gateway = SupabaseAuthGateway(client.auth, _NoGoogle());
      final email = uniqueEmail();
      final users = gateway.userChanges.where((id) => id != null).first;

      expect(await gateway.sendEmailCode(email.toUpperCase()), isA<Ok<void>>());
      final code = RegExp('\\b\\d{$emailCodeLength}\\b')
          .firstMatch(await lastEmailText(email))
          ?.group(0);
      expect(code, isNotNull, reason: 'xatda $emailCodeLength xonali kod');

      final wrong = code == '000000' ? '111111' : '000000';
      expect(
        await gateway.verifyEmailCode(email, wrong),
        isA<Err<void>>().having(
          (e) => e.failure,
          'failure',
          const RejectedFailure('otp_expired'),
        ),
      );

      expect(await gateway.verifyEmailCode(email, code!), isA<Ok<void>>());
      expect(await users, gateway.currentUserId);

      final boot = await RpcRemoteApi(supabaseTransport(client)).bootstrap();
      final households = switch (boot) {
        Ok(:final value) => value.households,
        Err(:final failure) => fail('bootstrap: $failure'),
      };
      expect(households.single.role, MemberRole.owner);
      expect(households.single.onboarded, isFalse);

      await gateway.signOut();
      expect(gateway.currentUserId, isNull);
    },
  );
}
