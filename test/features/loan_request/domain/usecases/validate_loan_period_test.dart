import 'package:flutter_test/flutter_test.dart';
import 'package:pe/features/loan_request/domain/usecases/validate_loan_period.dart';

void main() {
  final validate = const ValidateLoanPeriod();
  final now = DateTime(2026, 8, 1);

  test('rejects a borrow date in the past', () {
    final error = validate(
      borrowDate: DateTime(2026, 7, 31),
      returnDate: DateTime(2026, 8, 5),
      now: now,
    );
    expect(error, LoanDateError.borrowDateInPast);
  });

  test('rejects a return date that is not after the borrow date (reversed dates)', () {
    final error = validate(
      borrowDate: DateTime(2026, 8, 10),
      returnDate: DateTime(2026, 8, 5),
      now: now,
    );
    expect(error, LoanDateError.returnNotAfterBorrow);
  });

  test('rejects a return date equal to the borrow date', () {
    final error = validate(
      borrowDate: DateTime(2026, 8, 5),
      returnDate: DateTime(2026, 8, 5),
      now: now,
    );
    expect(error, LoanDateError.returnNotAfterBorrow);
  });

  test('rejects a period longer than 14 days', () {
    final error = validate(
      borrowDate: DateTime(2026, 8, 1),
      returnDate: DateTime(2026, 8, 16),
      now: now,
    );
    expect(error, LoanDateError.periodTooLong);
  });

  test('accepts exactly 14 days (boundary)', () {
    final error = validate(
      borrowDate: DateTime(2026, 8, 1),
      returnDate: DateTime(2026, 8, 15),
      now: now,
    );
    expect(error, isNull);
  });

  test('accepts a valid short period', () {
    final error = validate(
      borrowDate: DateTime(2026, 8, 1),
      returnDate: DateTime(2026, 8, 3),
      now: now,
    );
    expect(error, isNull);
  });
}
