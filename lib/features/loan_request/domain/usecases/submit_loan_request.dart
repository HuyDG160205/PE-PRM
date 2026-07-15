import 'package:pe/core/utils/result.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_payload.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_result.dart';
import 'package:pe/features/loan_request/domain/repositories/loan_request_repository.dart';

class SubmitLoanRequest {
  const SubmitLoanRequest(this._repository);

  final LoanRequestRepository _repository;

  Future<Result<LoanRequestResult>> call(LoanRequestPayload payload) =>
      _repository.submit(payload);
}
