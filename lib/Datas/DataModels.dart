import 'package:classmonitor/models/classesDataModel.dart';
import 'package:flutter/material.dart';

class DataModels {
  static List<ClassPeriod> get periods {
    return _createPeriodsForDate(DateTime.now());
  }

  static List<ClassPeriod> getPeriodsForDate(DateTime date) {
    return _createPeriodsForDate(date);
  }

  static ClassPeriod _createPeriod({
    required String subject,
    required int startHour,
    required int startMin,
    required int endHour,
    required int endMin,
    required DateTime forDate,
  }) {
    final startTime = DateTime(
      forDate.year,
      forDate.month,
      forDate.day,
      startHour,
      startMin,
    );

    final endTime = DateTime(
      forDate.year,
      forDate.month,
      forDate.day,
      endHour,
      endMin,
    );

    return ClassPeriod(
      subject: subject,
      startTime: startTime,
      endTime: endTime,
      status: getPeriodStatus(startTime, endTime, forDate),
      remark: '',
      attendanceStatus: false,
    );
  }

  static PeriodStatus getPeriodStatus(
    DateTime start,
    DateTime end,
    DateTime selectedDate,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final aSelectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (aSelectedDay.isBefore(today)) {
      return PeriodStatus.completed;
    }

    if (aSelectedDay.isAfter(today)) {
      return PeriodStatus.upcoming;
    }

    if (now.isBefore(start)) return PeriodStatus.upcoming;
    if (now.isAfter(end)) return PeriodStatus.completed;
    return PeriodStatus.ongoing;
  }

  static List<ClassPeriod> _createPeriodsForDate(DateTime date) {
    return [
      _createPeriod(
        subject: 'P1',
        startHour: 9,
        startMin: 30,
        endHour: 10,
        endMin: 25,
        forDate: date,
      ),
      _createPeriod(
        subject: 'P2',
        startHour: 10,
        startMin: 30,
        endHour: 11,
        endMin: 25,
        forDate: date,
      ),
      _createPeriod(
        subject: 'P3',
        startHour: 11,
        startMin: 30,
        endHour: 12,
        endMin: 25,
        forDate: date,
      ),
      _createPeriod(
        subject: 'P4',
        startHour: 12,
        startMin: 30,
        endHour: 13,
        endMin: 30,
        forDate: date,
      ),
      _createPeriod(
        subject: 'P5',
        startHour: 13,
        startMin: 31,
        endHour: 14,
        endMin: 25,
        forDate: date,
      ),
      _createPeriod(
        subject: 'P6',
        startHour: 14,
        startMin: 30,
        endHour: 15,
        endMin: 25,
        forDate: date,
      ),
      _createPeriod(
        subject: 'P7',
        startHour: 15,
        startMin: 30,
        endHour: 16,
        endMin: 25,
        forDate: date,
      ),
      _createPeriod(
        subject: 'P8',
        startHour: 16,
        startMin: 30,
        endHour: 17,
        endMin: 35,
        forDate: date,
      ),
    ];
  }
}
