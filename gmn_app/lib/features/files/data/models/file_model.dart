class FileModel {
  final String id;
  final String name;
  final String type;
  final int size;
  final String path;
  final String? workOrderId;
  final WorkOrderRef? workOrder;
  final DateTime createdAt;

  FileModel({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.path,
    this.workOrderId,
    this.workOrder,
    required this.createdAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'other',
      size: json['size'] ?? 0,
      path: json['path'] ?? '',
      workOrderId: json['workOrderId']?.toString(),
      workOrder: json['workOrder'] != null
          ? WorkOrderRef.fromJson(json['workOrder'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isImage =>
      type == 'image' ||
      [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
      ].any((ext) => name.toLowerCase().endsWith(ext));
  bool get isPdf => type == 'pdf' || name.toLowerCase().endsWith('.pdf');
  bool get isVideo =>
      type == 'video' ||
      [
        'mp4',
        'mov',
        'avi',
        'webm',
      ].any((ext) => name.toLowerCase().endsWith(ext));

  String get iconType {
    if (isImage) return 'image';
    if (isPdf) return 'pdf';
    if (isVideo) return 'video';
    return 'other';
  }
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

class FilesFilter {
  final String? type;

  FilesFilter({this.type});

  Map<String, dynamic> toQueryParameters() {
    return {if (type != null && type!.isNotEmpty) 'type': type};
  }
}
