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
  String get actionCopy => 'Копировать';

  @override
  String get actionShare => 'Поделиться';

  @override
  String membersShareText(String code) {
    return 'Присоединяйтесь к бюджету в My Wallet. Код приглашения: $code';
  }

  @override
  String get actionClose => 'Закрыть';

  @override
  String get copied => 'Скопировано';

  @override
  String get roleOwner => 'Владелец';

  @override
  String get roleAdmin => 'Админ';

  @override
  String get roleMember => 'Участник';

  @override
  String get roleViewer => 'Наблюдатель';

  @override
  String get membersTitle => 'Участники';

  @override
  String get membersInvite => 'Пригласить';

  @override
  String get membersInviteHint => 'Передайте код или QR — действует 7 дней';

  @override
  String get membersYou => 'вы';

  @override
  String get membersRemove => 'Убрать из бюджета';

  @override
  String get membersLeave => 'Выйти из бюджета';

  @override
  String membersSetRole(String role) {
    return 'Роль: $role';
  }

  @override
  String membersActions(String name) {
    return '$name: действия';
  }

  @override
  String get membersOffline => 'Для списка участников нужен интернет';

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
  String get monthNext => 'Следующий месяц';

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

  @override
  String get kindExpense => 'Расход';

  @override
  String get kindIncome => 'Доход';

  @override
  String get kindTransfer => 'Перевод';

  @override
  String get fieldCategory => 'Категория';

  @override
  String get fieldPayee => 'Место / кому';

  @override
  String get fieldNote => 'Комментарий';

  @override
  String get fieldFxRate => 'Курс';

  @override
  String get fxRateMissing => 'На эту дату курса нет — введите курс вручную';

  @override
  String fieldToAmount(String currency) {
    return 'Сумма зачисления ($currency)';
  }

  @override
  String get fieldTo => 'Куда';

  @override
  String get dateToday => 'Сегодня';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String get dateChoose => 'Дата';

  @override
  String get categorySearch => 'Поиск категории';

  @override
  String get saved => 'Сохранено';

  @override
  String get errorMonthClosed => 'Месяц закрыт — запись невозможна';

  @override
  String get categoryNew => 'Новая категория';

  @override
  String get fieldTags => 'Теги';

  @override
  String get fieldDebt => 'Привязать к долгу';

  @override
  String get errorCategoryRequired => 'Выберите категорию';

  @override
  String get errorCategoryInvalid => 'Эту категорию нельзя выбрать';

  @override
  String get errorAccountRequired => 'Выберите счёт';

  @override
  String get errorTargetAccount => 'Выберите другой счёт';

  @override
  String get errorAmountRequired => 'Введите сумму';

  @override
  String get monthClosedConfirmTitle => 'Месяц закрыт';

  @override
  String get monthClosedConfirmBody =>
      'Операция попадёт в закрытый месяц. Всё равно записать?';

  @override
  String get actionRecord => 'Записать';

  @override
  String monthHintIncome(String month, String relation) {
    return '→ будет записано как доход за $month ($relation)';
  }

  @override
  String monthHintExpense(String month, String relation) {
    return '→ в бюджет за $month ($relation)';
  }

  @override
  String get monthRelationSame => 'этот месяц';

  @override
  String get monthRelationPrevious => 'прошлый месяц';

  @override
  String get monthRelationNext => 'следующий месяц';

  @override
  String get monthRelationManual => 'выбран вручную';

  @override
  String get monthQuestion => 'В бюджет какого месяца?';

  @override
  String get monthByDate => 'По дате';

  @override
  String get monthChoose => 'Выбрать';

  @override
  String quickSaved(String name, String amount) {
    return '$name — $amount записано';
  }

  @override
  String get actionUndo => 'Отменить';

  @override
  String get quickHint => 'Нажмите — запишется сразу, удерживайте — изменить';

  @override
  String get fundAllocationHint =>
      '👤 Это считается отчислением — уменьшает остаток месяца';

  @override
  String get fundReturnHint =>
      '👤 Возврат отчисления — увеличивает остаток месяца';

  @override
  String get fundSpendHint => '👤 Трата из фонда — не влияет на остаток месяца';

  @override
  String get errorCurrencyMismatch =>
      'У счетов разные валюты — такой перевод появится позже';

  @override
  String weekdayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'понедельник',
      '2': 'вторник',
      '3': 'среда',
      '4': 'четверг',
      '5': 'пятница',
      '6': 'суббота',
      '7': 'воскресенье',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String dayTitle(int day, String month, String weekday) {
    return '$day $month, $weekday';
  }

  @override
  String get transactionsEmpty => 'В этом месяце нет операций';

  @override
  String get transactionsEmptyFiltered => 'Нет операций по фильтру';

  @override
  String get searchHint => 'Место, комментарий или сумма';

  @override
  String get filterAll => 'Все';

  @override
  String get filterClear => 'Сбросить фильтр';

  @override
  String get monthClosedBanner => 'Месяц закрыт — изменения с подтверждением';

  @override
  String get deleted => 'Удалено';

  @override
  String get editTitle => 'Редактирование';

  @override
  String get receipt => 'Чек';

  @override
  String get receiptCamera => 'Камера';

  @override
  String get receiptGallery => 'Галерея';

  @override
  String get receiptScan => 'Сканировать чек';

  @override
  String get receiptScanTitle => 'QR-код чека';

  @override
  String get receiptTooLarge => 'Изображение слишком большое — выберите другое';

  @override
  String get receiptPending => 'Ожидает загрузки';

  @override
  String get dashBalance => 'Остаток';

  @override
  String get dashForecast => 'Прогноз остатка';

  @override
  String dashMonthEnd(String amount) {
    return 'К концу месяца ≈ $amount';
  }

  @override
  String dashPerDay(String amount) {
    return 'В день ≈ $amount';
  }

  @override
  String get dashSaved => 'Отложено';

  @override
  String get dashCard => 'Карта';

  @override
  String get dashCash => 'Наличные';

  @override
  String get dashPlan => 'Выполнение плана';

  @override
  String dashUnknown(int count) {
    return '+ $count шт. ?';
  }

  @override
  String get dashUpcoming => 'Ближайшие платежи';

  @override
  String get dashMarkPaid => 'Оплачено';

  @override
  String get dashCategories => 'Категории';

  @override
  String get dashMembers => 'По участникам';

  @override
  String get dashAttention => 'Обратите внимание';

  @override
  String insightSpike(String name, int percent, String average) {
    return '$name: на $percent% больше среднего за 3 месяца (в среднем $average)';
  }

  @override
  String insightSubscription(String payee, String amount, int months) {
    return '$payee — $amount, повторяется $months месяцев';
  }

  @override
  String get dashIncomeTypes => 'Виды дохода';

  @override
  String get dashFund => '👤 Личный фонд';

  @override
  String get dashSavings => '🏦 Накопления';

  @override
  String get dashThisMonth => 'Этот месяц';

  @override
  String get dashAllocated => 'Отчислено';

  @override
  String get dashSpent => 'Потрачено';

  @override
  String get dashDebts => 'Долги';

  @override
  String get dashIOwe => 'Я должен';

  @override
  String get dashOwedToMe => 'Мне должны';

  @override
  String get dashMonthly => 'В месяц';

  @override
  String get dashGoals => 'Цели';

  @override
  String get dashForecastTitle => 'Прогноз';

  @override
  String dashDays(int elapsed, int total) {
    return '$elapsed / $total дн.';
  }

  @override
  String get dashDailySpend => 'Расход в день';

  @override
  String get dashMonthEndSpend => 'Расход к концу месяца';

  @override
  String get dashExpectedIncome => 'Ожидаемый доход';

  @override
  String dashReceivedSoFar(String amount) {
    return 'пока поступило $amount';
  }

  @override
  String get dashNotOpened =>
      'Месяц ещё не открыт — постоянные платежи не в плане';

  @override
  String get dashOpenMonth => 'Открыть месяц';

  @override
  String dashOpenMonthBody(int count) {
    return 'Будет создано планов: $count';
  }

  @override
  String get dashClosed => 'Закрыт';

  @override
  String get dashEmpty => 'В этом месяце пока нет записей';

  @override
  String get dashEmptyHint => 'Нажмите «+», чтобы добавить первую операцию';

  @override
  String get fieldDate => 'Дата';

  @override
  String get payTabExpenses => 'Расходы';

  @override
  String get payTabIncome => 'Ожидаемые доходы';

  @override
  String get payUnpaid => 'Не оплачено';

  @override
  String get payIncomePending => 'Ожидается';

  @override
  String get paySectionOverdue => '⚠️ Просрочено';

  @override
  String get paySectionToday => '📌 Сегодня';

  @override
  String paySectionSoon(int days) {
    return '🗓 В ближайшие $days дн.';
  }

  @override
  String get paySectionLater => 'Позже';

  @override
  String get paySectionPaid => '✅ Оплачено';

  @override
  String get paySectionReceived => '✅ Поступило';

  @override
  String get paySectionSkipped => '⏭ Пропущено';

  @override
  String get payMarkReceived => 'Поступило';

  @override
  String get paySkip => 'Пропустить';

  @override
  String get payUnskip => 'Вернуть';

  @override
  String get paySkipped => 'Пропущено';

  @override
  String get payEditAmount => 'Сумма в этом месяце';

  @override
  String get payClose => 'Закрыть';

  @override
  String get payReopen => 'Открыть снова';

  @override
  String get payAmountVaries => 'Сумма меняется';

  @override
  String get payAmountRequired =>
      'У этого платежа нет суммы — введите, сколько вы заплатили';

  @override
  String get payPartialTitle => 'Частичная оплата';

  @override
  String payPartialBody(String amount) {
    return 'Оставшиеся $amount оплатите позже?';
  }

  @override
  String get payPartialLater => 'Позже';

  @override
  String get payAutoPay => 'Автоплатёж';

  @override
  String get payEmpty => 'В этом месяце нет планов';

  @override
  String get payEmptyHint =>
      'Откройте месяц — планы создадутся из регулярных платежей';

  @override
  String get payCalendar => 'Календарь';

  @override
  String get payList => 'Список';

  @override
  String get payDayEmpty => 'В этот день платежей нет';

  @override
  String get errorPlanPaid => 'Этот план уже оплачен';

  @override
  String get errorPlanSkipped => 'План пропущен';

  @override
  String get errorPlanNotFound => 'План не найден';

  @override
  String openMonthCreates(int count) {
    return 'Будет создано: $count';
  }

  @override
  String openMonthExisting(int count) {
    return 'Уже есть: $count';
  }

  @override
  String get openMonthNothing => 'Новых планов нет — все уже есть';

  @override
  String yearTitle(String year) {
    return '$year год';
  }

  @override
  String get yearTotal => 'ИТОГО';

  @override
  String get yearView => 'Годовой обзор';

  @override
  String get yearEmpty => 'В этом году нет записей';

  @override
  String get yearSummaryTitle => 'Итоги года';

  @override
  String yearSummaryMonths(int count) {
    return 'По $count месяцам с записями';
  }

  @override
  String get yearSummaryAvgExpense => 'Средний расход в месяц';

  @override
  String get yearSummaryBest => 'Лучший месяц';

  @override
  String get yearSummaryWorst => 'Худший месяц';

  @override
  String get categoryTrend => 'По месяцам';

  @override
  String get categoryTransactions => 'Показать операции';

  @override
  String monthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'Янв',
      '2': 'Фев',
      '3': 'Мар',
      '4': 'Апр',
      '5': 'Май',
      '6': 'Июн',
      '7': 'Июл',
      '8': 'Авг',
      '9': 'Сен',
      '10': 'Окт',
      '11': 'Ноя',
      '12': 'Дек',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String get shareReport => 'Поделиться отчётом';

  @override
  String get shareAction => 'Поделиться';

  @override
  String get shareFailed => 'Не удалось поделиться';

  @override
  String get shareTopExpenses => 'Крупнейшие расходы';

  @override
  String get fieldName => 'Название';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get errorInvalidName => 'Введите название (до 60 символов)';

  @override
  String get errorDuplicateName => 'Такое название уже есть';

  @override
  String get errorInvalidAmount => 'Неверная сумма';

  @override
  String get errorPaidBefore => 'Оплачено ранее не может превышать сумму';

  @override
  String get accountTypeCash => 'Наличные';

  @override
  String get accountTypeCard => 'Карта';

  @override
  String get accountTypeBank => 'Банковский счёт';

  @override
  String get accountTypeEwallet => 'Электронный кошелёк';

  @override
  String get accountTypeDeposit => 'Вклад';

  @override
  String get accountTypePersonalFund => 'Личный фонд';

  @override
  String get accountTypeOther => 'Другое';

  @override
  String get walletAccounts => 'Счета';

  @override
  String get walletTotalNoFund => 'Итого (без фонда)';

  @override
  String get walletTotalBase => 'Итого (в основной валюте)';

  @override
  String get walletNegativeCash =>
      'Остаток наличных отрицательный — проверьте записи';

  @override
  String get walletDebts => '💳 Долги';

  @override
  String get walletGoals => '🎯 Цели';

  @override
  String get walletLimits => '📊 Лимиты';

  @override
  String get fundAllTime => 'За всё время';

  @override
  String get fundAddSpend => 'Добавить расход';

  @override
  String get fundSpends => 'История расходов';

  @override
  String get fundAllocation => 'Отчисление в этом месяце';

  @override
  String fundAllocationLive(String amount, String percent) {
    return 'От текущего дохода: $amount ($percent%)';
  }

  @override
  String get fundAllocationNone => 'Плана отчисления в этом месяце нет';

  @override
  String get fundMonths => 'По месяцам';

  @override
  String get savingsTotal => 'Накоплено';

  @override
  String get savingsAvg => 'В среднем в месяц';

  @override
  String savingsMonthsCount(int count) {
    return '$count мес.';
  }

  @override
  String get savingsAccumulated => 'Накоплено';

  @override
  String get savingsNote =>
      'Накопления — показатель. Где деньги физически, показывают «Счета».';

  @override
  String get debtNet => '⚖️ Чистая позиция';

  @override
  String get debtMonthly => 'Ежемесячные обязательства';

  @override
  String get debtPaidThisMonth => 'Оплачено в этом месяце';

  @override
  String get debtStatusPaying => 'Погашается';

  @override
  String get debtStatusPending => 'Ожидается';

  @override
  String get debtStatusUnlinked => 'Не привязан';

  @override
  String get debtStatusClosed => 'Закрыт';

  @override
  String debtRemaining(String amount) {
    return 'Осталось: $amount';
  }

  @override
  String debtEnds(String month) {
    return 'Закончится: $month';
  }

  @override
  String debtPending(String amount) {
    return 'Ожидается: $amount';
  }

  @override
  String get debtAdd => 'Добавить долг';

  @override
  String get debtEdit => 'Изменить долг';

  @override
  String get debtTotal => 'Общая сумма';

  @override
  String get debtPaidBefore => 'Оплачено ранее';

  @override
  String get debtMonthlyPayment => 'Ежемесячный платёж';

  @override
  String get debtDueDate => 'Срок';

  @override
  String get debtArchive => 'В архив';

  @override
  String get debtUnarchive => 'Из архива';

  @override
  String get debtArchived => 'Архив';

  @override
  String get debtPayments => 'Связанные платежи';

  @override
  String get debtNoPayments => 'Платежей пока нет';

  @override
  String get debtsEmpty => 'Долгов нет';

  @override
  String get goalAdd => 'Добавить цель';

  @override
  String get goalEdit => 'Изменить цель';

  @override
  String get goalTarget => 'Нужная сумма';

  @override
  String get goalSaved => 'Накоплено';

  @override
  String get goalMonthly => 'Отчисление в месяц';

  @override
  String get goalDeadline => 'Срок (месяц)';

  @override
  String get goalAccount => 'Привязать к счёту';

  @override
  String get goalAccountNone => 'Не привязана (вручную)';

  @override
  String goalPerMonth(String amount) {
    return '$amount в месяц';
  }

  @override
  String goalPerMonthAvg(String amount) {
    return '$amount в месяц (в среднем)';
  }

  @override
  String goalEta(int months, String month) {
    return '$months мес. ($month)';
  }

  @override
  String get goalOnTrack => '✅ Успевает';

  @override
  String get goalOffTrack => '⚠️ Не успевает';

  @override
  String get goalReached => '🎉 Собрано';

  @override
  String goalCongrats(String name) {
    return 'Поздравляем! Цель «$name» собрана';
  }

  @override
  String get goalThanks => 'Спасибо';

  @override
  String goalDeleteConfirm(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get goalsEmpty => 'Целей нет';

  @override
  String get goalNoForecast => 'Укажите отчисление в месяц для прогноза';

  @override
  String get limitSet => 'Установить лимит';

  @override
  String get limitNone => 'Без лимита';

  @override
  String get limitRemove => 'Убрать лимит';

  @override
  String get limitsReadOnly =>
      'Лимиты меняют только владелец или администратор';

  @override
  String get limitMonthly => 'Месячный лимит';

  @override
  String get limitRollover => 'Переносить остаток на следующий месяц';

  @override
  String get limitRolloverNegative => 'Вычитать перерасход';

  @override
  String limitCarry(String amount) {
    return 'с прошлого месяца $amount';
  }

  @override
  String get onboardingNotifyTitle => '🔔 Напоминания';

  @override
  String get onboardingNotifyBody =>
      'Напомним о днях платежей, лимитах и месячном отчёте';

  @override
  String get onboardingNotifyAllow => 'Включить';

  @override
  String get onboardingNotifyOn => 'Включено';

  @override
  String get onboardingNotifyDenied =>
      'Не разрешено — можно включить позже в настройках';

  @override
  String get reminderTitle => '📌 Сегодня день платежа';

  @override
  String reminderBody(String name, String amount) {
    return '$name — $amount';
  }

  @override
  String reminderBodyUnknown(String name) {
    return '$name — сумма меняется';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get notifTitle => 'Уведомления';

  @override
  String get notifChannels => 'Каналы';

  @override
  String get notifPush => 'Push-уведомления';

  @override
  String get notifTelegram => 'Telegram';

  @override
  String get notifEmail => 'Email';

  @override
  String get notifSchedule => 'Напоминания';

  @override
  String get notifReminderHour => 'Время напоминания';

  @override
  String get notifDaysAhead => 'За сколько дней';

  @override
  String notifDays(int days) {
    return '$days дн.';
  }

  @override
  String get notifMonthlyReport => 'Месячный отчёт';

  @override
  String get notifReportDay => 'День отчёта';

  @override
  String get notifLimitAlerts => 'Предупреждения о лимитах';

  @override
  String get notifIncomeMissing => 'Напоминание о задержке дохода';

  @override
  String get notifTelegramLinked => 'Подключён';

  @override
  String get notifTelegramNotLinked => 'Не подключён';

  @override
  String get notifTelegramLink => 'Подключить';

  @override
  String get notifTelegramUnlink => 'Отключить';

  @override
  String get notifTest => 'Отправить тестовое сообщение';

  @override
  String get notifQueued => 'отправлено';

  @override
  String get notifReasonDisabled => 'выключено в настройках';

  @override
  String get notifReasonNoDevice => 'нет зарегистрированного устройства';

  @override
  String get notifReasonNotLinked => 'не подключено';

  @override
  String get notifReasonNotConfigured => 'не настроено на сервере';

  @override
  String get notifPermission => 'Разрешение устройства';

  @override
  String get notifPermissionAllow => 'Разрешить';

  @override
  String get notifOffline => 'Для настроек нужен интернет';

  @override
  String get settingsProfile => 'Профиль';

  @override
  String get settingsHousehold => 'Бюджет';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageSystem => 'Язык устройства';

  @override
  String get settingsSecurity => 'Безопасность';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsExport => 'Экспорт (JSON)';

  @override
  String get settingsExportText => 'Экспорт My Wallet';

  @override
  String get settingsExportFailed => 'Не удалось экспортировать';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountBody =>
      'Бюджеты, где вы единственный участник, и их данные будут удалены, из остальных вы выйдете. Это нельзя отменить.';

  @override
  String deleteAccountConfirm(String word) {
    return 'Введите «$word» для подтверждения';
  }

  @override
  String get deleteAccountWord => 'УДАЛИТЬ';

  @override
  String get deleteAccountLastOwner =>
      'Вы единственный владелец бюджета с другими участниками — сначала передайте владение';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get settingsLicenses => 'Лицензии';

  @override
  String get amountHidden => 'Сумма скрыта';

  @override
  String get statusOverdue => 'Просрочено';

  @override
  String get statusPartial => 'Оплачено частично';

  @override
  String get statusPaid => 'Оплачено';

  @override
  String get statusSkipped => 'Пропущено';

  @override
  String get statusPending => 'Ожидается';
}
