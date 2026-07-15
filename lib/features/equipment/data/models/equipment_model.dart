import 'package:pe/features/equipment/domain/entities/equipment.dart';

/// Maps the flexible `{id, name, data}` shape returned by the authenticated
/// collection objects endpoint into an [Equipment] entity, tolerating a
/// missing/null `data` object and missing/non-numeric nested fields.
class EquipmentModel extends Equipment {
  EquipmentModel({
    required super.id,
    required super.name,
    required super.rawData,
    super.year,
    super.price,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final Map<String, dynamic>? data = rawData is Map ? rawData.cast<String, dynamic>() : null;

    return EquipmentModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unnamed device').toString(),
      rawData: data,
      year: _readInt(data, const ['year', 'Year', 'generation']),
      price: _readDouble(data, const ['price', 'Price', 'cost']),
    );
  }

  static int? _readInt(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;
    for (final key in keys) {
      final value = data[key];
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'data': rawData,
  };
}
