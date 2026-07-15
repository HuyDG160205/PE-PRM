import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pe/core/error/exceptions.dart';
import 'package:pe/core/utils/result.dart';
import 'package:pe/features/equipment/data/datasources/equipment_local_data_source.dart';
import 'package:pe/features/equipment/data/datasources/equipment_remote_data_source.dart';
import 'package:pe/features/equipment/data/models/equipment_model.dart';
import 'package:pe/features/equipment/data/repositories/equipment_repository_impl.dart';
import 'package:pe/features/equipment/domain/repositories/equipment_repository.dart';

class MockRemoteDataSource extends Mock implements EquipmentRemoteDataSource {}

class MockLocalDataSource extends Mock implements EquipmentLocalDataSource {}

void main() {
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late EquipmentRepositoryImpl repository;

  final cachedDevices = [
    EquipmentModel.fromJson({'id': '1', 'name': 'Cached Laptop', 'data': {'price': 200}}),
  ];

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    repository = EquipmentRepositoryImpl(remoteDataSource: remote, localDataSource: local);
  });

  group('getDevices', () {
    test('returns remote devices and caches them on success', () async {
      final devices = [
        EquipmentModel.fromJson({'id': '2', 'name': 'Remote Phone', 'data': null}),
      ];
      when(() => remote.getAll()).thenAnswer((_) async => devices);
      when(() => local.cacheDevices(any())).thenAnswer((_) async {});

      final result = await repository.getDevices();

      expect(result, isA<Success<EquipmentListResult>>());
      final success = result as Success<EquipmentListResult>;
      expect(success.value.isFromCache, isFalse);
      expect(success.value.devices, devices);
      verify(() => local.cacheDevices(devices)).called(1);
    });

    test('falls back to cached devices when the remote call is offline', () async {
      when(() => remote.getAll()).thenThrow(NetworkException());
      when(() => local.getCachedDevices()).thenAnswer((_) async => cachedDevices);

      final result = await repository.getDevices();

      expect(result, isA<Success<EquipmentListResult>>());
      final success = result as Success<EquipmentListResult>;
      expect(success.value.isFromCache, isTrue);
      expect(success.value.devices, cachedDevices);
    });

    test('returns a NetworkFailure when offline and no cache is available', () async {
      when(() => remote.getAll()).thenThrow(NetworkException());
      when(() => local.getCachedDevices()).thenThrow(CacheException());

      final result = await repository.getDevices();

      expect(result.isFailure, isTrue);
    });
  });
}
