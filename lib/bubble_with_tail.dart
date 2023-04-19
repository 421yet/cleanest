/// Basically a copy-paste of https://github.com/prahack/chat_bubbles

import 'package:flutter/material.dart';

class TailedBubble extends CustomPainter {
  final Color color;
  final Alignment alignment;
  final bool tail;

  TailedBubble({
    required this.color,
    required this.alignment,
    required this.tail,
  });

  final double _radius = 10.0;
  final double _x = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          _x,
          0,
          size.width,
          size.height,
          bottomRight: Radius.circular(_radius),
          topRight: Radius.circular(_radius),
          bottomLeft: Radius.circular(_radius),
        ),
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
    var path = Path();
    path.moveTo(_x, 0);
    path.lineTo(_x, 10);
    path.lineTo(0, 0);
    canvas.clipPath(path);
    canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          0,
          0.0,
          _x,
          size.height,
          topLeft: const Radius.circular(3),
        ),
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
