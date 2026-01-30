import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/technicians_repository.dart';
import '../data/models/technician.dart';
import '../../../core/data/mock_data.dart';

const bool _useMockData = true;

// Filter state
class TechniciansFilter {
  final String? trade;
  final String? search;
  final bool includeBlacklisted;

  const TechniciansFilter({
    this.trade,
    this.search,
    this.includeBlacklisted = true,
  });

  TechniciansFilter copyWith({
    String? trade,
    String? search,
    bool? includeBlacklisted,
    bool clearTrade = false,
    bool clearSearch = false,
  }) {
    return TechniciansFilter(
      trade: clearTrade ? null : (trade ?? this.trade),
      search: clearSearch ? null : (search ?? this.search),
      includeBlacklisted: includeBlacklisted ?? this.includeBlacklisted,
    );
  }
}

final techniciansFilterProvider = StateProvider<TechniciansFilter>(
  (ref) => const TechniciansFilter(),
);

// Technicians list provider
final techniciansProvider = FutureProvider.autoDispose<TechniciansResponse>((
  ref,
) async {
  if (_useMockData) {
    await Future.delayed(const Duration(milliseconds: 300));
    final filter = ref.watch(techniciansFilterProvider);
    var technicians = MockData.technicians;

    if (filter.trade != null && filter.trade!.isNotEmpty) {
      technicians = technicians.where((t) => t.trade == filter.trade).toList();
    }
    if (filter.search != null && filter.search!.isNotEmpty) {
      final search = filter.search!.toLowerCase();
      technicians = technicians
          .where((t) => t.name.toLowerCase().contains(search))
          .toList();
    }
    if (!filter.includeBlacklisted) {
      technicians = technicians.where((t) => !t.isBlacklisted).toList();
    }

    return TechniciansResponse(
      data: technicians,
      total: technicians.length,
      page: 1,
      limit: 50,
    );
  }

  final repository = ref.watch(techniciansRepositoryProvider);
  final filter = ref.watch(techniciansFilterProvider);

  return repository.getTechnicians(
    trade: filter.trade,
    search: filter.search,
    includeBlacklisted: filter.includeBlacklisted,
  );
});

// Single technician provider
final technicianProvider = FutureProvider.autoDispose
    .family<Technician, String>((ref, id) async {
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 200));
        return MockData.technicians.firstWhere((t) => t.id == id);
      }

      final repository = ref.watch(techniciansRepositoryProvider);
      return repository.getTechnician(id);
    });

// Trades list provider
final tradesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final repository = ref.watch(techniciansRepositoryProvider);
  try {
    return await repository.getTrades();
  } catch (_) {
    // Fallback to default trades if API fails
    return [
      'HVAC',
      'Plumbing',
      'Electrical',
      'Appliance',
      'Locksmith',
      'General',
    ];
  }
});

// Technicians notifier for mutations
class TechniciansNotifier extends StateNotifier<AsyncValue<void>> {
  final TechniciansRepository _repository;
  final Ref _ref;

  TechniciansNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<Technician> createTechnician(CreateTechnicianRequest request) async {
    state = const AsyncValue.loading();
    try {
      final technician = await _repository.createTechnician(request);
      state = const AsyncValue.data(null);
      _ref.invalidate(techniciansProvider);
      return technician;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Technician> updateTechnician(
    String id,
    UpdateTechnicianRequest request,
  ) async {
    state = const AsyncValue.loading();
    try {
      final technician = await _repository.updateTechnician(id, request);
      state = const AsyncValue.data(null);
      _ref.invalidate(techniciansProvider);
      _ref.invalidate(technicianProvider(id));
      return technician;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteTechnician(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteTechnician(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(techniciansProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> toggleBlacklist(
    String id, {
    required bool isBlacklisted,
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleBlacklist(
        id,
        isBlacklisted: isBlacklisted,
        reason: reason,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(techniciansProvider);
      _ref.invalidate(technicianProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final techniciansNotifierProvider =
    StateNotifierProvider<TechniciansNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(techniciansRepositoryProvider);
      return TechniciansNotifier(repository, ref);
    });
