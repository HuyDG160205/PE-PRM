import 'package:pe/core/error/exceptions.dart';
import 'package:pe/core/error/failures.dart';
import 'package:pe/core/utils/result.dart';
import 'package:pe/features/equipment/data/datasources/equipment_local_data_source.dart';
import 'package:pe/features/equipment/data/datasources/equipment_remote_data_source.dart';
import 'package:pe/features/equipment/domain/entities/equipment.dart';
import 'package:pe/features/equipment/domain/repositories/equipment_repository.dart';

class EquipmentRepositoryImpl implements EquipmentRepository {
  EquipmentRepositoryImpl({
    required EquipmentRemoteDataSource remoteDataSource,
    required EquipmentLocalDataSource localDataSource,
  }) : _remote = remoteDataSource,
       _local = localDataSource;

  final EquipmentRemoteDataSource _remote;
  final EquipmentLocalDataSource _local;

  @override
  Future<Result<EquipmentListResult>> getDevices() async {
    try {
      final devices = await _remote.getAll();
      await _local.cacheDevices(devices);
      return Success(EquipmentListResult(devices: devices, isFromCache: false));
    } on NetworkException catch (_) {
      return _fallbackToCache();
    } on ServerException catch (e) {
      // Server errors (not connectivity) also fall back to cache if available,
      // otherwise surface the server failure.
      final fallback = await _tryCache();
      if (fallback != null) return Success(fallback);
      return Failed(ServerFailure(e.message));
    } catch (_) {
      final fallback = await _tryCache();
      if (fallback != null) return Success(fallback);
      return const Failed(UnknownFailure());
    }
  }

  Future<Result<EquipmentListResult>> _fallbackToCache() async {
    final fallback = await _tryCache();
    if (fallback != null) return Success(fallback);
    return const Failed(NetworkFailure());
  }

  Future<EquipmentListResult?> _tryCache() async {
    try {
      final cached = await _local.getCachedDevices();
      return EquipmentListResult(devices: cached, isFromCache: true);
    } on CacheException {
      return null;
    }
  }

  @override
  Future<Result<Equipment>> getDeviceById(String id) async {
    try {
      final device = await _remote.getById(id);
      return Success(device);
    } on NetworkException catch (_) {
      final cached = await _findInCache(id);
      if (cached != null) return Success(cached);
      return const Failed(NetworkFailure());
    } on NotFoundException catch (e) {
      return Failed(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    } catch (_) {
      return const Failed(UnknownFailure());
    }
  }

  Future<Equipment?> _findInCache(String id) async {
    try {
      final cached = await _local.getCachedDevices();
      for (final device in cached) {
        if (device.id == id) return device;
      }
      return null;
    } on CacheException {
      return null;
    }
  }
}
