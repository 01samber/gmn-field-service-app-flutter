// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkOrder _$WorkOrderFromJson(Map<String, dynamic> json) => WorkOrder(
  id: json['id'] as String,
  woNumber: json['woNumber'] as String,
  client: json['client'] as String,
  trade: json['trade'] as String,
  description: json['description'] as String?,
  nte: (json['nte'] as num?)?.toDouble() ?? 0,
  status: json['status'] as String? ?? 'waiting',
  priority: json['priority'] as String? ?? 'normal',
  city: json['city'] as String?,
  state: json['state'] as String?,
  address: json['address'] as String?,
  etaAt: json['etaAt'] == null ? null : DateTime.parse(json['etaAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  notes: json['notes'] as String?,
  technicianId: json['technicianId'] as String?,
  createdById: json['createdById'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  technician: json['technician'] == null
      ? null
      : Technician.fromJson(json['technician'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WorkOrderToJson(WorkOrder instance) => <String, dynamic>{
  'id': instance.id,
  'woNumber': instance.woNumber,
  'client': instance.client,
  'trade': instance.trade,
  'description': instance.description,
  'nte': instance.nte,
  'status': instance.status,
  'priority': instance.priority,
  'city': instance.city,
  'state': instance.state,
  'address': instance.address,
  'etaAt': instance.etaAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'notes': instance.notes,
  'technicianId': instance.technicianId,
  'createdById': instance.createdById,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'technician': instance.technician,
};

WorkOrdersResponse _$WorkOrdersResponseFromJson(Map<String, dynamic> json) =>
    WorkOrdersResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => WorkOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$WorkOrdersResponseToJson(WorkOrdersResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };

CreateWorkOrderRequest _$CreateWorkOrderRequestFromJson(
  Map<String, dynamic> json,
) => CreateWorkOrderRequest(
  client: json['client'] as String,
  trade: json['trade'] as String,
  description: json['description'] as String?,
  nte: (json['nte'] as num?)?.toDouble(),
  status: json['status'] as String?,
  priority: json['priority'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  address: json['address'] as String?,
  etaAt: json['etaAt'] == null ? null : DateTime.parse(json['etaAt'] as String),
  technicianId: json['technicianId'] as String?,
);

Map<String, dynamic> _$CreateWorkOrderRequestToJson(
  CreateWorkOrderRequest instance,
) => <String, dynamic>{
  'client': instance.client,
  'trade': instance.trade,
  'description': instance.description,
  'nte': instance.nte,
  'status': instance.status,
  'priority': instance.priority,
  'city': instance.city,
  'state': instance.state,
  'address': instance.address,
  'etaAt': instance.etaAt?.toIso8601String(),
  'technicianId': instance.technicianId,
};

UpdateWorkOrderRequest _$UpdateWorkOrderRequestFromJson(
  Map<String, dynamic> json,
) => UpdateWorkOrderRequest(
  client: json['client'] as String?,
  trade: json['trade'] as String?,
  description: json['description'] as String?,
  nte: (json['nte'] as num?)?.toDouble(),
  status: json['status'] as String?,
  priority: json['priority'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  address: json['address'] as String?,
  etaAt: json['etaAt'] == null ? null : DateTime.parse(json['etaAt'] as String),
  technicianId: json['technicianId'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$UpdateWorkOrderRequestToJson(
  UpdateWorkOrderRequest instance,
) => <String, dynamic>{
  'client': instance.client,
  'trade': instance.trade,
  'description': instance.description,
  'nte': instance.nte,
  'status': instance.status,
  'priority': instance.priority,
  'city': instance.city,
  'state': instance.state,
  'address': instance.address,
  'etaAt': instance.etaAt?.toIso8601String(),
  'technicianId': instance.technicianId,
  'notes': instance.notes,
};
