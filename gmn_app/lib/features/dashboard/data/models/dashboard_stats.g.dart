// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    DashboardStats(
      overview: Overview.fromJson(json['overview'] as Map<String, dynamic>),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList(),
      financial: Financial.fromJson(json['financial'] as Map<String, dynamic>),
      topTechnicians: (json['topTechnicians'] as List<dynamic>)
          .map((e) => TopTechnician.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusBreakdown: StatusBreakdown.fromJson(
        json['statusBreakdown'] as Map<String, dynamic>,
      ),
      recentActivity: (json['recentActivity'] as List<dynamic>)
          .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardStatsToJson(DashboardStats instance) =>
    <String, dynamic>{
      'overview': instance.overview,
      'alerts': instance.alerts,
      'financial': instance.financial,
      'topTechnicians': instance.topTechnicians,
      'statusBreakdown': instance.statusBreakdown,
      'recentActivity': instance.recentActivity,
    };

Overview _$OverviewFromJson(Map<String, dynamic> json) => Overview(
  totalWorkOrders: (json['totalWorkOrders'] as num).toInt(),
  activeWorkOrders: (json['activeWorkOrders'] as num).toInt(),
  completedThisMonth: (json['completedThisMonth'] as num).toInt(),
  totalTechnicians: (json['totalTechnicians'] as num).toInt(),
  activeTechnicians: (json['activeTechnicians'] as num).toInt(),
  pendingCosts: (json['pendingCosts'] as num).toInt(),
);

Map<String, dynamic> _$OverviewToJson(Overview instance) => <String, dynamic>{
  'totalWorkOrders': instance.totalWorkOrders,
  'activeWorkOrders': instance.activeWorkOrders,
  'completedThisMonth': instance.completedThisMonth,
  'totalTechnicians': instance.totalTechnicians,
  'activeTechnicians': instance.activeTechnicians,
  'pendingCosts': instance.pendingCosts,
};

Alert _$AlertFromJson(Map<String, dynamic> json) => Alert(
  type: json['type'] as String,
  message: json['message'] as String,
  count: (json['count'] as num).toInt(),
  severity: json['severity'] as String,
);

Map<String, dynamic> _$AlertToJson(Alert instance) => <String, dynamic>{
  'type': instance.type,
  'message': instance.message,
  'count': instance.count,
  'severity': instance.severity,
};

Financial _$FinancialFromJson(Map<String, dynamic> json) => Financial(
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  pendingPayments: (json['pendingPayments'] as num).toDouble(),
  paidThisMonth: (json['paidThisMonth'] as num).toDouble(),
  averageJobValue: (json['averageJobValue'] as num).toDouble(),
);

Map<String, dynamic> _$FinancialToJson(Financial instance) => <String, dynamic>{
  'totalRevenue': instance.totalRevenue,
  'pendingPayments': instance.pendingPayments,
  'paidThisMonth': instance.paidThisMonth,
  'averageJobValue': instance.averageJobValue,
};

TopTechnician _$TopTechnicianFromJson(Map<String, dynamic> json) =>
    TopTechnician(
      id: json['id'] as String,
      name: json['name'] as String,
      trade: json['trade'] as String,
      jobsCompleted: (json['jobsCompleted'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      earnings: (json['earnings'] as num).toDouble(),
    );

Map<String, dynamic> _$TopTechnicianToJson(TopTechnician instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'trade': instance.trade,
      'jobsCompleted': instance.jobsCompleted,
      'rating': instance.rating,
      'earnings': instance.earnings,
    };

StatusBreakdown _$StatusBreakdownFromJson(Map<String, dynamic> json) =>
    StatusBreakdown(
      waiting: (json['waiting'] as num).toInt(),
      inProgress: (json['in_progress'] as num).toInt(),
      completed: (json['completed'] as num).toInt(),
      invoiced: (json['invoiced'] as num).toInt(),
      paid: (json['paid'] as num).toInt(),
    );

Map<String, dynamic> _$StatusBreakdownToJson(StatusBreakdown instance) =>
    <String, dynamic>{
      'waiting': instance.waiting,
      'in_progress': instance.inProgress,
      'completed': instance.completed,
      'invoiced': instance.invoiced,
      'paid': instance.paid,
    };

RecentActivity _$RecentActivityFromJson(Map<String, dynamic> json) =>
    RecentActivity(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      entityId: json['entityId'] as String?,
      entityType: json['entityType'] as String?,
    );

Map<String, dynamic> _$RecentActivityToJson(RecentActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'entityId': instance.entityId,
      'entityType': instance.entityType,
    };
