import '../entities/settings.dart';
import '../value_objects/month_key.dart';

/// §2.1–2.2 — yozuv qaysi oy byudjetiga tegishli.
///
/// Bu ilovaning eng "sehrli" qoidasi: 1-sentabrda olingan oylik —
/// AVGUST oyining puli. Sheets'dagi `daromadOyi_` va `xarajatOyi_`
/// funksiyalarining aynan o'zi.
abstract final class MonthAttribution {
  /// Daromad: olingan sana oyidan qoidadagi siljish qadar suriladi.
  ///
  /// `tegishliOy = monthOf(olinganSana).shift(qoida[turi])`
  static MonthKey forIncome({
    required DateTime paidAt,
    required String type,
    required IncomeRules rules,
  }) =>
      MonthKey.of(paidAt).shift(rules.shiftFor(type));

  /// Xarajat: qo'lda ko'rsatilgan oy ustun, aks holda to'lov sanasidan.
  ///
  /// `tegishliOy = qo'ldaOy ?? monthOf(to'lovSanasi)`
  static MonthKey forExpense({
    required DateTime dueDate,
    MonthKey? manualMonth,
  }) =>
      manualMonth ?? MonthKey.of(dueDate);

  /// Shaxsiy fond sarfi — har doim sarf sanasining oyi.
  static MonthKey forPersonalSpend(DateTime spentAt) => MonthKey.of(spentAt);
}
