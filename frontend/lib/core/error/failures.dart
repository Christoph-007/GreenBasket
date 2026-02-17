import 'package:equatable/equatable.dart';

/// Base failure class used by repositories (domain-level errors).
abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, this.fieldErrors});

  final Map<String, dynamic>? fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}
