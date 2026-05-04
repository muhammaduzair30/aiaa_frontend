import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF534AB7);
  static const Color secondary = Color(0xFF1D9E75);
  static const Color background = Color(0xFFF8F8FF);
  static const Color surface = Colors.white;
  static const Color error = Colors.red;

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
