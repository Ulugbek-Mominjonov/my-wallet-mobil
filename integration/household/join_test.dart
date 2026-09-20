// E14-T02: byudjet yaratish va taklif kodi bilan qo'shilish — haqiqiy
// RPC'lar (create_household, create_invite, accept_invite; BR-010, BR-012).
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../support/local_supabase.dart';

void main() {
  setUpAll(requireLocalSupabase);

  Future<(SupabaseClient, RemoteApi)> signIn() async {
    final (email, password) = await createUser();
    final client = newClient();
    addTearDown(client.dispose);
    await client.auth.signInWithPassword(email: email, password: password);
    return (client, RpcRemoteApi(supabaseTransport(client)));
  }

  T ok<T>(Result<T> result) => switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => fail('Ok kutilgan, $failure keldi'),
  };

  test("yangi byudjet va taklif kodi bilan qo'shilish", () async {
    final (ownerClient, owner) = await signIn();
    final (_, guest) = await signIn();

    final householdId = ok(await owner.createHousehold('Oila'));
    final invite = await ownerClient.rpc<List<dynamic>>(
      'create_invite',
      params: {'p_household': householdId},
    );
    final code = (invite.single as Map)['code'] as String;
    expect(code, hasLength(8));

    expect(ok(await guest.acceptInvite(code.toLowerCase())), householdId);
    final guestHouseholds = ok(await guest.bootstrap()).households;
    expect(
      guestHouseholds.map((h) => h.id),
      contains(householdId),
      reason: "taklif qabul qilingan byudjet ro'yxatda",
    );
    expect(
      guestHouseholds.firstWhere((h) => h.id == householdId).role,
      MemberRole.member,
    );

    // Bir martalik kod (BR-012) — ishlatilgani qayta qabul qilinmaydi.
    expect(
      await guest.acceptInvite(code),
      isA<Err<String>>().having(
        (e) => e.failure,
        'failure',
        const RejectedFailure('invite_used'),
      ),
    );
    expect(
      await guest.acceptInvite('ZZZZ9999'),
      isA<Err<String>>().having(
        (e) => e.failure,
        'failure',
        const RejectedFailure('invite_not_found'),
      ),
    );
  });
}
