import 'package:pe/core/error/failures.dart';
import 'package:pe/core/utils/result.dart';
import 'package:pe/features/equipment/domain/entities/equipment.dart';

/// Result of a catalogue load that also tells the UI whether the data came
/// from the offline cache, so it can show an offline banner.
class EquipmentListResult {
  const EquipmentListResult({required this.devices, required this.isFromCache});

  final List<Equipment> devices;
  final bool isFromCache;
}

abstract class EquipmentRepository {
  Future<Result<EquipmentListResult>> getDevices();
  Future<Result<Equipment>> getDeviceById(String id);
}

typedef EquipmentResult = Result<Equipment>;
typedef EquipmentFailure = Failure;
