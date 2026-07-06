import 'package:flutter/material.dart';

class GridBackground extends StatelessWidget {
  final Widget child;

  const GridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PerspectiveGridPainter(),
      child: child,
    );
  }
}

class _PerspectiveGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF8C00).withOpacity(0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double step = 45.0;

    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    final rect = Offset.zero & size;
    final fadePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          Colors.transparent,
          const Color(0xFFFAF9F6), // Warm off-white, matches scaffold background
        ],
        stops: const [0.3, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.srcOver;

    canvas.drawRect(rect, fadePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
