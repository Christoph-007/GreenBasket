import 'package:dio/dio.dart';
import 'package:greenbasket/core/error/failures.dart';
import 'package:greenbasket/core/network/api_exceptions.dart';

/// Converts exceptions to domain [Failure] objects.
class ErrorHandler {
  ErrorHandler._();

  static Failure handle(dynamic error) {
    if (error is DioException) {
      final appError = error.error;
      if (appError is AppException) {
        return _fromAppException(appError);
      }
      return const NetworkFailure(
        message: 'No internet connection. Please check your network.',
      );
    }
    if (error is AppException) {
      return _fromAppException(error);
    }
    return UnknownFailure(message: error.toString());
  }

  static Failure _fromAppException(AppException e) {
    if (e is NetworkException) {
      return NetworkFailure(message: e.message);
    }
    if (e is UnauthorizedException) {
      return AuthFailure(message: e.message);
    }
    if (e is ValidationException) {
      return ValidationFailure(
        message: e.message,
        fieldErrors: e.fieldErrors,
      );
    }
    if (e is ServerException) {
      return ServerFailure(message: e.message);
    }
    if (e is NotFoundException) {
      return ServerFailure(message: e.message);
    }
    return UnknownFailure(message: e.message);
  }
}
