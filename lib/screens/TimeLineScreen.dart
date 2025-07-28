import 'package:classmonitor/Datas/DataModels.dart';
import 'package:classmonitor/components/ClassPeriodCard.dart';
import 'package:classmonitor/models/classesDataModel.dart';
import 'package:flutter/material.dart';

class TimeLineScreen extends StatefulWidget {
  const TimeLineScreen({super.key});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Class Checker')),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          itemCount: DataModels.periods.length,
          itemBuilder: (context, index) {
            final period = DataModels.periods[index];
            return ClassPeriodCard(
              period: period,
              onCardTapped: () => _markPeriodAsDone(period),
              onRemarkSaved: (newRemark) => _updateRemark(period, newRemark),
            );
          },
        ),
      ),
    );
  }
}
