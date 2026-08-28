import 'package:flutter/material.dart';
import '../models/attendance_result.dart';

class AttendanceCalculatorService {
  static const int _minShiftMinutes = 60;      // حد أدنى: ساعة واحدة
  static const int _maxShiftMinutes = 12 * 60; // حد أقصى: 12 ساعة

  /// يتحقق من صحة مدة الدوام
  bool isValidShiftDuration(Duration duration) {
    final mins = duration.inMinutes;
    return mins >= _minShiftMinutes && mins <= _maxShiftMinutes;
  }

  AttendanceResult calculate({
    required TimeOfDay inTime,
    required Duration shiftDuration,
  }) {
    assert(isValidShiftDuration(shiftDuration),
        'شيفت غير صالح: يجب أن يكون بين ساعة و 12 ساعة');

    final inMinutes = inTime.hour * 60 + inTime.minute;

    // بداية التواجد: +2 ساعة و1 دقيقة
    final presenceStartTotal = inMinutes + (2 * 60) + 1;
    // نهاية التواجد: +3 ساعات
    final presenceEndTotal = inMinutes + (3 * 60);
    // بصمة الخروج: + مدة الدوام كاملة
    final outTotal = inMinutes + shiftDuration.inMinutes;

    return AttendanceResult(
      presenceStart: _toTimeOfDay(presenceStartTotal),
      presenceStartNextDay: presenceStartTotal >= 24 * 60,
      presenceEnd: _toTimeOfDay(presenceEndTotal),
      presenceEndNextDay: presenceEndTotal >= 24 * 60,
      outTime: _toTimeOfDay(outTotal),
      outTimeNextDay: outTotal >= 24 * 60,
    );
  }

  TimeOfDay _toTimeOfDay(int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    return TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
  }
}
