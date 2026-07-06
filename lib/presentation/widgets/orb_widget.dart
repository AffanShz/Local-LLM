import 'package:flutter/material.dart';

class OrbWidget extends StatefulWidget {
  final double size;
  final bool withText;

  const OrbWidget({super.key, this.size = 200, this.withText = true});

  @override
  State<OrbWidget> createState() => _OrbWidgetState();
}

class _OrbWidgetState extends State<OrbWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Create a gentle breathing and rotating effect
        final scale = 0.95 + 0.05 * _controller.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                radius: 1.2,
                colors: [
                  Colors.white.withOpacity(0.9),
                  const Color(0xFFFFDAB9), // Soft Peach
                  const Color(0xFFFFA07A).withOpacity(0.8), // Light Salmon
                  const Color(0xFFFF8C00).withOpacity(0.6), // Dark Orange
                ],
                stops: const [0.1, 0.4, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8C00).withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(-10, -10),
                ),
              ],
            ),
            child: widget.withText ? _buildLogoContent() : null,
          ),
        );
      },
    );
  }

  Widget _buildLogoContent() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'orange',
              style: TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: widget.size * 0.16,
                fontWeight: FontWeight.w300,
                color: const Color(0xFFD2691E), // Chocolate / darker orange
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        // Draw the small star/sparkle or dot typically seen in such logos
        Positioned(
          top: widget.size * 0.42,
          left: widget.size * 0.53,
          child: Container(
            width: widget.size * 0.025,
            height: widget.size * 0.025,
            decoration: const BoxDecoration(
              color: Color(0xFFFF8C00),
              shape: BoxShape.circle,
            ),
          ),
        )
      ],
    );
  }
}
