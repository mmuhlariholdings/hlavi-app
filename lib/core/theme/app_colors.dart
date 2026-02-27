import 'package:flutter/material.dart';

/// App color palette
/// Inspired by Shopify design system with clean, modern colors
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF5C6AC4); // Shopify purple
  static const Color primaryDark = Color(0xFF202E78);
  static const Color primaryLight = Color(0xFF9C6ADE);

  // Secondary Colors
  static const Color secondary = Color(0xFF00A0AC); // Teal accent
  static const Color secondaryDark = Color(0xFF007A7A);
  static const Color secondaryLight = Color(0xFF00C6D7);

  // Neutral Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F6F8);

  // Text Colors
  static const Color textPrimary = Color(0xFF202223);
  static const Color textSecondary = Color(0xFF6D7175);
  static const Color textTertiary = Color(0xFF8C9196);
  static const Color textDisabled = Color(0xFFB5B9BD);

  // Status Colors (matching web app's task statuses)
  static const Color statusNew = Color(0xFF9E9E9E); // Gray
  static const Color statusOpen = Color(0xFF2196F3); // Blue
  static const Color statusInProgress = Color(0xFFFFC107); // Amber
  static const Color statusPending = Color(0xFFFF9800); // Orange
  static const Color statusReview = Color(0xFF9C27B0); // Purple
  static const Color statusDone = Color(0xFF4CAF50); // Green
  static const Color statusClosed = Color(0xFF607D8B); // Blue Grey

  // Border Colors
  static const Color borderLight = Color(0xFFE1E3E5);
  static const Color borderMedium = Color(0xFFC4CDD5);
  static const Color borderDark = Color(0xFF8C9196);

  // Semantic Colors
  static const Color success = Color(0xFF50B83C);
  static const Color warning = Color(0xFFEEC200);
  static const Color error = Color(0xFFD82C0D);
  static const Color info = Color(0xFF006FBB);

  // Shadow
  static const Color shadow = Color(0x1A000000);

  AppColors._();
}
