import '../models/shift_type.dart';

class ShiftCalculatorService {
  /// تاريخ مرجعي: 1 يناير 2026 (يعتبر بداية الدورة، شيفت A)
  static final DateTime _baseDate = DateTime.utc(2026, 1, 1);

  static const List<ShiftType> _cycle = [ShiftType.a, ShiftType.b, ShiftType.c];

  /// يحسب الشيفت الحالي بناءً على التاريخ
  ShiftType calculateCurrentShift({DateTime? forDate}) {
    final date = forDate ?? DateTime.now();
    final dateUtc = DateTime.utc(date.year, date.month, date.day);

    final diffInDays = dateUtc.difference(_baseDate).inDays;

    final index = ((diffInDays % 3) + 3) % 3; // نتيجة موجبة دائمًا حتى مع تواريخ قبل baseDate
    return _cycle[index];
  }

  /// يحسب شيفت أي تاريخ مستقبلي/ماضٍ - مفيد لعرض تقويم لاحقًا
  ShiftType shiftForDate(DateTime date) => calculateCurrentShift(forDate: date);
}
