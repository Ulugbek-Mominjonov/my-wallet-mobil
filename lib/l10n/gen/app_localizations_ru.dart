// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'My Wallet';

  @override
  String get tabHome => 'Сводка';

  @override
  String get tabTransactions => 'Операции';

  @override
  String get tabPayments => 'Платежи';

  @override
  String get tabWallet => 'Кошелёк';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get errorUnexpected => 'Непредвиденная ошибка. Попробуйте ещё раз.';

  @override
  String get errorNotFound => 'Страница не найдена';

  @override
  String get emptyTitle => 'Пока нет данных';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'Январь',
      '2': 'Февраль',
      '3': 'Март',
      '4': 'Апрель',
      '5': 'Май',
      '6': 'Июнь',
      '7': 'Июль',
      '8': 'Август',
      '9': 'Сентябрь',
      '10': 'Октябрь',
      '11': 'Ноябрь',
      '12': 'Декабрь',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String get notFoundMessage => 'Ссылка устарела или указана с ошибкой.';

  @override
  String get actionHome => 'На главную';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get addTitle => 'Новая операция';

  @override
  String get navAddLabel => 'Добавить операцию';

  @override
  String get syncStatusTitle => 'Синхронизация';

  @override
  String get syncSynced => 'Синхронизировано';

  @override
  String get syncSyncing => 'Отправка…';

  @override
  String syncPending(int count) {
    return 'Не отправлено изменений: $count';
  }

  @override
  String get syncOffline => 'Офлайн — отправим, когда появится сеть';

  @override
  String syncIssues(int count) {
    return 'Проблем: $count';
  }

  @override
  String get syncSignedOut => 'Нужно войти снова';

  @override
  String syncLastAt(String time) {
    return 'Последняя синхронизация: $time';
  }

  @override
  String get syncNever => 'Ещё не синхронизировано';

  @override
  String get syncNow => 'Синхронизировать';

  @override
  String get syncFullReload => 'Полная перезагрузка';

  @override
  String get syncFullReloadConfirm =>
      'Данные бюджета будут заново загружены с сервера. Неотправленные изменения сохранятся.';

  @override
  String get syncIssueConflict =>
      'Изменено на другом устройстве — показана версия сервера';

  @override
  String syncIssueRejected(String code) {
    return 'Сервер не принял ($code) — изменение отменено';
  }

  @override
  String get syncKeepMine => 'Оставить мою версию';

  @override
  String get syncDismiss => 'Понятно';

  @override
  String syncRecordKind(String table) {
    String _temp0 = intl.Intl.selectLogic(table, {
      'transactions': 'Операция',
      'planned_items': 'Платёж',
      'accounts': 'Счёт',
      'categories': 'Категория',
      'debts': 'Долг',
      'goals': 'Цель',
      'other': 'Запись',
    });
    return '$_temp0';
  }

  @override
  String get authTagline => 'Знайте, куда уходят ваши деньги';

  @override
  String get authGoogle => 'Войти через Google';

  @override
  String get authOr => 'или';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authSendCode => 'Получить код';

  @override
  String get authCodeTitle => 'Проверьте почту';

  @override
  String authCodeSent(String email, int length) {
    return 'Мы отправили $length-значный код на $email';
  }

  @override
  String get authCodeLabel => 'Код';

  @override
  String get authVerify => 'Войти';

  @override
  String get authResend => 'Отправить код ещё раз';

  @override
  String authResendIn(int seconds) {
    return 'Повторно — через $seconds с';
  }

  @override
  String get authChangeEmail => 'Другой email';

  @override
  String get authErrorInvalidEmail => 'Проверьте адрес email';

  @override
  String authErrorInvalidCode(int length) {
    return 'Введите $length-значный код';
  }

  @override
  String get authErrorCodeExpired => 'Неверный или устаревший код';

  @override
  String get authErrorRateLimit =>
      'Слишком много попыток — попробуйте чуть позже';

  @override
  String get authErrorGoogle =>
      'Не удалось войти через Google — войдите по email';

  @override
  String get errorOffline => 'Нет интернета — проверьте подключение';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutConfirm =>
      'Данные на устройстве будут удалены — при следующем входе они загрузятся с сервера.';

  @override
  String signOutUnsent(int count) {
    return 'Не отправлено на сервер изменений: $count — при выходе они пропадут.';
  }
}
