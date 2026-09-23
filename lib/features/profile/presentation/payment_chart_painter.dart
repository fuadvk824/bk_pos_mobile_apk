import 'dart:math';
import 'package:flutter/material.dart';

class PaymentChartPainter extends CustomPainter {
  final double cash;
  final double transfer;
  final double qris;

  PaymentChartPainter({
    required this.cash,
    required this.transfer,
    required this.qris,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = cash + transfer + qris;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 15;
 
    if (total <= 0) {
      // Ring luar
      final emptyPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 25
        ..color = const Color(0xFFD1D5DB);

      canvas.drawCircle(center, radius, emptyPaint);

      // Lingkaran tengah
      final centerPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFF3F4F6);

      canvas.drawCircle(center, radius - 17, centerPaint);

      // Text utama
      _drawText(
        canvas: canvas,
        text: 'Belum ada',
        center: center,
        offsetY: -15,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
      );

      // Text kedua
      _drawText(
        canvas: canvas,
        text: 'pembayaran',
        center: center,
        offsetY: 3,
        fontSize: 10,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF9CA3AF),
      );

      return;
    }

    // ============================================
    // ADA PEMBAYARAN
    // ============================================

    final values = [cash, transfer, qris];
    final colors = [Colors.orange, Colors.blue, Colors.green];

    double startAngle = -pi / 2;

    for (int i = 0; i < values.length; i++) {
      if (values[i] <= 0) {
        continue;
      }

      final sweepAngle = values[i] / total * 2 * pi;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 25
        ..strokeCap = StrokeCap.butt
        ..color = colors[i];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Tengah donut
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xff1F2937);

    canvas.drawCircle(center, radius - 17, centerPaint);

    _drawText(
      canvas: canvas,
      text: 'TOTAL',
      center: center,
      offsetY: -20,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Colors.white70,
    );

    _drawText(
      canvas: canvas,
      text: _formatShort(total),
      center: center,
      offsetY: 0,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  void _drawText({
    required Canvas canvas,
    required String text,
    required Offset center,
    required double offsetY,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy + offsetY),
    );
  }

  String _formatShort(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} M';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} jt';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} rb';
    }

    return value.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(covariant PaymentChartPainter oldDelegate) {
    return oldDelegate.cash != cash ||
        oldDelegate.transfer != transfer ||
        oldDelegate.qris != qris;
  }
} 