import 'package:pe/core/utils/date_validator_rules.dart';

enum LoanDateError { borrowDateInPast, returnNotAfterBorrow, periodTooLong }

/// Pure domain rule (Change Request #3): borrow date cannot be in the past,
/// return date must be strictly later than the borrow date, and the total
/// period cannot exceed [DateValidatorRules.maxLoanDays] days.
class ValidateLoanPeriod {
  const ValidateLoanPeriod();

  LoanDateError? call({
    required DateTime borrowDate,
    required DateTime returnDate,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    if (DateValidatorRules.isPast(borrowDate, today)) {
      return LoanDateError.borrowDateInPast;
    }
    if (!DateValidatorRules.isAfter(returnDate, borrowDate)) {
      return LoanDateError.returnNotAfterBorrow;
    }
    if (DateValidatorRules.periodInDays(borrowDate, returnDate) > DateValidatorRules.maxLoanDays) {
      return LoanDateError.periodTooLong;
    }
    return null;
  }
}

extension LoanDateErrorMessage on LoanDateError {
  String get message {
    switch (this) {
      case LoanDateError.borrowDateInPast:
        return 'Borrow date cannot be in the past';
      case LoanDateError.returnNotAfterBorrow:
        return 'Return date must be after the borrow date';
      case LoanDateError.periodTooLong:
        return 'Loan period cannot exceed ${DateValidatorRules.maxLoanDays} days';
    }
  }
}
