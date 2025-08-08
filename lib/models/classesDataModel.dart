// file: lib/models/classesDataModel.dart

enum PeriodStatus { completed, ongoing, upcoming, missed }

class ClassPeriod {
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final PeriodStatus status;
  final String? remark;
  final bool? attendanceStatus;

  ClassPeriod({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.remark,
    this.attendanceStatus,
  });

  factory ClassPeriod.fromJson(Map<String, dynamic> json) {
    return ClassPeriod(
      subject: json['subject'] as String? ?? 'Unknown Subject',
      startTime:
          DateTime.tryParse(json['start_time'] as String? ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(json['end_time'] as String? ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      status: _parseStatus(json['status'] as String?),
      remark: json['remark'] as String?,
      attendanceStatus: json['attendance_status'] as bool?,
    );
  }

  static PeriodStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return PeriodStatus.completed;
      case 'ongoing':
        return PeriodStatus.ongoing;
      case 'upcoming':
        return PeriodStatus.upcoming;
      case 'missed':
        return PeriodStatus.missed;
      default:
        return PeriodStatus.upcoming;
    }
  }

  ClassPeriod copyWith({
    String? subject,
    DateTime? startTime,
    DateTime? endTime,
    PeriodStatus? status,
    String? remark,
    bool? attendanceStatus,
  }) {
    return ClassPeriod(
      subject: subject ?? this.subject,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      remark: remark ?? this.remark,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
    );
  }
}
