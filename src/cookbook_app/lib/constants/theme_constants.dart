import 'package:flutter/material.dart';

class ThemeConstants {
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  static final cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(26), // 0.1 * 255
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static final buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}