import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/reports/domain/receipt.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Tanlangan oy uchun chek: amallar ro'yxati va oy oxiridagi qoldiqlar.
/// Hammasi lokal bazadan — oflaynda ham ishlaydi.
final FutureProviderFamily<Receipt?, MonthKey> receiptProvider =
    FutureProvider.family((ref, month) async {
      final householdId = ref.watch(currentHouseholdIdProvider);
      final startup = ref.watch(startupProvider);
      if (householdId == null || startup is! StartupReady) return null;
      final db = ref.watch(appDatabaseProvider);

      final entries = await db.reportDao.monthEntries(
        householdId,
        month,
        base: startup.currency,
      );
      // Qoldiq oy oxiriga ko'ra kesiladi — serverdagi hisobot bilan bir xil.
      final balances = await db.ledgerDao.accountBalances(
        householdId,
        asOf: month.lastDay.toString(),
      );
      final accounts =
          await (db.select(db.accounts)..where(
                (a) =>
                    a.householdId.equals(householdId) &
                    a.deletedAt.isNull() &
                    a.archivedAt.isNull(),
              ))
              .get();

      return Receipt(
        household: startup.household.name,
        month: month,
        entries: entries,
        balances: {
          for (final account in accounts) account.name: ?balances[account.id],
        },
        base: startup.currency,
      );
    });
