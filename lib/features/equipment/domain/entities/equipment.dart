import 'package:pe/core/utils/category_inferrer.dart';
import 'package:pe/core/utils/deposit_calculator.dart';

/// Domain representation of a loanable campus device. `year` and `price`
/// are optional because the remote catalogue's nested `data` object is a
/// flexible/free-form map that may omit either field entirely.
class Equipment {
  Equipment({
    required this.id,
    required this.name,
    required this.rawData,
    this.year,
    this.price,
  }) : category = CategoryInferrer.infer(name),
       deposit = DepositCalculator.estimate(price);

  final String id;
  final String name;
  final int? year;
  final double? price;
  final String category;
  final double deposit;

  /// Original nested `data` object from the API response (may be null),
  /// kept so the detail screen can render any extra fields it contains.
  final Map<String, dynamic>? rawData;

  bool get hasPrice => price != null;
  bool get hasYear => year != null;
}
