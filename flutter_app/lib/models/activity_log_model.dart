class ActivityLogModel {
  final String? id;
  final String changedBy;
  final String changedByName;
  final String fromStatus;
  final String toStatus;
  final DateTime timestamp;
  final String note;
  final String? taskId;
  final String? taskTitle;

  ActivityLogModel({
    this.id,
    required this.changedBy,
    required this.changedByName,
    required this.fromStatus,
    required this.toStatus,
    required this.timestamp,
    this.note = '',
    this.taskId,
    this.taskTitle,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    String changedById = '';
    String changedByName = json['changedByName'] ?? '';

    if (json['changedBy'] is Map) {
      changedById = json['changedBy']['_id'] ?? '';
      if (changedByName.isEmpty) {
        changedByName = json['changedBy']['name'] ?? '';
      }
    } else {
      changedById = json['changedBy'] ?? '';
    }

    return ActivityLogModel(
      id: json['_id'],
      changedBy: changedById,
      changedByName: changedByName,
      fromStatus: json['fromStatus'] ?? '',
      toStatus: json['toStatus'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      note: json['note'] ?? '',
      taskId: json['taskId'],
      taskTitle: json['taskTitle'],
    );
  }
}
