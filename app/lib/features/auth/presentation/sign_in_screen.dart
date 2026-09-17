import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/widgets/actions.dart';
import '../../../di/providers.dart';

/// Kirish ekrani — Google yoki anonim.
///
/// Anonim boshlash ataylab qoldirilgan: ilovani darhol sinab ko'rish
/// mumkin, keyin hisobni bog'lash (link) orqali ma'lumot saqlanib qoladi.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    await runAction(context, action: action);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _google() => _run(() async {
        final signIn = GoogleSignIn.instance;
        await signIn.initialize();
        final account = await signIn.authenticate();
        final tokens = account.authentication;
        await ref.read(firebaseAuthProvider).signInWithCredential(
              GoogleAuthProvider.credential(idToken: tokens.idToken),
            );
      });

  Future<void> _anonymous() =>
      _run(() => ref.read(firebaseAuthProvider).signInAnonymously());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '💰',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              Text(
                Uz.appName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Daromad, xarajat, qarz va maqsadlar — bitta joyda.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: _busy ? null : _google,
                icon: const Icon(Icons.login),
                label: const Text('Google bilan kirish'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _busy ? null : _anonymous,
                child: const Text('Hisobsiz boshlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
