import 'package:flutter/material.dart';

class AttendanceResult {
  final TimeOfDay presenceStart;
  final bool presenceStartNextDay;
  final TimeOfDay presenceEnd;
  final bool presenceEndNextDay;
  final TimeOfDay outTime;
  final bool outTimeNextDay;

  const AttendanceResult({
    required this.presenceStart,
    required this.presenceStartNextDay,
    required this.presenceEnd,
    required this.presenceEndNextDay,
    required this.outTime,
    required this.outTimeNextDay,
  });
}
