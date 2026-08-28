# KPA Shift & Attendance Tracker — Master Implementation Plan
> نواة مشروع كاملة للتنفيذ عبر وكيل AI (Gemini / Antigravity). كل مرحلة مستقلة وقابلة للتنفيذ والاختبار بمفردها قبل الانتقال للتالية.

---

## 0. نظرة عامة (Context for the Agent)

تطبيق أندرويد بـ **Flutter** لموظفي KPA، يعرض:
1. الشيفت الحالي (A/B/C) بناءً على تقويم دوراني ثابت.
2. حاسبة مواعيد البصمة (تواجد + خروج) بناءً على وقت الدخول ومدة الدوام.

**قواعد صارمة يجب الالتزام بها في كل مراحل التنفيذ:**
- لا `setState` كإدارة حالة أساسية — استخدم `Riverpod` (أو `Provider` إن كان أبسط) من البداية.
- كل منطق حسابي يوضع في `services/` منفصل تمامًا عن الواجهة، وقابل للاختبار بـ Unit Tests بدون تشغيل واجهة.
- كل دالة حساب وقت يجب أن تتعامل مع تجاوز منتصف الليل (Midnight Rollover) وتُرجع علم `isNextDay`.
- استخدم `intl` أو حزمة تاريخ/وقت للتعامل مع المنطقة الزمنية المحلية (الكويت UTC+3) بدل الاعتماد الأعمى على UTC.
- كتابة Unit Tests لكل Service قبل اعتبار المرحلة مكتملة.

**الحزم المطلوبة (pubspec.yaml):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1
  flutter_riverpod: ^2.5.1
  shared_preferences: ^2.2.3
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

---

## المرحلة 1 — الإعداد والبنية الأساسية

### الهدف
تجهيز هيكل المشروع والثيم والألوان دون أي منطق عمل بعد.

### هيكل المجلدات المطلوب
```
lib/
 ├─ main.dart
 ├─ core/
 │   ├─ theme/app_colors.dart
 │   └─ theme/app_theme.dart
 ├─ models/
 │   ├─ shift_type.dart
 │   └─ attendance_result.dart
 ├─ services/
 │   ├─ shift_calculator_service.dart
 │   └─ attendance_calculator_service.dart
 ├─ providers/
 │   └─ shift_providers.dart
 ├─ screens/
 │   └─ home_screen.dart
 └─ widgets/
     ├─ shift_header_card.dart
     ├─ time_input_section.dart
     └─ result_card.dart

test/
 ├─ shift_calculator_service_test.dart
 └─ attendance_calculator_service_test.dart
```

### الألوان (core/theme/app_colors.dart)
```dart
import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF4F6F9);
  static const primary = Color(0xFF1F5FA8);

  // Shift A - Pink
  static const shiftALight = Color(0xFFFDE1E1);
  static const shiftADark = Color(0xFFF6BCBC);

  // Shift B - Green
  static const shiftBLight = Color(0xFFE2F5E2);
  static const shiftBDark = Color(0xFFCFEECD);

  // Shift C - Yellow
  static const shiftCLight = Color(0xFFFFF3CD);
  static const shiftCDark = Color(0xFFFFE49A);
}
```

### الخط والثيم (core/theme/app_theme.dart)
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
      );
}
```

### معيار القبول لهذه المرحلة
- التطبيق يبني وينفذ (`flutter run`) ويعرض شاشة فارغة بالخلفية والخط الصحيحين، بدون أخطاء compile.

---

## المرحلة 2 — طبقة النماذج (Models)

### models/shift_type.dart
```dart
enum ShiftType { a, b, c }

extension ShiftTypeX on ShiftType {
  String get label => switch (this) {
        ShiftType.a => 'A',
        ShiftType.b => 'B',
        ShiftType.c => 'C',
      };
}
```

### models/attendance_result.dart
```dart
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
```

### معيار القبول
- الملفات تُبنى بدون أخطاء، لا منطق بعد — فقط بنية بيانات.

---

## المرحلة 3 — طبقة الخدمات (Services) — **الجزء الأهم**

### أ. حساب الشيفت الحالي — مع معالجة التوقيت المحلي بشكل صحيح

**ملاحظة مهمة للوكيل:** الكود الأصلي كان يعتمد على `now.millisecondsSinceEpoch` مباشرة، ما يجعل التبديل بين الشيفتات يحدث عند منتصف الليل بتوقيت UTC وليس التوقيت المحلي (الكويت UTC+3). النسخة الصحيحة أدناه تحسب رقم اليوم بناءً على **التاريخ المحلي** (سنة/شهر/يوم) وليس الطابع الزمني الكامل.

```dart
// services/shift_calculator_service.dart
import '../models/shift_type.dart';

class ShiftCalculatorService {
  /// تاريخ مرجعي: 1 يناير 2026 (يعتبر بداية الدورة، شيفت A)
  static final DateTime _baseDate = DateTime(2026, 1, 1);

  static const List<ShiftType> _cycle = [ShiftType.a, ShiftType.b, ShiftType.c];

  /// يحسب الشيفت الحالي بناءً على التاريخ المحلي لجهاز المستخدم
  ShiftType calculateCurrentShift({DateTime? forDate}) {
    final date = forDate ?? DateTime.now();
    final localDateOnly = DateTime(date.year, date.month, date.day);

    final diffInDays = localDateOnly.difference(_baseDate).inDays;

    final index = ((diffInDays % 3) + 3) % 3; // نتيجة موجبة دائمًا حتى مع تواريخ قبل baseDate
    return _cycle[index];
  }

  /// يحسب شيفت أي تاريخ مستقبلي/ماضٍ - مفيد لعرض تقويم لاحقًا
  ShiftType shiftForDate(DateTime date) => calculateCurrentShift(forDate: date);
}
```

### ب. حاسبة البصمة — مع دعم Midnight Rollover

```dart
// services/attendance_calculator_service.dart
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
```

### اختبارات الوحدة المطلوبة (يجب على الوكيل كتابتها وتشغيلها فعليًا)

```dart
// test/shift_calculator_service_test.dart
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
```

```dart
// test/attendance_calculator_service_test.dart
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
```

### معيار القبول لهذه المرحلة
- `flutter test` ينجح لكل الحالات أعلاه بدون فشل.
- لا يوجد أي استيراد لـ Widgets داخل ملفات `services/`.

---

## المرحلة 4 — إدارة الحالة (Riverpod Providers)

```dart
// providers/shift_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/shift_calculator_service.dart';
import '../services/attendance_calculator_service.dart';
import '../models/shift_type.dart';
import '../models/attendance_result.dart';

final shiftCalculatorProvider = Provider((ref) => ShiftCalculatorService());
final attendanceCalculatorProvider = Provider((ref) => AttendanceCalculatorService());

final currentShiftProvider = Provider<ShiftType>((ref) {
  return ref.watch(shiftCalculatorProvider).calculateCurrentShift();
});

final inTimeProvider = StateProvider<TimeOfDay?>((ref) => null);
final shiftDurationProvider = StateProvider<Duration>((ref) => const Duration(hours: 6, minutes: 30));

final attendanceResultProvider = Provider<AttendanceResult?>((ref) {
  final inTime = ref.watch(inTimeProvider);
  final duration = ref.watch(shiftDurationProvider);
  if (inTime == null) return null;

  final calculator = ref.watch(attendanceCalculatorProvider);
  if (!calculator.isValidShiftDuration(duration)) return null;

  return calculator.calculate(inTime: inTime, shiftDuration: duration);
});
```

### معيار القبول
- تغيير `inTimeProvider` أو `shiftDurationProvider` يحدّث `attendanceResultProvider` تلقائيًا دون أي كود يدوي إضافي.

---

## المرحلة 5 — الحفظ المحلي (Persistence)

**الهدف:** حفظ آخر `shiftDuration` مختارة، لاستعادتها تلقائيًا عند فتح التطبيق مرة أخرى (المستخدم عادة لا يغيّرها كل يوم).

```dart
// services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyShiftMinutes = 'last_shift_duration_minutes';

  Future<void> saveShiftDuration(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyShiftMinutes, duration.inMinutes);
  }

  Future<Duration> loadShiftDuration({Duration fallback = const Duration(hours: 6, minutes: 30)}) async {
    final prefs = await SharedPreferences.getInstance();
    final mins = prefs.getInt(_keyShiftMinutes);
    return mins != null ? Duration(minutes: mins) : fallback;
  }
}
```
- اربط هذه الخدمة بـ `shiftDurationProvider` عند بدء التطبيق (تحميل القيمة المحفوظة) وعند كل تعديل (حفظ القيمة الجديدة).

### معيار القبول
- إغلاق التطبيق وإعادة فتحه يُظهر آخر مدة دوام تم اختيارها، وليس القيمة الافتراضية دائمًا.

---

## المرحلة 6 — واجهة المستخدم (UI)

### 6.1 شاشة رئيسية (screens/home_screen.dart)
- `Scaffold` بسيط مع `AppBar` (عنوان: "شيفت اليوم").
- `ShiftHeaderCard` أعلى الشاشة.
- `TimeInputSection` في المنتصف.
- `ResultCard` (أو 3 بطاقات) أسفل الشاشة، تظهر فقط بعد اختيار وقت الدخول (`attendanceResultProvider != null`).

### 6.2 بطاقة الشيفت (widgets/shift_header_card.dart)
- تعرض التاريخ الحالي (`intl` لتنسيق التاريخ بالعربي).
- لون الخلفية يتغير حسب `currentShiftProvider` (استخدم `AnimatedContainer` للانتقال السلس بين الألوان).
- حرف الشيفت (A/B/C) بخط كبير وواضح.

### 6.3 قسم الإدخال (widgets/time_input_section.dart)
- زر لفتح `showTimePicker` وتحديث `inTimeProvider`.
- Dropdown لمدة الدوام بخيارات شائعة: `06:00`, `06:30`, `07:00`, `08:00`, بالإضافة لخيار "تخصيص" يفتح Picker مدة مخصصة.
- عند اختيار مدة جديدة: استدعِ `PreferencesService.saveShiftDuration`.

### 6.4 بطاقات النتائج (widgets/result_card.dart)
- كل بطاقة: عنوان (بداية التواجد / نهاية التواجد / بصمة الخروج) + الوقت.
- **إلزامي:** إذا كان `xNextDay == true`، أضف تسمية صغيرة "(اليوم التالي)" بجانب الوقت بلون تنبيهي (مثلاً برتقالي فاتح).
- حواف دائرية (`BorderRadius.circular(16)`) وظل خفيف (`BoxShadow` بشفافية منخفضة).

### معيار القبول
- تدفق كامل: فتح التطبيق → رؤية الشيفت والتاريخ فورًا → اختيار وقت دخول → ظهور 3 بطاقات نتائج فورًا → تغيير مدة الدوام يحدّث النتائج مباشرة بدون إعادة فتح التطبيق.

---

## المرحلة 7 — تحسينات اختيارية (Backlog لما بعد v1)

لا تُنفَّذ إلا بعد اكتمال واعتماد المراحل 1-6:
- إشعار محلي (`flutter_local_notifications`) يذكّر الموظف قبل 10 دقائق من بصمة الخروج.
- دعم الوضع الليلي (Dark Theme) بنفس ألوان الشيفتات لكن بدرجات أغمق.
- شاشة تقويم شهري تعرض شيفت كل يوم (باستخدام `shiftForDate` الموجودة أصلًا في الخدمة).
- Android Home Screen Widget يعرض شيفت اليوم مباشرة بدون فتح التطبيق.

---

## ملاحظات ختامية للوكيل المنفّذ

1. نفّذ المراحل بالترتيب، ولا تنتقل لمرحلة قبل اجتياز "معيار القبول" الخاص بالمرحلة السابقة.
2. عند أي تعارض بين هذا الملف وأي افتراض ضمني، اتبع هذا الملف كمصدر الحقيقة الوحيد.
3. شغّل `flutter analyze` بعد كل مرحلة وتأكد من عدم وجود تحذيرات قبل الاستمرار.
4. اسم الحزمة المقترح في `pubspec.yaml`: `kpa_shift_app` (مطابق للاستيرادات في اختبارات المرحلة 3).
