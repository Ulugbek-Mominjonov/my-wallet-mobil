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

  @override
  String get startupLoading => 'Загружаем бюджет…';

  @override
  String get startupFailed => 'Не удалось загрузить данные';

  @override
  String get householdSetupTitle => 'Начните бюджет';

  @override
  String get householdSetupSubtitle =>
      'Создайте новый бюджет или присоединитесь к существующему по коду приглашения.';

  @override
  String get householdCreateTitle => 'Новый бюджет';

  @override
  String get householdNameLabel => 'Название бюджета';

  @override
  String get householdNameDefault => 'Мой бюджет';

  @override
  String get householdCreate => 'Создать';

  @override
  String get householdJoinTitle => 'Присоединиться по коду';

  @override
  String get householdCodeLabel => 'Код приглашения';

  @override
  String get householdJoin => 'Присоединиться';

  @override
  String get householdScan => 'Сканировать QR-код';

  @override
  String get householdScanTitle => 'QR-код приглашения';

  @override
  String get householdErrorName => 'Введите название бюджета';

  @override
  String get householdErrorCode => 'Код состоит из 8 символов';

  @override
  String get householdErrorNotFound => 'Такой код не найден';

  @override
  String get householdErrorUsed => 'Код уже использован';

  @override
  String get householdErrorExpired => 'Срок действия кода истёк (7 дней)';

  @override
  String get householdErrorMember => 'Вы уже участник этого бюджета';

  @override
  String get onboardingTitle => 'Настройка';

  @override
  String onboardingStep(int current, int total) {
    return 'Шаг $current/$total';
  }

  @override
  String get onboardingAccountsTitle => 'Счета и остаток';

  @override
  String get onboardingAccountsSubtitle =>
      'Введите текущий остаток — дальше всё считается от него.';

  @override
  String get onboardingIncomeTitle => 'График доходов';

  @override
  String get onboardingIncomeSubtitle =>
      'Какие доходы вы получаете, какого числа и к какому месяцу относятся.';

  @override
  String get onboardingRecurringTitle => 'Постоянные платежи';

  @override
  String get onboardingRecurringSubtitle =>
      'Ежемесячные платежи — каждый месяц попадают в план автоматически.';

  @override
  String get onboardingFundTitle => '👤 Личный фонд';

  @override
  String get onboardingFundSubtitle =>
      'Доля, которую вы каждый месяц откладываете на себя.';

  @override
  String get onboardingDoneTitle => 'Готово!';

  @override
  String get onboardingDoneSubtitle =>
      'Откроется текущий месяц и создадутся планы.';

  @override
  String get onboardingWaiting => 'Загружаем справочники…';

  @override
  String get onboardingFinish => 'Начать';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get actionNext => 'Далее';

  @override
  String get actionBack => 'Назад';

  @override
  String get fieldDay => 'День';

  @override
  String get fieldAmount => 'Сумма';

  @override
  String get fieldAccount => 'Счёт';

  @override
  String get monthThis => 'Этот месяц';

  @override
  String get monthPrevious => 'Прошлый месяц';

  @override
  String get fundPercentMode => 'Процент';

  @override
  String get fundFixedMode => 'Фиксированная сумма';

  @override
  String get fundPercent => 'Процент от дохода';

  @override
  String get fundSource => 'С какого счёта';

  @override
  String get autoPay => 'Автоплатёж';

  @override
  String onboardingSummary(int accounts, int incomes, int plans) {
    return 'Счетов: $accounts, видов дохода: $incomes, постоянных платежей: $plans';
  }

  @override
  String get updateRequiredTitle => 'Обновите приложение';

  @override
  String updateRequiredBody(String version) {
    return 'Нужна новая версия ($version) — обновите в Play Маркете.';
  }

  @override
  String get householdSwitch => 'Сменить бюджет';

  @override
  String get householdAdd => 'Новый бюджет или код приглашения';

  @override
  String get offlineBanner => 'Офлайн — изменения отправятся при подключении';

  @override
  String get menuSettings => 'Настройки';

  @override
  String get lockTitle => 'Блокировка приложения';

  @override
  String get lockEnterPin => 'Введите PIN-код';

  @override
  String get lockWrongPin => 'Неверный PIN-код';

  @override
  String get lockBiometrics => 'Биометрия';

  @override
  String get lockNewPin => 'Новый PIN-код';

  @override
  String get lockRepeatPin => 'Повторите PIN-код';

  @override
  String get lockMismatch => 'PIN-коды не совпадают';

  @override
  String get lockSetPin => 'Установить PIN-код';

  @override
  String get lockChangePin => 'Изменить PIN-код';

  @override
  String get lockDisable => 'Отключить блокировку';

  @override
  String get lockAuto => 'Автоблокировка';

  @override
  String lockAutoValue(int minutes) {
    return 'Через $minutes мин';
  }

  @override
  String get lockSecureScreen => 'Скрывать в списке приложений';

  @override
  String get lockForgot => 'Забыли PIN — выйти';

  @override
  String get privacyMode => 'Режим приватности';
}
