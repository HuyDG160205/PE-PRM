import 'package:intl/intl.dart';

/// Exact nested `data` object sent to `POST /collections/.../objects`. Kept
/// as its own type (separate from the mutable [LoanRequestDraft]) so the
/// payload stored for offline retry matches what was (or will be) submitted.
class LoanRequestPayload {
  const LoanRequestPayload({
    required this.deviceId,
    required this.studentId,
    required this.borrowDate,
    required this.returnDate,
    required this.purpose,
    required this.deposit,
    this.status = 'pending',
  });

  final String deviceId;
  final String studentId;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String purpose;
  final double deposit;
  final String status;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Map<String, dynamic> toData() => {
    'deviceId': deviceId,
    'studentId': studentId,
    'borrowDate': _dateFormat.format(borrowDate),
    'returnDate': _dateFormat.format(returnDate),
    'purpose': purpose,
    'deposit': deposit,
    'status': status,
  };

  Map<String, dynamic> toRequestBody() => {
    'name': 'Campus Equipment Loan Request',
    'data': toData(),
  };

  factory LoanRequestPayload.fromData(Map<String, dynamic> data) => LoanRequestPayload(
    deviceId: (data['deviceId'] ?? '').toString(),
    studentId: (data['studentId'] ?? '').toString(),
    borrowDate: DateTime.parse(data['borrowDate']),
    returnDate: DateTime.parse(data['returnDate']),
    purpose: (data['purpose'] ?? '').toString(),
    deposit: (data['deposit'] as num).toDouble(),
    status: (data['status'] ?? 'pending').toString(),
  );
}
