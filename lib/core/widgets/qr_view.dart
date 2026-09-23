import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// QR kod (taklif havolasi — BR-012). Kodlash — `qr` (sof Dart), chizish —
/// bitta `CustomPainter`: qo'shimcha vidjet kutubxonasi kerak emas.
class QrView extends StatelessWidget {
  const new(this.data, {this.size = 180, super.key});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: data,
    child: Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: CustomPaint(
        painter: _QrPainter(
          QrImage(QrCode(payload: QrPayload.fromString(data))),
        ),
      ),
    ),
  );
}

class _QrPainter extends CustomPainter {
  const new(this.image);

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / image.moduleCount;
    final paint = Paint()..color = Colors.black;
    for (var row = 0; row < image.moduleCount; row++) {
      for (var col = 0; col < image.moduleCount; col++) {
        if (!image.isDark(row, col)) continue;
        // Qo'shni kataklar orasida oq chiziq qolmasin — yarim piksel ustma-ust.
        canvas.drawRect(
          Rect.fromLTWH(col * cell, row * cell, cell + 0.5, cell + 0.5),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.image != image;
}
