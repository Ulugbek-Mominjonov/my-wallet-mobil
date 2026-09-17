import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/providers.dart';
import '../l10n/strings.dart';

/// Oflayn holatida ko'rinadigan lenta.
///
/// Firestore'ning o'z metadatasidan foydalanamiz: `meta/totals` hujjati
/// keshdan kelayotgan bo'lsa (`isFromCache`) — server bilan aloqa yo'q.
/// Qo'shimcha kutubxona (connectivity) kerak emas va bu ROSTDAN ham
/// ma'lumot sinxronmi degan savolga javob beradi.
final _connectionProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(refsProvider)
      .totals
      .snapshots(includeMetadataChanges: true)
      .map((snapshot) => !snapshot.metadata.isFromCache),
);

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(_connectionProvider).value ?? true;
    if (online) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.tertiaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            Uz.offline,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
