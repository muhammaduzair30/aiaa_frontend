import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../router/app_router.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final Dio dio;
  final AuthRemoteDataSource authDataSource;

  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
    required this.authDataSource,
  });

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.read(key: AppConstants.accessTokenKey);
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final isRetry = err.requestOptions.extra['is_retry'] ?? false;
      final isRefresh = err.requestOptions.extra['is_refresh'] ?? false;

      // Avoid infinite loop if this is a retry or a refresh request
      if (!isRetry && !isRefresh && !err.requestOptions.path.contains('/auth/refresh')) {
        try {
          final newToken = await authDataSource.refreshToken();
          
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          err.requestOptions.extra['is_retry'] = true;
          
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          await _handleLogout();
          return handler.next(err);
        }
      } else {
        await _handleLogout();
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  Future<void> _handleLogout() async {
    await secureStorage.delete(key: AppConstants.accessTokenKey);
    await secureStorage.delete(key: AppConstants.refreshTokenKey);
    await secureStorage.delete(key: AppConstants.tokenKey);
    
    final context = AppRouter.router.routerDelegate.navigatorKey.currentContext;
    if (context != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired, please login')),
        );
        context.go('/login');
      }
    } else {
      AppRouter.router.go('/login');
    }
  }
}
