import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/work_orders_repository.dart';
import '../data/models/work_order.dart';

// Filter state
class WorkOrdersFilter {
  final String? status;
  final String? search;
  final String? technicianId;

  const WorkOrdersFilter({this.status, this.search, this.technicianId});

  WorkOrdersFilter copyWith({
    String? status,
    String? search,
    String? technicianId,
    bool clearStatus = false,
    bool clearSearch = false,
    bool clearTechnicianId = false,
  }) {
    return WorkOrdersFilter(
      status: clearStatus ? null : (status ?? this.status),
      search: clearSearch ? null : (search ?? this.search),
      technicianId: clearTechnicianId
          ? null
          : (technicianId ?? this.technicianId),
    );
  }
}

final workOrdersFilterProvider = StateProvider<WorkOrdersFilter>(
  (ref) => const WorkOrdersFilter(),
);

// Work orders list provider
final workOrdersProvider = FutureProvider.autoDispose<WorkOrdersResponse>((
  ref,
) async {
  final repository = ref.watch(workOrdersRepositoryProvider);
  final filter = ref.watch(workOrdersFilterProvider);

  return repository.getWorkOrders(
    status: filter.status,
    search: filter.search,
    technicianId: filter.technicianId,
  );
});

// Single work order provider
final workOrderProvider = FutureProvider.autoDispose.family<WorkOrder, String>((
  ref,
  id,
) async {
  final repository = ref.watch(workOrdersRepositoryProvider);
  return repository.getWorkOrder(id);
});

// Work orders notifier for mutations
class WorkOrdersNotifier extends StateNotifier<AsyncValue<void>> {
  final WorkOrdersRepository _repository;
  final Ref _ref;

  WorkOrdersNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<WorkOrder> createWorkOrder(CreateWorkOrderRequest request) async {
    state = const AsyncValue.loading();
    try {
      final workOrder = await _repository.createWorkOrder(request);
      state = const AsyncValue.data(null);
      _ref.invalidate(workOrdersProvider);
      return workOrder;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<WorkOrder> updateWorkOrder(
    String id,
    UpdateWorkOrderRequest request,
  ) async {
    state = const AsyncValue.loading();
    try {
      final workOrder = await _repository.updateWorkOrder(id, request);
      state = const AsyncValue.data(null);
      _ref.invalidate(workOrdersProvider);
      _ref.invalidate(workOrderProvider(id));
      return workOrder;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteWorkOrder(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteWorkOrder(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(workOrdersProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateStatus(id, status);
      state = const AsyncValue.data(null);
      _ref.invalidate(workOrdersProvider);
      _ref.invalidate(workOrderProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final workOrdersNotifierProvider =
    StateNotifierProvider<WorkOrdersNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(workOrdersRepositoryProvider);
      return WorkOrdersNotifier(repository, ref);
    });
