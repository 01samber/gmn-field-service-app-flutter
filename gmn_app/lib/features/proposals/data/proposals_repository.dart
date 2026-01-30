import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'models/proposal.dart';

class ProposalsRepository {
  final ApiClient _apiClient;

  ProposalsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Proposal>> getProposals() async {
    final response = await _apiClient.get(ApiConstants.proposals);
    
    final List<dynamic> data = response.data is List 
        ? response.data 
        : (response.data['data'] ?? []);
    return data.map((json) => Proposal.fromJson(json)).toList();
  }

  Future<Proposal> getProposal(String id) async {
    final response = await _apiClient.get('${ApiConstants.proposals}/$id');
    return Proposal.fromJson(response.data);
  }

  Future<Proposal> createProposal(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.proposals,
      data: data,
    );
    return Proposal.fromJson(response.data);
  }

  Future<Proposal> updateProposal(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '${ApiConstants.proposals}/$id',
      data: data,
    );
    return Proposal.fromJson(response.data);
  }

  Future<void> deleteProposal(String id) async {
    await _apiClient.delete('${ApiConstants.proposals}/$id');
  }

  Future<Proposal> updateStatus(String id, String status) async {
    return updateProposal(id, {'status': status});
  }
}
