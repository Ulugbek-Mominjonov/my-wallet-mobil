import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderFamily;
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/remote/json_read.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// BR-011: joriy byudjet a'zolari (serverdan — sinxron jadvali emas).
/// Muvaffaqiyatli javob lokal keshga yoziladi: oflaynda ham "kim yozdi"
/// ismlari ko'rinadi.
final FutureProvider<Result<List<HouseholdMember>>> membersProvider =
    FutureProvider((ref) async {
      final householdId = ref.watch(currentHouseholdIdProvider);
      if (householdId == null) return const Ok([]);
      final db = ref.watch(appDatabaseProvider);
      final result = await ref
          .watch(remoteApiProvider)
          .householdMembers(householdId);
      if (result case Ok(:final value)) {
        await db.setSetting(_cacheKey(householdId), _encode(value));
        ref.invalidate(cachedMembersProvider);
      }
      return result;
    });

/// Oxirgi muvaffaqiyatli ro'yxat (lokal kesh) — oflaynda ismlar uchun.
final FutureProvider<List<HouseholdMember>> cachedMembersProvider =
    FutureProvider((ref) async {
      final householdId = ref.watch(currentHouseholdIdProvider);
      if (householdId == null) return const [];
      final raw = await ref
          .watch(appDatabaseProvider)
          .setting(_cacheKey(householdId));
      return raw == null ? const [] : _decode(raw);
    });

/// BR-011 "kim yozdi": boshqa a'zo yozgan bo'lsa — ismi. Yolg'iz byudjetda
/// yoki o'zi yozganda `null` (ortiqcha belgi ko'rsatilmaydi).
final ProviderFamily<String?, String?> authorNameProvider = Provider.family((
  ref,
  userId,
) {
  if (userId == null) return null;
  final members = ref.watch(cachedMembersProvider).value ?? const [];
  if (members.length < 2) return null;
  final member = members.where((m) => m.userId == userId).firstOrNull;
  return member == null || member.isMe ? null : member.name;
});

String _cacheKey(String householdId) => 'members:$householdId';

String _encode(List<HouseholdMember> members) => jsonEncode([
  for (final m in members)
    {
      'user_id': m.userId,
      'name': m.name,
      'role': m.role.wire,
      'joined_at': m.joinedAt.toIso8601String(),
      'is_me': m.isMe,
    },
]);

List<HouseholdMember> _decode(String raw) {
  final list = jsonDecode(raw);
  if (list is! List) return const [];
  return [
    for (final item in list)
      if (item is Map<String, Object?>)
        (
          userId: read<String>(item, 'user_id'),
          name: read<String>(item, 'name'),
          role: MemberRole.fromWire(read<String>(item, 'role')),
          joinedAt: DateTime.parse(read<String>(item, 'joined_at')),
          isMe: read<bool>(item, 'is_me'),
        ),
  ];
}

/// A'zolar bilan amallar (BR-011..014) — huquqni server tekshiradi, UI esa
/// tugmalarni rolga qarab yashiradi.
final Provider<MemberActions> memberActionsProvider = Provider(
  MemberActions.new,
);

final class MemberActions {
  const new(this._ref);

  final Ref _ref;

  Future<Result<HouseholdInvite>> invite({
    MemberRole role = MemberRole.member,
  }) => _run((api, id) => api.createInvite(id, role: role));

  Future<Result<void>> setRole(String userId, MemberRole role) =>
      _refresh((api, id) => api.setMemberRole(id, userId, role));

  Future<Result<void>> remove(String userId) =>
      _refresh((api, id) => api.removeMember(id, userId));

  /// BR-014: o'zi chiqadi — byudjetlar ro'yxati ham qaytadan yuklanadi.
  Future<Result<void>> leave() async {
    final result = await _run((api, id) => api.leaveHousehold(id));
    if (result is Ok) _ref.invalidate(startupProvider);
    return result;
  }

  Future<Result<T>> _run<T>(
    Future<Result<T>> Function(RemoteApi api, String householdId) action,
  ) async {
    final householdId = _ref.read(currentHouseholdIdProvider);
    if (householdId == null) return const Err(UnauthorizedFailure());
    return await action(_ref.read(remoteApiProvider), householdId);
  }

  Future<Result<T>> _refresh<T>(
    Future<Result<T>> Function(RemoteApi api, String householdId) action,
  ) async {
    final result = await _run(action);
    if (result is Ok) _ref.invalidate(membersProvider);
    return result;
  }
}
