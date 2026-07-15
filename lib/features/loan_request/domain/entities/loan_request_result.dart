import 'package:pe/features/loan_request/domain/entities/loan_request_payload.dart';

/// Outcome shown on the Request Result screen. When [isPending] is true the
/// request could not reach the server and was queued locally (Part 3); [id]
/// and [createdAt] are only populated for a real POST response.
class LoanRequestResult {
  const LoanRequestResult({
    required this.payload,
    required this.isPending,
    this.id,
    this.createdAt,
  });

  final LoanRequestPayload payload;
  final bool isPending;
  final String? id;
  final DateTime? createdAt;
}
