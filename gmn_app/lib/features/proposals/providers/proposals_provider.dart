import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/data/mock_data.dart';
import '../data/proposals_repository.dart';
import '../data/models/proposal.dart';

const bool _useMockData = true;

final proposalsRepositoryProvider = Provider<ProposalsRepository>((ref) {
  return ProposalsRepository(apiClient: ref.watch(apiClientProvider));
});

// Proposals list
final proposalsProvider = FutureProvider.autoDispose<List<Proposal>>((
  ref,
) async {
  if (_useMockData) {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.proposalsList;
  }

  final repository = ref.watch(proposalsRepositoryProvider);
  return repository.getProposals();
});

// Single proposal
final proposalProvider = FutureProvider.autoDispose.family<Proposal, String>((
  ref,
  id,
) async {
  if (_useMockData) {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.proposalsList.firstWhere((p) => p.id == id);
  }

  final repository = ref.watch(proposalsRepositoryProvider);
  return repository.getProposal(id);
});

// Proposals operations notifier
class ProposalsNotifier extends StateNotifier<AsyncValue<void>> {
  final ProposalsRepository _repository;
  final Ref _ref;

  ProposalsNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<Proposal?> create(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final proposal = await _repository.createProposal(data);
      _ref.invalidate(proposalsProvider);
      state = const AsyncValue.data(null);
      return proposal;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Proposal?> update(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final proposal = await _repository.updateProposal(id, data);
      _ref.invalidate(proposalsProvider);
      _ref.invalidate(proposalProvider(id));
      state = const AsyncValue.data(null);
      return proposal;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteProposal(id);
      _ref.invalidate(proposalsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateStatus(id, status);
      _ref.invalidate(proposalsProvider);
      _ref.invalidate(proposalProvider(id));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final proposalsNotifierProvider =
    StateNotifierProvider<ProposalsNotifier, AsyncValue<void>>((ref) {
      return ProposalsNotifier(ref.watch(proposalsRepositoryProvider), ref);
    });
