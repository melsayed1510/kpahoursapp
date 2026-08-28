import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../models/shift_type.dart';
import '../services/shift_calculator_service.dart';

class ShiftScheduleScreen extends ConsumerStatefulWidget {
  const ShiftScheduleScreen({super.key});

  @override
  ConsumerState<ShiftScheduleScreen> createState() => _ShiftScheduleScreenState();
}

class _ShiftScheduleScreenState extends ConsumerState<ShiftScheduleScreen> {
  final ShiftCalculatorService _shiftCalculator = ShiftCalculatorService();
  DateTime _currentDate = DateTime.now();
  DateTime _lookupDate = DateTime.now();
  ShiftType? _filterShift;
  bool _isYearView = false;

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  void _previousYear() {
    setState(() {
      _currentDate = DateTime(_currentDate.year - 1, _currentDate.month, 1);
    });
  }

  void _nextYear() {
    setState(() {
      _currentDate = DateTime(_currentDate.year + 1, _currentDate.month, 1);
    });
  }

  Color _getShiftColor(ShiftType type) {
    switch (type) {
      case ShiftType.a:
        return const Color(0xFF1E40AF);
      case ShiftType.b:
        return const Color(0xFF047857);
      case ShiftType.c:
        return const Color(0xFFB45309);
    }
  }

  Color _getShiftBg(ShiftType type) {
    switch (type) {
      case ShiftType.a:
        return const Color(0xFFEFF6FF);
      case ShiftType.b:
        return const Color(0xFFECFDF5);
      case ShiftType.c:
        return const Color(0xFFFFFBEB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'جدول النوبات',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. شريط التحكم في العرض وفلترة النوبة (ممركزة في المنتصف)
              _buildViewAndFilterControls(),
              const SizedBox(height: 14),

              // 2. شريط التنقل الزمني (الشهر / السنة)
              _buildDateNavigator(),
              const SizedBox(height: 16),

              // 3. المحتوى الرئيسي (عرض شهري أو سنوي)
              if (_isYearView)
                _buildYearlyOverview()
              else ...[
                _buildMonthlyCalendar(),
                const SizedBox(height: 16),
                _buildDateLookupCard(),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewAndFilterControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isYearView = false),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isYearView ? AppColors.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '📅 عرض شهري تفاعلي',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: !_isYearView ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isYearView = true),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _isYearView ? AppColors.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '🗓️ ملخص سنوي',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _isYearView ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // فلترة حسب الوردية (ممركزة في المنتصف بشكل أنيق)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'الوردية:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 10),
              _buildFilterChip('الكل', null),
              const SizedBox(width: 8),
              _buildFilterChip('A', ShiftType.a),
              const SizedBox(width: 8),
              _buildFilterChip('B', ShiftType.b),
              const SizedBox(width: 8),
              _buildFilterChip('C', ShiftType.c),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ShiftType? type) {
    final isSelected = _filterShift == type;
    Color color = AppColors.primary;
    if (type == ShiftType.a) color = const Color(0xFF1E40AF);
    if (type == ShiftType.b) color = const Color(0xFF047857);
    if (type == ShiftType.c) color = const Color(0xFFB45309);

    return InkWell(
      onTap: () => setState(() => _filterShift = type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : const Color(0xFFCBD5E1), width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildDateNavigator() {
    final monthName = DateFormat.MMMM('ar').format(_currentDate);
    final yearStr = _currentDate.year.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
            onPressed: _isYearView ? _previousYear : _previousMonth,
            tooltip: 'السابق',
          ),
          Text(
            _isYearView ? 'سنة $yearStr' : '$monthName $yearStr',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
            onPressed: _isYearView ? _nextYear : _nextMonth,
            tooltip: 'التالي',
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyCalendar() {
    final year = _currentDate.year;
    final month = _currentDate.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final today = DateTime.now();

    final startWeekday = (firstDayOfMonth.weekday + 1) % 7;
    final weekDays = ['سبت', 'أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox.shrink();
              }

              final dayNum = index - startWeekday + 1;
              final cellDate = DateTime(year, month, dayNum);
              final shift = _shiftCalculator.shiftForDate(cellDate);
              final isToday = today.year == year && today.month == month && today.day == dayNum;
              final isDimmed = _filterShift != null && _filterShift != shift;

              return InkWell(
                onTap: () {
                  setState(() {
                    _lookupDate = cellDate;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Opacity(
                  opacity: isDimmed ? 0.25 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary.withOpacity(0.08) : _getShiftBg(shift),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday ? AppColors.primary : _getShiftColor(shift).withOpacity(0.4),
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                            color: isToday ? AppColors.primary : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: _getShiftColor(shift),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            shift.code,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // بطاقة الاستعلام عن نوبة أي تاريخ
  Widget _buildDateLookupCard() {
    final shift = _shiftCalculator.shiftForDate(_lookupDate);
    final formattedLookupDate = DateFormat('EEEE، d MMMM yyyy', 'ar').format(_lookupDate);
    final shiftColor = _getShiftColor(shift);
    final shiftBg = _getShiftBg(shift);

    return Container(
      padding: const EdgeInsets.all(16),
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
          // زر اختيار التاريخ (يبدأ بتاريخ اليوم افتراضياً)
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _lookupDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                locale: const Locale('ar'),
              );
              if (picked != null) {
                setState(() {
                  _lookupDate = picked;
                });
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        formattedLookupDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'تغيير التاريخ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // عرض نتيجة النوبة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: shiftBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: shiftColor.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوبة هذا اليوم هي:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedLookupDate,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: shiftColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'نوبة ',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        shift.code,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyOverview() {
    final year = _currentDate.year;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final month = index + 1;
        final monthDate = DateTime(year, month, 1);
        final monthName = DateFormat.MMMM('ar').format(monthDate);
        final daysInMonth = DateTime(year, month + 1, 0).day;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$monthName $year',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    '$daysInMonth يوم',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List.generate(daysInMonth, (dIndex) {
                  final day = dIndex + 1;
                  final shift = _shiftCalculator.shiftForDate(DateTime(year, month, day));
                  final isDimmed = _filterShift != null && _filterShift != shift;

                  return Opacity(
                    opacity: isDimmed ? 0.2 : 1.0,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _getShiftBg(shift),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _getShiftColor(shift).withOpacity(0.4)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          Text(
                            shift.code,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: _getShiftColor(shift),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
