import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmonitor/models/classesDataModel.dart';
import 'package:classmonitor/models/user_account.dart';

class ClassPeriodCard extends StatelessWidget {
  final ClassPeriod period;
  final UserAccount user;
  final int? selectedBatch;
  final VoidCallback onCardTapped;
  final Function(String) onRemarkSaved;

  const ClassPeriodCard({
    super.key,
    required this.period,
    required this.user,
    required this.selectedBatch,
    required this.onCardTapped,
    required this.onRemarkSaved,
  });

  void _showRemarkDialog(BuildContext context) {
    final remarkController = TextEditingController(text: period.remark);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final mediaQuery = MediaQuery.of(dialogContext);
        final screenWidth = mediaQuery.size.width;
        final screenHeight = mediaQuery.size.height;

        const double kTabletBreakpoint = 600.0;
        const double kLargeScreenBreakpoint = 900.0;

        final isTablet = screenWidth > kTabletBreakpoint;
        final isLargeScreen = screenWidth > kLargeScreenBreakpoint;

        final dialogWidth = isLargeScreen
            ? screenWidth * 0.4
            : isTablet
            ? screenWidth * 0.6
            : screenWidth * 0.9;
        final maxDialogHeight = screenHeight * 0.8;

        final titleSize = isLargeScreen
            ? 28.0
            : isTablet
            ? 26.0
            : 24.0;
        final subtitleSize = isLargeScreen
            ? 16.0
            : isTablet
            ? 15.0
            : 14.0;
        final textFieldSize = isLargeScreen
            ? 18.0
            : isTablet
            ? 17.0
            : 16.0;
        final buttonTextSize = isLargeScreen
            ? 18.0
            : isTablet
            ? 17.0
            : 16.0;
        final hintTextSize = isLargeScreen
            ? 18.0
            : isTablet
            ? 17.0
            : 16.0;

        final dialogPadding = isLargeScreen
            ? 32.0
            : isTablet
            ? 28.0
            : 24.0;
        final iconSize = isLargeScreen
            ? 28.0
            : isTablet
            ? 26.0
            : 24.0;
        final iconPadding = isLargeScreen
            ? 16.0
            : isTablet
            ? 14.0
            : 12.0;
        final headerSpacing = isLargeScreen
            ? 20.0
            : isTablet
            ? 18.0
            : 16.0;
        final sectionSpacing = isLargeScreen
            ? 32.0
            : isTablet
            ? 28.0
            : 24.0;
        final buttonRowSpacing = isLargeScreen
            ? 40.0
            : isTablet
            ? 36.0
            : 32.0;
        final buttonHeight = isLargeScreen
            ? 56.0
            : isTablet
            ? 52.0
            : 48.0;
        final buttonSpacing = 16.0;
        final verticalButtonSpacing = 12.0;

        final textFieldMaxLines = isTablet ? 5 : 4;
        final textFieldMinLines = isTablet ? 4 : 3;
        final textFieldContentPadding = isLargeScreen
            ? 24.0
            : isTablet
            ? 22.0
            : 20.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: maxDialogHeight,
            ),
            child: Dialog(
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF8F9FA), Color(0xFFE3F2FD)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(dialogPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(iconPadding),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF667EEA,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit_note_rounded,
                                color: Colors.white,
                                size: iconSize,
                              ),
                            ),
                            SizedBox(width: headerSpacing),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Add Remark',
                                      style: GoogleFonts.poppins(
                                        fontSize: titleSize,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2D3748),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 4 : 2),
                                  Text(
                                    'Share your thoughts about this class',
                                    style: GoogleFonts.poppins(
                                      fontSize: subtitleSize,
                                      color: const Color(0xFF718096),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sectionSpacing),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: remarkController,
                            maxLines: textFieldMaxLines,
                            minLines: textFieldMinLines,
                            autofocus: true,
                            style: GoogleFonts.poppins(
                              fontSize: textFieldSize,
                              color: const Color(0xFF2D3748),
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  "What would you like to note about this class?",
                              hintStyle: GoogleFonts.poppins(
                                color: const Color(0xFF9CA3AF),
                                fontSize: hintTextSize,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.all(
                                textFieldContentPadding,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF667EEA),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: buttonRowSpacing),
                        isTablet
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _buildCancelButton(
                                      dialogContext,
                                      buttonHeight,
                                      buttonTextSize,
                                    ),
                                  ),
                                  SizedBox(width: buttonSpacing),
                                  Expanded(
                                    child: _buildSaveButton(
                                      dialogContext,
                                      remarkController,
                                      onRemarkSaved,
                                      buttonHeight,
                                      buttonTextSize,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: _buildSaveButton(
                                      dialogContext,
                                      remarkController,
                                      onRemarkSaved,
                                      buttonHeight,
                                      buttonTextSize,
                                    ),
                                  ),
                                  SizedBox(height: verticalButtonSpacing),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _buildCancelButton(
                                      dialogContext,
                                      buttonHeight,
                                      buttonTextSize,
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 50), () {
        remarkController.dispose();
      });
    });
  }

  Widget _buildCancelButton(
    BuildContext context,
    double height,
    double textSize,
  ) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              fontSize: textSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    TextEditingController controller,
    Function(String) onSaveCallback,
    double height,
    double textSize,
  ) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          final remarkText = controller.text.trim();
          Navigator.of(context).pop();
          onSaveCallback(remarkText);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.save_rounded, color: Colors.white, size: textSize + 4),
              const SizedBox(width: 8),
              Text(
                'Save Remark',
                style: GoogleFonts.poppins(
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodStatus = period.status;
    final cardTheme = _getThemeForStatus(periodStatus);
    final String startTime = DateFormat.jm().format(period.startTime);
    final String endTime = DateFormat.jm().format(period.endTime);
    final bool isClickable = periodStatus == PeriodStatus.ongoing;
    final bool canAddRemark = periodStatus != PeriodStatus.upcoming;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return GestureDetector(
      onTap: isClickable ? onCardTapped : null,
      child: Opacity(
        opacity: isClickable ? 1.0 : 0.6,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      child: Center(
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Icon(
                              cardTheme.icon,
                              color: cardTheme.color,
                              size: isSmallScreen ? 26 : 28,
                            ),
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
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
                      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                  icon: const Icon(
                                    Icons.edit_note,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => _showRemarkDialog(context),
                                  tooltip: 'Add/Edit Remark',
                                  splashRadius: 20,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (period.subject == 'Lunch Break')
                            Text(
                              'Enjoy Your Break time!',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: cardTheme.textColor.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Time: $startTime - $endTime',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: cardTheme.textColor.withOpacity(0.8),
                            ),
                          ),

                          if (period.remark != null &&
                              period.remark!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'Remark: ${period.remark}',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  fontStyle: FontStyle.italic,
                                  color: cardTheme.textColor.withOpacity(0.7),
                                ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
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
