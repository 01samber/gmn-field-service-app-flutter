import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'models/work_order.dart';

final workOrdersRepositoryProvider = Provider<WorkOrdersRepository>((ref) {
  return WorkOrdersRepository(apiClient: ApiClient());
});

class WorkOrdersRepository {
  final ApiClient _apiClient;

  WorkOrdersRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<WorkOrdersResponse> getWorkOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    String? technicianId,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (technicianId != null && technicianId.isNotEmpty) {
      queryParams['technicianId'] = technicianId;
    }

    final response = await _apiClient.get(
      ApiEndpoints.workOrders,
      queryParameters: queryParams,
    );
    return WorkOrdersResponse.fromJson(response.data);
  }

  Future<WorkOrder> getWorkOrder(String id) async {
    final response = await _apiClient.get(ApiEndpoints.workOrder(id));
    return WorkOrder.fromJson(response.data);
  }

  Future<WorkOrder> createWorkOrder(CreateWorkOrderRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.workOrders,
      data: request.toJson(),
    );
    return WorkOrder.fromJson(response.data);
  }

  Future<WorkOrder> updateWorkOrder(
    String id,
    UpdateWorkOrderRequest request,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.workOrder(id),
      data: request.toJson(),
    );
    return WorkOrder.fromJson(response.data);
  }

  Future<void> deleteWorkOrder(String id) async {
    await _apiClient.delete(ApiEndpoints.workOrder(id));
  }

  Future<WorkOrder> updateStatus(String id, String status) async {
    return updateWorkOrder(id, UpdateWorkOrderRequest(status: status));
  }
}
