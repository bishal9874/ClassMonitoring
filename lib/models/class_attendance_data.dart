// file: lib/models/class_attendance_data.dart

import 'package:classmonitor/models/class_stat.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:intl/intl.dart';

// This is the main data structure used within the TimeLineScreen's state
class ClassAttendanceData {
  String date;
  String prog;
  String dept;
  String sem;
  String batch;
  String section;
  int p1;
  int p2;
  int p3;
  int p4;
  int p5;
  int p6;
  int p7;
  int p8;
  String p1Remarks;
  String p2Remarks;
  String p3Remarks;
  String p4Remarks;
  String p5Remarks;
  String p6Remarks;
  String p7Remarks;
  String p8Remarks;
  String lastEntry;
  String crMarking;
  String profMarking;

  ClassAttendanceData({
    required this.date,
    required this.prog,
    required this.dept,
    required this.sem,
    required this.batch,
    required this.section,
    this.p1 = 0,
    this.p2 = 0,
    this.p3 = 0,
    this.p4 = 0,
    this.p5 = 0,
    this.p6 = 0,
    this.p7 = 0,
    this.p8 = 0,
    this.p1Remarks = '',
    this.p2Remarks = '',
    this.p3Remarks = '',
    this.p4Remarks = '',
    this.p5Remarks = '',
    this.p6Remarks = '',
    this.p7Remarks = '',
    this.p8Remarks = '',
    this.lastEntry = '',
    this.crMarking = '',
    this.profMarking = '',
  });

  // Factory to create an instance from a ClassStat object
  factory ClassAttendanceData.fromClassStat(ClassStat stat) {
    return ClassAttendanceData(
      date: stat.date,
      prog: stat.prog,
      dept: stat.dept,
      sem: stat.sem,
      batch: stat.batch,
      section: stat.section,
      p1: stat.p1,
      p2: stat.p2,
      p3: stat.p3,
      p4: stat.p4,
      p5: stat.p5,
      p6: stat.p6,
      p7: stat.p7,
      p8: stat.p8,
      p1Remarks: stat.p1Remarks,
      p2Remarks: stat.p2Remarks,
      p3Remarks: stat.p3Remarks,
      p4Remarks: stat.p4Remarks,
      p5Remarks: stat.p5Remarks,
      p6Remarks: stat.p6Remarks,
      p7Remarks: stat.p7Remarks,
      p8Remarks: stat.p8Remarks,
      lastEntry: stat.lastEntry,
      crMarking: stat.crMarking,
      profMarking: stat.profMarking,
    );
  }

  void updateMarking(UserRole userRole) {
    List<String> attendedPeriods = [];
    if (p1 == 1) attendedPeriods.add('p1');
    if (p2 == 1) attendedPeriods.add('p2');
    if (p3 == 1) attendedPeriods.add('p3');
    if (p4 == 1) attendedPeriods.add('p4');
    if (p5 == 1) attendedPeriods.add('p5');
    if (p6 == 1) attendedPeriods.add('p6');
    if (p7 == 1) attendedPeriods.add('p7');
    if (p8 == 1) attendedPeriods.add('p8');

    final String markingString = attendedPeriods.join('.');
    lastEntry = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if (userRole == UserRole.student) {
      crMarking = markingString;
    } else if (userRole == UserRole.teacher ||
        userRole == UserRole.superAdmin) {
      profMarking = markingString;
    }
  }

  void togglePeriod(int periodNumber, UserRole userRole) {
    switch (periodNumber) {
      case 1:
        p1 = (p1 == 1) ? 0 : 1;
        break;
      case 2:
        p2 = (p2 == 1) ? 0 : 1;
        break;
      case 3:
        p3 = (p3 == 1) ? 0 : 1;
        break;
      case 4:
        p4 = (p4 == 1) ? 0 : 1;
        break;
      case 5:
        p5 = (p5 == 1) ? 0 : 1;
        break;
      case 6:
        p6 = (p6 == 1) ? 0 : 1;
        break;
      case 7:
        p7 = (p7 == 1) ? 0 : 1;
        break;
      case 8:
        p8 = (p8 == 1) ? 0 : 1;
        break;
    }
    updateMarking(userRole);
  }

  void setPeriodRemark(int periodNumber, String remark) {
    switch (periodNumber) {
      case 1:
        p1Remarks = remark;
        break;
      case 2:
        p2Remarks = remark;
        break;
      case 3:
        p3Remarks = remark;
        break;
      case 4:
        p4Remarks = remark;
        break;
      case 5:
        p5Remarks = remark;
        break;
      case 6:
        p6Remarks = remark;
        break;
      case 7:
        p7Remarks = remark;
        break;
      case 8:
        p8Remarks = remark;
        break;
    }
  }

  int getPeriodStatus(int periodNumber) {
    switch (periodNumber) {
      case 1:
        return p1;
      case 2:
        return p2;
      case 3:
        return p3;
      case 4:
        return p4;
      case 5:
        return p5;
      case 6:
        return p6;
      case 7:
        return p7;
      case 8:
        return p8;
      default:
        return 0;
    }
  }

  String getPeriodRemark(int periodNumber) {
    switch (periodNumber) {
      case 1:
        return p1Remarks;
      case 2:
        return p2Remarks;
      case 3:
        return p3Remarks;
      case 4:
        return p4Remarks;
      case 5:
        return p5Remarks;
      case 6:
        return p6Remarks;
      case 7:
        return p7Remarks;
      case 8:
        return p8Remarks;
      default:
        return '';
    }
  }
}

// This is the data model that directly maps to your API JSON response
