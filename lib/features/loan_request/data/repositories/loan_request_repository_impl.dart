import 'package:uuid/uuid.dart';
import 'package:pe/core/error/exceptions.dart';
import 'package:pe/core/error/failures.dart';
import 'package:pe/core/utils/result.dart';
import 'package:pe/features/loan_request/data/datasources/loan_request_local_data_source.dart';
import 'package:pe/features/loan_request/data/datasources/loan_request_remote_data_source.dart';
import 'package:pe/features/loan_request/data/models/pending_loan_request_model.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_draft.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_payload.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_result.dart';
import 'package:pe/features/loan_request/domain/repositories/loan_request_repository.dart';

class LoanRequestRepositoryImpl implements LoanRequestRepository {
  LoanRequestRepositoryImpl({
    required LoanRequestRemoteDataSource remoteDataSource,
    required LoanRequestLocalDataSource localDataSource,
    Uuid? uuid,
  }) : _remote = remoteDataSource,
       _local = localDataSource,
       _uuid = uuid ?? const Uuid();

  final LoanRequestRemoteDataSource _remote;
  final LoanRequestLocalDataSource _local;
  final Uuid _uuid;

  /// Prevents a retry from firing twice for the same queued entry if it is
  /// triggered concurrently (e.g. app-start retry racing a manual retry tap).
  final Set<String> _inFlightKeys = {};

  @override
  Future<Result<LoanRequestResult>> submit(LoanRequestPayload payload) async {
    try {
      final result = await _remote.submit(payload);
      return Success(result);
    } on NetworkException catch (_) {
      final key = _uuid.v4();
      await _local.enqueuePending(
        PendingLoanRequestModel(idempotencyKey: key, payload: payload, queuedAt: DateTime.now()),
      );
      return Success(LoanRequestResult(payload: payload, isPending: true));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    } catch (_) {
      return const Failed(UnknownFailure());
    }
  }

  @override
  Future<void> retryPendingRequests() async {
    final pending = await _local.getPendingRequests();
    for (final request in pending) {
      if (request.submitted || _inFlightKeys.contains(request.idempotencyKey)) continue;
      _inFlightKeys.add(request.idempotencyKey);
      try {
        await _remote.submit(request.payload);
        await _local.markSubmitted(request.idempotencyKey);
      } on NetworkException catch (_) {
        // Still offline: leave queued, try again on the next retry trigger.
      } catch (_) {
        // Server rejected it; leave queued rather than silently dropping data.
      } finally {
        _inFlightKeys.remove(request.idempotencyKey);
      }
    }
  }

  @override
  Future<void> saveDraft(LoanRequestDraft draft) => _local.saveDraft(draft);

  @override
  Future<LoanRequestDraft?> loadDraft() => _local.loadDraft();

  @override
  Future<void> clearDraft() => _local.clearDraft();
}
