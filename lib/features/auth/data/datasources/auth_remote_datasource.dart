import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String fullName, String password);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Future<String> refreshToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await dio.post(
      ApiConstants.authLogin,
      data: {'email': email, 'password': password},
    );

    final accessToken = response.data['access_token'];
    final refreshToken = response.data['refresh_token'];

    // Save tokens
    await secureStorage.write(
        key: AppConstants.accessTokenKey, value: accessToken);
    await secureStorage.write(
        key: AppConstants.tokenKey,
        value:
            accessToken); // Keeping this for backward compatibility with app_router.dart

    if (refreshToken != null) {
      await secureStorage.write(
          key: AppConstants.refreshTokenKey, value: refreshToken);
    }

    if (response.data['user'] != null) {
      return UserModel.fromJson(response.data['user']);
    } else {
      // If backend doesn't return user info, fetch it separately
      return await getCurrentUser();
    }
  }

  @override
  Future<UserModel> register(
      String email, String fullName, String password) async {
    final response = await dio.post(
      ApiConstants.authRegister,
      data: {
        'email': email,
        'full_name': fullName,
        'password': password,
      },
    );

    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: AppConstants.accessTokenKey);
    await secureStorage.delete(key: AppConstants.refreshTokenKey);
    await secureStorage.delete(
        key: AppConstants.tokenKey); // Keeping this for backward compatibility
  }

  Future<String> refreshToken() async {
    final refreshToken =
        await secureStorage.read(key: AppConstants.refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    // Use a clean Dio instance to prevent interceptor loops
    final refreshDio = Dio(dio.options);
    
    final response = await refreshDio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final newAccessToken = response.data['access_token'];
    final newRefreshToken = response.data['refresh_token'];

    await secureStorage.write(
        key: AppConstants.accessTokenKey, value: newAccessToken);
    await secureStorage.write(
        key: AppConstants.tokenKey, value: newAccessToken);
    if (newRefreshToken != null) {
      await secureStorage.write(
          key: AppConstants.refreshTokenKey, value: newRefreshToken);
    }

    return newAccessToken;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await dio.get(ApiConstants.authMe);
    return UserModel.fromJson(response.data);
  }
}
