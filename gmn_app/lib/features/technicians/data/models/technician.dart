import 'package:json_annotation/json_annotation.dart';

part 'technician.g.dart';

@JsonSerializable()
class Technician {
  final String id;
  final String name;
  final String trade;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? notes;
  final double hourlyRate;
  final int jobsDone;
  final double gmnMoneyMade;
  final double rating;
  final bool isBlacklisted;
  final String? blacklistReason;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed counts from API
  @JsonKey(name: '_count')
  final TechnicianCounts? counts;

  const Technician({
    required this.id,
    required this.name,
    required this.trade,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.notes,
    this.hourlyRate = 0,
    this.jobsDone = 0,
    this.gmnMoneyMade = 0,
    this.rating = 5,
    this.isBlacklisted = false,
    this.blacklistReason,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.counts,
  });

  factory Technician.fromJson(Map<String, dynamic> json) =>
      _$TechnicianFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicianToJson(this);

  Technician copyWith({
    String? id,
    String? name,
    String? trade,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? notes,
    double? hourlyRate,
    int? jobsDone,
    double? gmnMoneyMade,
    double? rating,
    bool? isBlacklisted,
    String? blacklistReason,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    TechnicianCounts? counts,
  }) {
    return Technician(
      id: id ?? this.id,
      name: name ?? this.name,
      trade: trade ?? this.trade,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      notes: notes ?? this.notes,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      jobsDone: jobsDone ?? this.jobsDone,
      gmnMoneyMade: gmnMoneyMade ?? this.gmnMoneyMade,
      rating: rating ?? this.rating,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      blacklistReason: blacklistReason ?? this.blacklistReason,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      counts: counts ?? this.counts,
    );
  }

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    return parts.join(', ');
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Technician && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class TechnicianCounts {
  final int workOrders;
  final int costs;

  const TechnicianCounts({this.workOrders = 0, this.costs = 0});

  factory TechnicianCounts.fromJson(Map<String, dynamic> json) =>
      _$TechnicianCountsFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicianCountsToJson(this);
}

@JsonSerializable()
class TechniciansResponse {
  final List<Technician> data;
  final int total;
  final int page;
  final int limit;

  const TechniciansResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory TechniciansResponse.fromJson(Map<String, dynamic> json) =>
      _$TechniciansResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TechniciansResponseToJson(this);

  int get totalPages => (total / limit).ceil();
  bool get hasMore => page < totalPages;
}

@JsonSerializable()
class CreateTechnicianRequest {
  final String name;
  final String trade;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? notes;
  final double? hourlyRate;

  const CreateTechnicianRequest({
    required this.name,
    required this.trade,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.notes,
    this.hourlyRate,
  });

  factory CreateTechnicianRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTechnicianRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTechnicianRequestToJson(this);
}

@JsonSerializable()
class UpdateTechnicianRequest {
  final String? name;
  final String? trade;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? notes;
  final double? hourlyRate;
  final double? rating;
  final bool? isBlacklisted;
  final String? blacklistReason;

  const UpdateTechnicianRequest({
    this.name,
    this.trade,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.notes,
    this.hourlyRate,
    this.rating,
    this.isBlacklisted,
    this.blacklistReason,
  });

  factory UpdateTechnicianRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTechnicianRequestFromJson(json);
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (trade != null) json['trade'] = trade;
    if (phone != null) json['phone'] = phone;
    if (email != null) json['email'] = email;
    if (address != null) json['address'] = address;
    if (city != null) json['city'] = city;
    if (state != null) json['state'] = state;
    if (zipCode != null) json['zipCode'] = zipCode;
    if (notes != null) json['notes'] = notes;
    if (hourlyRate != null) json['hourlyRate'] = hourlyRate;
    if (rating != null) json['rating'] = rating;
    if (isBlacklisted != null) json['isBlacklisted'] = isBlacklisted;
    if (blacklistReason != null) json['blacklistReason'] = blacklistReason;
    return json;
  }
}
