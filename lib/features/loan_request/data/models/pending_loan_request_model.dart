import 'package:pe/features/loan_request/domain/entities/loan_request_payload.dart';

/// A locally-queued loan request awaiting network connectivity. [idempotencyKey]
/// guarantees a single retry is ever actually POSTed for this entry, and
/// [submitted] is flipped only after a confirmed server response.
class PendingLoanRequestModel {
  const PendingLoanRequestModel({
    required this.idempotencyKey,
    required this.payload,
    required this.queuedAt,
    this.submitted = false,
  });

  final String idempotencyKey;
  final LoanRequestPayload payload;
  final DateTime queuedAt;
  final bool submitted;

  PendingLoanRequestModel copyWith({bool? submitted}) => PendingLoanRequestModel(
    idempotencyKey: idempotencyKey,
    payload: payload,
    queuedAt: queuedAt,
    submitted: submitted ?? this.submitted,
  );

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'data': payload.toData(),
    'queuedAt': queuedAt.toIso8601String(),
    'submitted': submitted,
  };

  factory PendingLoanRequestModel.fromJson(Map<String, dynamic> json) => PendingLoanRequestModel(
    idempotencyKey: (json['idempotencyKey'] ?? '').toString(),
    payload: LoanRequestPayload.fromData((json['data'] as Map).cast<String, dynamic>()),
    queuedAt: DateTime.tryParse((json['queuedAt'] ?? '').toString()) ?? DateTime.now(),
    submitted: json['submitted'] == true,
  );
}
