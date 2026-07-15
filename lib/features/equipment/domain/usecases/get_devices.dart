import 'package:pe/core/utils/result.dart';
import 'package:pe/features/equipment/domain/repositories/equipment_repository.dart';

class GetDevices {
  const GetDevices(this._repository);

  final EquipmentRepository _repository;

  Future<Result<EquipmentListResult>> call() => _repository.getDevices();
}
