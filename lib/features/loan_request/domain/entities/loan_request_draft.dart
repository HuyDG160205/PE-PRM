/// The in-progress loan form. Persisted after every change so it survives an
/// app restart, and cleared once a request is successfully submitted.
class LoanRequestDraft {
  const LoanRequestDraft({
    required this.deviceId,
    this.studentId = '',
    this.borrowDate,
    this.returnDate,
    this.purpose = '',
  });

  final String deviceId;
  final String studentId;
  final DateTime? borrowDate;
  final DateTime? returnDate;
  final String purpose;

  static const empty = LoanRequestDraft(deviceId: '');

  LoanRequestDraft copyWith({
    String? deviceId,
    String? studentId,
    DateTime? borrowDate,
    DateTime? returnDate,
    String? purpose,
    bool clearBorrowDate = false,
    bool clearReturnDate = false,
  }) {
    return LoanRequestDraft(
      deviceId: deviceId ?? this.deviceId,
      studentId: studentId ?? this.studentId,
      borrowDate: clearBorrowDate ? null : (borrowDate ?? this.borrowDate),
      returnDate: clearReturnDate ? null : (returnDate ?? this.returnDate),
      purpose: purpose ?? this.purpose,
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'studentId': studentId,
    'borrowDate': borrowDate?.toIso8601String(),
    'returnDate': returnDate?.toIso8601String(),
    'purpose': purpose,
  };

  factory LoanRequestDraft.fromJson(Map<String, dynamic> json) => LoanRequestDraft(
    deviceId: (json['deviceId'] ?? '').toString(),
    studentId: (json['studentId'] ?? '').toString(),
    borrowDate: json['borrowDate'] != null ? DateTime.tryParse(json['borrowDate']) : null,
    returnDate: json['returnDate'] != null ? DateTime.tryParse(json['returnDate']) : null,
    purpose: (json['purpose'] ?? '').toString(),
  );
}
