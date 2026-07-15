import 'package:pe/features/loan_request/domain/repositories/loan_request_repository.dart';

/// Run at app startup (and can be wired to a manual "Retry" action) so any
/// requests queued while offline are sent exactly once each as soon as the
/// network is available again.
class RetryPendingRequests {
  const RetryPendingRequests(this._repository);

  final LoanRequestRepository _repository;

  Future<void> call() => _repository.retryPendingRequests();
}
