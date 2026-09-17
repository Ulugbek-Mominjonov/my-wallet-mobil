import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

import '../dto/aggregate_dto.dart';
import '../dto/converters.dart';
import '../dto/entry_dto.dart';
import '../dto/settings_dto.dart';
import '../refs.dart';

/// ★ §5.2 — domen buyrug'ini BITTA `WriteBatch` ga aylantiradi.
///
/// Nega `runTransaction` emas:
/// * tranzaksiya serverga murojaat qiladi — AVIAREJIMDA ISHLAMAYDI;
/// * `batch` + `increment` esa lokal keshga darhol qo'llanadi va tarmoq
///   paydo bo'lganda o'zi sinxronlanadi;
/// * `increment` kommutativ — ikki qurilma bir vaqtda yozsa ham qiymat
///   yo'qolmaydi.
final class FirestoreBudgetWriter implements BudgetWriter {
  const FirestoreBudgetWriter({
    required this.refs,
    this.onSyncError,
    this.awaitServer = false,
  });

  final FirestoreRefs refs;

  /// Sinxronlash xatosi — yutib yuborilmaydi, chaqiruvchiga xabar beriladi.
  final void Function(Object error, StackTrace stackTrace)? onSyncError;

  /// `true` bo'lsa server tasdig'i kutiladi (test va serverdagi cron uchun).
  final bool awaitServer;

  @override
  Future<void> commit(WriteCommand command) async {
    if (command.isEmpty) return;

    final batch = refs.db.batch();
    for (final mutation in command.mutations) {
      _applyMutation(batch, mutation);
    }
    _applyDelta(batch, command.delta);

    final pending = batch.commit();
    if (awaitServer) {
      await pending;
      return;
    }
    // Offline'da `commit()` Future'i faqat server tasdig'idan keyin
    // bajariladi. UI ni bloklamaslik uchun kutmaymiz — lokal kesh
    // allaqachon yangilangan, qoldiq ekranda DARHOL o'zgaradi.
    unawaited(
      pending.catchError((Object error, StackTrace stackTrace) {
        onSyncError?.call(error, stackTrace);
      }),
    );
  }

  void _applyMutation(WriteBatch batch, DocMutation mutation) {
    switch (mutation) {
      case UpsertIncome(:final income):
        batch.set(
          refs.income(income.id),
          IncomeDto.toFirestore(income),
          SetOptions(merge: true),
        );
      case DeleteIncome(:final id):
        batch.delete(refs.income(id));
      case UpsertExpense(:final expense):
        batch.set(
          refs.expense(expense.id),
          ExpenseDto.toFirestore(expense),
          SetOptions(merge: true),
        );
      case DeleteExpense(:final id):
        batch.delete(refs.expense(id));
      case UpsertPersonalSpend(:final spend):
        batch.set(
          refs.personalSpend(spend.id),
          PersonalSpendDto.toFirestore(spend),
          SetOptions(merge: true),
        );
      case DeletePersonalSpend(:final id):
        batch.delete(refs.personalSpend(id));
      case UpsertDebt(:final debt, :final includeCounters):
        batch.set(
          refs.debt(debt.id),
          DebtDto.toFirestore(debt, includeCounters: includeCounters),
          SetOptions(merge: true),
        );
      case DeleteDebt(:final id):
        batch.delete(refs.debt(id));
      case UpsertGoal(:final goal):
        batch.set(
          refs.goal(goal.id),
          GoalDto.toFirestore(goal),
          SetOptions(merge: true),
        );
      case DeleteGoal(:final id):
        batch.delete(refs.goal(id));
      case UpsertRecurring(:final recurring):
        batch.set(
          refs.recurring.doc(recurring.id),
          RecurringDto.toFirestore(recurring),
          SetOptions(merge: true),
        );
      case DeleteRecurring(:final id):
        batch.delete(refs.recurring.doc(id));
      case UpsertLimit(:final limit):
        batch.set(
          refs.limits.doc(limit.id),
          LimitDto.toFirestore(limit),
          SetOptions(merge: true),
        );
      case DeleteLimit(:final id):
        batch.delete(refs.limits.doc(id));
      case UpsertQuickAdd(:final quickAdd):
        batch.set(
          refs.quickAdds.doc(quickAdd.id),
          QuickAddDto.toFirestore(quickAdd),
          SetOptions(merge: true),
        );
      case DeleteQuickAdd(:final id):
        batch.delete(refs.quickAdds.doc(id));
      case SaveSettings(:final settings):
        batch
          ..set(
            refs.appSettings,
            AppSettingsDto.toFirestore(settings.app),
            SetOptions(merge: true),
          )
          ..set(
            refs.personalFundSettings,
            PersonalFundSettingsDto.toFirestore(settings.personalFund),
            SetOptions(merge: true),
          )
          ..set(
            refs.incomeRules,
            IncomeRulesDto.toFirestore(settings.incomeRules),
            SetOptions(merge: true),
          )
          ..set(
            refs.reminders,
            ReminderSettingsDto.toFirestore(settings.reminders),
            SetOptions(merge: true),
          );
      case SetMonthClosed(:final monthKey, :final closed):
        batch.set(
          refs.month(monthKey),
          <String, Object?>{
            'monthKey': monthKey.value,
            'closed': closed,
            'updatedAt': Write.now,
          },
          SetOptions(merge: true),
        );
      case OverwriteMonthAggregate(:final summary):
        // Reconciler MUTLAQ qiymat yozadi — merge emas, to'liq almashtirish.
        batch.set(
          refs.month(summary.monthKey),
          MonthSummaryDto.toFirestore(summary),
        );
      case OverwriteTotals(:final totals):
        batch.set(refs.totals, TotalsDto.toFirestore(totals));
    }
  }

  void _applyDelta(WriteBatch batch, AggregateDelta delta) {
    for (final entry in delta.months.entries) {
      batch.set(
        refs.month(entry.key),
        <String, Object?>{
          ...Write.increments(entry.value.toIncrements()),
          // Hujjat hali yo'q bo'lsa `merge` uni o'zi yaratadi.
          'monthKey': entry.key.value,
          'updatedAt': Write.now,
        },
        SetOptions(merge: true),
      );
    }

    if (!delta.totals.isEmpty) {
      batch.set(
        refs.totals,
        <String, Object?>{
          ...Write.increments(delta.totals.toIncrements()),
          'updatedAt': Write.now,
        },
        SetOptions(merge: true),
      );
    }

    for (final entry in delta.debts.entries) {
      batch.set(
        refs.debt(entry.key),
        <String, Object?>{
          ...Write.increments(entry.value.toIncrements()),
          'updatedAt': Write.now,
        },
        SetOptions(merge: true),
      );
    }
  }
}
