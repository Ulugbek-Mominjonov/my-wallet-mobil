import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Kodni qayta yuborishgacha kutish — admin `config.toml` dagi
/// `auth.email.max_frequency` bilan bir xil.
const resendCooldown = Duration(seconds: 30);

/// Kirish ekrani holati: email → kod bosqichlari.
@immutable
final class SignInState {
  const new({
    this.email = '',
    this.codeSent = false,
    this.sends = 0,
    this.busy = false,
    this.failure,
  });

  /// Kod yuborilgan manzil (normallashtirilgan).
  final String email;

  /// `true` — kod kiritish bosqichi.
  final bool codeSent;

  /// Nechta kod yuborilgan — qayta yuborish taymeri shu bilan boshlanadi.
  final int sends;
  final bool busy;
  final Failure? failure;
}

final NotifierProvider<SignInController, SignInState> signInControllerProvider =
    NotifierProvider.autoDispose(SignInController.new);

/// Kirish amallari. Muvaffaqiyatli kirishdan keyin router o'zi yo'naltiradi
/// (`authUserProvider`).
final class SignInController extends Notifier<SignInState> {
  @override
  SignInState build() => const SignInState();

  AuthGateway get _gateway => ref.read(authGatewayProvider);

  Future<void> sendCode(String email) async {
    if (state.busy) return;
    _setBusy();
    final result = await _gateway.sendEmailCode(email);
    state = switch (result) {
      Ok() => SignInState(
        email: normalizeEmail(email),
        codeSent: true,
        sends: state.sends + 1,
      ),
      Err(:final failure) => _failed(failure),
    };
  }

  Future<void> resend() => sendCode(state.email);

  Future<void> verify(String code) async {
    if (state.busy) return;
    _setBusy();
    final result = await _gateway.verifyEmailCode(state.email, code);
    state = switch (result) {
      Ok() => _idle(),
      Err(:final failure) => _failed(failure),
    };
  }

  Future<void> signInWithGoogle() async {
    if (state.busy) return;
    _setBusy();
    final result = await _gateway.signInWithGoogle();
    state = switch (result) {
      Ok() => _idle(),
      Err(:final failure) => _failed(failure),
    };
  }

  /// Kod bosqichidan emailni o'zgartirishga qaytish.
  void changeEmail() => state = SignInState(email: state.email);

  void _setBusy() => state = SignInState(
    email: state.email,
    codeSent: state.codeSent,
    sends: state.sends,
    busy: true,
  );

  SignInState _idle() => SignInState(
    email: state.email,
    codeSent: state.codeSent,
    sends: state.sends,
  );

  SignInState _failed(Failure failure) => SignInState(
    email: state.email,
    codeSent: state.codeSent,
    sends: state.sends,
    failure: failure,
  );
}
