/// Data-layer exceptions thrown by datasources; repositories translate these
/// into [Failure]s for the domain/presentation layers.
class ServerException implements Exception {
  ServerException([this.message = 'Server error']);
  final String message;
}

class NetworkException implements Exception {
  NetworkException([this.message = 'No internet connection']);
  final String message;
}

class NotFoundException implements Exception {
  NotFoundException([this.message = 'Resource not found']);
  final String message;
}

class CacheException implements Exception {
  CacheException([this.message = 'No cached data available']);
  final String message;
}
