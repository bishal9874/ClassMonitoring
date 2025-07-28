import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Assuming models/classesDataModel.dart contains ClassPeriod and PeriodStatus
import 'package:classmonitor/models/classesDataModel.dart';

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

  // Helper method to show the remark dialog
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
              border: OutlineInputBorder(), // Add a border for better visual
            ),
            maxLines: 3,
            minLines: 1, // Allow it to be single line if content is short
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
              // Style the save button a bit more
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodStatus = period.status;
    final cardTheme = _getThemeForStatus(periodStatus);
    final String startTime = DateFormat.jm().format(period.startTime);
    final String endTime = DateFormat.jm().format(period.endTime);

    // Determine if the card is clickable (only for ongoing periods)
    final bool isClickable = periodStatus == PeriodStatus.ongoing;
    // Determine if remarks can be added/edited (not for upcoming)
    final bool canAddRemark = periodStatus != PeriodStatus.upcoming;

    return GestureDetector(
      // Only enable tap if the card is clickable
      onTap: isClickable ? onCardTapped : null,
      child: Opacity(
        // Reduce opacity for non-ongoing cards to visually indicate status
        opacity: isClickable ? 1.0 : 0.6, // Slightly more pronounced opacity
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment
                .stretch, // Ensure children stretch vertically
            children: [
              SizedBox(
                width: 80, // Consistent width for timeline
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Align timeline items to start
                  children: [
                    const SizedBox(height: 12), // Align with card's top padding
                    Text(
                      startTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // Consistent font size
                        color: Colors.black87, // Darker color for time
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Expanded(
                              // Top line segment
                              child: Container(
                                width: 2,
                                color: Colors
                                    .grey
                                    .shade400, // Lighter grey for timeline
                              ),
                            ),
                            Icon(
                              cardTheme.icon,
                              color: cardTheme.color,
                              size: 28,
                            ),
                            Expanded(
                              // Bottom line segment
                              child: Container(
                                width: 2,
                                color: Colors
                                    .grey
                                    .shade400, // Lighter grey for timeline
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      endTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // Consistent font size
                        color: Colors.black87, // Darker color for time
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ), // Align with card's bottom padding
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    0,
                    12,
                    16,
                    12,
                  ), // Padding around the card
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
                                    // decoration:
                                    //     (periodStatus ==
                                    //             PeriodStatus.completed ||
                                    //         periodStatus == PeriodStatus.missed)
                                    //     ? TextDecoration.lineThrough
                                    //     : TextDecoration.none,
                                    decorationColor: cardTheme.textColor
                                        .withOpacity(0.7),
                                    decorationThickness: 2.0,
                                  ),
                                ),
                              ),
                              // Edit Remark Button (only if remarks can be added)
                              if (canAddRemark)
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_note,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => _showRemarkDialog(context),
                                  tooltip: 'Add/Edit Remark',
                                  splashRadius: 20, // Smaller splash effect
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Display teacher or "Enjoy Your Break Time" based on subject
                          (period.subject == 'Lunch Break')
                              ? Text(
                                  'Enjoy Your Break time!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: cardTheme.textColor.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Text(
                                  'Teacher: ${period.teacher}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: cardTheme.textColor.withOpacity(0.8),
                                  ),
                                ),
                          const SizedBox(height: 8),
                          Text(
                            'Time: $startTime - $endTime',
                            style: TextStyle(
                              fontSize: 14,
                              color: cardTheme.textColor.withOpacity(0.8),
                            ),
                          ),
                          // Display "IN PROGRESS" tag for ongoing classes
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
                          // Display remark if available
                          if (period.remark != null &&
                              period.remark!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'Remark: ${period.remark}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: cardTheme.textColor.withOpacity(0.7),
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

  // Helper method to get theme data based on status
  _CardThemeData _getThemeForStatus(PeriodStatus status) {
    switch (status) {
      case PeriodStatus.completed:
        return _CardThemeData(
          color: const Color.fromARGB(255, 4, 209, 14),
          icon: Icons.check_circle,
          textColor: Colors.black,
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
