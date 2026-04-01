import 'package:dio/dio.dart';
import 'package:greenbasket/core/constants/app_config.dart';
import 'package:greenbasket/core/network/auth_interceptor.dart';
import 'package:greenbasket/core/network/error_interceptor.dart';
import 'package:greenbasket/core/storage/secure_storage.dart';

/// Creates and configures the single Dio instance used across the app.
Dio createDio(SecureStorageService secureStorage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(secureStorage, dio),
    ErrorInterceptor(),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
}
