import 'package:pe/core/error/failures.dart';

/// Lightweight Either-style result so domain/data layers can return typed
/// success/failure without throwing across layer boundaries.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failed<T>;

  R fold<R>(R Function(Failure failure) onFailure, R Function(T value) onSuccess) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.value);
    if (self is Failed<T>) return onFailure(self.failure);
    throw StateError('Unknown Result subtype');
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final Failure failure;
}
