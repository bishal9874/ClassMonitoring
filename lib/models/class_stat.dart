import 'package:intl/intl.dart';

class ClassStat {
  final DateTime date;
  final String prog;
  final String dept;
  final int sem;
  final String batch;
  final String section;
  final int p1;
  final int p2;
  final int p3;
  final int p4;
  final int p5;
  final int p6;
  final int p7;
  final int p8;
  final String lastEntry;
  final String crMarking;
  final String profMarking;

  ClassStat({
    required this.date,
    required this.prog,
    required this.dept,
    required this.sem,
    required this.batch,
    required this.section,
    required this.p1,
    required this.p2,
    required this.p3,
    required this.p4,
    required this.p5,
    required this.p6,
    required this.p7,
    required this.p8,
    this.lastEntry = '',
    this.crMarking = '',
    this.profMarking = '',
  });

  factory ClassStat.fromJson(Map<String, dynamic> json) {
    return ClassStat(
      date: DateTime.parse(json['date'] as String),
      prog: json['prog'] as String,
      dept: json['dept'] as String,
      sem: int.tryParse(json['sem']?.toString() ?? '0') ?? 0,
      batch: json['batch'] as String,
      section: json['section'] as String,
      p1: int.tryParse(json['p1']?.toString() ?? '0') ?? 0,
      p2: int.tryParse(json['p2']?.toString() ?? '0') ?? 0,
      p3: int.tryParse(json['p3']?.toString() ?? '0') ?? 0,
      p4: int.tryParse(json['p4']?.toString() ?? '0') ?? 0,
      p5: int.tryParse(json['p5']?.toString() ?? '0') ?? 0,
      p6: int.tryParse(json['p6']?.toString() ?? '0') ?? 0,
      p7: int.tryParse(json['p7']?.toString() ?? '0') ?? 0,
      p8: int.tryParse(json['p8']?.toString() ?? '0') ?? 0,
      lastEntry: json['last_entry'] as String? ?? '',
      crMarking: json['cr_marking'] as String? ?? '',
      profMarking: json['prof_marking'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': DateFormat('yyyy-MM-dd').format(date),
      'prog': prog,
      'dept': dept,
      'sem': sem,
      'batch': batch,
      'section': section,
      'p1': p1,
      'p2': p2,
      'p3': p3,
      'p4': p4,
      'p5': p5,
      'p6': p6,
      'p7': p7,
      'p8': p8,
      'last_entry': lastEntry,
      'cr_marking': crMarking,
      'prof_marking': profMarking,
    };
  }
}
