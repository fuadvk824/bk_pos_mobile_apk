import 'dart:math';

import 'package:bk_pos/model/user_model.dart';
import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  final List<MonthlySales> data;

  ChartPainter({
    required this.data,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 38.0;
    const bottomPadding = 25.0;
    const topPadding = 10.0;
    const rightPadding = 8.0;

    final chartWidth =
        size.width - leftPadding - rightPadding;

    final chartHeight =
        size.height - bottomPadding - topPadding;

    if (data.isEmpty) {
      return;
    }

    final maxValue = data
        .map((item) => item.total)
        .fold<double>(
          0,
          max,
        );

    // Supaya chart tidak rusak ketika semua omzet = 0
    final chartMax = maxValue <= 0
        ? 100.0
        : _niceMax(maxValue);

    final axisPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1;

    final gridPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = .7;

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );

    // =========================
    // GRID Y
    // =========================

    const gridCount = 4;

    for (int i = 0; i <= gridCount; i++) {
      final ratio = i / gridCount;

      final y =
          topPadding +
          chartHeight -
          (chartHeight * ratio);

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(
          size.width - rightPadding,
          y,
        ),
        gridPaint,
      );

      final value = chartMax * ratio;

      final tp = TextPainter(
        text: TextSpan(
          text: _formatShort(value),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(
          leftPadding - tp.width - 5,
          y - tp.height / 2,
        ),
      );
    }

    // =========================
    // AXIS
    // =========================

    canvas.drawLine(
      Offset(
        leftPadding,
        topPadding,
      ),
      Offset(
        leftPadding,
        topPadding + chartHeight,
      ),
      axisPaint,
    );

    canvas.drawLine(
      Offset(
        leftPadding,
        topPadding + chartHeight,
      ),
      Offset(
        size.width - rightPadding,
        topPadding + chartHeight,
      ),
      axisPaint,
    );

    // =========================
    // LABEL BULAN
    // =========================

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Ags",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];

    for (int i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding +
              (chartWidth / (data.length - 1)) * i;

      final tp = TextPainter(
        text: TextSpan(
          text: months[i],
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(
          x - tp.width / 2,
          topPadding + chartHeight + 5,
        ),
      );
    }

    // =========================
    // POINTS
    // =========================

    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding +
              (chartWidth / (data.length - 1)) * i;

      final ratio = data[i].total / chartMax;

      final y =
          topPadding +
          chartHeight -
          (chartHeight * ratio);

      points.add(
        Offset(x, y),
      );
    }

    // =========================
    // LINE CHART
    // =========================

    if (points.isNotEmpty) {
      final path = Path();

      path.moveTo(
        points.first.dx,
        points.first.dy,
      );

      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        final middleX =
            p1.dx + (p2.dx - p1.dx) / 2;

        path.cubicTo(
          middleX,
          p1.dy,
          middleX,
          p2.dy,
          p2.dx,
          p2.dy,
        );
      }

      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(
        path,
        linePaint,
      );

      // =========================
      // POINT
      // =========================

      for (final point in points) {
        canvas.drawCircle(
          point,
          5,
          Paint()..color = Colors.white,
        );

        canvas.drawCircle(
          point,
          2.5,
          Paint()..color = const Color(0xffFF9800),
        );
      }
    }
  }

  double _niceMax(double value) {
    if (value <= 100000) {
      return ((value / 10000).ceil()) * 10000;
    }

    if (value <= 1000000) {
      return ((value / 100000).ceil()) * 100000;
    }

    if (value <= 10000000) {
      return ((value / 1000000).ceil()) * 1000000;
    }

    if (value <= 100000000) {
      return ((value / 10000000).ceil()) * 10000000;
    }

    return ((value / 100000000).ceil()) * 100000000;
  }

  String _formatShort(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} M';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} jt';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} rb';
    }

    return value.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(
    covariant ChartPainter oldDelegate,
  ) {
    return oldDelegate.data != data;
  }
}