import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kpa_shift_app/services/attendance_calculator_service.dart';

void main() {
  final service = AttendanceCalculatorService();

  test('مثال أساسي: دخول 07:30 ودوام 6:30', () {
    final result = service.calculate(
      inTime: const TimeOfDay(hour: 7, minute: 30),
      shiftDuration: const Duration(hours: 6, minutes: 30),
    );
    expect(result.presenceStart, const TimeOfDay(hour: 9, minute: 31));
    expect(result.presenceEnd, const TimeOfDay(hour: 10, minute: 30));
    expect(result.outTime, const TimeOfDay(hour: 14, minute: 0));
    expect(result.outTimeNextDay, false);
    expect(result.isLate, false);
    expect(result.lateMinutes, 0);
    expect(result.cappedOutTime, const TimeOfDay(hour: 14, minute: 0));
  });

  test('دخول مبكر 06:00: بصمة التواجد تبدأ إجبارياً من 09:01 حتى 10:00', () {
    final result = service.calculate(
      inTime: const TimeOfDay(hour: 6, minute: 0),
      shiftDuration: const Duration(hours: 6, minutes: 30),
    );
    expect(result.presenceStart, const TimeOfDay(hour: 9, minute: 1));
    expect(result.presenceEnd, const TimeOfDay(hour: 10, minute: 0));
    expect(result.isEarlyPresenceAdjusted, true);
    expect(result.outTime, const TimeOfDay(hour: 12, minute: 30));
    expect(result.isLate, false);
  });

  test('دخول متأخر بعد 08:30 (مثلاً 09:00 مع دوام 6:30): تأخير 30 دقيقة وسقف الخروج 15:00', () {
    final result = service.calculate(
      inTime: const TimeOfDay(hour: 9, minute: 0),
      shiftDuration: const Duration(hours: 6, minutes: 30),
    );
    expect(result.isLate, true);
    expect(result.lateMinutes, 30);
    expect(result.cappedOutTime, const TimeOfDay(hour: 15, minute: 0));
    expect(result.outTime, const TimeOfDay(hour: 15, minute: 30));
  });

  test('تجاوز منتصف الليل: دخول 22:00 ودوام 6:00', () {
    final result = service.calculate(
      inTime: const TimeOfDay(hour: 22, minute: 0),
      shiftDuration: const Duration(hours: 6),
    );
    expect(result.outTime, const TimeOfDay(hour: 4, minute: 0));
    expect(result.outTimeNextDay, true);
  });

  test('رفض مدة دوام أقل من الحد الأدنى', () {
    expect(
      service.isValidShiftDuration(const Duration(minutes: 30)),
      false,
    );
  });

  test('رفض مدة دوام أكثر من 12 ساعة', () {
    expect(
      service.isValidShiftDuration(const Duration(hours: 13)),
      false,
    );
  });
}
