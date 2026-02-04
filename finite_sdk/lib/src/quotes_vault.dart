import 'package:flutter/material.dart';

class Quote {
  final String text;
  final String author;

  const Quote(this.text, this.author);
}

class QuoteVault {
  // A curated list of timeless wisdom.
  // In a real app, you would have 365 entries here.
  static const List<Quote> _library = [
    Quote("We suffer more often in imagination than in reality.", "Seneca"),
    Quote(
        "You could leave life right now. Let that determine what you do and say and think.",
        "Marcus Aurelius"),
    Quote("He who has a why to live for can bear almost any how.", "Nietzsche"),
    Quote("Life is long if you know how to use it.", "Seneca"),
    Quote("The trouble is, you think you have time.", "Buddha"),
    Quote("Do not act as if you had ten thousand years to throw away.",
        "Marcus Aurelius"),
    Quote(
        "Begin at once to live, and count each separate day as a separate life.",
        "Seneca"),
    Quote(
        "Time is the currency of your life. Do not let others spend it for you.",
        "Carl Sandburg"),
    Quote(
        "It is not death that a man should fear, but he should fear never beginning to live.",
        "Marcus Aurelius"),
    Quote(
        "What man actually needs is not a tensionless state but rather the striving and struggling for a worthy goal.",
        "Viktor Frankl"),
  ];

  static Quote getDailyQuote() {
    final now = DateTime.now();
    // Calculate "Day of Year" (1-365)
    final dayOfYear = int.parse(
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");

    // Use math to pick a quote based on the day.
    // This ensures everyone sees the same quote on the same day.
    final index = dayOfYear % _library.length;
    return _library[index];
  }
}
