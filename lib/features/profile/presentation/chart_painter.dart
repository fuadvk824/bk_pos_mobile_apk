import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 22.0;
    const bottomPadding = 22.0;
    const topPadding = 8.0;
    const rightPadding = 8.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - bottomPadding - topPadding;

    // Axis
    final axisPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1;

    // Grid
    final gridPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = .7;

    // Text
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );

    /// ==========================
    /// GRID + LABEL Y
    /// ==========================
    const labelsY = ["0", "25", "50", "75", "100"];

    for (int i = 0; i < labelsY.length; i++) {
      final y = topPadding + chartHeight - (chartHeight / 4 * i);

      // garis horizontal
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(text: labelsY[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(leftPadding - tp.width - 5, y - tp.height / 2));
    }

    /// ==========================
    /// AXIS
    /// ==========================
    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, topPadding + chartHeight),
      axisPaint,
    );

    canvas.drawLine(
      Offset(leftPadding, topPadding + chartHeight),
      Offset(size.width - rightPadding, topPadding + chartHeight),
      axisPaint,
    );

    /// ==========================
    /// LABEL X
    /// ==========================
    const months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun"];

    for (int i = 0; i < months.length; i++) {
      final x = leftPadding + chartWidth / (months.length - 1) * i;

      final tp = TextPainter(
        text: TextSpan(text: months[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(x - tp.width / 2, topPadding + chartHeight + 4));
    }

    /// ==========================
    /// DATA
    /// ==========================
    final points = [
      Offset(leftPadding + chartWidth * .00, topPadding + chartHeight * .80),
      Offset(leftPadding + chartWidth * .20, topPadding + chartHeight * .45),
      Offset(leftPadding + chartWidth * .40, topPadding + chartHeight * .65),
      Offset(leftPadding + chartWidth * .60, topPadding + chartHeight * .18),
      Offset(leftPadding + chartWidth * .80, topPadding + chartHeight * .55),
      Offset(leftPadding + chartWidth * 1.00, topPadding + chartHeight * .25),
    ];

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      path.cubicTo(
        p1.dx + (p2.dx - p1.dx) / 2,
        p1.dy,
        p1.dx + (p2.dx - p1.dx) / 2,
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

    canvas.drawPath(path, linePaint);

    // Titik
    for (final point in points) {
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);

      canvas.drawCircle(point, 2.5, Paint()..color = const Color(0xffFF9800));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
