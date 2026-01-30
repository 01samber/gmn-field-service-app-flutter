// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technician.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Technician _$TechnicianFromJson(Map<String, dynamic> json) => Technician(
  id: json['id'] as String,
  name: json['name'] as String,
  trade: json['trade'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['zipCode'] as String?,
  notes: json['notes'] as String?,
  hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
  jobsDone: (json['jobsDone'] as num?)?.toInt() ?? 0,
  gmnMoneyMade: (json['gmnMoneyMade'] as num?)?.toDouble() ?? 0,
  rating: (json['rating'] as num?)?.toDouble() ?? 5,
  isBlacklisted: json['isBlacklisted'] as bool? ?? false,
  blacklistReason: json['blacklistReason'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  counts: json['_count'] == null
      ? null
      : TechnicianCounts.fromJson(json['_count'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TechnicianToJson(Technician instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'trade': instance.trade,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'zipCode': instance.zipCode,
      'notes': instance.notes,
      'hourlyRate': instance.hourlyRate,
      'jobsDone': instance.jobsDone,
      'gmnMoneyMade': instance.gmnMoneyMade,
      'rating': instance.rating,
      'isBlacklisted': instance.isBlacklisted,
      'blacklistReason': instance.blacklistReason,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      '_count': instance.counts,
    };

TechnicianCounts _$TechnicianCountsFromJson(Map<String, dynamic> json) =>
    TechnicianCounts(
      workOrders: (json['workOrders'] as num?)?.toInt() ?? 0,
      costs: (json['costs'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TechnicianCountsToJson(TechnicianCounts instance) =>
    <String, dynamic>{
      'workOrders': instance.workOrders,
      'costs': instance.costs,
    };

TechniciansResponse _$TechniciansResponseFromJson(Map<String, dynamic> json) =>
    TechniciansResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Technician.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$TechniciansResponseToJson(
  TechniciansResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
};

CreateTechnicianRequest _$CreateTechnicianRequestFromJson(
  Map<String, dynamic> json,
) => CreateTechnicianRequest(
  name: json['name'] as String,
  trade: json['trade'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['zipCode'] as String?,
  notes: json['notes'] as String?,
  hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CreateTechnicianRequestToJson(
  CreateTechnicianRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'trade': instance.trade,
  'phone': instance.phone,
  'email': instance.email,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'zipCode': instance.zipCode,
  'notes': instance.notes,
  'hourlyRate': instance.hourlyRate,
};

UpdateTechnicianRequest _$UpdateTechnicianRequestFromJson(
  Map<String, dynamic> json,
) => UpdateTechnicianRequest(
  name: json['name'] as String?,
  trade: json['trade'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['zipCode'] as String?,
  notes: json['notes'] as String?,
  hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
  rating: (json['rating'] as num?)?.toDouble(),
  isBlacklisted: json['isBlacklisted'] as bool?,
  blacklistReason: json['blacklistReason'] as String?,
);

Map<String, dynamic> _$UpdateTechnicianRequestToJson(
  UpdateTechnicianRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'trade': instance.trade,
  'phone': instance.phone,
  'email': instance.email,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'zipCode': instance.zipCode,
  'notes': instance.notes,
  'hourlyRate': instance.hourlyRate,
  'rating': instance.rating,
  'isBlacklisted': instance.isBlacklisted,
  'blacklistReason': instance.blacklistReason,
};
