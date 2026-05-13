import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../router/app_router.dart';

/// Dio interceptor that attaches the JWT Bearer token to every outgoing
/// request and transparently refreshes the access token on 401 responses.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final AuthRemoteDataSource authDataSource;

  /// Guards concurrent refresh attempts.
  Completer<String?>? _refreshCompleter;

  AuthInterceptor({
    required this.secureStorage,
    required this.authDataSource,
  });

  // ── onRequest ──────────────────────────────────────────────────────────
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await secureStorage.read(key: AppConstants.accessTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Proceed without token on storage read error
    }
    handler.next(options);
  }

  // ── onError ────────────────────────────────────────────────────────────
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Skip refresh for auth endpoints themselves
    final path = err.requestOptions.path;
    if (path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh')) {
      return handler.next(err);
    }

    // ── Attempt transparent token refresh ──
    try {
      final newToken = await _performLockedRefresh();

      if (newToken != null && newToken.isNotEmpty) {
        // Retry the original request with the fresh token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        // We use a clean Dio for the retry to avoid interceptor recursion
        final retryDio = Dio(err.requestOptions.baseUrl.isEmpty
            ? BaseOptions()
            : BaseOptions(baseUrl: err.requestOptions.baseUrl));

        final response = await retryDio.fetch(err.requestOptions);
        return handler.resolve(response);
      }
    } catch (e) {
      debugPrint('[AuthInterceptor] Refresh / retry failed: $e');
    }

    // If we reach here, refresh failed — clear session
    await _handleLogout();
    return handler.next(err);
  }

  // ── Locked refresh ─────────────────────────────────────────────────────
  /// Ensures only one refresh request is in-flight at a time.
  /// Concurrent callers await the same [Completer].
  Future<String?> _performLockedRefresh() async {
    // If a refresh is already running, wait for its result
    if (_refreshCompleter != null) {
      debugPrint('[AuthInterceptor] Waiting for in-flight refresh…');
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();
    String? newToken;

    try {
      debugPrint(
          '[AuthInterceptor] Refreshing access token via AuthDataSource…');
      newToken = await authDataSource.refreshToken();
      _refreshCompleter!.complete(newToken);
    } catch (e) {
      debugPrint('[AuthInterceptor] Refresh request error: $e');
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }

    return newToken;
  }

  // ── Logout helper ──────────────────────────────────────────────────────
  Future<void> _handleLogout() async {
    debugPrint('[AuthInterceptor] Clearing tokens and redirecting to login');
    try {
      await authDataSource.logout();
    } catch (_) {}

    try {
      final context =
          AppRouter.router.routerDelegate.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        context.go('/login');
      } else {
        AppRouter.router.go('/login');
      }
    } catch (_) {
      AppRouter.router.go('/login');
    }
  }
}
