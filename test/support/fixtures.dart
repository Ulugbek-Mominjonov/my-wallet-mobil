import 'dart:convert';
import 'dart:io';

import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:wallet_domain/testing.dart';

// Golden fixture'lar (contracts/fixtures — admin bilan umumiy): holatni
// lokal bazaga yozish va holatlar ro'yxati.

/// Golden fixture holati → lokal baza (repository yozadigan ko'rinishda).
Future<void> storeFixture(AppDatabase db, FixtureLedger ledger) =>
    db.batch((batch) {
      batch
        ..insert(db.households, ledger.household.toRow())
        ..insertAll(db.accounts, [
          for (final a in ledger.accounts.values) a.toCompanion(),
        ])
        ..insertAll(db.categories, [
          for (final c in ledger.categories.values) c.toCompanion(),
        ])
        ..insertAll(db.exchangeRates, [
          for (final row in ledger.rateRows)
            ExchangeRatesCompanion.insert(
              currency: row.currency.code,
              rateDate: row.date.toString(),
              rateToBase: row.rate.toString(),
            ),
        ])
        ..insertAll(db.categoryLimits, [
          for (final l in ledger.limits) l.toCompanion(),
        ])
        ..insertAll(db.goals, [for (final g in ledger.goals) g.toCompanion()])
        ..insertAll(db.debts, [
          for (final d in ledger.debts.values) d.toCompanion(),
        ])
        ..insertAll(db.plannedItems, [
          for (final p in ledger.plans.values) p.toCompanion(),
        ])
        ..insertAll(db.transactions, [
          for (final t in ledger.transactions) t.toCompanion(),
        ]);
    });

List<Map<String, Object?>> fixtureCases() {
  final files =
      Directory('contracts/fixtures')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final file in files)
      for (final c
          in ((jsonDecode(file.readAsStringSync())
                      as Map<String, Object?>)['cases']!
                  as List<Object?>)
              .cast<Map<String, Object?>>())
        {...c, 'file': file.uri.pathSegments.last},
  ];
}
