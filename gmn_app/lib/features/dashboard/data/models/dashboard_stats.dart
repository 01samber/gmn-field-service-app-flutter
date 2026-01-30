import 'package:json_annotation/json_annotation.dart';

part 'dashboard_stats.g.dart';

@JsonSerializable()
class DashboardStats {
  final Overview overview;
  final List<Alert> alerts;
  final Financial financial;
  final List<TopTechnician> topTechnicians;
  final StatusBreakdown statusBreakdown;
  final List<RecentActivity> recentActivity;

  const DashboardStats({
    required this.overview,
    required this.alerts,
    required this.financial,
    required this.topTechnicians,
    required this.statusBreakdown,
    required this.recentActivity,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);
}

@JsonSerializable()
class Overview {
  final int totalWorkOrders;
  final int activeWorkOrders;
  final int completedThisMonth;
  final int totalTechnicians;
  final int activeTechnicians;
  final int pendingCosts;

  const Overview({
    required this.totalWorkOrders,
    required this.activeWorkOrders,
    required this.completedThisMonth,
    required this.totalTechnicians,
    required this.activeTechnicians,
    required this.pendingCosts,
  });

  factory Overview.fromJson(Map<String, dynamic> json) =>
      _$OverviewFromJson(json);
  Map<String, dynamic> toJson() => _$OverviewToJson(this);
}

@JsonSerializable()
class Alert {
  final String type;
  final String message;
  final int count;
  final String severity;

  const Alert({
    required this.type,
    required this.message,
    required this.count,
    required this.severity,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
  Map<String, dynamic> toJson() => _$AlertToJson(this);
}

@JsonSerializable()
class Financial {
  final double totalRevenue;
  final double pendingPayments;
  final double paidThisMonth;
  final double averageJobValue;

  const Financial({
    required this.totalRevenue,
    required this.pendingPayments,
    required this.paidThisMonth,
    required this.averageJobValue,
  });

  factory Financial.fromJson(Map<String, dynamic> json) =>
      _$FinancialFromJson(json);
  Map<String, dynamic> toJson() => _$FinancialToJson(this);
}

@JsonSerializable()
class TopTechnician {
  final String id;
  final String name;
  final String trade;
  final int jobsCompleted;
  final double rating;
  final double earnings;

  const TopTechnician({
    required this.id,
    required this.name,
    required this.trade,
    required this.jobsCompleted,
    required this.rating,
    required this.earnings,
  });

  factory TopTechnician.fromJson(Map<String, dynamic> json) =>
      _$TopTechnicianFromJson(json);
  Map<String, dynamic> toJson() => _$TopTechnicianToJson(this);
}

@JsonSerializable()
class StatusBreakdown {
  final int waiting;
  @JsonKey(name: 'in_progress')
  final int inProgress;
  final int completed;
  final int invoiced;
  final int paid;

  const StatusBreakdown({
    required this.waiting,
    required this.inProgress,
    required this.completed,
    required this.invoiced,
    required this.paid,
  });

  factory StatusBreakdown.fromJson(Map<String, dynamic> json) =>
      _$StatusBreakdownFromJson(json);
  Map<String, dynamic> toJson() => _$StatusBreakdownToJson(this);

  int get total => waiting + inProgress + completed + invoiced + paid;
}

@JsonSerializable()
class RecentActivity {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? entityId;
  final String? entityType;

  const RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.entityId,
    this.entityType,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityFromJson(json);
  Map<String, dynamic> toJson() => _$RecentActivityToJson(this);
}
