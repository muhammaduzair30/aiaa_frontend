import 'package:dio/dio.dart';
import 'failures.dart';

/// Maps a [DioException] to the appropriate [Failure] type.
///
/// Centralises error-mapping so every repository uses consistent logic
/// without needing a Dio interceptor (which can't reliably re-throw
/// custom exception types).
Failure mapDioExceptionToFailure(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure('Connection timeout with server');

    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        return const AuthFailure('Authentication failed');
      }

      // Try to extract a meaningful message from the response body
      final responseData = e.response?.data;
      String errorMessage = 'Server error: $statusCode';
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['detail']?.toString() ??
            responseData['message']?.toString() ??
            errorMessage;
      }
      return ServerFailure(errorMessage);

    default:
      return ServerFailure(
          'Unexpected error occurred: ${e.message ?? 'Unknown'}');
  }
}
