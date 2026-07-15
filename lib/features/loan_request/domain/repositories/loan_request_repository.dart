import 'package:pe/core/utils/result.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_draft.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_payload.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_result.dart';

abstract class LoanRequestRepository {
  /// Submits [payload]. On success returns the remote POST response mapped
  /// to a [LoanRequestResult]; on a network failure it is queued locally and
  /// a `isPending: true` result is returned instead of a [Failed].
  Future<Result<LoanRequestResult>> submit(LoanRequestPayload payload);

  /// Retries every not-yet-submitted queued request exactly once each,
  /// guarded by its idempotency key so a retry never double-submits.
  Future<void> retryPendingRequests();

  Future<void> saveDraft(LoanRequestDraft draft);
  Future<LoanRequestDraft?> loadDraft();
  Future<void> clearDraft();
}
