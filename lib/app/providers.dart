import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:pe/core/network/dio_client.dart';
import 'package:pe/core/storage/local_storage.dart';

/// Overridden in `main.dart` with the real, already-awaited instance so the
/// rest of the app can depend on synchronous providers instead of threading
/// `FutureProvider`s through every datasource.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final localStorageProvider = Provider<LocalStorage>((ref) {
  return SharedPreferencesStorage(ref.watch(sharedPreferencesProvider));
});

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final uuidProvider = Provider<Uuid>((ref) => const Uuid());
