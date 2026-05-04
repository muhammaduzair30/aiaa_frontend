import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';

  // Auth
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';

  // CV
  static const String cv = '/cv';
  static const String cvUpload = '/cv/upload';
  static String cvById(String id) => '/cv/$id';

  // Job
  static const String job = '/job';
  static const String jobScrape = '/job/scrape';
  static String jobById(String id) => '/job/$id';

  // Analysis
  static const String analysisRun = '/analysis/run';
  static const String analysisHistory = '/analysis/history';
  static String analysisById(String id) => '/analysis/$id';

  // Applications
  static const String applications = '/applications';
  static String applicationsById(String id) => '/applications/$id';
}
