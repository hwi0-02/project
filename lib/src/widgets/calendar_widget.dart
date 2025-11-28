import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/date_utils.dart';

/// 캘린더 위젯
/// 
/// 한 달 간의 미션 완료 현황을 표시하는 캘린더
class CalendarWidget extends StatefulWidget {
  final List<DateTime> completedDates;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  const CalendarWidget({
    super.key,
    required this.completedDates,
    this.selectedDate,
    this.onDateSelected,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  bool _isCompleted(DateTime date) {
    return widget.completedDates.any((d) => AppDateUtils.isSameDay(d, date));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildWeekdayHeader(),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousMonth,
          color: AppColors.textPrimary,
        ),
        Text(
          '${_currentMonth.year}년 ${AppDateUtils.getMonthName(_currentMonth.month)}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextMonth,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        final isWeekend = day == '일' || day == '토';
        return SizedBox(
          width: 36,
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: isWeekend ? AppColors.textSecondary : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = AppDateUtils.getMonthStart(_currentMonth);
    final daysInMonth = AppDateUtils.getDaysInMonth(_currentMonth);
    
    // 일요일 = 0, 월요일 = 1, ... 토요일 = 6 (우리 캘린더는 일요일 시작)
    final startWeekday = firstDayOfMonth.weekday % 7;
    
    final totalCells = (startWeekday + daysInMonth + 6) ~/ 7 * 7;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNumber = index - startWeekday + 1;
        
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }
        
        final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
        final isToday = AppDateUtils.isToday(date);
        final isCompleted = _isCompleted(date);
        final isFuture = date.isAfter(DateTime.now());
        
        return _buildDayCell(
          dayNumber: dayNumber,
          isToday: isToday,
          isCompleted: isCompleted,
          isFuture: isFuture,
          date: date,
        );
      },
    );
  }

  Widget _buildDayCell({
    required int dayNumber,
    required bool isToday,
    required bool isCompleted,
    required bool isFuture,
    required DateTime date,
  }) {
    Color backgroundColor;
    Color textColor;
    
    if (isCompleted) {
      backgroundColor = AppColors.success;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.2);
      textColor = AppColors.primary;
    } else {
      backgroundColor = Colors.transparent;
      textColor = isFuture ? AppColors.textSecondary : AppColors.textPrimary;
    }
    
    return GestureDetector(
      onTap: isFuture ? null : () => widget.onDateSelected?.call(date),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: isToday && !isCompleted
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '$dayNumber',
            style: TextStyle(
              color: textColor,
              fontWeight: isToday || isCompleted ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
