/// Base type for domain/data-layer failures surfaced to the presentation layer.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error, please try again']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error occurred']);
}

/// Wraps a [Failure] as a throwable so Riverpod `AsyncNotifier`/`FutureProvider`
/// builders can surface it through the normal `AsyncValue.error` channel.
class FailureException implements Exception {
  const FailureException(this.failure);

  final Failure failure;

  @override
  String toString() => failure.message;
}
