import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../data/costs_repository.dart';
import '../data/models/cost.dart';

final costsRepositoryProvider = Provider<CostsRepository>((ref) {
  return CostsRepository(apiClient: ref.watch(apiClientProvider));
});

// Filter state
final costsFilterProvider = StateProvider<CostsFilter>((ref) {
  return CostsFilter();
});

// Costs list
final costsProvider = FutureProvider.autoDispose<List<Cost>>((ref) async {
  final repository = ref.watch(costsRepositoryProvider);
  final filter = ref.watch(costsFilterProvider);
  return repository.getCosts(filter: filter);
});

// Cost summary
final costSummaryProvider = Provider.autoDispose<CostSummary>((ref) {
  final costsAsync = ref.watch(costsProvider);

  return costsAsync.when(
    data: (costs) {
      double requested = 0;
      double approved = 0;
      double paid = 0;

      for (final cost in costs) {
        switch (cost.status) {
          case 'requested':
            requested += cost.amount;
            break;
          case 'approved':
            approved += cost.amount;
            break;
          case 'paid':
            paid += cost.amount;
            break;
        }
      }

      return CostSummary(requested: requested, approved: approved, paid: paid);
    },
    loading: () => CostSummary(requested: 0, approved: 0, paid: 0),
    error: (_, __) => CostSummary(requested: 0, approved: 0, paid: 0),
  );
});

// Costs operations notifier
class CostsNotifier extends StateNotifier<AsyncValue<void>> {
  final CostsRepository _repository;
  final Ref _ref;

  CostsNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<Cost?> create(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final cost = await _repository.createCost(data);
      _ref.invalidate(costsProvider);
      state = const AsyncValue.data(null);
      return cost;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Cost?> update(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final cost = await _repository.updateCost(id, data);
      _ref.invalidate(costsProvider);
      state = const AsyncValue.data(null);
      return cost;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteCost(id);
      _ref.invalidate(costsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> approve(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.approveCost(id);
      _ref.invalidate(costsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> markAsPaid(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsPaid(id);
      _ref.invalidate(costsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final costsNotifierProvider =
    StateNotifierProvider<CostsNotifier, AsyncValue<void>>((ref) {
      return CostsNotifier(ref.watch(costsRepositoryProvider), ref);
    });
