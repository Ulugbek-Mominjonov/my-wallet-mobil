import 'package:flutter/material.dart';
import 'package:my_wallet/core/design_system/tokens.dart';

/// Oyma-oy ustun grafik: har oy uchun bir yoki ikki ustun (masalan daromad
/// va xarajat). Qiymatlar — bir xil birlikda (tiyin); manfiylar nol.
class MonthBars extends StatelessWidget {
  const new({
    required this.labels,
    required this.series,
    required this.colors,
    this.height = 160,
    this.semanticLabel,
    super.key,
  }) : assert(series.length == colors.length, 'har qatorga rang');

  final List<String> labels;

  /// Har qator — `labels` uzunligida qiymatlar.
  final List<List<int>> series;
  final List<Color> colors;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: semanticLabel,
      child: Column(
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: CustomPaint(
              painter: _BarsPainter(
                series: series,
                colors: colors,
                baseline: theme.colorScheme.outlineVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (final label in labels)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  const new({
    required this.series,
    required this.colors,
    required this.baseline,
  });

  final List<List<int>> series;
  final List<Color> colors;
  final Color baseline;

  @override
  void paint(Canvas canvas, Size size) {
    final count = series.isEmpty ? 0 : series.first.length;
    if (count == 0) return;
    var max = 1;
    for (final values in series) {
      for (final value in values) {
        if (value > max) max = value;
      }
    }
    final slot = size.width / count;
    final gap = slot * 0.2;
    final barWidth = (slot - gap) / series.length;
    for (var i = 0; i < count; i++) {
      for (final (s, values) in series.indexed) {
        final value = values[i] < 0 ? 0 : values[i];
        final barHeight = size.height * value / max;
        final left = i * slot + gap / 2 + s * barWidth;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              left,
              size.height - barHeight,
              barWidth * 0.9,
              barHeight,
            ),
            const Radius.circular(2),
          ),
          Paint()..color = colors[s],
        );
      }
    }
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()..color = baseline,
    );
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.series != series || old.colors != colors;
}
