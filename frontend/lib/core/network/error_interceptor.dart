import 'package:dio/dio.dart';
import 'package:greenbasket/core/network/api_exceptions.dart';

/// Maps DioExceptions to typed [AppException] subclasses.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final AppException mapped;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        mapped = NetworkException(
          message: 'No internet connection. Please check your network.',
          statusCode: err.response?.statusCode,
        );
      default:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;
        final serverMessage = responseData is Map<String, dynamic>
            ? responseData['message'] as String?
            : null;

        if (statusCode == null) {
          mapped = NetworkException(
            message: 'No internet connection. Please check your network.',
          );
        } else if (statusCode == 401) {
          mapped = UnauthorizedException(
            message: serverMessage ?? 'Session expired. Please login again.',
          );
        } else if (statusCode == 400) {
          final errors = responseData is Map<String, dynamic>
              ? responseData['errors'] as Map<String, dynamic>?
              : null;
          mapped = ValidationException(
            message: serverMessage ?? 'Invalid request.',
            fieldErrors: errors,
          );
        } else if (statusCode == 404) {
          mapped = NotFoundException(
            message: serverMessage ?? 'Resource not found.',
          );
        } else if (statusCode >= 500) {
          mapped = ServerException(
            message: serverMessage ?? 'Server error. Please try again later.',
            statusCode: statusCode,
          );
        } else {
          mapped = UnknownException(
            message: serverMessage ?? 'Something went wrong.',
            statusCode: statusCode,
          );
        }
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapped,
      ),
    );
  }
}
