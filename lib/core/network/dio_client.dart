import 'package:dio/dio.dart';
import 'package:pe/core/constants/api_constants.dart';

/// Thin wrapper around a configured [Dio] instance. Kept separate from
/// datasources so it can be swapped/mocked without touching business logic.
class DioClient {
  DioClient({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: ApiConstants.connectTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              headers: const {
                'Content-Type': 'application/json',
                'x-api-key': ApiConstants.apiKey,
              },
            ),
          );

  final Dio dio;
}

/// True when a [DioException] represents an offline/unreachable condition
/// (as opposed to a server-side error response).
bool isNetworkDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    case DioExceptionType.unknown:
      return error.error is Exception && error.response == null;
    default:
      return false;
  }
}
