import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/shift_calculator_service.dart';
import '../services/attendance_calculator_service.dart';
import '../services/preferences_service.dart';
import '../models/shift_type.dart';
import '../models/attendance_result.dart';

final preferencesServiceProvider = Provider((ref) => PreferencesService());
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
