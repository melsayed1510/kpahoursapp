import 'package:flutter/material.dart';
import '../models/attendance_result.dart';

class AttendanceCalculatorService {
  static const int _minShiftMinutes = 60;      // حد أدنى: ساعة واحدة
  static const int _maxShiftMinutes = 12 * 60; // حد أقصى: 12 ساعة

  // سقف بصمة الدخول الصباحية: 08:30 صباحاً (510 دقيقة)
  static const int maxAllowedInMinutes = (8 * 60) + 30;

  // أدنى موعد لبدء نافذة التواجد: 09:00 صباحاً (540 دقيقة) -> تبدأ 09:01
  static const int minPresenceThresholdMinutes = 9 * 60;
  static const int forcedPresenceStartMinutes = (9 * 60) + 1; // 09:01
  static const int forcedPresenceEndMinutes = 10 * 60;        // 10:00

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

    // 1. حساب نافذة التواجد مع شرط عدم البدء قبل الساعة 09:00
    final theoreticalPresenceStart = inMinutes + (2 * 60) + 1;
    final theoreticalPresenceEnd = inMinutes + (3 * 60);

    final bool isEarlyAdjusted = (inMinutes < minPresenceThresholdMinutes) &&
        (theoreticalPresenceStart < forcedPresenceStartMinutes);

    final int presenceStartTotal =
        isEarlyAdjusted ? forcedPresenceStartMinutes : theoreticalPresenceStart;
    final int presenceEndTotal =
        isEarlyAdjusted ? forcedPresenceEndMinutes : theoreticalPresenceEnd;

    // 2. حساب وقت الخروج الفعلي
    final outTotal = inMinutes + shiftDuration.inMinutes;

    // 3. احتساب التأخير وسقف موعد الخروج إذا كان الدخول بعد 08:30
    final bool isLate = inMinutes > maxAllowedInMinutes;
    final int lateMinutes = isLate ? (inMinutes - maxAllowedInMinutes) : 0;

    // وقت الخروج المعتمد (لا يتجاوز سقف 08:30 + مدة الدوام)
    final int cappedOutTotal = isLate
        ? (maxAllowedInMinutes + shiftDuration.inMinutes)
        : outTotal;

    return AttendanceResult(
      presenceStart: _toTimeOfDay(presenceStartTotal),
      presenceStartNextDay: presenceStartTotal >= 24 * 60,
      presenceEnd: _toTimeOfDay(presenceEndTotal),
      presenceEndNextDay: presenceEndTotal >= 24 * 60,
      isEarlyPresenceAdjusted: isEarlyAdjusted,
      outTime: _toTimeOfDay(outTotal),
      outTimeNextDay: outTotal >= 24 * 60,
      isLate: isLate,
      lateMinutes: lateMinutes,
      cappedOutTime: _toTimeOfDay(cappedOutTotal),
      cappedOutTimeNextDay: cappedOutTotal >= 24 * 60,
    );
  }

  TimeOfDay _toTimeOfDay(int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    return TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
  }
}
