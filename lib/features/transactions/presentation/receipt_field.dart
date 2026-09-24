import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/receipts/receipt_providers.dart';
import 'package:my_wallet/features/transactions/application/add_transaction_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// BR-201: chek rasmlari — kamera/galereya, ≤ 1 MB ga siqiladi; yangi
/// rasmlar saqlashda navbatga tushadi. Tahrirlashda mavjudlari ham ko'rinadi.
class ReceiptField extends ConsumerWidget {
  const new({required this.state, super.key});

  final AddTransactionState state;

  static const double _thumb = 64;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final controller = ref.read(addTransactionProvider.notifier);
    final editingId = state.editing?.id;
    final uploaded = editingId == null
        ? const <AttachmentRow>[]
        : ref.watch(attachmentsForTransactionProvider(editingId)).value ??
              const <AttachmentRow>[];
    final pending = editingId == null
        ? const <PendingUploadRow>[]
        : ref.watch(pendingReceiptsProvider(editingId)).value ??
              const <PendingUploadRow>[];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final row in uploaded)
            _Thumb(
              size: _thumb,
              source: RemoteReceipt(row.storagePath),
              onRemove: () => unawaited(
                ref.read(receiptQueueProvider).removeAttachment(row.id),
              ),
            ),
          for (final row in pending)
            _Thumb(
              size: _thumb,
              source: LocalReceipt(FileImage(File(row.localPath))),
              badge: Icons.cloud_upload_outlined,
              onRemove: () => unawaited(
                ref.read(receiptQueueProvider).cancelPending(row.id),
              ),
            ),
          for (final (index, image) in state.receipts.indexed)
            _Thumb(
              size: _thumb,
              source: LocalReceipt(MemoryImage(image.bytes)),
              onRemove: () => controller.removeReceipt(index),
            ),
          ActionChip(
            avatar: const Icon(Icons.receipt_outlined, size: 18),
            label: Text(l10n.receipt),
            onPressed: () => unawaited(_pick(context, ref)),
          ),
          // E33-T02: fiskal chek QR kodi — summa va sana formaga tushadi.
          ActionChip(
            avatar: const Icon(Icons.qr_code_scanner, size: 18),
            label: Text(l10n.receiptScan),
            onPressed: () => unawaited(_scan(context, ref)),
          ),
        ],
      ),
    );
  }

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final scan = await context.push<ReceiptScan>(receiptScanPath);
    if (scan == null) return;
    ref.read(addTransactionProvider.notifier).applyReceiptScan(scan);
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final camera = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.receiptCamera),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.receiptGallery),
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
    if (camera == null) return;
    final image = await ref.read(receiptPickerProvider)(camera: camera);
    if (image == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.receiptTooLarge)));
      return;
    }
    ref.read(addTransactionProvider.notifier).addReceipt(image);
  }
}

/// Chek rasmi manbai: qurilmada (xotira/fayl) yoki Storage'da.
sealed class ReceiptSource {
  const new();
}

final class LocalReceipt extends ReceiptSource {
  const new(this.image);

  final ImageProvider image;
}

/// Storage'dagi chek — vaqtinchalik havola orqali (tarmoq kerak).
final class RemoteReceipt extends ReceiptSource {
  const new(this.path);

  final String path;
}

class _ReceiptImage extends ConsumerWidget {
  const new({required this.source, this.size});

  final ReceiptSource source;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kichik rasm ekrandagi o'lchamida dekodlanadi (E20-T02): to'liq
    // o'lchamli chek xotirani (rasm keshini) behuda egallamaydi.
    final cacheWidth = switch (size) {
      final size? => (size * MediaQuery.devicePixelRatioOf(context)).round(),
      null => null,
    };
    switch (source) {
      case LocalReceipt(:final image):
        return Image(
          image: ResizeImage.resizeIfNeeded(cacheWidth, null, image),
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      case RemoteReceipt(:final path):
        final url = ref.watch(receiptUrlProvider(path)).value;
        if (url == null) {
          return SizedBox.square(
            dimension: size,
            child: const Icon(Icons.image_outlined),
          );
        }
        return Image.network(
          url,
          width: size,
          height: size,
          cacheWidth: cacheWidth,
          fit: BoxFit.cover,
        );
    }
  }
}

class _Thumb extends StatelessWidget {
  const new({
    required this.size,
    required this.source,
    required this.onRemove,
    this.badge,
  });

  final double size;
  final ReceiptSource source;
  final VoidCallback onRemove;
  final IconData? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              fullscreenDialog: true,
              builder: (_) => ReceiptViewer(source: source),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: _ReceiptImage(source: source, size: size),
          ),
        ),
        if (badge != null)
          Positioned(
            left: 2,
            bottom: 2,
            child: Icon(
              badge,
              size: 16,
              semanticLabel: AppL10n.of(context).receiptPending,
            ),
          ),
        Positioned(
          right: -8,
          top: -8,
          child: IconButton.filledTonal(
            iconSize: 14,
            visualDensity: VisualDensity.compact,
            tooltip: AppL10n.of(context).actionCancel,
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}

/// Chekni kattalashtirib ko'rish (zoom).
class ReceiptViewer extends StatelessWidget {
  const new({required this.source, super.key});

  final ReceiptSource source;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text(AppL10n.of(context).receipt),
    ),
    body: InteractiveViewer(
      maxScale: 5,
      child: Center(child: _ReceiptImage(source: source)),
    ),
  );
}
