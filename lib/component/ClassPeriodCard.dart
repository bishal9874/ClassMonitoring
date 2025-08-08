import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/classesDataModel.dart';

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

  @override
  Widget build(BuildContext context) {
    PeriodStatus finalStatus = period.status;
    final bool attendanceMarked = period.attendanceStatus ?? false;

    if (finalStatus == PeriodStatus.completed && !attendanceMarked) {
      finalStatus = PeriodStatus.missed;
    }

    final cardTheme = _getThemeForStatus(finalStatus, period.subject);

    final String startTime = DateFormat('h:mm a').format(period.startTime);
    final String endTime = DateFormat('h:mm a').format(period.endTime);

    final bool isClickable = finalStatus == PeriodStatus.ongoing;
    final bool canAddRemark = finalStatus != PeriodStatus.upcoming;
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return GestureDetector(
      onTap: isClickable ? onCardTapped : null,
      child: AnimatedOpacity(
        opacity: isClickable ? 1.0 : 0.85,
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTimeline(cardTheme, isSmallScreen, startTime, endTime),
                _buildDetailsCard(
                  context,
                  cardTheme,
                  canAddRemark,
                  isSmallScreen,
                  startTime,
                  endTime,
                  finalStatus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(
    _CardThemeData cardTheme,
    bool isSmallScreen,
    String startTime,
    String endTime,
  ) {
    return SizedBox(
      width: isSmallScreen ? 80 : 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(
          //   startTime,
          //   textAlign: TextAlign.center,
          //   style: GoogleFonts.poppins(
          //     fontWeight: FontWeight.w600,
          //     fontSize: isSmallScreen ? 11 : 12,
          //     color: Colors.black87,
          //   ),
          // ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade300,
                        cardTheme.color.withOpacity(0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: cardTheme.color, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: cardTheme.color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    cardTheme.icon,
                    color: cardTheme.color,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Text(
          //   endTime,
          //   textAlign: TextAlign.center,
          //   style: GoogleFonts.poppins(
          //     fontWeight: FontWeight.w600,
          //     fontSize: isSmallScreen ? 11 : 12,
          //     color: Colors.black87,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    _CardThemeData cardTheme,
    bool canAddRemark,
    bool isSmallScreen,
    String startTime,
    String endTime,
    PeriodStatus finalStatus,
  ) {
    final bool attendanceMarked = period.attendanceStatus ?? false;

    return Expanded(
      child: Card(
        elevation: 6.0,
        shadowColor: cardTheme.color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: finalStatus == PeriodStatus.missed
                ? Colors.red.shade400
                : (attendanceMarked
                      ? Colors.green.shade600
                      : cardTheme.color.withOpacity(0.8)),
            width: attendanceMarked || finalStatus == PeriodStatus.missed
                ? 2.5
                : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, cardTheme.color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        period.subject,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 18,
                          color: cardTheme.textColor,
                        ),
                      ),
                    ),
                    if (canAddRemark)
                      IconButton(
                        icon: Icon(
                          Icons.edit_note,
                          color: cardTheme.textColor.withOpacity(0.7),
                          size: isSmallScreen ? 20 : 24,
                        ),
                        onPressed: () => _showRemarkDialog(context),
                        tooltip: 'Add/Edit Remark',
                        splashRadius: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Time: $startTime - $endTime',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: cardTheme.textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if ((period.remark ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.comment,
                          size: isSmallScreen ? 14 : 16,
                          color: cardTheme.textColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Remark: ${period.remark}',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 11 : 12,
                              fontStyle: FontStyle.italic,
                              color: cardTheme.textColor.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (finalStatus == PeriodStatus.ongoing)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cardTheme.color,
                            cardTheme.color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: cardTheme.color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'IN PROGRESS',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 10 : 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemarkDialog(BuildContext context) {
    final remarkController = TextEditingController(text: period.remark);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.edit_note, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 8),
              Text(
                'Add Remark',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: remarkController,
            autofocus: true,
            maxLines: 4,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: "Enter notes for this period...",
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                onRemarkSaved(remarkController.text.trim());
                Navigator.of(dialogContext).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _CardThemeData _getThemeForStatus(PeriodStatus status, String subject) {
    if (subject.contains('Lunch')) {
      return _CardThemeData(
        color: Colors.orange.shade600,
        gradientColors: [Colors.orange.shade400, Colors.yellow.shade400],
        icon: Icons.restaurant_menu,
        textColor: Colors.black87,
      );
    }
    switch (status) {
      case PeriodStatus.completed:
        return _CardThemeData(
          color: Colors.green.shade500,
          gradientColors: [Colors.green.shade400, Colors.teal.shade400],
          icon: Icons.check_circle_outline,
          textColor: Colors.black87,
        );
      case PeriodStatus.missed:
        return _CardThemeData(
          color: Colors.red.shade400,
          gradientColors: [Colors.red.shade300, Colors.pink.shade300],
          icon: Icons.cancel_outlined,
          textColor: Colors.black87,
        );
      case PeriodStatus.ongoing:
        return _CardThemeData(
          color: Colors.indigo.shade600,
          gradientColors: [Colors.indigo.shade500, Colors.blue.shade500],
          icon: Icons.timelapse_rounded,
          textColor: Colors.black87,
        );
      case PeriodStatus.upcoming:
        return _CardThemeData(
          color: Colors.amber.shade800,
          gradientColors: [Colors.amber.shade600, Colors.orange.shade600],
          icon: Icons.notifications_none_rounded,
          textColor: Colors.black87,
        );
    }
  }
}

class _CardThemeData {
  final Color color;
  final List<Color> gradientColors;
  final IconData icon;
  final Color textColor;

  _CardThemeData({
    required this.color,
    required this.gradientColors,
    required this.icon,
    required this.textColor,
  });
}
