import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_firebase/data_firebase.dart';
import 'package:domain/domain.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_log.dart';

/// ★ Barcha bog'liqliklar SHU YERDA ulanadi.
///
/// Ekranlar Firebase'ni umuman ko'rmaydi: ular faqat domen interfeyslari
/// va usecase'lar bilan ishlaydi. Shu sababli backend almashtirilsa
/// (§15) faqat shu fayl va `data_*` paketi o'zgaradi.

// ───────────────────────── Firebase ─────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authStateProvider).value,
);

/// Faqat kirgan foydalanuvchi uchun; `AuthGate` ostida chaqiriladi.
final uidProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw StateError('uidProvider faqat kirgan foydalanuvchi uchun');
  }
  return user.uid;
});

final refsProvider = Provider<FirestoreRefs>(
  (ref) => FirestoreRefs(
    db: ref.watch(firestoreProvider),
    uid: ref.watch(uidProvider),
  ),
);

// ───────────────────────── Portlar ─────────────────────────

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final idGeneratorProvider = Provider<IdGenerator>(
  (ref) => FirestoreIdGenerator(ref.watch(firestoreProvider)),
);

final writerProvider = Provider<BudgetWriter>(
  (ref) => FirestoreBudgetWriter(
    refs: ref.watch(refsProvider),
    onSyncError: (error, stackTrace) =>
        AppLog.error('Sinxronlash xatosi', error, stackTrace),
  ),
);

// ───────────────────── Repozitoriylar ─────────────────────

final monthRepositoryProvider = Provider<MonthRepository>(
  (ref) => FirestoreMonthRepository(ref.watch(refsProvider)),
);

final totalsRepositoryProvider = Provider<TotalsRepository>(
  (ref) => FirestoreTotalsRepository(ref.watch(refsProvider)),
);

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => FirestoreExpenseRepository(ref.watch(refsProvider)),
);

final incomeRepositoryProvider = Provider<IncomeRepository>(
  (ref) => FirestoreIncomeRepository(ref.watch(refsProvider)),
);

final personalSpendRepositoryProvider = Provider<PersonalSpendRepository>(
  (ref) => FirestorePersonalSpendRepository(ref.watch(refsProvider)),
);

final debtRepositoryProvider = Provider<DebtRepository>(
  (ref) => FirestoreDebtRepository(ref.watch(refsProvider)),
);

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => FirestoreGoalRepository(ref.watch(refsProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => FirestoreSettingsRepository(ref.watch(refsProvider)),
);

final healthRepositoryProvider = Provider<HealthRepository>(
  (ref) => FirestoreHealthRepository(ref.watch(refsProvider)),
);

// ───────────────────────── Sozlamalar ─────────────────────────

final settingsStreamProvider = StreamProvider<BudgetSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Sozlamalar hali yuklanmagan bo'lsa standart qiymatlar ishlatiladi —
/// ekran hech qachon "bo'sh" holatda qotib qolmaydi.
final settingsProvider = Provider<BudgetSettings>(
  (ref) => ref.watch(settingsStreamProvider).value ?? const BudgetSettings(),
);

final personalCategoryKeyProvider = Provider<String>(
  (ref) => ref.watch(settingsProvider).app.personalCategoryKey,
);

final incomeRulesProvider = Provider<IncomeRules>(
  (ref) => ref.watch(settingsProvider).incomeRules,
);

// ───────────────────────── Usecase'lar ─────────────────────────

final addIncomeProvider = Provider<AddIncome>(
  (ref) => AddIncome(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final editIncomeProvider = Provider<EditIncome>(
  (ref) => EditIncome(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
  ),
);

final removeIncomeProvider = Provider<RemoveIncome>(
  (ref) => RemoveIncome(ref.watch(writerProvider)),
);

final addExpenseProvider = Provider<AddExpense>(
  (ref) => AddExpense(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
    personalCategoryKey: ref.watch(personalCategoryKeyProvider),
  ),
);

final editExpenseProvider = Provider<EditExpense>(
  (ref) => EditExpense(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
    personalCategoryKey: ref.watch(personalCategoryKeyProvider),
  ),
);

final removeExpenseProvider = Provider<RemoveExpense>(
  (ref) => RemoveExpense(
    writer: ref.watch(writerProvider),
    personalCategoryKey: ref.watch(personalCategoryKeyProvider),
  ),
);

final markPaidProvider = Provider<MarkExpensePaid>(
  (ref) => MarkExpensePaid(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
    personalCategoryKey: ref.watch(personalCategoryKeyProvider),
  ),
);

final addPersonalSpendProvider = Provider<AddPersonalSpend>(
  (ref) => AddPersonalSpend(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final removePersonalSpendProvider = Provider<RemovePersonalSpend>(
  (ref) => RemovePersonalSpend(ref.watch(writerProvider)),
);

final saveDebtProvider = Provider<SaveDebt>(
  (ref) => SaveDebt(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final removeDebtProvider = Provider<RemoveDebt>(
  (ref) => RemoveDebt(ref.watch(writerProvider)),
);

final saveGoalProvider = Provider<SaveGoal>(
  (ref) => SaveGoal(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final removeGoalProvider = Provider<RemoveGoal>(
  (ref) => RemoveGoal(ref.watch(writerProvider)),
);

final openMonthProvider = Provider<OpenMonth>(
  (ref) => OpenMonth(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
    expenses: ref.watch(expenseRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
    months: ref.watch(monthRepositoryProvider),
    personalCategoryKey: ref.watch(personalCategoryKeyProvider),
  ),
);

final setMonthLockProvider = Provider<SetMonthLock>(
  (ref) => SetMonthLock(ref.watch(writerProvider)),
);

final recalcMonthKeysProvider = Provider<RecalcMonthKeys>(
  (ref) => RecalcMonthKeys(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
  ),
);

final paymentSweepProvider = Provider<RunPaymentSweep>(
  (ref) => RunPaymentSweep(
    writer: ref.watch(writerProvider),
    clock: ref.watch(clockProvider),
    personalCategoryKey: ref.watch(personalCategoryKeyProvider),
  ),
);

final reconcileMonthProvider = Provider<ReconcileMonth>(
  (ref) => ReconcileMonth(
    writer: ref.watch(writerProvider),
    personalCategoryKey: ref.watch(personalCategoryKeyProvider),
  ),
);

// ───────────────────── Katalog usecase'lari ─────────────────────

final saveRecurringProvider = Provider<SaveRecurring>(
  (ref) => SaveRecurring(
    writer: ref.watch(writerProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final saveLimitProvider = Provider<SaveLimit>(
  (ref) => SaveLimit(
    writer: ref.watch(writerProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final saveQuickAddProvider = Provider<SaveQuickAdd>(
  (ref) => SaveQuickAdd(
    writer: ref.watch(writerProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final removeCatalogItemProvider = Provider<RemoveCatalogItem>(
  (ref) => RemoveCatalogItem(ref.watch(writerProvider)),
);

final saveSettingsProvider = Provider<SaveBudgetSettings>(
  (ref) => SaveBudgetSettings(ref.watch(writerProvider)),
);
