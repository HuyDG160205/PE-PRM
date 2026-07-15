class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.restful-api.dev';

  /// Authenticated collections (avoids the public /objects 50/day quota).
  static const String equipmentCollection = 'equipment';
  static const String loanRequestsCollection = 'loan-requests';
  static const String apiKey = 'ba6eeea3-82a4-40f5-8079-644a0979b2e5';

  static const String objects = '/collections/$equipmentCollection/objects';
  static const String loanRequests = '/collections/$loanRequestsCollection/objects';

  static String objectById(String id) => '$objects/$id';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
