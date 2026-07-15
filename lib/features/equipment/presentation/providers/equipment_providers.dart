import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pe/app/providers.dart';
import 'package:pe/core/constants/storage_keys.dart';
import 'package:pe/core/error/failures.dart';
import 'package:pe/core/utils/deposit_calculator.dart';
import 'package:pe/features/equipment/data/datasources/equipment_local_data_source.dart';
import 'package:pe/features/equipment/data/datasources/equipment_remote_data_source.dart';
import 'package:pe/features/equipment/data/repositories/equipment_repository_impl.dart';
import 'package:pe/features/equipment/domain/entities/equipment.dart';
import 'package:pe/features/equipment/domain/repositories/equipment_repository.dart';
import 'package:pe/features/equipment/domain/usecases/get_device_by_id.dart';
import 'package:pe/features/equipment/domain/usecases/get_devices.dart';

enum SortOption { none, depositLowToHigh, nameAToZ }

final equipmentRemoteDataSourceProvider = Provider<EquipmentRemoteDataSource>((ref) {
  return EquipmentRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final equipmentLocalDataSourceProvider = Provider<EquipmentLocalDataSource>((ref) {
  return EquipmentLocalDataSourceImpl(ref.watch(localStorageProvider));
});

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepositoryImpl(
    remoteDataSource: ref.watch(equipmentRemoteDataSourceProvider),
    localDataSource: ref.watch(equipmentLocalDataSourceProvider),
  );
});

final getDevicesProvider = Provider<GetDevices>((ref) {
  return GetDevices(ref.watch(equipmentRepositoryProvider));
});

final getDeviceByIdProvider = Provider<GetDeviceById>((ref) {
  return GetDeviceById(ref.watch(equipmentRepositoryProvider));
});

/// Persists the selected compare-list ids across restarts. Kept as its own
/// small notifier (loaded once from storage) so [CompareListNotifier] can
/// simply `watch` it for the initial value and `save` on every mutation.
class CompareListStorageNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final storage = ref.read(localStorageProvider);
    final raw = await storage.getString(StorageKeys.compareIds);
    if (raw == null || raw.isEmpty) return;
    state = raw.split(',').where((e) => e.isNotEmpty).toList();
  }

  Future<void> save(List<String> ids) async {
    state = ids;
    final storage = ref.read(localStorageProvider);
    await storage.setString(StorageKeys.compareIds, ids.join(','));
  }
}

final compareListStorageProvider = NotifierProvider<CompareListStorageNotifier, List<String>>(
  CompareListStorageNotifier.new,
);

/// State exposed by [equipmentListProvider]: the loaded devices plus whether
/// they came from the offline cache (drives the offline banner).
class EquipmentListState {
  const EquipmentListState({required this.devices, required this.isFromCache});

  final List<Equipment> devices;
  final bool isFromCache;
}

class EquipmentListNotifier extends AsyncNotifier<EquipmentListState> {
  @override
  Future<EquipmentListState> build() async {
    final result = await ref.watch(getDevicesProvider).call();
    return result.fold(
      (failure) => throw FailureException(failure),
      (data) => EquipmentListState(devices: data.devices, isFromCache: data.isFromCache),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final equipmentListProvider = AsyncNotifierProvider<EquipmentListNotifier, EquipmentListState>(
  EquipmentListNotifier.new,
);

/// Owns the search query's debounce lifecycle: the UI calls [setQuery] on
/// every keystroke, but the exposed state (and therefore dependent providers
/// like [filteredDevicesProvider]) only updates 400ms after the user stops
/// typing, so the remote-backed list is never re-filtered on every keypress.
class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  void setQuery(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      state = query;
    });
  }

  void clear() {
    _debounce?.cancel();
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Immediate (non-debounced) text currently typed, so the search field can
/// stay responsive while [searchQueryProvider] settles.
final searchInputProvider = StateProvider<String>((ref) => '');

final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.none);

/// Category chip filter on the catalogue. Empty string means "All".
final categoryFilterProvider = StateProvider<String>((ref) => '');

/// At most two device ids may be compared at once; the cap is enforced here
/// (not in the widget) and every mutation is persisted so the selection
/// survives an app restart.
class CompareListNotifier extends Notifier<List<String>> {
  static const int maxCompareItems = 2;

  @override
  List<String> build() {
    final stored = ref.watch(compareListStorageProvider);
    return stored;
  }

  Future<void> toggle(String id) async {
    final current = List<String>.from(state);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      if (current.length >= maxCompareItems) {
        return; // Cap enforced here: silently reject a 3rd selection.
      }
      current.add(id);
    }
    state = current;
    await ref.read(compareListStorageProvider.notifier).save(current);
  }

  bool isFull() => state.length >= maxCompareItems;
}

final compareListProvider = NotifierProvider<CompareListNotifier, List<String>>(
  CompareListNotifier.new,
);

final deviceDetailProvider = FutureProvider.family<Equipment, String>((ref, id) async {
  final result = await ref.watch(getDeviceByIdProvider).call(id);
  return result.fold((failure) => throw FailureException(failure), (device) => device);
});

/// Search (debounced) -> category filter -> sort, applied over a defensive
/// copy of the loaded list so the original API order is preserved for
/// [SortOption.none].
final filteredDevicesProvider = Provider<List<Equipment>>((ref) {
  final listState = ref.watch(equipmentListProvider).valueOrNull;
  if (listState == null) return const [];

  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(categoryFilterProvider);
  final sort = ref.watch(sortOptionProvider);

  var devices = List<Equipment>.from(listState.devices);
  if (query.isNotEmpty) {
    devices = devices.where((d) => d.name.toLowerCase().contains(query)).toList();
  }
  if (category.isNotEmpty) {
    devices = devices.where((d) => d.category == category).toList();
  }

  switch (sort) {
    case SortOption.none:
      break;
    case SortOption.depositLowToHigh:
      devices.sort(
        (a, b) => DepositCalculator.sortKey(a.price).compareTo(DepositCalculator.sortKey(b.price)),
      );
    case SortOption.nameAToZ:
      devices.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
  return devices;
});
