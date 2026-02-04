import 'package:flutter/material.dart';
import 'dart:math' as Math;

class FiniteLogo extends StatelessWidget {
  final double size;
  final bool animate; // Option to make the sun pulse slightly

  const FiniteLogo({
    super.key,
    this.size = 100,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    // If animate is true, we could wrap this in an animation builder.
    // For the static logo, we just render the painter.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: const Color(0xFF121212), // The Void Background
          borderRadius: BorderRadius.circular(size * 0.2), // App Icon shape
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]),
      child: CustomPaint(
        painter: _LogoPainter(),
        size: Size(size, size),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double padding = size.width * 0.2; // Padding inside the box
    final double gridSize = size.width - (padding * 2);
    final double cellSize = gridSize / 3;
    final double dotRadius = (cellSize * 0.6) / 2; // Dots are 60% of cell width

    final Paint stonePaint = Paint()
      ..color = const Color(0xFF333333) // Dark Grey
      ..style = PaintingStyle.fill;

    final Paint sunPaint = Paint()
      ..color = const Color(0xFFFF4500) // Vitality Orange
      ..style = PaintingStyle.fill;

    // Glow Effect for the Sun
    final Paint sunGlowPaint = Paint()
      ..color = const Color(0xFFFF4500).withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Draw 3x3 Grid
    for (int col = 0; col < 3; col++) {
      for (int row = 0; row < 3; row++) {
        // Calculate Center of this cell
        final double dx = padding + (col * cellSize) + (cellSize / 2);
        final double dy = padding + (row * cellSize) + (cellSize / 2);
        final Offset center = Offset(dx, dy);

        // Check if Center Cell (1,1)
        if (col == 1 && row == 1) {
          // DRAW THE SUN

          // 1. Draw Glow (Behind)
          canvas.drawCircle(center, dotRadius * 1.5, sunGlowPaint);

          // 2. Draw Core
          canvas.drawCircle(center, dotRadius * 1.1, sunPaint);

          // 3. Optional: Tiny inner white spec for intensity
          canvas.drawCircle(center, dotRadius * 0.3,
              Paint()..color = Colors.white.withOpacity(0.3));
        } else {
          // DRAW THE VOID DOTS
          canvas.drawCircle(center, dotRadius, stonePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
