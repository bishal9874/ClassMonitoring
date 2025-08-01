enum PeriodStatus { upcoming, ongoing, completed, missed }

class ClassPeriod {
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  bool isManuallyCompleted;
  String? remark;

  ClassPeriod({
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.isManuallyCompleted = false,
    this.remark,
  });

  PeriodStatus get status {
    final now = DateTime.now();
    // Rule 1: If manually completed, it's always 'completed'.
    if (isManuallyCompleted) {
      return PeriodStatus.completed;
    }
    // Rule 2: If time has passed and it was never completed, it's 'missed'.
    if (now.isAfter(endTime)) {
      return PeriodStatus.missed;
    }
    // Rule 3: If within the time frame, it's 'ongoing'.
    if (now.isAfter(startTime) && now.isBefore(endTime)) {
      return PeriodStatus.ongoing;
    }
    // Rule 4: Otherwise, it must be 'upcoming'.
    return PeriodStatus.upcoming;
  }
}
