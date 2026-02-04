import 'package:flutter/material.dart';

class PebbleWidget extends StatelessWidget {
  const PebbleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Match the app background
      color: const Color(0xFFF4F4F0),
      child: Center(
        child: Container(
          // The Dot (Larger here since it's the only thing)
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFF4500), // International Orange
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4500).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
