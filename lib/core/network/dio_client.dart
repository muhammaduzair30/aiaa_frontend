import 'package:aiaa/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
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

    // 1. Auth interceptor — attaches token & handles 401 refresh
    dio.interceptors.add(authInterceptor);

    // 2. Logger — logs full request / response / error details to the
    //    debug console. No error-mapping interceptor after this; error
    //    mapping is done in the repository layer via mapDioExceptionToFailure.
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
  }
}
