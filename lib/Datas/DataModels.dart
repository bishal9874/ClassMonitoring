import 'package:classmonitor/models/classesDataModel.dart'; // Ensure this path is correct

class DataModels {
  // Make the list static so it belongs to the class itself, not an instance.
  static final List<ClassPeriod> _periods = [
    ClassPeriod(
      subject: 'Quantum Physics',
      teacher: 'Dr. Evelyn Reed',
      startTime: DateTime.now().copyWith(hour: 9, minute: 0, second: 0),
      endTime: DateTime.now().copyWith(hour: 9, minute: 50, second: 0),
    ),
    ClassPeriod(
      subject: 'Advanced Mathematics',
      teacher: 'Prof. Alan Turing',
      startTime: DateTime.now().copyWith(hour: 10, minute: 0, second: 0),
      endTime: DateTime.now().copyWith(hour: 10, minute: 50, second: 0),
    ),
    ClassPeriod(
      subject: 'Software Engineering',
      teacher: 'Ms. Ada Lovelace',
      startTime: DateTime.now().copyWith(hour: 11, minute: 0, second: 0),
      endTime: DateTime.now().copyWith(hour: 11, minute: 50, second: 0),
    ),
    ClassPeriod(
      subject: 'Lunch Break',
      teacher: 'Cafeteria',
      startTime: DateTime.now().copyWith(hour: 12, minute: 0, second: 0),
      endTime: DateTime.now().copyWith(hour: 13, minute: 0, second: 0),
    ),
    ClassPeriod(
      subject: 'C Programming Lab',
      teacher: 'Dr. Marie Curie',
      startTime: DateTime.now().copyWith(hour: 14, minute: 0, second: 0),
      endTime: DateTime.now().copyWith(hour: 15, minute: 30, second: 0),
    ),
    ClassPeriod(
      subject: 'java Programming Lab',
      teacher: 'Dr Debdutta Pal',
      startTime: DateTime.now().copyWith(hour: 15, minute: 35, second: 0),
      endTime: DateTime.now().copyWith(hour: 16, minute: 30, second: 0),
    ),
    ClassPeriod(
      subject: 'java Programming Lab',
      teacher: 'Dr Debdutta Pal',
      startTime: DateTime.now().copyWith(hour: 16, minute: 35, second: 0),
      endTime: DateTime.now().copyWith(hour: 17, minute: 30, second: 0),
    ),
  ];

  // Create a public static getter to access the private list.
  static List<ClassPeriod> get periods => _periods;
}
