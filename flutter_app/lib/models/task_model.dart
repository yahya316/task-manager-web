import 'activity_log_model.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String contactName;
  final String contactPhone;
  final String status;
  final String? createdByName;
  final String? createdById;
  final String? assignedToName;
  final String? assignedToId;
  final DateTime? deadlineAt;
  final bool? paymentReceived;
  final DateTime? paymentMarkedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ActivityLogModel> activityLog;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.contactName,
    required this.contactPhone,
    required this.status,
    this.createdByName,
    this.createdById,
    this.assignedToName,
    this.assignedToId,
    this.deadlineAt,
    this.paymentReceived,
    this.paymentMarkedAt,
    required this.createdAt,
    required this.updatedAt,
    this.activityLog = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    String? createdByName;
    String? createdById;
    String? assignedToName;
    String? assignedToId;

    if (json['createdBy'] is Map) {
      createdByName = json['createdBy']['name'];
      createdById = json['createdBy']['_id'];
    } else {
      createdById = json['createdBy'];
    }

    if (json['assignedTo'] is Map) {
      assignedToName = json['assignedTo']['name'];
      assignedToId = json['assignedTo']['_id'];
    } else {
      assignedToId = json['assignedTo'];
    }

    List<ActivityLogModel> logs = [];
    if (json['activityLog'] != null) {
      logs = (json['activityLog'] as List)
          .map((log) => ActivityLogModel.fromJson(log))
          .toList();
    }

    return TaskModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      contactName: json['contactName'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      status: json['status'] ?? 'Pending',
      createdByName: createdByName,
      createdById: createdById,
      assignedToName: assignedToName,
      assignedToId: assignedToId,
      deadlineAt: json['deadlineAt'] != null
          ? DateTime.parse(json['deadlineAt'])
          : null,
      paymentReceived: json['paymentReceived'],
      paymentMarkedAt: json['paymentMarkedAt'] != null
          ? DateTime.parse(json['paymentMarkedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      activityLog: logs,
    );
  }

  /// Returns the name of the person who last changed the status
  String? get lastChangedByName {
    if (activityLog.isEmpty) return null;
    final sorted = List<ActivityLogModel>.from(activityLog)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.first.changedByName;
  }
}
