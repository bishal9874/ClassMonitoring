import 'package:classmonitor/Datas/DataModels.dart';
import 'package:classmonitor/components/ClassPeriodCard.dart';
import 'package:classmonitor/models/classesDataModel.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:classmonitor/models/user_account.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class TimeLineScreen extends StatefulWidget {
  final UserAccount user;
  final int? selectedBatch;

  const TimeLineScreen({super.key, required this.user, this.selectedBatch});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  List<ClassPeriod> _periods = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPeriods();
  }

  Future<void> _fetchPeriods() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      List<ClassPeriod> periods = DataModels.periods;
      setState(() {
        _periods = periods;
      });
    } catch (e) {
      debugPrint('Error fetching periods: $e');
      setState(() {
        _errorMessage =
            'Failed to load periods: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _markPeriodAsDone(ClassPeriod periodToMark) {
    if (periodToMark.status == PeriodStatus.ongoing) {
      setState(() {
        periodToMark.isManuallyCompleted = true;
      });
    }
  }

  void _updateRemark(ClassPeriod periodToUpdate, String newRemark) {
    setState(() {
      periodToUpdate.remark = newRemark;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Format the date using intl package
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(now); // e.g., Thursday, July 31, 2025

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Class Checker',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Periods',
            onPressed: _isLoading ? null : _fetchPeriods,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            // Styled Date Display
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 20.0,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4a90e2),
                          ),
                        ),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 50,
                              color: Colors.red.shade600,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                color: Colors.red.shade700,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _fetchPeriods,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4a90e2),
                                      Color(0xFF9013fe),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _periods.isEmpty
                    ? Center(
                        child: Text(
                          'No periods available for ${widget.selectedBatch ?? 'selected batch'}.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        itemCount: _periods.length,
                        itemBuilder: (context, index) {
                          final period = _periods[index];
                          return ClassPeriodCard(
                            period: period,
                            user: widget.user,
                            selectedBatch: widget.selectedBatch,
                            onCardTapped: () => _markPeriodAsDone(period),
                            onRemarkSaved: (newRemark) =>
                                _updateRemark(period, newRemark),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
