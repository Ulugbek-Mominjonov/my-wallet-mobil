/// Oylik byudjet — domen qatlami.
///
/// Bu paketda Flutter ham, Firebase ham YO'Q. Shu sababli:
///
/// * barcha biznes qoidalari testda soniyalar ichida tekshiriladi;
/// * backend almashtirilsa (Supabase, PostgreSQL) faqat `data_*` paketi
///   qayta yoziladi;
/// * bir xil mantiq TypeScript'ga ko'chirilib (`packages/calc-ts`), umumiy
///   fixture'lar bilan solishtiriladi.
library;

export 'src/calc/debt_calc.dart';
export 'src/calc/delta_calc.dart';
export 'src/calc/forecast_calc.dart';
export 'src/calc/goal_calc.dart';
export 'src/calc/limit_calc.dart';
export 'src/calc/month_attribution.dart';
export 'src/calc/month_open_calc.dart';
export 'src/calc/month_summary_calc.dart';
export 'src/calc/payment_status_calc.dart';
export 'src/calc/personal_fund_calc.dart';
export 'src/calc/reconcile_calc.dart';
export 'src/calc/reminder_calc.dart';
export 'src/calc/savings_calc.dart';
export 'src/entities/catalog.dart';
export 'src/entities/debt.dart';
export 'src/entities/entity_support.dart';
export 'src/entities/expense.dart';
export 'src/entities/goal.dart';
export 'src/entities/income.dart';
export 'src/entities/month_summary.dart';
export 'src/entities/overall_totals.dart';
export 'src/entities/personal_spend.dart';
export 'src/entities/settings.dart';
export 'src/repositories/clock.dart';
export 'src/repositories/errors.dart';
export 'src/repositories/id_generator.dart';
export 'src/repositories/repositories.dart';
export 'src/repositories/write_command.dart';
export 'src/usecases/batch_chunker.dart';
export 'src/usecases/catalog_usecases.dart';
export 'src/usecases/debt_goal_usecases.dart';
export 'src/usecases/expense_usecases.dart';
export 'src/usecases/income_usecases.dart';
export 'src/usecases/maintenance_usecases.dart';
export 'src/usecases/month_usecases.dart';
export 'src/usecases/personal_fund_usecases.dart';
export 'src/usecases/validation.dart';
export 'src/value_objects/day.dart';
export 'src/value_objects/enums.dart';
export 'src/value_objects/money.dart';
export 'src/value_objects/month_key.dart';
export 'src/value_objects/name_key.dart';
