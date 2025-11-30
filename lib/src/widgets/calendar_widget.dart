import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/date_utils.dart';

/// 캘린더 위젯 - 미니멀 프리미엄 디자인
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
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: AppTheme.spacing16),
          _buildWeekdayHeader(),
          const SizedBox(height: AppTheme.spacing8),
          _buildCalendarGrid(),
          const SizedBox(height: AppTheme.spacing16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final canGoForward = _currentMonth.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month),
    );
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          onPressed: _previousMonth,
        ),
        Text(
          '${_currentMonth.year}년 ${AppDateUtils.getMonthName(_currentMonth.month)}',
          style: AppTheme.textStyles.title.copyWith(
            color: AppTheme.neutral800,
            fontWeight: FontWeight.w700,
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          onPressed: canGoForward ? null : _nextMonth,
          enabled: !canGoForward,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.asMap().entries.map((entry) {
        final isWeekend = entry.key == 0 || entry.key == 6;
        return SizedBox(
          width: 36,
          child: Center(
            child: Text(
              entry.value,
              style: AppTheme.textStyles.caption.copyWith(
                color: isWeekend ? AppTheme.neutral400 : AppTheme.neutral500,
                fontWeight: FontWeight.w600,
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
        return _DayCell(
          dayNumber: dayNumber,
          isToday: AppDateUtils.isToday(date),
          isCompleted: _isCompleted(date),
          isFuture: date.isAfter(DateTime.now()),
          isSelected: widget.selectedDate != null && 
                      AppDateUtils.isSameDay(date, widget.selectedDate!),
          onTap: date.isAfter(DateTime.now()) 
              ? null 
              : () => widget.onDateSelected?.call(date),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: AppTheme.success,
          label: '완료',
        ),
        const SizedBox(width: AppTheme.spacing16),
        _LegendItem(
          color: AppTheme.primary,
          label: '오늘',
          isOutlined: true,
        ),
      ],
    );
  }
}

/// 네비게이션 버튼
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;
  
  const _NavButton({
    required this.icon,
    this.onPressed,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: enabled ? AppTheme.neutral100 : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Icon(
            icon,
            color: enabled ? AppTheme.neutral700 : AppTheme.neutral300,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// 날짜 셀
class _DayCell extends StatelessWidget {
  final int dayNumber;
  final bool isToday;
  final bool isCompleted;
  final bool isFuture;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const _DayCell({
    required this.dayNumber,
    required this.isToday,
    required this.isCompleted,
    required this.isFuture,
    required this.isSelected,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Border? border;
    
    if (isCompleted) {
      backgroundColor = AppTheme.success;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = AppTheme.primary.withValues(alpha: 0.1);
      textColor = AppTheme.primary;
      border = Border.all(color: AppTheme.primary, width: 2);
    } else if (isSelected) {
      backgroundColor = AppTheme.primary.withValues(alpha: 0.15);
      textColor = AppTheme.primary;
    } else {
      backgroundColor = Colors.transparent;
      textColor = isFuture ? AppTheme.neutral300 : AppTheme.neutral700;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Center(
          child: Text(
            '$dayNumber',
            style: AppTheme.textStyles.body.copyWith(
              color: textColor,
              fontWeight: isToday || isCompleted ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// 범례 아이템
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isOutlined;
  
  const _LegendItem({
    required this.color,
    required this.label,
    this.isOutlined = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: isOutlined ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: AppTheme.spacing6),
        Text(
          label,
          style: AppTheme.textStyles.caption.copyWith(
            color: AppTheme.neutral500,
          ),
        ),
      ],
    );
  }
}
