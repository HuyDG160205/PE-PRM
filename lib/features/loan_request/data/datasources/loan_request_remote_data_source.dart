import 'package:dio/dio.dart';
import 'package:pe/core/constants/api_constants.dart';
import 'package:pe/core/error/exceptions.dart';
import 'package:pe/core/network/dio_client.dart';
import 'package:pe/features/loan_request/data/models/loan_request_result_model.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_payload.dart';

abstract class LoanRequestRemoteDataSource {
  Future<LoanRequestResultModel> submit(LoanRequestPayload payload);
}

class LoanRequestRemoteDataSourceImpl implements LoanRequestRemoteDataSource {
  LoanRequestRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<LoanRequestResultModel> submit(LoanRequestPayload payload) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.loanRequests,
        data: payload.toRequestBody(),
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode != 200 && statusCode != 201) {
        throw ServerException('Unexpected response status $statusCode');
      }
      final data = response.data;
      if (data is! Map) throw ServerException('Unexpected loan-request response shape');
      return LoanRequestResultModel.fromJson(data.cast<String, dynamic>());
    } on DioException catch (e) {
      if (isNetworkDioError(e)) throw NetworkException();
      final body = e.response?.data;
      if (body is Map) {
        final apiError = body['error'];
        if (apiError is String && apiError.isNotEmpty) {
          throw ServerException(apiError);
        }
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
