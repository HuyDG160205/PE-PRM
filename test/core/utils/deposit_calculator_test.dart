import 'package:flutter_test/flutter_test.dart';
import 'package:pe/core/utils/deposit_calculator.dart';

void main() {
  group('DepositCalculator.estimate', () {
    test('returns \$50 when price is at or above the threshold', () {
      expect(DepositCalculator.estimate(100), 50);
      expect(DepositCalculator.estimate(999), 50);
    });

    test('returns \$20 when price is below the threshold', () {
      expect(DepositCalculator.estimate(99.99), 20);
      expect(DepositCalculator.estimate(0), 20);
    });

    test('returns \$20 when price is missing (null)', () {
      expect(DepositCalculator.estimate(null), 20);
    });
  });

  group('DepositCalculator.sortKey', () {
    test('missing price sorts after any known price for low-to-high order', () {
      final keys = [
        DepositCalculator.sortKey(null),
        DepositCalculator.sortKey(10),
        DepositCalculator.sortKey(500),
      ]..sort();

      expect(keys.last, double.infinity);
    });
  });
}
