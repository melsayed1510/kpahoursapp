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
          'جدول النوبات (شهري وسنوي)',
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
              _buildViewAndFilterControls(),
              const SizedBox(height: 14),
              _buildDateNavigator(),
              const SizedBox(height: 16),
              if (_isYearView)
                _buildYearlyOverview()
              else ...[
                _buildMonthlyCalendar(),
                const SizedBox(height: 16),
                _buildMonthlyStats(),
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
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'الوردية:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              _buildFilterChip('الكل', null),
              const SizedBox(width: 6),
              _buildFilterChip('A', ShiftType.a),
              const SizedBox(width: 6),
              _buildFilterChip('B', ShiftType.b),
              const SizedBox(width: 6),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
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
          Column(
            children: [
              Text(
                _isYearView ? 'سنة $yearStr' : '$monthName $yearStr',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (!_isYearView)
                Text(
                  'دورة النوبات الثلاثية (A / B / C)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
            ],
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

              return Opacity(
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    final year = _currentDate.year;
    final month = _currentDate.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    int countA = 0;
    int countB = 0;
    int countC = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final shift = _shiftCalculator.shiftForDate(DateTime(year, month, day));
      if (shift == ShiftType.a) countA++;
      if (shift == ShiftType.b) countB++;
      if (shift == ShiftType.c) countC++;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات نوبات هذا الشهر:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard('نوبة A', countA, const Color(0xFF1E40AF), const Color(0xFFEFF6FF)),
              const SizedBox(width: 8),
              _buildStatCard('نوبة B', countB, const Color(0xFF047857), const Color(0xFFECFDF5)),
              const SizedBox(width: 8),
              _buildStatCard('نوبة C', countC, const Color(0xFFB45309), const Color(0xFFFFFBEB)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              '$count يوم',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
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
