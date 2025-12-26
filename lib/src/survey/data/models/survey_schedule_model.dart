import 'package:cloud_firestore/cloud_firestore.dart';

/// Survey schedule for tracking follow-up surveys
class SurveySchedule {
  final String id;
  final String userId;
  final DateTime baselineCompletedAt;
  final DateTime followUpDueDate;
  final DateTime? followUpCompletedAt;
  final List<ReminderRecord> remindersSent;
  final ScheduleStatus status;

  const SurveySchedule({
    required this.id,
    required this.userId,
    required this.baselineCompletedAt,
    required this.followUpDueDate,
    this.followUpCompletedAt,
    required this.remindersSent,
    required this.status,
  });

  /// Check if follow-up is overdue
  bool get isOverdue {
    if (followUpCompletedAt != null) return false;
    return DateTime.now().isAfter(followUpDueDate.add(const Duration(days: 7)));
  }

  /// Check if follow-up is due soon (within 7 days)
  bool get isDueSoon {
    if (followUpCompletedAt != null) return false;
    final now = DateTime.now();
    final daysUntilDue = followUpDueDate.difference(now).inDays;
    return daysUntilDue <= 7 && daysUntilDue >= 0;
  }
}

/// Status of survey schedule
enum ScheduleStatus {
  pending,
  completed,
  overdue,
}

extension ScheduleStatusExtension on ScheduleStatus {
  String get key {
    switch (this) {
      case ScheduleStatus.pending:
        return 'pending';
      case ScheduleStatus.completed:
        return 'completed';
      case ScheduleStatus.overdue:
        return 'overdue';
    }
  }

  static ScheduleStatus fromKey(String key) {
    switch (key) {
      case 'pending':
        return ScheduleStatus.pending;
      case 'completed':
        return ScheduleStatus.completed;
      case 'overdue':
        return ScheduleStatus.overdue;
      default:
        return ScheduleStatus.pending;
    }
  }
}

/// Record of a reminder sent to user
class ReminderRecord {
  final DateTime sentAt;
  final ReminderType type;

  const ReminderRecord({
    required this.sentAt,
    required this.type,
  });
}

/// Type of reminder
enum ReminderType {
  email,
  push,
  inApp,
}

extension ReminderTypeExtension on ReminderType {
  String get key {
    switch (this) {
      case ReminderType.email:
        return 'email';
      case ReminderType.push:
        return 'push';
      case ReminderType.inApp:
        return 'inApp';
    }
  }

  static ReminderType fromKey(String key) {
    switch (key) {
      case 'email':
        return ReminderType.email;
      case 'push':
        return ReminderType.push;
      case 'inApp':
        return ReminderType.inApp;
      default:
        return ReminderType.inApp;
    }
  }
}

/// Firestore model for SurveySchedule
class SurveyScheduleModel extends SurveySchedule {
  const SurveyScheduleModel({
    required super.id,
    required super.userId,
    required super.baselineCompletedAt,
    required super.followUpDueDate,
    super.followUpCompletedAt,
    required super.remindersSent,
    required super.status,
  });

  /// Create from Firestore document
  factory SurveyScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SurveyScheduleModel(
      id: doc.id,
      userId: data['userId'] as String,
      baselineCompletedAt: (data['baselineCompletedAt'] as Timestamp).toDate(),
      followUpDueDate: (data['followUpDueDate'] as Timestamp).toDate(),
      followUpCompletedAt: data['followUpCompletedAt'] != null
          ? (data['followUpCompletedAt'] as Timestamp).toDate()
          : null,
      remindersSent: (data['remindersSent'] as List<dynamic>?)
              ?.map((r) => ReminderRecordModel.fromMap(r))
              .toList() ??
          [],
      status: ScheduleStatusExtension.fromKey(
          data['status'] as String? ?? 'pending'),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'baselineCompletedAt': Timestamp.fromDate(baselineCompletedAt),
      'followUpDueDate': Timestamp.fromDate(followUpDueDate),
      'followUpCompletedAt': followUpCompletedAt != null
          ? Timestamp.fromDate(followUpCompletedAt!)
          : null,
      'remindersSent': remindersSent
          .map((r) => ReminderRecordModel.fromEntity(r).toMap())
          .toList(),
      'status': status.key,
    };
  }

  /// Create from entity
  factory SurveyScheduleModel.fromEntity(SurveySchedule entity) {
    return SurveyScheduleModel(
      id: entity.id,
      userId: entity.userId,
      baselineCompletedAt: entity.baselineCompletedAt,
      followUpDueDate: entity.followUpDueDate,
      followUpCompletedAt: entity.followUpCompletedAt,
      remindersSent: entity.remindersSent,
      status: entity.status,
    );
  }
}

/// Model for ReminderRecord
class ReminderRecordModel extends ReminderRecord {
  const ReminderRecordModel({
    required super.sentAt,
    required super.type,
  });

  factory ReminderRecordModel.fromMap(Map<String, dynamic> map) {
    return ReminderRecordModel(
      sentAt: (map['sentAt'] as Timestamp).toDate(),
      type: ReminderTypeExtension.fromKey(map['type'] as String? ?? 'inApp'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sentAt': Timestamp.fromDate(sentAt),
      'type': type.key,
    };
  }

  factory ReminderRecordModel.fromEntity(ReminderRecord entity) {
    return ReminderRecordModel(
      sentAt: entity.sentAt,
      type: entity.type,
    );
  }
}
