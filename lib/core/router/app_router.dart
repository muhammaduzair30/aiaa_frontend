import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/cv/presentation/screens/cv_upload_screen.dart';
import '../../features/cv/presentation/screens/cv_list_screen.dart';
import '../../features/cv/domain/entities/cv_entity.dart';
import '../../features/job/presentation/screens/job_input_screen.dart';
import '../../features/job/domain/entities/job_entity.dart';
import '../../features/analysis/presentation/screens/analysis_screen.dart';
import '../../features/analysis/presentation/screens/analysis_history_screen.dart';
import '../../features/analysis/presentation/screens/result_screen.dart';
import '../../features/job_application/presentation/screens/applications_screen.dart';
import '../../features/job_application/presentation/screens/application_detail_screen.dart';
import '../constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.tokenKey);
    if (!mounted) return;
    if (token != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/cv/upload',
        builder: (context, state) => const CVUploadScreen(),
      ),
      GoRoute(
        path: '/cv/list',
        builder: (context, state) => const CVListScreen(),
      ),
      GoRoute(
        path: '/job/input',
        builder: (context, state) => const JobInputScreen(),
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) {
          final extra = state.extra;
          String? preSelectedCvId;
          JobEntity? preSelectedJob;
          if (extra is CVEntity) {
            preSelectedCvId = extra.id;
          } else if (extra is JobEntity) {
            preSelectedJob = extra;
          }
          return AnalysisScreen(
            preSelectedCvId: preSelectedCvId,
            preSelectedJob: preSelectedJob,
          );
        },
      ),
      GoRoute(
        path: '/analysis/history',
        builder: (context, state) => const AnalysisHistoryScreen(),
      ),
      GoRoute(
        path: '/analysis/result',
        builder: (context, state) {
          final analysis = state.extra;
          return ResultScreen(analysis: analysis as dynamic);
        },
      ),
      GoRoute(
        path: '/applications',
        builder: (context, state) => const ApplicationsScreen(),
      ),
      GoRoute(
        path: '/application/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final application = state.extra as dynamic;
          return ApplicationDetailScreen(id: id, application: application);
        },
      ),
    ],
  );
}
