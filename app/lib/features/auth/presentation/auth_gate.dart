import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../di/providers.dart';
import 'sign_in_screen.dart';

/// Kirmagan foydalanuvchini kirish ekraniga yuboradi.
///
/// Barcha ma'lumot `users/{uid}` ostida — shuning uchun `uidProvider`
/// faqat shu darvozadan o'tgandan keyin ishlatiladi.
class AuthGate extends ConsumerWidget {
  const AuthGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(authStateProvider)) {
        AsyncData<User?>(value: final user) =>
          user == null ? const SignInScreen() : child,
        AsyncError<User?>(:final error) => Scaffold(
            body: ErrorState(message: error.toString()),
          ),
        _ => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
      };
}
