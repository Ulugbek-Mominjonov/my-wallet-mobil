import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

/// ID ni KLIENT beradi — serverga borib kelish shart emas.
///
/// Shu tufayli aviarejimda yozuv darhol yaratiladi va sinxronlashda
/// takrorlanmaydi (Firestore avtomatik ID lari global unikal).
final class FirestoreIdGenerator implements IdGenerator {
  const FirestoreIdGenerator(this._db);

  final FirebaseFirestore _db;

  @override
  String next() => _db.collection('_ids').doc().id;
}
