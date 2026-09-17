import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logging/app_log.dart';

/// 🔒 Lokal qulf — moliyaviy ilova uchun (reja §7.2).
///
/// Sozlama ATAYLAB Firestore'da emas, QURILMADA saqlanadi: qulf — bu
/// qurilma xususiyati. Telefon almashtirilsa yangi qurilmada qulf o'zi
/// yoqilmaydi, planshetda esa boshqacha sozlash mumkin.
final class AppLockService {
  const AppLockService(this._preferences, this._auth);

  static const String _key = 'app_lock_enabled';

  final SharedPreferences _preferences;
  final LocalAuthentication _auth;

  bool get isEnabled => _preferences.getBool(_key) ?? false;

  Future<void> setEnabled({required bool value}) async {
    await _preferences.setBool(_key, value);
  }

  /// Qurilmada biometrika yoki PIN sozlanganmi?
  Future<bool> get isAvailable async {
    try {
      return await _auth.isDeviceSupported();
    } on Object catch (error, stackTrace) {
      AppLog.error("Qulfni tekshirib bo'lmadi", error, stackTrace);
      return false;
    }
  }

  /// Foydalanuvchini tasdiqlaydi. Xato bo'lsa `false` — ilova ochilmaydi.
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Byudjetni ochish uchun tasdiqlang',
        persistAcrossBackgrounding: true,
      );
    } on Object catch (error, stackTrace) {
      AppLog.error('Tasdiqlash xatosi', error, stackTrace);
      return false;
    }
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final appLockProvider = Provider<AppLockService?>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider).value;
  if (preferences == null) return null;
  return AppLockService(preferences, LocalAuthentication());
});

/// Qulf yoqilgan bo'lsa ilova ustida tasdiqlash ekranini ko'rsatadi.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  bool _unlocked = false;
  bool _checking = false;

  Future<void> _unlock(AppLockService service) async {
    if (_checking) return;
    setState(() => _checking = true);
    final granted = await service.authenticate();
    if (!mounted) return;
    setState(() {
      _unlocked = granted;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(appLockProvider);
    if (service == null) {
      // Sozlamalar hali o'qilmagan — qulfni qo'llashdan oldin kutamiz.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!service.isEnabled || _unlocked) return widget.child;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 16),
            const Text('Byudjet qulflangan'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _checking ? null : () => _unlock(service),
              icon: const Icon(Icons.fingerprint),
              label: Text(_checking ? 'Kutilmoqda…' : 'Ochish'),
            ),
          ],
        ),
      ),
    );
  }
}
