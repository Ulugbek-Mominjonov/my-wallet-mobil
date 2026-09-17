// Firebase konfiguratsiyasi.
//
// Haqiqiy loyihada bu fayl `flutterfire configure` bilan yaratiladi.
// Bu yerdagi versiya qiymatlarni `--dart-define` orqali oladi, shunda
// bitta kod bazasi dev / prod muhitlariga ulanadi (§13.2) va repoda
// hech qanday muhitga bog'liq qiymat qotib qolmaydi.
//
// Misol:
//   flutter run --dart-define=FIREBASE_PROJECT_ID=oylik-byudjet-dev ...
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Muhitdan o'qiladigan Firebase sozlamalari.
abstract final class DefaultFirebaseOptions {
  static const String _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String _appIdAndroid =
      String.fromEnvironment('FIREBASE_APP_ID_ANDROID');
  static const String _appIdIos = String.fromEnvironment('FIREBASE_APP_ID_IOS');
  static const String _senderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String _projectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String _storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const String _iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'uz.oylikbyudjet.app',
  );

  /// Sozlamalar berilganmi? Berilmagan bo'lsa ilova tushunarli xato beradi.
  static bool get isConfigured => _projectId.isNotEmpty && _apiKey.isNotEmpty;

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw StateError(
        'Firebase sozlanmagan. `flutterfire configure` ni ishlating yoki '
        '--dart-define=FIREBASE_PROJECT_ID=... qiymatlarini bering.',
      );
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => FirebaseOptions(
          apiKey: _apiKey,
          appId: _appIdIos,
          messagingSenderId: _senderId,
          projectId: _projectId,
          storageBucket: _storageBucket,
          iosBundleId: _iosBundleId,
        ),
      _ => FirebaseOptions(
          apiKey: _apiKey,
          appId: _appIdAndroid,
          messagingSenderId: _senderId,
          projectId: _projectId,
          storageBucket: _storageBucket,
        ),
    };
  }
}
