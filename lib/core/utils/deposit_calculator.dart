/// Single source of truth for the $50/$20 estimated-deposit rule so display
/// and sorting logic never disagree about missing-price handling.
class DepositCalculator {
  DepositCalculator._();

  static const double highDeposit = 50;
  static const double lowDeposit = 20;
  static const double priceThreshold = 100;

  /// Estimated deposit for display and for the loan-request payload.
  /// Devices with a known price >= [priceThreshold] require the $50 deposit,
  /// everything else (including devices with no price at all) uses $20.
  static double estimate(double? price) {
    if (price != null && price >= priceThreshold) return highDeposit;
    return lowDeposit;
  }

  /// Sort key for ascending "deposit low to high" ordering. A missing price
  /// is treated as +infinity so devices with unknown price consistently sort
  /// last, even though [estimate] still shows them a defined $20 deposit.
  static double sortKey(double? price) {
    if (price == null) return double.infinity;
    return estimate(price);
  }
}
