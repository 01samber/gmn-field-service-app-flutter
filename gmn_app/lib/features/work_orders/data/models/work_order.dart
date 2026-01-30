import 'package:json_annotation/json_annotation.dart';
import '../../../technicians/data/models/technician.dart';

part 'work_order.g.dart';

@JsonSerializable()
class WorkOrder {
  final String id;
  final String woNumber;
  final String client;
  final String trade;
  final String? description;
  final double nte;
  final String status;
  final String priority;
  final String? city;
  final String? state;
  final String? address;
  final DateTime? etaAt;
  final DateTime? completedAt;
  final String? notes;
  final String? technicianId;
  final String? createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Technician? technician;

  const WorkOrder({
    required this.id,
    required this.woNumber,
    required this.client,
    required this.trade,
    this.description,
    this.nte = 0,
    this.status = 'waiting',
    this.priority = 'normal',
    this.city,
    this.state,
    this.address,
    this.etaAt,
    this.completedAt,
    this.notes,
    this.technicianId,
    this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.technician,
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) =>
      _$WorkOrderFromJson(json);
  Map<String, dynamic> toJson() => _$WorkOrderToJson(this);

  WorkOrder copyWith({
    String? id,
    String? woNumber,
    String? client,
    String? trade,
    String? description,
    double? nte,
    String? status,
    String? priority,
    String? city,
    String? state,
    String? address,
    DateTime? etaAt,
    DateTime? completedAt,
    String? notes,
    String? technicianId,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
    Technician? technician,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      woNumber: woNumber ?? this.woNumber,
      client: client ?? this.client,
      trade: trade ?? this.trade,
      description: description ?? this.description,
      nte: nte ?? this.nte,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      city: city ?? this.city,
      state: state ?? this.state,
      address: address ?? this.address,
      etaAt: etaAt ?? this.etaAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      technicianId: technicianId ?? this.technicianId,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      technician: technician ?? this.technician,
    );
  }

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkOrder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class WorkOrdersResponse {
  final List<WorkOrder> data;
  final int total;
  final int page;
  final int limit;

  const WorkOrdersResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory WorkOrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkOrdersResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WorkOrdersResponseToJson(this);

  int get totalPages => (total / limit).ceil();
  bool get hasMore => page < totalPages;
}

@JsonSerializable()
class CreateWorkOrderRequest {
  final String client;
  final String trade;
  final String? description;
  final double? nte;
  final String? status;
  final String? priority;
  final String? city;
  final String? state;
  final String? address;
  final DateTime? etaAt;
  final String? technicianId;

  const CreateWorkOrderRequest({
    required this.client,
    required this.trade,
    this.description,
    this.nte,
    this.status,
    this.priority,
    this.city,
    this.state,
    this.address,
    this.etaAt,
    this.technicianId,
  });

  factory CreateWorkOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateWorkOrderRequestToJson(this);
}

@JsonSerializable()
class UpdateWorkOrderRequest {
  final String? client;
  final String? trade;
  final String? description;
  final double? nte;
  final String? status;
  final String? priority;
  final String? city;
  final String? state;
  final String? address;
  final DateTime? etaAt;
  final String? technicianId;
  final String? notes;

  const UpdateWorkOrderRequest({
    this.client,
    this.trade,
    this.description,
    this.nte,
    this.status,
    this.priority,
    this.city,
    this.state,
    this.address,
    this.etaAt,
    this.technicianId,
    this.notes,
  });

  factory UpdateWorkOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateWorkOrderRequestFromJson(json);
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (client != null) json['client'] = client;
    if (trade != null) json['trade'] = trade;
    if (description != null) json['description'] = description;
    if (nte != null) json['nte'] = nte;
    if (status != null) json['status'] = status;
    if (priority != null) json['priority'] = priority;
    if (city != null) json['city'] = city;
    if (state != null) json['state'] = state;
    if (address != null) json['address'] = address;
    if (etaAt != null) json['etaAt'] = etaAt!.toIso8601String();
    if (technicianId != null) json['technicianId'] = technicianId;
    if (notes != null) json['notes'] = notes;
    return json;
  }
}
