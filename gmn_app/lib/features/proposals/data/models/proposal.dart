import 'dart:convert';

class Proposal {
  final String id;
  final String proposalNumber;
  final String status;
  final double tripFee;
  final double assessmentFee;
  final double techHours;
  final double techRate;
  final double helperHours;
  final double helperRate;
  final List<Part> parts;
  final double costMultiplier;
  final double taxRate;
  final double subtotal;
  final double tax;
  final double total;
  final String? workOrderId;
  final WorkOrderRef? workOrder;
  final String? technicianId;
  final TechnicianRef? technician;
  final String? helperId;
  final TechnicianRef? helper;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  Proposal({
    required this.id,
    required this.proposalNumber,
    required this.status,
    required this.tripFee,
    required this.assessmentFee,
    required this.techHours,
    required this.techRate,
    required this.helperHours,
    required this.helperRate,
    required this.parts,
    required this.costMultiplier,
    required this.taxRate,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.workOrderId,
    this.workOrder,
    this.technicianId,
    this.technician,
    this.helperId,
    this.helper,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    List<Part> partsList = [];
    if (json['parts'] != null) {
      if (json['parts'] is String) {
        try {
          final decoded = jsonDecode(json['parts']);
          if (decoded is List) {
            partsList = decoded.map((p) => Part.fromJson(p)).toList();
          }
        } catch (_) {}
      } else if (json['parts'] is List) {
        partsList = (json['parts'] as List).map((p) => Part.fromJson(p)).toList();
      }
    }

    return Proposal(
      id: json['id']?.toString() ?? '',
      proposalNumber: json['proposalNumber'] ?? '',
      status: json['status'] ?? 'draft',
      tripFee: (json['tripFee'] ?? 0).toDouble(),
      assessmentFee: (json['assessmentFee'] ?? 0).toDouble(),
      techHours: (json['techHours'] ?? 0).toDouble(),
      techRate: (json['techRate'] ?? 0).toDouble(),
      helperHours: (json['helperHours'] ?? 0).toDouble(),
      helperRate: (json['helperRate'] ?? 0).toDouble(),
      parts: partsList,
      costMultiplier: (json['costMultiplier'] ?? 1.35).toDouble(),
      taxRate: (json['taxRate'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      workOrderId: json['workOrderId']?.toString(),
      workOrder: json['workOrder'] != null ? WorkOrderRef.fromJson(json['workOrder']) : null,
      technicianId: json['technicianId']?.toString(),
      technician: json['technician'] != null ? TechnicianRef.fromJson(json['technician']) : null,
      helperId: json['helperId']?.toString(),
      helper: json['helper'] != null ? TechnicianRef.fromJson(json['helper']) : null,
      createdById: json['createdById']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proposalNumber': proposalNumber,
      'status': status,
      'tripFee': tripFee,
      'assessmentFee': assessmentFee,
      'techHours': techHours,
      'techRate': techRate,
      'helperHours': helperHours,
      'helperRate': helperRate,
      'parts': jsonEncode(parts.map((p) => p.toJson()).toList()),
      'costMultiplier': costMultiplier,
      'taxRate': taxRate,
      'workOrderId': workOrderId,
      'technicianId': technicianId,
      'helperId': helperId,
    };
  }

  double get laborCost => (techHours * techRate) + (helperHours * helperRate);
  double get partsCost => parts.fold(0.0, (sum, part) => sum + part.total);
  double get baseCost => tripFee + assessmentFee + laborCost + partsCost;

  bool get isDraft => status == 'draft';
  bool get isSent => status == 'sent';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

class Part {
  final String name;
  final int quantity;
  final double unitPrice;

  Part({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  double get total => quantity * unitPrice;
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

  TechnicianRef({
    required this.id,
    required this.name,
    required this.trade,
  });

  factory TechnicianRef.fromJson(Map<String, dynamic> json) {
    return TechnicianRef(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      trade: json['trade'] ?? '',
    );
  }
}
