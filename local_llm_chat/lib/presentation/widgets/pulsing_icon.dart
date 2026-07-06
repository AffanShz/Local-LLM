import 'package:flutter/material.dart';

class PulsingIcon extends StatefulWidget {
  const PulsingIcon({super.key});

  @override
  State<PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<PulsingIcon> with SingleTickerProviderStateMixin {
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
        // We use a custom pulsing effect based on the controller value
        final pulse1 = 1.0 + 0.1 * _controller.value;
        final pulse2 = 1.0 + 0.05 * (1.0 - _controller.value);

        return SizedBox(
          width: 128,
          height: 128,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse
              Transform.scale(
                scale: pulse1,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: const Color(0xFF004AC6).withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Inner pulse
              Transform.scale(
                scale: pulse2,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFF004AC6).withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Icon container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FB),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFC3C6D7).withOpacity(0.2),
                  ),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 40,
                  color: Color(0xFF004AC6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
