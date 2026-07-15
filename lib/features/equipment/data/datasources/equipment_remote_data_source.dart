import 'package:dio/dio.dart';
import 'package:pe/core/constants/api_constants.dart';
import 'package:pe/core/error/exceptions.dart';
import 'package:pe/core/network/dio_client.dart';
import 'package:pe/features/equipment/data/models/equipment_model.dart';

abstract class EquipmentRemoteDataSource {
  Future<List<EquipmentModel>> getAll();
  Future<EquipmentModel> getById(String id);
}

class EquipmentRemoteDataSourceImpl implements EquipmentRemoteDataSource {
  EquipmentRemoteDataSourceImpl(this._client);

  final DioClient _client;

  /// Sample catalogue seeded once into the authenticated collection so the
  /// Explore tab has devices when the collection is empty.
  static const _seedCatalogue = <Map<String, dynamic>>[
    {
      'name': 'Apple MacBook Pro 16',
      'data': {
        'year': 2019,
        'price': 1849.99,
        'CPU model': 'Intel Core i9',
        'Hard disk size': '1 TB',
      },
    },
    {
      'name': 'Google Pixel 6 Pro',
      'data': {'color': 'Cloudy White', 'capacity': '128 GB', 'price': 899.0, 'year': 2021},
    },
    {
      'name': 'Apple iPhone 12 Pro Max',
      'data': {'color': 'Pacific Blue', 'capacity GB': 256, 'price': 1099.0, 'year': 2020},
    },
    {
      'name': 'Samsung Galaxy Z Fold2',
      'data': {'price': 689.99, 'color': 'Brown', 'year': 2020},
    },
    {
      'name': 'Apple iPad Air',
      'data': {'Generation': '4th', 'Price': '519.99', 'Capacity': '256 GB', 'year': 2020},
    },
    {
      'name': 'Dell XPS 13 Laptop',
      'data': {'year': 2022, 'price': 1299.0, 'CPU model': 'Intel Core i7'},
    },
  ];

  @override
  Future<List<EquipmentModel>> getAll() async {
    try {
      var devices = await _fetchAll();
      if (devices.isEmpty) {
        await _seedIfEmpty();
        devices = await _fetchAll();
      }
      return devices;
    } on DioException catch (e) {
      throw _translate(e);
    }
  }

  @override
  Future<EquipmentModel> getById(String id) async {
    try {
      final response = await _client.dio.get(ApiConstants.objectById(id));
      final data = response.data;
      if (data is! Map) throw ServerException('Unexpected device response shape');
      return EquipmentModel.fromJson(data.cast<String, dynamic>());
    } on DioException catch (e) {
      throw _translate(e);
    }
  }

  Future<List<EquipmentModel>> _fetchAll() async {
    final response = await _client.dio.get(ApiConstants.objects);
    final data = response.data;
    if (data is! List) throw ServerException('Unexpected catalogue response shape');
    return data
        .whereType<Map>()
        .map((e) => EquipmentModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> _seedIfEmpty() async {
    for (final item in _seedCatalogue) {
      await _client.dio.post(ApiConstants.objects, data: item);
    }
  }

  Exception _translate(DioException e) {
    if (isNetworkDioError(e)) return NetworkException();
    if (e.response?.statusCode == 404) return NotFoundException();

    // Prefer the API body (`{"error":"..."}`) over Dio's generic status text.
    final body = e.response?.data;
    if (body is Map) {
      final apiError = body['error'];
      if (apiError is String && apiError.isNotEmpty) {
        return ServerException(apiError);
      }
    }
    return ServerException(e.message ?? 'Server error');
  }
}
