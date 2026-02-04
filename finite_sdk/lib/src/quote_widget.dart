import 'package:flutter/material.dart';
import 'quotes_vault.dart';

class QuoteWidget extends StatelessWidget {
  final int livedWeeks; // Now accepts the week count

  const QuoteWidget({required this.livedWeeks, super.key});

  @override
  Widget build(BuildContext context) {
    final quote = QuoteVault.getDailyQuote();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: Container(
          // INCREASED SIZE: We draw it large (400px) so it shrinks down crisp
          width: 400,
          height: 400,
          padding: const EdgeInsets.all(32), // More padding for the larger size
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F0),
            borderRadius:
                BorderRadius.circular(48), // larger radius for high-res
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 12, // Larger dot
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4500),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // DYNAMIC WEEK COUNT
                  Text(
                    'WEEK $livedWeeks',
                    style: const TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 20, // Larger font
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                ],
              ),

              // Quote
              Center(
                child: Text(
                  quote.text,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32, // Much larger font for high-res render
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),

              // Author
              Text(
                "— ${quote.author}",
                style: const TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 24, // Larger font
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF8E8E8E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
