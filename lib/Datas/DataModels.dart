import 'package:classmonitor/models/classesDataModel.dart'; // Ensure this path is correct

class DataModels {
  // Make the list static so it belongs to the class itself, not an instance.
  static final List<ClassPeriod> _periods = [
    ClassPeriod(
      subject: 'P1',
      startTime: DateTime.now().copyWith(hour: 9, minute: 30, second: 0),
      endTime: DateTime.now().copyWith(hour: 10, minute: 25, second: 0),
    ),
    ClassPeriod(
      subject: 'P2',
      startTime: DateTime.now().copyWith(hour: 10, minute: 30, second: 0),
      endTime: DateTime.now().copyWith(hour: 11, minute: 25, second: 0),
    ),
    ClassPeriod(
      subject: 'P3',
      startTime: DateTime.now().copyWith(hour: 11, minute: 30, second: 0),
      endTime: DateTime.now().copyWith(hour: 12, minute: 25, second: 0),
    ),
    ClassPeriod(
      subject: 'Lunch Break',
      startTime: DateTime.now().copyWith(hour: 12, minute: 30, second: 0),
      endTime: DateTime.now().copyWith(hour: 13, minute: 30, second: 0),
    ),
    ClassPeriod(
      subject: 'P5',
      startTime: DateTime.now().copyWith(hour: 13, minute: 31, second: 0),
      endTime: DateTime.now().copyWith(hour: 14, minute: 25, second: 0),
    ),
    ClassPeriod(
      subject: 'P6',
      startTime: DateTime.now().copyWith(hour: 14, minute: 30, second: 0),
      endTime: DateTime.now().copyWith(hour: 15, minute: 25, second: 0),
    ),
    ClassPeriod(
      subject: 'P7',
      startTime: DateTime.now().copyWith(hour: 15, minute: 30, second: 0),
      endTime: DateTime.now().copyWith(hour: 16, minute: 25, second: 0),
    ),
    ClassPeriod(
      subject: 'P8',
      startTime: DateTime.now().copyWith(hour: 16, minute: 30, second: 0),
      endTime: DateTime.now().copyWith(hour: 17, minute: 35, second: 0),
    ),
  ];

  // Create a public static getter to access the private list.
  static List<ClassPeriod> get periods => _periods;
}
