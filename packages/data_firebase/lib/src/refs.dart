import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

/// ★ Firestore yo'llari YAGONA joyda.
///
/// Hech bir repozitoriy `collection('expenses')` deb qo'lda yozmaydi —
/// yo'l o'zgarsa (masalan `users/{uid}` dan `households/{id}` ga ko'chirilsa,
/// §15) faqat shu fayl tahrirlanadi.
final class FirestoreRefs {
  const FirestoreRefs({required this.db, required this.uid});

  static const String usersCollection = 'users';
  static const String incomesCollection = 'incomes';
  static const String expensesCollection = 'expenses';
  static const String personalSpendsCollection = 'personalSpends';
  static const String debtsCollection = 'debts';
  static const String goalsCollection = 'goals';
  static const String monthsCollection = 'months';
  static const String metaCollection = 'meta';
  static const String settingsCollection = 'settings';
  static const String auditCollection = 'auditLog';

  final FirebaseFirestore db;
  final String uid;

  DocumentReference<Map<String, dynamic>> get user =>
      db.collection(usersCollection).doc(uid);

  CollectionReference<Map<String, dynamic>> get incomes =>
      user.collection(incomesCollection);

  CollectionReference<Map<String, dynamic>> get expenses =>
      user.collection(expensesCollection);

  CollectionReference<Map<String, dynamic>> get personalSpends =>
      user.collection(personalSpendsCollection);

  CollectionReference<Map<String, dynamic>> get debts =>
      user.collection(debtsCollection);

  CollectionReference<Map<String, dynamic>> get goals =>
      user.collection(goalsCollection);

  CollectionReference<Map<String, dynamic>> get months =>
      user.collection(monthsCollection);

  CollectionReference<Map<String, dynamic>> get auditLog =>
      user.collection(auditCollection);

  DocumentReference<Map<String, dynamic>> income(String id) =>
      incomes.doc(id);

  DocumentReference<Map<String, dynamic>> expense(String id) =>
      expenses.doc(id);

  DocumentReference<Map<String, dynamic>> personalSpend(String id) =>
      personalSpends.doc(id);

  DocumentReference<Map<String, dynamic>> debt(String id) => debts.doc(id);

  DocumentReference<Map<String, dynamic>> goal(String id) => goals.doc(id);

  DocumentReference<Map<String, dynamic>> month(MonthKey key) =>
      months.doc(key.value);

  /// ★ Global agregat — dashboard shu hujjatni o'qiydi.
  DocumentReference<Map<String, dynamic>> get totals =>
      user.collection(metaCollection).doc('totals');

  /// 🩺 Reconciler hisoboti (klient yozmaydi — rules taqiqlaydi).
  DocumentReference<Map<String, dynamic>> get health =>
      user.collection(metaCollection).doc('health');

  DocumentReference<Map<String, dynamic>> get appSettings =>
      user.collection(settingsCollection).doc('app');

  DocumentReference<Map<String, dynamic>> get personalFundSettings =>
      user.collection(settingsCollection).doc('personalFund');

  DocumentReference<Map<String, dynamic>> get incomeRules =>
      user.collection(settingsCollection).doc('incomeRules');

  DocumentReference<Map<String, dynamic>> get reminders =>
      user.collection(settingsCollection).doc('reminders');

  // Katalog kolleksiyalari foydalanuvchi ostida to'g'ridan-to'g'ri turadi:
  // Firestore'da subkolleksiya faqat HUJJAT ostida bo'ladi, shuning uchun
  // ularni `settings/app` hujjatiga osib qo'yish sun'iy ierarxiya bo'lardi.
  CollectionReference<Map<String, dynamic>> get recurring =>
      user.collection('recurring');

  CollectionReference<Map<String, dynamic>> get limits =>
      user.collection('limits');

  CollectionReference<Map<String, dynamic>> get quickAdds =>
      user.collection('quickAdd');

  CollectionReference<Map<String, dynamic>> get categories =>
      user.collection('categories');
}
