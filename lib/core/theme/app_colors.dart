import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF534AB7);
  static const Color secondary = Color(0xFF1D9E75);
  static const Color background = Color(0xFFF8F8FF);
  static const Color surface = Colors.white;
  static const Color error = Colors.red;

  // Modern UI Colors
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF4B5563); // Gray 600
  static const Color textHint = Color(0xFF9CA3AF); // Gray 400
  static const Color inputFill = Color(0xFFF9FAFB); // Gray 50
  static const Color inputBorder = Color(0xFFE5E7EB); // Gray 200
  static const Color inputBorderFocused = Color(0xFF534AB7); // Match primary
  static const Color cardShadow = Color(0x0C000000);

  // Status colors
  static const Color statusSaved = Colors.grey;
  static const Color statusApplied = Colors.blue;
  static const Color statusInterview = Colors.orange;
  static const Color statusOffer = Colors.green;
  static const Color statusRejected = Colors.red;

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'saved':
        return statusSaved;
      case 'applied':
        return statusApplied;
      case 'interview':
        return statusInterview;
      case 'offer':
        return statusOffer;
      case 'rejected':
        return statusRejected;
      default:
        return Colors.grey;
    }
  }
}
