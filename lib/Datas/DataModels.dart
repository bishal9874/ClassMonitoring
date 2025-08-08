// lib/data/data_models.dart

import 'package:classmonitor/models/classesDataModel.dart';

/// A utility class that provides a static list of default class periods.
class DataModels {
  static List<ClassPeriod> get periods => _periods;

  // --- Private Implementation Details ---
  static final List<ClassPeriod> _periods = [
    _createPeriod(
      subject: 'P1',
      startHour: 9,
      startMin: 30,
      endHour: 10,
      endMin: 25,
    ),
    _createPeriod(
      subject: 'P2',
      startHour: 10,
      startMin: 30,
      endHour: 11,
      endMin: 25,
    ),
    _createPeriod(
      subject: 'P3',
      startHour: 11,
      startMin: 30,
      endHour: 12,
      endMin: 25,
    ),
    _createPeriod(
      subject: 'P3',
      startHour: 12,
      startMin: 30,
      endHour: 13,
      endMin: 30,
    ),
    _createPeriod(
      subject: 'P5',
      startHour: 13,
      startMin: 31,
      endHour: 14,
      endMin: 25,
    ),
    _createPeriod(
      subject: 'P6',
      startHour: 14,
      startMin: 30,
      endHour: 15,
      endMin: 25,
    ),
    _createPeriod(
      subject: 'P7',
      startHour: 15,
      startMin: 30,
      endHour: 16,
      endMin: 25,
    ),
    _createPeriod(
      subject: 'P8',
      startHour: 16,
      startMin: 30,
      endHour: 17,
      endMin: 35,
    ),
  ];

  static ClassPeriod _createPeriod({
    required String subject,
    required int startHour,
    required int startMin,
    required int endHour,
    required int endMin,
  }) {
    final now = DateTime.now();
    final startTime = DateTime(
      now.year,
      now.month,
      now.day,
      startHour,
      startMin,
    );
    final endTime = DateTime(now.year, now.month, now.day, endHour, endMin);

    return ClassPeriod(
      subject: subject,
      startTime: startTime,
      endTime: endTime,
      status: _getPeriodStatus(startTime, endTime),
      remark: '',
      attendanceStatus: false,
    );
  }

  static PeriodStatus _getPeriodStatus(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isBefore(start)) return PeriodStatus.upcoming;
    if (now.isAfter(end)) return PeriodStatus.completed;
    return PeriodStatus.ongoing;
  }
}
