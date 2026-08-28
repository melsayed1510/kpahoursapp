import 'package:flutter_test/flutter_test.dart';
import 'package:kpa_shift_app/services/shift_calculator_service.dart';
import 'package:kpa_shift_app/models/shift_type.dart';

void main() {
  final service = ShiftCalculatorService();

  test('1 يناير 2026 يجب أن يكون شيفت A', () {
    expect(service.shiftForDate(DateTime(2026, 1, 1)), ShiftType.a);
  });

  test('2 يناير 2026 يجب أن يكون شيفت B', () {
    expect(service.shiftForDate(DateTime(2026, 1, 2)), ShiftType.b);
  });

  test('4 يناير 2026 يعود للدورة = شيفت A مجددًا', () {
    expect(service.shiftForDate(DateTime(2026, 1, 4)), ShiftType.a);
  });

  test('تاريخ قبل baseDate يجب ألا يسبب خطأ أو رقم سالب', () {
    expect(() => service.shiftForDate(DateTime(2025, 12, 30)), returnsNormally);
  });
}
