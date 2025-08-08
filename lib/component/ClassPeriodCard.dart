import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// Make sure the path to your data model is correct for your project
import '../models/classesDataModel.dart';

/// A card widget that displays information about a single class period.
class ClassPeriodCard extends StatelessWidget {
  final ClassPeriod period;
  final VoidCallback onCardTapped;
  final Function(String) onRemarkSaved;

  // The constructor does not have a 'user' parameter.
  const ClassPeriodCard({
    super.key,
    required this.period,
    required this.onCardTapped,
    required this.onRemarkSaved,
  });

  @override
  Widget build(BuildContext context) {
    final cardTheme = _getThemeForStatus(period.status);
    final String startTime = DateFormat.jm().format(period.startTime);
    final String endTime = DateFormat.jm().format(period.endTime);

    final bool isClickable = period.status == PeriodStatus.ongoing;
    final bool canAddRemark = period.status != PeriodStatus.upcoming;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return GestureDetector(
      onTap: isClickable ? onCardTapped : null,
      child: Opacity(
        opacity: isClickable ? 1.0 : 0.75,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimeline(startTime, endTime, cardTheme, isSmallScreen),
              _buildDetailsCard(
                context,
                cardTheme,
                canAddRemark,
                isSmallScreen,
                startTime,
                endTime,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (All helper methods like _buildTimeline, _buildDetailsCard, _showRemarkDialog, etc. remain unchanged)
  Widget _buildTimeline(
    String startTime,
    String endTime,
    _CardThemeData cardTheme,
    bool isSmallScreen,
  ) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Text(
            startTime,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12 : 13,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(width: 2, color: Colors.grey.shade300),
                ),
                Icon(
                  cardTheme.icon,
                  color: cardTheme.color,
                  size: isSmallScreen ? 26 : 28,
                ),
                Expanded(
                  child: Container(width: 2, color: Colors.grey.shade300),
                ),
              ],
            ),
          ),
          Text(
            endTime,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12 : 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
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
  ) {
    final bool attendanceMarked = period.attendanceStatus ?? false;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
        child: Card(
          elevation: 4.0,
          shadowColor: Colors.grey.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              // Use green for attended, or the status color otherwise
              color: attendanceMarked
                  ? Colors.green.shade600
                  : cardTheme.color.withOpacity(0.8),
              width: attendanceMarked ? 2.0 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        icon: const Icon(Icons.edit_note, color: Colors.grey),
                        onPressed: () => _showRemarkDialog(context),
                        tooltip: 'Add/Edit Remark',
                        splashRadius: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Time: $startTime - $endTime',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: cardTheme.textColor.withOpacity(0.8),
                  ),
                ),
                if (period.remark != null && period.remark!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'Remark: ${period.remark}',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 13,
                        fontStyle: FontStyle.italic,
                        color: cardTheme.textColor.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (period.status == PeriodStatus.ongoing)
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
                        style: GoogleFonts.poppins(
                          color: cardTheme.color,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
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
          title: Text(
            'Add Remark',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: remarkController,
            autofocus: true,
            maxLines: 4,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              hintText: "Enter notes for this period...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
              onPressed: () {
                onRemarkSaved(remarkController.text.trim());
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _CardThemeData _getThemeForStatus(PeriodStatus status) {
    switch (status) {
      case PeriodStatus.completed:
        return _CardThemeData(
          color: Colors.grey.shade500,
          icon: Icons.check_circle_outline,
          textColor: Colors.black54,
        );
      case PeriodStatus.ongoing:
        return _CardThemeData(
          color: Colors.indigo.shade600,
          icon: Icons.timelapse_rounded,
          textColor: Colors.black87,
        );
      case PeriodStatus.upcoming:
        return _CardThemeData(
          color: Colors.amber.shade800,
          icon: Icons.notifications_none_rounded,
          textColor: Colors.black87,
        );
      case PeriodStatus.missed:
        return _CardThemeData(
          color: Colors.red.shade400,
          icon: Icons.cancel_outlined,
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
