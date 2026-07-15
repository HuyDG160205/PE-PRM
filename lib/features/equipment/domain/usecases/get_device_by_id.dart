import 'package:pe/core/utils/result.dart';
import 'package:pe/features/equipment/domain/entities/equipment.dart';
import 'package:pe/features/equipment/domain/repositories/equipment_repository.dart';

class GetDeviceById {
  const GetDeviceById(this._repository);

  final EquipmentRepository _repository;

  Future<Result<Equipment>> call(String id) => _repository.getDeviceById(id);
}
