// file: lib/screens/timeline_with_card.dart

import 'package:classmonitor/Datas/DataModels.dart';
import 'package:classmonitor/component/ClassPeriodCard.dart';
import 'package:classmonitor/models/class_stat.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:classmonitor/models/classesDataModel.dart';
import 'package:classmonitor/models/user_account.dart';
import 'package:classmonitor/models/class_attendance_data.dart';
import 'package:classmonitor/utils/ApiService.dart';

class TimeLineScreen extends StatefulWidget {
  final UserAccount user;
  final int? selectedBatch;

  const TimeLineScreen({super.key, required this.user, this.selectedBatch});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  List<ClassPeriod> _periods = [];
  ClassAttendanceData? _attendanceData;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  final _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _cancelToken.cancel('Widget disposed');
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadAllData();
    }
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = widget.user.copyWith(
        batch: widget.selectedBatch?.toString() ?? widget.user.batch,
      );

      final stats = await ApiService.fetchClassStatsByDate(
        _selectedDate,
        userRole: widget.user.role,
        user: user,
        cancelToken: _cancelToken,
      );

      final ClassStat? currentStat = stats.isNotEmpty ? stats.first : null;

      if (currentStat != null) {
        _attendanceData = ClassAttendanceData.fromClassStat(currentStat);
      } else {
        _attendanceData = ClassAttendanceData(
          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
          prog: user.prog!,
          sem: user.sem!,
          dept: user.dept!,
          batch: user.batch!,
          section: user.sec!,
        );
      }

      // Fetch periods from DataModels
      final newPeriods = DataModels.getPeriodsForDate(_selectedDate).map((
        period,
      ) {
        // debugPrint(
        //   'Fetched period: ${period.subject}, Start: ${DateFormat('h:mm a').format(period.startTime)}, End: ${DateFormat('h:mm a').format(period.endTime)}',
        // );
        final periodNumber = _getPeriodNumberFromSubject(period.subject);
        final bool hasAttended =
            (currentStat?.getPeriodStatus(periodNumber) ?? 0) == 1;

        // Update status for completed but not attended periods
        PeriodStatus status = period.status;
        if (status == PeriodStatus.completed && !hasAttended) {
          status = PeriodStatus.missed;
        }

        return period.copyWith(
          status: status,
          remark: currentStat?.getRemark(periodNumber) ?? '',
          attendanceStatus: hasAttended,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _periods = newPeriods;
        _isLoading = false;
      });
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        debugPrint('Request canceled: $e');
        return;
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred while loading data.";
        _periods = [];
      });
    }
  }

  // PeriodStatus _getPeriodStatus(DateTime start, DateTime end) {
  //   return DataModels.getPeriodStatus(start, end, _selectedDate);
  // }

  void _syncAttendanceToPeriods() {
    if (_attendanceData == null) return;

    _periods = _periods.map((period) {
      final periodNumber = _getPeriodNumberFromSubject(period.subject);
      if (periodNumber > 0) {
        return period.copyWith(
          remark: _attendanceData!.getPeriodRemark(periodNumber),
          attendanceStatus: _attendanceData!.getPeriodStatus(periodNumber) == 1,
        );
      }
      return period;
    }).toList();
  }

  Future<void> _updateBackend({required int periodNumber}) async {
    if (_attendanceData == null) return;

    setState(() {
      _syncAttendanceToPeriods();
    });

    final statToSubmit = ClassStat(
      date: _attendanceData!.date,
      prog: _attendanceData!.prog,
      dept: _attendanceData!.dept,
      sem: _attendanceData!.sem,
      batch: _attendanceData!.batch,
      section: _attendanceData!.section,
      p1: _attendanceData!.p1,
      p2: _attendanceData!.p2,
      p3: _attendanceData!.p3,
      p4: _attendanceData!.p4,
      p5: _attendanceData!.p5,
      p6: _attendanceData!.p6,
      p7: _attendanceData!.p7,
      p8: _attendanceData!.p8,
      p1Remarks: _attendanceData!.p1Remarks,
      p2Remarks: _attendanceData!.p2Remarks,
      p3Remarks: _attendanceData!.p3Remarks,
      p4Remarks: _attendanceData!.p4Remarks,
      p5Remarks: _attendanceData!.p5Remarks,
      p6Remarks: _attendanceData!.p6Remarks,
      p7Remarks: _attendanceData!.p7Remarks,
      p8Remarks: _attendanceData!.p8Remarks,
      lastEntry: _attendanceData!.lastEntry,
      crMarking: _attendanceData!.crMarking,
      profMarking: _attendanceData!.profMarking,
    );

    try {
      final success = await ApiService.upsertClassStat(
        statToSubmit,
        userRole: widget.user.role,
        cancelToken: _cancelToken,
      );

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Period $periodNumber updated successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted && !success) {
        _showErrorSnackBar('Failed to save changes. Please retry.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(_getUserFriendlyError(e.toString()));
      }
    }
  }

  String _getUserFriendlyError(String error) {
    if (error.contains('timeout') || error.contains('TimeoutException')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (error.contains('SocketException') ||
        error.contains('NetworkException')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('FormatException')) {
      return 'Server returned invalid data. Please try again later.';
    } else if (error.contains('401') || error.contains('unauthorized')) {
      return 'Authentication failed. Please login again.';
    } else if (error.contains('403') || error.contains('forbidden')) {
      return 'Access denied. Please check your permissions.';
    } else if (error.contains('404') || error.contains('not found')) {
      return 'Server endpoint not found. Please contact support.';
    } else if (error.contains('500') || error.contains('server error')) {
      return 'Server error. Please try again later.';
    }
    return 'Failed to load data. Please try again.';
  }

  int _getPeriodNumberFromSubject(String subject) {
    if (subject.toUpperCase().startsWith('P')) {
      final numberStr = subject.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(numberStr) ?? 0;
    }
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(subject);
    if (match != null) {
      return int.tryParse(match.group(0) ?? '0') ?? 0;
    }
    return 0;
  }

  void _handleCardTapped(int periodNumber) async {
    if (_attendanceData == null) {
      debugPrint('❌ Cannot handle tap - _attendanceData is null');
      return;
    }
    debugPrint('🔄 Handling card tap for period $periodNumber');
    _attendanceData!.togglePeriod(periodNumber, widget.user.role);
    await _updateBackend(periodNumber: periodNumber);
  }

  void _handleRemarkSaved(int periodNumber, String newRemark) async {
    if (_attendanceData == null) {
      debugPrint('❌ Cannot save remark - _attendanceData is null');
      return;
    }
    debugPrint('💾 Saving remark for period $periodNumber: $newRemark');
    _attendanceData!.setPeriodRemark(periodNumber, newRemark);
    await _updateBackend(periodNumber: periodNumber);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _loadAllData(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            tooltip: 'Refresh Data',
            onPressed: _isLoading ? null : _loadAllData,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            tooltip: 'Select Date',
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading class data...'),
                ],
              ),
            )
          : Container(
              color: Colors.white,
              child: Column(
                children: [
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
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(16.0),
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
                            DateFormat(
                              'EEEE, MMMM d, yyyy',
                            ).format(_selectedDate),
                            style: GoogleFonts.poppins(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _errorMessage != null
                        ? _buildErrorState()
                        : _periods.isEmpty
                        ? _buildEmptyState()
                        : _buildPeriodsList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6a11cb).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _loadAllData,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Try Again',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Classes Today',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no class periods scheduled for this date.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: _loadAllData,
              icon: Icon(Icons.refresh, color: Colors.blue.shade600),
              label: Text(
                'Refresh',
                style: GoogleFonts.poppins(
                  color: Colors.blue.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodsList() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _periods.length,
        itemBuilder: (context, index) {
          final period = _periods[index];
          final periodNumber = _getPeriodNumberFromSubject(period.subject);

          return ClassPeriodCard(
            period: period,
            onCardTapped: () {
              if (periodNumber > 0) {
                _handleCardTapped(periodNumber);
              } else {
                debugPrint('⚠️ Invalid period number for ${period.subject}');
              }
            },
            onRemarkSaved: (newRemark) {
              if (periodNumber > 0) {
                _handleRemarkSaved(periodNumber, newRemark);
              } else {
                debugPrint(
                  '⚠️ Invalid period number for remark save: ${period.subject}',
                );
              }
            },
          );
        },
      ),
    );
  }
}
