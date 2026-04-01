import 'dart:async';
import 'package:dio/dio.dart';
import 'package:greenbasket/core/constants/api_endpoints.dart';
import 'package:greenbasket/core/storage/secure_storage.dart';

/// Attaches JWT to outgoing requests and handles 401 with token refresh.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage, this._dio);

  final SecureStorageService _secureStorage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingQueue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't attempt refresh for auth endpoints themselves.
    final path = err.requestOptions.path;
    if (path == ApiEndpoints.login ||
        path == ApiEndpoints.signup ||
        path == ApiEndpoints.refreshToken) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      // Queue the request and wait for the active refresh to complete.
      final completer = Completer<Response>();
      _pendingQueue.add(_RetryRequest(err.requestOptions, completer));
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _clearAndReject(handler, err);
        return;
      }

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['data']?['accessToken'] as String?;
      final newRefreshToken =
          response.data['data']?['refreshToken'] as String?;

      if (newAccessToken == null) {
        await _clearAndReject(handler, err);
        return;
      }

      await _secureStorage.saveAccessToken(newAccessToken);
      if (newRefreshToken != null) {
        await _secureStorage.saveRefreshToken(newRefreshToken);
      }

      // Retry original request with new token.
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);

      // Retry queued requests.
      for (final pending in _pendingQueue) {
        pending.options.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final res = await _dio.fetch(pending.options);
          pending.completer.complete(res);
        } catch (e) {
          pending.completer.completeError(e);
        }
      }
    } catch (_) {
      await _clearAndReject(handler, err);
      for (final pending in _pendingQueue) {
        pending.completer.completeError(err);
      }
    } finally {
      _isRefreshing = false;
      _pendingQueue.clear();
    }
  }

  Future<void> _clearAndReject(
    ErrorInterceptorHandler handler,
    DioException err,
  ) async {
    await _secureStorage.clearTokens();
    handler.next(err);
  }
}

class _RetryRequest {
  _RetryRequest(this.options, this.completer);
  final RequestOptions options;
  final Completer<Response> completer;
}
