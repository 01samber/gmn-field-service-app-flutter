class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final DateTime? endTime;
  final String priority;
  final String? color;
  final bool isCompleted;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.endTime,
    required this.priority,
    this.color,
    required this.isCompleted,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dateTime: json['dateTime'] != null 
          ? DateTime.parse(json['dateTime']) 
          : DateTime.now(),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime']) 
          : null,
      priority: json['priority'] ?? 'normal',
      color: json['color'],
      isCompleted: json['isCompleted'] ?? false,
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
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'priority': priority,
      'color': color,
      'isCompleted': isCompleted,
    };
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    DateTime? endTime,
    String? priority,
    String? color,
    bool? isCompleted,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isHighPriority => priority == 'high' || priority == 'urgent';
  bool get isUrgent => priority == 'urgent';
}

// Used to display both events and work order ETAs
class CalendarItem {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime dateTime;
  final String type; // 'event' or 'work_order'
  final String priority;
  final bool isCompleted;
  final bool isOverdue;

  CalendarItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.dateTime,
    required this.type,
    required this.priority,
    required this.isCompleted,
    required this.isOverdue,
  });

  factory CalendarItem.fromEvent(CalendarEvent event) {
    return CalendarItem(
      id: event.id,
      title: event.title,
      subtitle: event.description,
      dateTime: event.dateTime,
      type: 'event',
      priority: event.priority,
      isCompleted: event.isCompleted,
      isOverdue: !event.isCompleted && DateTime.now().isAfter(event.dateTime),
    );
  }

  factory CalendarItem.fromWorkOrder(Map<String, dynamic> wo) {
    final etaAt = wo['etaAt'] != null ? DateTime.parse(wo['etaAt']) : DateTime.now();
    final status = wo['status'] ?? 'waiting';
    final isCompleted = status == 'completed' || status == 'invoiced' || status == 'paid';
    
    return CalendarItem(
      id: wo['id']?.toString() ?? '',
      title: '${wo['woNumber']} - ${wo['client']}',
      subtitle: wo['trade'],
      dateTime: etaAt,
      type: 'work_order',
      priority: wo['priority'] ?? 'normal',
      isCompleted: isCompleted,
      isOverdue: !isCompleted && DateTime.now().isAfter(etaAt),
    );
  }
}
