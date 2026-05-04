import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient({required this.dio, required AuthInterceptor authInterceptor}) {
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 120);
    dio.options.headers = {
      'Content-Type': 'application/json',
    };

    dio.interceptors.add(authInterceptor);

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, ErrorInterceptorHandler handler) {
          switch (err.type) {
            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
            case DioExceptionType.connectionError:
              throw NetworkException(message: 'Connection timeout with server');
            case DioExceptionType.badResponse:
              final statusCode = err.response?.statusCode;
              if (statusCode == 401 || statusCode == 403) {
                throw AuthException(message: 'Authentication failed');
              } else {
                throw ServerException(message: 'Server error: $statusCode');
              }
            default:
              throw ServerException(
                  message: 'Unexpected error occurred: ${err.message}');
          }
        },
      ),
    );
  }
}
