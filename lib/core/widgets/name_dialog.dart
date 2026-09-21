import 'package:flutter/material.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Bitta nom so'raydigan dialog (yangi kategoriya, teg va h.k.).
/// Bekor qilinsa yoki bo'sh bo'lsa — `null`.
Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  required String label,
  String initial = '',
  int maxLength = 60,
}) async {
  final name = await showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(
      title: title,
      label: label,
      initial: initial,
      maxLength: maxLength,
    ),
  );
  final trimmed = name?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

/// Controller dialog holatida — yopilish animatsiyasi tugaguncha yashaydi.
class _NameDialog extends StatefulWidget {
  const new({
    required this.title,
    required this.label,
    required this.initial,
    required this.maxLength,
  });

  final String title;
  final String label;
  final String initial;
  final int maxLength;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
