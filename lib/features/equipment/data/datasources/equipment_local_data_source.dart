import 'dart:convert';

import 'package:pe/core/constants/storage_keys.dart';
import 'package:pe/core/error/exceptions.dart';
import 'package:pe/core/storage/local_storage.dart';
import 'package:pe/features/equipment/data/models/equipment_model.dart';

abstract class EquipmentLocalDataSource {
  Future<void> cacheDevices(List<EquipmentModel> devices);
  Future<List<EquipmentModel>> getCachedDevices();
}

class EquipmentLocalDataSourceImpl implements EquipmentLocalDataSource {
  EquipmentLocalDataSourceImpl(this._storage);

  final LocalStorage _storage;

  @override
  Future<void> cacheDevices(List<EquipmentModel> devices) async {
    final encoded = jsonEncode(devices.map((d) => d.toJson()).toList());
    await _storage.setString(StorageKeys.cachedDevices, encoded);
    await _storage.setString(StorageKeys.cachedDevicesAt, DateTime.now().toIso8601String());
  }

  @override
  Future<List<EquipmentModel>> getCachedDevices() async {
    final raw = await _storage.getString(StorageKeys.cachedDevices);
    if (raw == null) throw CacheException();
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw CacheException();
    return decoded
        .whereType<Map>()
        .map((e) => EquipmentModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}
