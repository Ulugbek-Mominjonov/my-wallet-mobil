import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/core/share/file_sharer.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/core/widgets/qr_view.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/features/household/application/invite_links.dart';
import 'package:my_wallet/features/household/application/members_controller.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// E30-T04 (BR-011..014): byudjet a'zolari — ro'yxat, rollar, taklif
/// (kod, havola, QR) va chiqish/chiqarish. Huquqni server tekshiradi;
/// bu yerda tugmalar rolga qarab ko'rsatiladi (BR-011).
class MembersScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final members = ref.watch(membersProvider);
    final role = switch (ref.watch(startupProvider)) {
      StartupReady(:final household) => household.role,
      _ => MemberRole.viewer,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.membersTitle)),
      floatingActionButton: role.canManage
          ? FloatingActionButton.extended(
              onPressed: () => unawaited(_invite(context, ref)),
              icon: const Icon(Icons.person_add_alt),
              label: Text(l10n.membersInvite),
            )
          : null,
      body: switch (members) {
        AsyncData(value: Ok(:final value)) => _MembersList(
          members: value,
          myRole: role,
        ),
        AsyncData(value: Err(:final failure)) => EmptyState(
          icon: Icons.cloud_off,
          title: l10n.membersOffline,
          message: '$failure',
        ),
        AsyncError() => EmptyState(
          icon: Icons.cloud_off,
          title: l10n.membersOffline,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  /// BR-012: taklif kodi — kod, havola va QR bitta oynada.
  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(memberActionsProvider).invite();
    if (!context.mounted) return;
    switch (result) {
      case Ok(:final value):
        await showDialog<void>(
          context: context,
          builder: (_) => _InviteDialog(invite: value),
        );
        ref.invalidate(membersProvider);
      case Err(:final failure):
        _snack(context, '$failure');
    }
  }
}

class _MembersList extends ConsumerWidget {
  const new({required this.members, required this.myRole});

  final List<HouseholdMember> members;
  final MemberRole myRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        for (final member in members)
          ListTile(
            leading: CircleAvatar(child: Text(_initial(member.name))),
            title: Text(
              member.isMe ? '${member.name} (${l10n.membersYou})' : member.name,
            ),
            subtitle: Text(roleLabel(l10n, member.role)),
            trailing: _MemberMenu(member: member, myRole: myRole),
          ),
      ],
    );
  }

  static String _initial(String name) =>
      name.isEmpty ? '?' : name.characters.first.toUpperCase();
}

/// A'zo amallari: rol (owner/admin), chiqarish yoki o'zi chiqishi.
class _MemberMenu extends ConsumerWidget {
  const new({required this.member, required this.myRole});

  final HouseholdMember member;
  final MemberRole myRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final actions = ref.read(memberActionsProvider);
    // BR-011: owner rolini faqat egalikni o'tkazish o'zgartiradi (admin
    // panelda); admin owner'ga tegolmaydi.
    final canEdit = myRole.canManage && member.role != MemberRole.owner;
    if (!canEdit && !member.isMe) return const SizedBox.shrink();

    return PopupMenuButton<void Function()>(
      tooltip: l10n.membersActions(member.name),
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        if (canEdit && !member.isMe)
          for (final role in const [
            MemberRole.admin,
            MemberRole.member,
            MemberRole.viewer,
          ])
            if (role != member.role)
              PopupMenuItem(
                value: () => unawaited(
                  _run(
                    context,
                    ref,
                    () => actions.setRole(member.userId, role),
                  ),
                ),
                child: Text(l10n.membersSetRole(roleLabel(l10n, role))),
              ),
        if (canEdit && !member.isMe)
          PopupMenuItem(
            value: () => unawaited(
              _run(context, ref, () => actions.remove(member.userId)),
            ),
            child: Text(l10n.membersRemove),
          ),
        if (member.isMe)
          PopupMenuItem(
            value: () => unawaited(_run(context, ref, actions.leave)),
            child: Text(l10n.membersLeave),
          ),
      ],
    );
  }

  static Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<Result<void>> Function() action,
  ) async {
    final result = await action();
    if (!context.mounted) return;
    if (result case Err(:final failure)) _snack(context, '$failure');
  }
}

class _InviteDialog extends ConsumerWidget {
  const new({required this.invite});

  final HouseholdInvite invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final link = inviteLink(invite.code, ref.watch(appConfigProvider).env);
    return AlertDialog(
      title: Text(l10n.membersInvite),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText(
            invite.code,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          QrView(link),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.membersInviteHint, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: link));
            if (context.mounted) _snack(context, l10n.copied);
          },
          child: Text(l10n.actionCopy),
        ),
        TextButton(
          onPressed: () => unawaited(
            ref.read(textSharerProvider)(
              '${l10n.membersShareText(invite.code)}\n$link',
            ),
          ),
          child: Text(l10n.actionShare),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionClose),
        ),
      ],
    );
  }
}

/// Rol nomi (BR-011) — ekranlar bir xil atamani ishlatsin.
String roleLabel(AppL10n l10n, MemberRole role) => switch (role) {
  MemberRole.owner => l10n.roleOwner,
  MemberRole.admin => l10n.roleAdmin,
  MemberRole.member => l10n.roleMember,
  MemberRole.viewer => l10n.roleViewer,
};

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
