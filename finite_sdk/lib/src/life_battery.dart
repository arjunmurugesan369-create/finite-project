import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LifeBatteryWidget extends StatelessWidget {
  final int livedWeeks;
  final int totalWeeks;

  const LifeBatteryWidget({
    super.key,
    required this.livedWeeks,
    required this.totalWeeks,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentage for the bar
    final double progress = (livedWeeks / totalWeeks).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F0), // Matches App Background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. The Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Current Week
              Text(
                'WEEK $livedWeeks',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFF4500), // International Orange
                  letterSpacing: 1.0,
                ),
              ),
              // Right: Total Weeks (The Limit)
              Text(
                '/ $totalWeeks',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB0B0B0), // Faint Grey
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. The Battery Bar
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0), // Fog (Empty Future)
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Stack(
                  children: [
                    // The Lived Past
                    Container(
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2B2B), // Stone (Heavy Past)
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
