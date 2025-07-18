import 'dart:ui';
import 'package:classmonitor/models/classesDataModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class ClassPeriodCard extends StatelessWidget {
//   final ClassPeriod period;

//   const ClassPeriodCard({super.key, required this.period});

//   @override
//   Widget build(BuildContext context) {
//     // Get the theme based on the dynamic status
//     final cardTheme = _getThemeForStatus(period.status);

//     // Format times for display
//     final String startTime = DateFormat.jm().format(period.startTime);
//     final String endTime = DateFormat.jm().format(period.endTime);

//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Timeline Column
//           SizedBox(
//             width: 70,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   startTime,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(width: 2, height: 20, color: Colors.grey.shade300),
//                 Icon(cardTheme.icon, color: cardTheme.color, size: 28),
//                 Expanded(
//                   child: Container(width: 2, color: Colors.grey.shade300),
//                 ),
//               ],
//             ),
//           ),
//           // Card Column
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
//               child: Card(
//                 elevation: 3.0,
//                 shape: RoundedRectangleBorder(
//                   side: BorderSide(
//                     color: cardTheme.color.withOpacity(0.7),
//                     width: 1.5,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         period.subject,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                           color: cardTheme.textColor,
//                           decoration: TextDecoration.none,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Teacher: ${period.teacher}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: cardTheme.textColor.withOpacity(0.8),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Time: $startTime - $endTime',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: cardTheme.textColor.withOpacity(0.8),
//                         ),
//                       ),
//                       if (period.status == PeriodStatus.ongoing)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 12.0),
//                           child: Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: cardTheme.color.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(
//                                   'IN PROGRESS',
//                                   style: TextStyle(
//                                     color: cardTheme.color,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to get theme data based on status
//   _CardThemeData _getThemeForStatus(PeriodStatus status) {
//     switch (status) {
//       case PeriodStatus.completed:
//         return _CardThemeData(
//           color: const Color.fromARGB(255, 56, 235, 32),
//           icon: Icons.check_circle,
//           textColor: Colors.grey.shade600,
//         );
//       case PeriodStatus.ongoing:
//         return _CardThemeData(
//           color: Colors.indigo,
//           icon: Icons.timelapse,
//           textColor: Colors.black87,
//         );
//       case PeriodStatus.upcoming:
//         return _CardThemeData(
//           color: Colors.amber.shade700,
//           icon: Icons.notifications,
//           textColor: Colors.black87,
//         );
//     }
//   }
// }

// // Simple data class to hold theme properties
// class _CardThemeData {
//   final Color color;
//   final IconData icon;
//   final Color textColor;
//   _CardThemeData({
//     required this.color,
//     required this.icon,
//     required this.textColor,
//   });
// }

class ClassPeriodCard extends StatelessWidget {
  final ClassPeriod period;
  final VoidCallback onCardTapped;
  final Function(String) onRemarkSaved;
  const ClassPeriodCard({
    super.key,
    required this.period,
    required this.onCardTapped,
    required this.onRemarkSaved,
  });

  void _showRemarkDialog(BuildContext context) {
    final remarkController = TextEditingController(text: period.remark);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add/Edit Remark'),
          content: TextField(
            controller: remarkController,
            decoration: const InputDecoration(
              hintText: "Enter your remarks here...",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onRemarkSaved(remarkController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodStatus = period.status; // Get the current status
    final cardTheme = _getThemeForStatus(periodStatus);
    final String startTime = DateFormat.jm().format(period.startTime);
    final String endTime = DateFormat.jm().format(period.endTime);
    final bool isClickable = periodStatus == PeriodStatus.ongoing;
    final bool canAddRemark = periodStatus != PeriodStatus.upcoming;
    return GestureDetector(
      onTap: isClickable ? onCardTapped : null,
      child: Opacity(
        opacity: periodStatus == PeriodStatus.ongoing ? 1.0 : 0.7,
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Column(
                  children: [
                    Text(
                      startTime,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      width: 2,
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                    Icon(cardTheme.icon, color: cardTheme.color, size: 28),
                    Expanded(
                      child: Container(width: 2, color: Colors.grey.shade300),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
                  child: Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: cardTheme.color.withOpacity(0.8),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  period.subject,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: cardTheme.textColor,
                                    decoration:
                                        periodStatus ==
                                                PeriodStatus.completed ||
                                            periodStatus == PeriodStatus.missed
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              // NEW: Edit Remark Button
                              if (canAddRemark)
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_note,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => _showRemarkDialog(context),
                                  tooltip: 'Add/Edit Remark',
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Teacher: ${period.teacher}',
                            style: TextStyle(
                              color: cardTheme.textColor.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Time: $startTime - $endTime',
                            style: TextStyle(
                              color: cardTheme.textColor.withOpacity(0.8),
                            ),
                          ),
                          if (periodStatus == PeriodStatus.ongoing)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: cardTheme.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'IN PROGRESS',
                                  style: TextStyle(
                                    color: cardTheme.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED: This helper now handles all four states.
  _CardThemeData _getThemeForStatus(PeriodStatus status) {
    switch (status) {
      case PeriodStatus.completed:
        return _CardThemeData(
          color: Colors.green.shade600,
          icon: Icons.check_circle,
          textColor: Colors.grey.shade700,
        );
      case PeriodStatus.ongoing:
        return _CardThemeData(
          color: Colors.indigo,
          icon: Icons.timelapse,
          textColor: Colors.black87,
        );
      case PeriodStatus.upcoming:
        return _CardThemeData(
          color: Colors.amber.shade700,
          icon: Icons.notifications,
          textColor: Colors.black87,
        );
      case PeriodStatus.missed:
        return _CardThemeData(
          color: Colors.red.shade400,
          icon: Icons.cancel,
          textColor: Colors.grey.shade700,
        );
    }
  }
}

// This simple data class remains the same.
class _CardThemeData {
  final Color color;
  final IconData icon;
  final Color textColor;
  _CardThemeData({
    required this.color,
    required this.icon,
    required this.textColor,
  });
}
