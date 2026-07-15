/// Pure loan-period rule constants/helpers shared by the domain usecase and
/// tests. Kept dependency-free (no Flutter, no IO) so it is trivially unit
/// testable.
class DateValidatorRules {
  DateValidatorRules._();

  static const int maxLoanDays = 14;

  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

  static bool isPast(DateTime date, DateTime now) => startOfDay(date).isBefore(startOfDay(now));

  static bool isAfter(DateTime a, DateTime b) => startOfDay(a).isAfter(startOfDay(b));

  static int periodInDays(DateTime borrowDate, DateTime returnDate) =>
      startOfDay(returnDate).difference(startOfDay(borrowDate)).inDays;
}
