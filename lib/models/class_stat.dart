class ClassStat {
  final String date;
  final String prog;
  final String dept;
  final String sem;
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
  final String p1Remarks;
  final String p2Remarks;
  final String p3Remarks;
  final String p4Remarks;
  final String p5Remarks;
  final String p6Remarks;
  final String p7Remarks;
  final String p8Remarks;
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

  // **FIXED**: Robust fromJson factory to prevent parsing errors
  factory ClassStat.fromJson(Map<String, dynamic> json) {
    return ClassStat(
      date: json['date'] as String? ?? '',
      prog: json['prog'] as String? ?? '',
      dept: json['dept'] as String? ?? '',
      sem: json['sem']?.toString() ?? '',
      batch: json['batch']?.toString() ?? '',
      section: json['section'] as String? ?? '',
      p1: int.tryParse(json['p1']?.toString() ?? '0') ?? 0,
      p2: int.tryParse(json['p2']?.toString() ?? '0') ?? 0,
      p3: int.tryParse(json['p3']?.toString() ?? '0') ?? 0,
      p4: int.tryParse(json['p4']?.toString() ?? '0') ?? 0,
      p5: int.tryParse(json['p5']?.toString() ?? '0') ?? 0,
      p6: int.tryParse(json['p6']?.toString() ?? '0') ?? 0,
      p7: int.tryParse(json['p7']?.toString() ?? '0') ?? 0,
      p8: int.tryParse(json['p8']?.toString() ?? '0') ?? 0,
      p1Remarks: json['p1_remarks'] as String? ?? '',
      p2Remarks: json['p2_remarks'] as String? ?? '',
      p3Remarks: json['p3_remarks'] as String? ?? '',
      p4Remarks: json['p4_remarks'] as String? ?? '',
      p5Remarks: json['p5_remarks'] as String? ?? '',
      p6Remarks: json['p6_remarks'] as String? ?? '',
      p7Remarks: json['p7_remarks'] as String? ?? '',
      p8Remarks: json['p8_remarks'] as String? ?? '',
      lastEntry: json['last_entry'] as String? ?? '',
      crMarking: json['cr_marking'] as String? ?? '',
      profMarking: json['prof_marking'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
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
      'p1_remarks': p1Remarks,
      'p2_remarks': p2Remarks,
      'p3_remarks': p3Remarks,
      'p4_remarks': p4Remarks,
      'p5_remarks': p5Remarks,
      'p6_remarks': p6Remarks,
      'p7_remarks': p7Remarks,
      'p8_remarks': p8Remarks,
      'last_entry': lastEntry,
      'cr_marking': crMarking,
      'prof_marking': profMarking,
    };
  }
}
