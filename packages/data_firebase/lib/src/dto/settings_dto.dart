import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

import 'converters.dart';

/// `settings/app`.
abstract final class AppSettingsDto {
  static Map<String, Object?> toFirestore(AppSettings settings) =>
      <String, Object?>{
        'locale': settings.locale,
        'themeMode': settings.themeMode,
        'currency': settings.currency,
        'timezone': settings.timezone,
        'personalCategory': settings.personalCategory,
        'personalRowName': settings.personalRowName,
        'updatedAt': Write.now,
      };

  static AppSettings fromMap(Map<String, dynamic> data) => AppSettings(
        locale: Read.text(data, 'locale', or: 'uz'),
        themeMode: Read.text(data, 'themeMode', or: 'system'),
        currency: Read.text(data, 'currency', or: 'UZS'),
        timezone: Read.text(data, 'timezone', or: 'Asia/Tashkent'),
        personalCategory: Read.text(
          data,
          'personalCategory',
          or: AppSettings.defaultPersonalCategory,
        ),
        personalRowName: Read.text(
          data,
          'personalRowName',
          or: AppSettings.defaultPersonalRowName,
        ),
      );
}

/// `settings/personalFund`.
abstract final class PersonalFundSettingsDto {
  static Map<String, Object?> toFirestore(PersonalFundSettings settings) =>
      <String, Object?>{
        'mode': settings.mode.wire,
        'value': settings.value,
        'method': settings.method.wire,
        'day': settings.day,
        'updatedAt': Write.now,
      };

  static PersonalFundSettings fromMap(Map<String, dynamic> data) =>
      PersonalFundSettings(
        mode: PersonalFundMode.fromWire(data['mode']),
        value: Read.integer(data, 'value', or: 10),
        method: PaymentMethod.fromWire(data['method']),
        day: Read.integer(data, 'day', or: 1),
      );
}

/// `settings/incomeRules`.
abstract final class IncomeRulesDto {
  static Map<String, Object?> toFirestore(IncomeRules rules) =>
      <String, Object?>{
        'rules': <Map<String, Object?>>[
          for (final rule in rules.rules)
            <String, Object?>{'type': rule.type, 'shift': rule.shift},
        ],
        'updatedAt': Write.now,
      };

  static IncomeRules fromMap(Map<String, dynamic> data) {
    final raw = Read.mapList(data, 'rules');
    if (raw.isEmpty) return IncomeRules.defaults;
    return IncomeRules(<IncomeRule>[
      for (final item in raw)
        IncomeRule(
          type: Read.text(item, 'type'),
          shift: Read.integer(item, 'shift'),
        ),
    ]);
  }
}

/// `settings/reminders`.
abstract final class ReminderSettingsDto {
  static Map<String, Object?> toFirestore(ReminderSettings settings) =>
      <String, Object?>{
        'pushEnabled': settings.pushEnabled,
        'telegramEnabled': settings.telegramEnabled,
        'email': settings.email,
        'daysAhead': settings.daysAhead,
        'hour': settings.hour,
        'monthlyEnabled': settings.monthlyEnabled,
        'reportDay': settings.reportDay,
        'updatedAt': Write.now,
      };

  static ReminderSettings fromMap(Map<String, dynamic> data) =>
      ReminderSettings(
        pushEnabled: Read.flag(data, 'pushEnabled', or: true),
        telegramEnabled: Read.flag(data, 'telegramEnabled'),
        email: Read.text(data, 'email'),
        daysAhead: Read.integer(data, 'daysAhead', or: 3).clamp(0, 30),
        hour: Read.integer(data, 'hour', or: 9).clamp(0, 23),
        monthlyEnabled: Read.flag(data, 'monthlyEnabled', or: true),
        reportDay: Read.integer(
          data,
          'reportDay',
          or: ReminderSettings.defaultReportDay,
        ).clamp(1, 28),
      );
}

/// `settings/app/recurring/{id}`.
abstract final class RecurringDto {
  static Map<String, Object?> toFirestore(RecurringExpense item) =>
      <String, Object?>{
        'name': item.name,
        'category': item.category,
        'amount': item.amount?.soum,
        'method': item.method.wire,
        'day': item.day,
        'autoPay': item.autoPay,
        'active': item.active,
        'debtId': item.debtId,
        'order': item.order,
        'updatedAt': Write.now,
      };

  static RecurringExpense fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return RecurringExpense(
      id: doc.id,
      name: Read.text(data, 'name'),
      category: Read.text(data, 'category', or: 'Boshqa'),
      method: PaymentMethod.fromWire(data['method']),
      day: Read.integer(data, 'day', or: 1).clamp(1, 31),
      amount: Read.optionalMoney(data, 'amount'),
      autoPay: Read.flag(data, 'autoPay'),
      active: Read.flag(data, 'active', or: true),
      debtId: Read.optionalText(data, 'debtId'),
      order: Read.integer(data, 'order'),
    );
  }
}

/// `settings/app/limits/{id}`.
abstract final class LimitDto {
  static Map<String, Object?> toFirestore(CategoryLimit item) =>
      <String, Object?>{
        'category': item.category,
        'monthlyLimit': item.monthlyLimit.soum,
        'updatedAt': Write.now,
      };

  static CategoryLimit fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return CategoryLimit(
      id: doc.id,
      category: Read.text(data, 'category'),
      monthlyLimit: Read.money(data, 'monthlyLimit'),
    );
  }
}

/// `settings/app/quickAdd/{id}`.
abstract final class QuickAddDto {
  static Map<String, Object?> toFirestore(QuickAdd item) => <String, Object?>{
        'name': item.name,
        'amount': item.amount.soum,
        'category': item.category,
        'method': item.method.wire,
        'order': item.order,
        'updatedAt': Write.now,
      };

  static QuickAdd fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return QuickAdd(
      id: doc.id,
      name: Read.text(data, 'name'),
      amount: Read.money(data, 'amount'),
      category: Read.text(data, 'category', or: 'Boshqa'),
      method: PaymentMethod.fromWire(data['method']),
      order: Read.integer(data, 'order'),
    );
  }
}

/// `settings/app/categories/{id}`.
abstract final class CategoryDto {
  static Map<String, Object?> toFirestore(CategoryDef item) =>
      <String, Object?>{
        'name': item.name,
        'kind': item.kind.wire,
        'icon': item.icon,
        'color': item.color,
        'order': item.order,
        'parentId': item.parentId,
        'archived': item.archived,
        'updatedAt': Write.now,
      };

  static CategoryDef fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return CategoryDef(
      id: doc.id,
      name: Read.text(data, 'name'),
      kind: CategoryKind.fromWire(data['kind']),
      icon: Read.text(data, 'icon'),
      color: Read.integer(data, 'color'),
      order: Read.integer(data, 'order'),
      parentId: Read.optionalText(data, 'parentId'),
      archived: Read.flag(data, 'archived'),
    );
  }
}
