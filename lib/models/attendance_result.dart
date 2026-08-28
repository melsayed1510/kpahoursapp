import 'package:flutter/material.dart';

class AttendanceResult {
  final TimeOfDay presenceStart;
  final bool presenceStartNextDay;
  final TimeOfDay presenceEnd;
  final bool presenceEndNextDay;
  final bool isEarlyPresenceAdjusted;

  final TimeOfDay outTime;
  final bool outTimeNextDay;

  final bool isLate;
  final int lateMinutes;
  final TimeOfDay cappedOutTime;
  final bool cappedOutTimeNextDay;

  const AttendanceResult({
    required this.presenceStart,
    required this.presenceStartNextDay,
    required this.presenceEnd,
    required this.presenceEndNextDay,
    required this.isEarlyPresenceAdjusted,
    required this.outTime,
    required this.outTimeNextDay,
    required this.isLate,
    required this.lateMinutes,
    required this.cappedOutTime,
    required this.cappedOutTimeNextDay,
  });
}
