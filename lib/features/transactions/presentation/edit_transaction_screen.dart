import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/features/transactions/application/add_transaction_controller.dart';
import 'package:my_wallet/features/transactions/presentation/add_transaction_screen.dart';

/// Amalni tahrirlash (E15-T06): o'sha forma, amal bilan to'ldirilgan.
class EditTransactionScreen extends ConsumerStatefulWidget {
  const new({required this.id, super.key});

  final String id;

  @override
  ConsumerState<EditTransactionScreen> createState() => _EditState();
}

class _EditState extends ConsumerState<EditTransactionScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final deps = ref.read(domainDepsProvider);
    final tx = await deps?.transactions.byId(widget.id);
    if (!mounted || tx == null || tx.isDeleted) return;
    ref.read(addTransactionProvider.notifier).load(tx);
  }

  @override
  Widget build(BuildContext context) => const AddTransactionScreen();
}
