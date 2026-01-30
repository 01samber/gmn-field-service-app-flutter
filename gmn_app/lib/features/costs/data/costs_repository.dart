import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'models/cost.dart';

class CostsRepository {
  final ApiClient _apiClient;

  CostsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Cost>> getCosts({CostsFilter? filter}) async {
    final response = await _apiClient.get(
      ApiConstants.costs,
      queryParameters: filter?.toQueryParameters(),
    );

    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['data'] ?? []);
    return data.map((json) => Cost.fromJson(json)).toList();
  }

  Future<Cost> getCost(String id) async {
    final response = await _apiClient.get('${ApiConstants.costs}/$id');
    return Cost.fromJson(response.data);
  }

  Future<Cost> createCost(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.costs, data: data);
    return Cost.fromJson(response.data);
  }

  Future<Cost> updateCost(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '${ApiConstants.costs}/$id',
      data: data,
    );
    return Cost.fromJson(response.data);
  }

  Future<void> deleteCost(String id) async {
    await _apiClient.delete('${ApiConstants.costs}/$id');
  }

  Future<Cost> approveCost(String id) async {
    return updateCost(id, {'status': 'approved'});
  }

  Future<Cost> markAsPaid(String id) async {
    return updateCost(id, {'status': 'paid'});
  }
}
