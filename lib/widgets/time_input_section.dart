import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/shift_providers.dart';

class TimeInputSection extends ConsumerWidget {
  const TimeInputSection({super.key});

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'حدد وقت الحضور';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inTime = ref.watch(inTimeProvider);
    final duration = ref.watch(shiftDurationProvider);
    final prefs = ref.read(preferencesServiceProvider);

    final currentHours = duration.inHours;
    final currentMinutes = duration.inMinutes % 60;

    // قائمة الساعات (من 1 إلى 12)
    final hoursList = List.generate(12, (index) => index + 1);

    // قائمة الدقائق (00, 05, 10 ... 55)
    final minutesList = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'حاسبة البصمة وساعات العمل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. وقت بصمة الدخول
          const Text(
            'وقت بصمة الدخول',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final initial = inTime ?? TimeOfDay.now();
              final picked = await showTimePicker(
                context: context,
                initialTime: initial,
                builder: (context, child) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: child ?? const SizedBox(),
                  );
                },
              );
              if (picked != null) {
                ref.read(inTimeProvider.notifier).state = picked;
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: inTime != null ? AppColors.primary.withOpacity(0.06) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: inTime != null ? AppColors.primary : const Color(0xFFCBD5E1),
                  width: inTime != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        color: inTime != null ? AppColors.primary : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _formatTimeOfDay(inTime),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: inTime != null ? FontWeight.bold : FontWeight.w500,
                          color: inTime != null ? AppColors.primary : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'تعديل',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. مدة الدوام كحقول منفصلة للساعات والدقائق
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'مدة الدوام الرسمية',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
              // عرض المدة الإجمالية المجمعة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'المجموع: ${currentHours.toString().padLeft(2, '0')}:${currentMinutes.toString().padLeft(2, '0')} س',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // حقول الساعات والدقائق المنفصلة مع العناوين البسيطة
          Row(
            children: [
              // حقل الساعات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الساعات',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: hoursList.contains(currentHours) ? currentHours : 6,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                          items: hoursList.map((h) {
                            return DropdownMenuItem<int>(
                              value: h,
                              child: Text(
                                h.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newHour) {
                            if (newHour != null) {
                              final newDuration = Duration(hours: newHour, minutes: currentMinutes);
                              ref.read(shiftDurationProvider.notifier).state = newDuration;
                              prefs.saveShiftDuration(newDuration);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // حقل الدقائق
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الدقائق',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: minutesList.contains(currentMinutes) ? currentMinutes : 30,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                          items: minutesList.map((m) {
                            return DropdownMenuItem<int>(
                              value: m,
                              child: Text(
                                m.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newMin) {
                            if (newMin != null) {
                              final newDuration = Duration(hours: currentHours, minutes: newMin);
                              ref.read(shiftDurationProvider.notifier).state = newDuration;
                              prefs.saveShiftDuration(newDuration);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
