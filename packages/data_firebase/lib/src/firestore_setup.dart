import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore'ni offline-first rejimga sozlaydi.
///
/// * doimiy kesh — aviarejimda ham ilova to'liq ishlaydi;
/// * 100 MB kesh — bir marta o'qilgan oy qayta o'qilmaydi (§5.4).
abstract final class FirestoreSetup {
  static const int cacheSizeBytes = 100 * 1024 * 1024;

  static void configure(FirebaseFirestore db) {
    db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: cacheSizeBytes,
    );
  }

  /// Emulyatorga ulanish (lokal ishlab chiqish va testlar uchun).
  static void useEmulator(
    FirebaseFirestore db, {
    String host = 'localhost',
    int port = 8080,
  }) {
    db.useFirestoreEmulator(host, port);
  }
}
