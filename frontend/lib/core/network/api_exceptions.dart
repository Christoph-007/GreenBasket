/// Base exception for all API-related errors.
abstract class AppException implements Exception {
  const AppException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AppException($statusCode): $message';
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.statusCode});
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({required super.message}) : super(statusCode: 401);
}

class ValidationException extends AppException {
  const ValidationException({required super.message, this.fieldErrors})
      : super(statusCode: 400);

  final Map<String, dynamic>? fieldErrors;
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message}) : super(statusCode: 404);
}

class UnknownException extends AppException {
  const UnknownException({required super.message, super.statusCode});
}
