import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/features/transactions/application/transaction_list_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_reports.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// "Hamyon" (E18): hisoblar (qoldiq, fondsiz jami, manfiy naqd — BR-025) va
/// bo'limlar — 👤 fond, 🏦 jamg'arma, 💳 qarzlar, 🎯 maqsadlar, 📊 limitlar.
/// Fond va jamg'arma alohida kartalarda, hech qayerda qo'shilmaydi (BR-005).
class WalletScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final accounts = ref.watch(accountsReportProvider).value;
    final savings = ref.watch(savingsReportProvider).value;
    final debts = ref.watch(debtsReportProvider).value;
    final goals = ref.watch(goalsReportProvider).value;
    if (accounts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final fund = accounts.fund;
    return ListView(
      // Pastdagi ＋ tugmasi oxirgi qatorni yopmasin.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        96,
      ),
      children: [
        _AccountsCard(report: accounts),
        const SizedBox(height: AppSpacing.md),
        _SectionTile(
          title: l10n.dashFund,
          amount: fund?.balance,
          onTap: () => context.push('/wallet/fund'),
        ),
        _SectionTile(
          title: l10n.dashSavings,
          amount: savings?.totals.totalBalance,
          onTap: () => context.push('/wallet/savings'),
        ),
        _SectionTile(
          title: l10n.walletDebts,
          amount: debts?.totals.net,
          tone: MoneyTone.auto,
          onTap: () => context.push('/wallet/debts'),
        ),
        _SectionTile(
          title: l10n.walletGoals,
          subtitle: goals == null || goals.lines.isEmpty
              ? null
              : '${goals.lines.where((g) => g.progress.isReached).length}'
                    ' / ${goals.lines.length}',
          onTap: () => context.push('/wallet/goals'),
        ),
        _SectionTile(
          title: l10n.walletLimits,
          onTap: () => context.push('/wallet/limits'),
        ),
      ],
    );
  }
}

/// BR-020..025: hisoblar turi bo'yicha; bosilsa — shu hisob harakatlari.
class _AccountsCard extends ConsumerWidget {
  const new({required this.report});

  final AccountsReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    void openAccount(String accountId) {
      ref
          .read(transactionListProvider.notifier)
          .setFilter(TransactionFilter(accountId: accountId));
      context.go('/transactions');
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.walletAccounts,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(l10n.kindTransfer),
                  onPressed: () => context.push('/add?kind=transfer'),
                ),
              ],
            ),
          ),
          if (report.negativeCash.isNotEmpty)
            ListTile(
              leading: Icon(
                Icons.warning_amber,
                color: context.appColors.expense,
              ),
              title: Text(l10n.walletNegativeCash),
            ),
          for (final (:account, :balance) in report.lines)
            ListTile(
              leading: Icon(accountTypeIcon(account.type)),
              title: Text(account.name),
              subtitle: Text(accountTypeLabel(l10n, account.type)),
              trailing: MoneyText(
                balance.minor,
                currency: balance.currency.code,
                tone: balance.isNegative
                    ? MoneyTone.expense
                    : MoneyTone.neutral,
              ),
              onTap: () => openAccount(account.id),
            ),
          const Divider(),
          for (final MapEntry(key: currency, value: total)
              in report.totals.entries)
            ListTile(
              dense: true,
              title: Text(
                l10n.walletTotalNoFund,
                style: theme.textTheme.titleSmall,
              ),
              trailing: MoneyText(
                total.minor,
                currency: currency.code,
                style: theme.textTheme.titleSmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const new({
    required this.title,
    required this.onTap,
    this.amount,
    this.subtitle,
    this.tone = MoneyTone.neutral,
  });

  final String title;
  final VoidCallback onTap;
  final Money? amount;
  final String? subtitle;
  final MoneyTone tone;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (amount case final amount?)
            MoneyText(amount.minor, currency: amount.currency.code, tone: tone)
          else if (subtitle case final subtitle?)
            Text(subtitle),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}

/// BR-020: hisob turi nomi.
String accountTypeLabel(AppL10n l10n, AccountType type) => switch (type) {
  AccountType.cash => l10n.accountTypeCash,
  AccountType.card => l10n.accountTypeCard,
  AccountType.bank => l10n.accountTypeBank,
  AccountType.ewallet => l10n.accountTypeEwallet,
  AccountType.deposit => l10n.accountTypeDeposit,
  AccountType.personalFund => l10n.accountTypePersonalFund,
  AccountType.other => l10n.accountTypeOther,
};

IconData accountTypeIcon(AccountType type) => switch (type) {
  AccountType.cash => Icons.payments_outlined,
  AccountType.card => Icons.credit_card,
  AccountType.bank => Icons.account_balance_outlined,
  AccountType.ewallet => Icons.phone_android,
  AccountType.deposit => Icons.savings_outlined,
  AccountType.personalFund => Icons.person_outline,
  AccountType.other => Icons.account_balance_wallet_outlined,
};
