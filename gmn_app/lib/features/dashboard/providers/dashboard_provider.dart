import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_data.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_stats.dart';

const bool _useMockData = true;

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((
  ref,
) async {
  if (_useMockData) {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.dashboardStats;
  }

  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getStats();
});

// Convenience providers for specific parts of stats
final overviewProvider = Provider.autoDispose<AsyncValue<Overview>>((ref) {
  return ref.watch(dashboardStatsProvider).whenData((stats) => stats.overview);
});

final financialProvider = Provider.autoDispose<AsyncValue<Financial>>((ref) {
  return ref.watch(dashboardStatsProvider).whenData((stats) => stats.financial);
});

final alertsProvider = Provider.autoDispose<AsyncValue<List<Alert>>>((ref) {
  return ref.watch(dashboardStatsProvider).whenData((stats) => stats.alerts);
});

final statusBreakdownProvider =
    Provider.autoDispose<AsyncValue<StatusBreakdown>>((ref) {
      return ref
          .watch(dashboardStatsProvider)
          .whenData((stats) => stats.statusBreakdown);
    });

final topTechniciansProvider =
    Provider.autoDispose<AsyncValue<List<TopTechnician>>>((ref) {
      return ref
          .watch(dashboardStatsProvider)
          .whenData((stats) => stats.topTechnicians);
    });

final recentActivityProvider =
    Provider.autoDispose<AsyncValue<List<RecentActivity>>>((ref) {
      return ref
          .watch(dashboardStatsProvider)
          .whenData((stats) => stats.recentActivity);
    });
