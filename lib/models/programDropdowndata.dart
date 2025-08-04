import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DepartmentData {
  final String name;
  final List<ProgramData> programs;

  DepartmentData({required this.name, required this.programs});

  factory DepartmentData.fromJson(Map<String, dynamic> json) {
    var programsList = json['programs'] as List;
    List<ProgramData> programs = programsList
        .map((i) => ProgramData.fromJson(i))
        .toList();
    return DepartmentData(name: json['name'], programs: programs);
  }
}

class ProgramData {
  final String name;
  final Map<int, List<String>> semesters;
  final List<String> batches; // Corrected: Added the batches field

  ProgramData({
    required this.name,
    required this.semesters,
    required this.batches, // Corrected: Added to the constructor
  });

  factory ProgramData.fromJson(Map<String, dynamic> json) {
    // Convert semester keys from String to int
    Map<String, dynamic> semJson = json['semesters'];
    Map<int, List<String>> semesters = {
      for (var entry in semJson.entries)
        int.parse(entry.key): List<String>.from(entry.value),
    };

    // Corrected: Parse the new 'batches' list from JSON
    final batches = (json['batches'] as List<dynamic>?)?.cast<String>() ?? [];

    return ProgramData(
      name: json['name'],
      semesters: semesters,
      batches: batches, // Corrected: Pass the parsed batches list
    );
  }
}

class ClassMonitorData {
  List<DepartmentData> _allDepartments = [];

  Future<void> loadJson() async {
    final String jsonString = await rootBundle.loadString(
      'assets/dropdown.json',
    );
    final decodedData = json.decode(jsonString);
    final departmentsList = decodedData['departments'] as List;
    _allDepartments = departmentsList
        .map((e) => DepartmentData.fromJson(e))
        .toList();
  }

  List<DepartmentData> get allDepartments => _allDepartments;
}
