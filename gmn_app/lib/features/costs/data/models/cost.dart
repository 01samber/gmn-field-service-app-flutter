class Cost {
  final String id;
  final double amount;
  final String status;
  final String? note;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final DateTime? paidAt;
  final String? workOrderId;
  final WorkOrderRef? workOrder;
  final String? technicianId;
  final TechnicianRef? technician;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cost({
    required this.id,
    required this.amount,
    required this.status,
    this.note,
    required this.requestedAt,
    this.approvedAt,
    this.paidAt,
    this.workOrderId,
    this.workOrder,
    this.technicianId,
    this.technician,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cost.fromJson(Map<String, dynamic> json) {
    return Cost(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'requested',
      note: json['note'],
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'])
          : DateTime.now(),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      workOrderId: json['workOrderId']?.toString(),
      workOrder: json['workOrder'] != null
          ? WorkOrderRef.fromJson(json['workOrder'])
          : null,
      technicianId: json['technicianId']?.toString(),
      technician: json['technician'] != null
          ? TechnicianRef.fromJson(json['technician'])
          : null,
      createdById: json['createdById']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'note': note,
      'workOrderId': workOrderId,
      'technicianId': technicianId,
    };
  }

  Cost copyWith({
    String? id,
    double? amount,
    String? status,
    String? note,
    DateTime? requestedAt,
    DateTime? approvedAt,
    DateTime? paidAt,
    String? workOrderId,
    WorkOrderRef? workOrder,
    String? technicianId,
    TechnicianRef? technician,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cost(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      note: note ?? this.note,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      paidAt: paidAt ?? this.paidAt,
      workOrderId: workOrderId ?? this.workOrderId,
      workOrder: workOrder ?? this.workOrder,
      technicianId: technicianId ?? this.technicianId,
      technician: technician ?? this.technician,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isRequested => status == 'requested';
  bool get isApproved => status == 'approved';
  bool get isPaid => status == 'paid';
}

class WorkOrderRef {
  final String id;
  final String woNumber;
  final String client;

  WorkOrderRef({
    required this.id,
    required this.woNumber,
    required this.client,
  });

  factory WorkOrderRef.fromJson(Map<String, dynamic> json) {
    return WorkOrderRef(
      id: json['id']?.toString() ?? '',
      woNumber: json['woNumber'] ?? '',
      client: json['client'] ?? '',
    );
  }
}

class TechnicianRef {
  final String id;
  final String name;
  final String trade;

  TechnicianRef({required this.id, required this.name, required this.trade});

  factory TechnicianRef.fromJson(Map<String, dynamic> json) {
    return TechnicianRef(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      trade: json['trade'] ?? '',
    );
  }
}

class CostSummary {
  final double requested;
  final double approved;
  final double paid;

  CostSummary({
    required this.requested,
    required this.approved,
    required this.paid,
  });

  double get total => requested + approved + paid;
}

class CostsFilter {
  final String? status;

  CostsFilter({this.status});

  Map<String, dynamic> toQueryParameters() {
    return {if (status != null && status!.isNotEmpty) 'status': status};
  }
}
