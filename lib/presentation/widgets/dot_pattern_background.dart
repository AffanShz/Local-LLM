import 'package:flutter/material.dart';

class DotPatternBackground extends StatelessWidget {
  final Widget child;

  const DotPatternBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _DotPatternPainter(),
          ),
        ),
        child,
      ],
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC3C6D7).withOpacity(0.2) // outline-variant color with opacity
      ..style = PaintingStyle.fill;

    const double spacing = 32.0;
    const double radius = 1.5;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
