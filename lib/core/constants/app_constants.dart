import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'AIAA';
  static const String appVersion = '1.0.0';

  static const String tokenKey = 'auth_token';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static const List<String> statusValues = [
    'saved',
    'applied',
    'interview',
    'offer',
    'rejected',
  ];

  static const Map<String, Color> statusColors = {
    'saved': Colors.grey,
    'applied': Colors.blue,
    'interview': Colors.orange,
    'offer': Colors.green,
    'rejected': Colors.red,
  };
}
