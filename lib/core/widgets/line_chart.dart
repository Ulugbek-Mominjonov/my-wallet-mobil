import 'package:flutter/material.dart';
import 'package:my_wallet/core/design_system/tokens.dart';

/// Oddiy chiziqli grafik (masalan jamg'arma to'planishi): nuqtalar bir xil
/// oraliqda, nol chizig'i bilan; manfiy qiymatlar ham ko'rinadi.
class LineChart extends StatelessWidget {
  const new({
    required this.labels,
    required this.values,
    required this.color,
    this.height = 160,
    this.semanticLabel,
    super.key,
  }) : assert(labels.length == values.length, 'har nuqtaga yorliq');

  final List<String> labels;

  /// Bir xil birlikda (tiyin).
  final List<int> values;
  final Color color;
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
              painter: _LinePainter(
                values: values,
                color: color,
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

class _LinePainter extends CustomPainter {
  const new({
    required this.values,
    required this.color,
    required this.baseline,
  });

  final List<int> values;
  final Color color;
  final Color baseline;

  static const double _stroke = 2.5;
  static const double _dot = 3.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    var max = 0;
    var min = 0;
    for (final value in values) {
      if (value > max) max = value;
      if (value < min) min = value;
    }
    final range = (max - min) == 0 ? 1 : max - min;
    // Har nuqta o'z ustuni markazida (yorliqlar bilan bir xil).
    final step = size.width / values.length;
    Offset point(int index) => Offset(
      step * index + step / 2,
      size.height - (values[index] - min) / range * size.height,
    );

    final zero = size.height - (0 - min) / range * size.height;
    canvas.drawLine(
      Offset(0, zero),
      Offset(size.width, zero),
      Paint()..color = baseline,
    );

    final line = Paint()
      ..color = color
      ..strokeWidth = _stroke
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(path, line);
    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(point(i), _dot, dot);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.values != values || old.color != color || old.baseline != baseline;
}
