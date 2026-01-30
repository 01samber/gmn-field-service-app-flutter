import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'models/technician.dart';

final techniciansRepositoryProvider = Provider<TechniciansRepository>((ref) {
  return TechniciansRepository(apiClient: ApiClient());
});

class TechniciansRepository {
  final ApiClient _apiClient;

  TechniciansRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<TechniciansResponse> getTechnicians({
    int page = 1,
    int limit = 20,
    String? trade,
    String? search,
    bool includeBlacklisted = true,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'includeBlacklisted': includeBlacklisted,
    };
    if (trade != null && trade.isNotEmpty) queryParams['trade'] = trade;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.get(
      ApiEndpoints.technicians,
      queryParameters: queryParams,
    );
    return TechniciansResponse.fromJson(response.data);
  }

  Future<Technician> getTechnician(String id) async {
    final response = await _apiClient.get(ApiEndpoints.technician(id));
    return Technician.fromJson(response.data);
  }

  Future<Technician> createTechnician(CreateTechnicianRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.technicians,
      data: request.toJson(),
    );
    return Technician.fromJson(response.data);
  }

  Future<Technician> updateTechnician(
    String id,
    UpdateTechnicianRequest request,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.technician(id),
      data: request.toJson(),
    );
    return Technician.fromJson(response.data);
  }

  Future<void> deleteTechnician(String id) async {
    await _apiClient.delete(ApiEndpoints.technician(id));
  }

  Future<Technician> toggleBlacklist(
    String id, {
    required bool isBlacklisted,
    String? reason,
  }) async {
    return updateTechnician(
      id,
      UpdateTechnicianRequest(
        isBlacklisted: isBlacklisted,
        blacklistReason: isBlacklisted ? reason : null,
      ),
    );
  }

  Future<List<String>> getTrades() async {
    final response = await _apiClient.get(
      '${ApiEndpoints.technicians}/meta/trades',
    );
    return List<String>.from(response.data);
  }
}
