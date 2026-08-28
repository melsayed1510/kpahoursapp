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
