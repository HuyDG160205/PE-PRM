import 'package:pe/features/loan_request/domain/entities/loan_request_payload.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_result.dart';

/// Maps the raw authenticated `POST .../objects` response (`{id, name, data, createdAt}`)
/// directly into the [LoanRequestResult] shown on the Request Result screen,
/// per the spec: "use the POST response itself as the success criterion".
class LoanRequestResultModel extends LoanRequestResult {
  LoanRequestResultModel({required super.payload, required super.id, required super.createdAt})
    : super(isPending: false);

  factory LoanRequestResultModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map).cast<String, dynamic>();
    return LoanRequestResultModel(
      payload: LoanRequestPayload.fromData(data),
      id: (json['id'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }
}
