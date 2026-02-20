import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/event_model.dart';
import 'day_cell.dart';

enum CalendarState { weekly, monthlyCompact, monthlyFull }

class CalendarController extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Map<DateTime, List<EventModel>> eventsByDay;
  final Widget Function(bool showList) eventListBuilder;

  const CalendarController({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.eventsByDay,
    required this.eventListBuilder,
  });

  @override
  State<CalendarController> createState() => _CalendarControllerState();
}

class _CalendarControllerState extends State<CalendarController>
    with SingleTickerProviderStateMixin {
  CalendarState _state = CalendarState.weekly;
  late AnimationController _animController;
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.selectedDate;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didUpdateWidget(CalendarController old) {
    super.didUpdateWidget(old);
    // If external selection changed, jump focus to it
    if (widget.selectedDate != old.selectedDate) {
      _focusedDate = widget.selectedDate;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double _dragOffset = 0.0;

  void _onVerticalDragStart(DragStartDetails details) {
    _dragOffset = 0.0;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _dragOffset += details.delta.dy;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    // Determine direction from either a fast fling OR a significant total drag distance
    final isSwipedDown = velocity > 300 || _dragOffset > 40;
    final isSwipedUp = velocity < -300 || _dragOffset < -40;

    if (isSwipedDown) {
      _expandCalendar();
    } else if (isSwipedUp) {
      _collapseCalendar();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 300) {
      if (_state == CalendarState.weekly) {
        _changeWeek(-1);
      } else {
        _changeMonth(-1);
      }
    } else if (velocity < -300) {
      if (_state == CalendarState.weekly) {
        _changeWeek(1);
      } else {
        _changeMonth(1);
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + delta, 1);
    });
  }

  void _changeWeek(int delta) {
    setState(() {
      _focusedDate = _focusedDate.add(Duration(days: delta * 7));
    });
  }

  void _expandCalendar() {
    setState(() {
      if (_state == CalendarState.weekly) {
        _state = CalendarState.monthlyCompact;
      } else if (_state == CalendarState.monthlyCompact) {
        _state = CalendarState.monthlyFull;
      }
    });
  }

  void _collapseCalendar() {
    setState(() {
      if (_state == CalendarState.monthlyFull) {
        _state = CalendarState.monthlyCompact;
      } else if (_state == CalendarState.monthlyCompact) {
        _state = CalendarState.weekly;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate explicit heights to prevent RenderFlex bounded height issues
    final double gridHeight;
    if (_state == CalendarState.weekly) {
      gridHeight = 70.0;
    } else if (_state == CalendarState.monthlyCompact) {
      gridHeight = 320.0; // Increased height for compact cells
    } else {
      // monthlyFull fills most of the screen
      final double headerAndNavHeight =
          300.0; // Approximate height of Agenda header + nav + calendar UI
      gridHeight = (screenHeight - headerAndNavHeight).clamp(320.0, 800.0);
    }

    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Column(
        children: [
          _buildStateIndicator(),
          _buildMonthSelector(),
          _buildDayLabels(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            height: gridHeight,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(), // Required for clipBehavior
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildCalendarGrid(),
            ),
          ),
          _buildDragHandle(),
          if (_state != CalendarState.monthlyFull)
            widget.eventListBuilder(true), // Only show list if not full
        ],
      ),
    );
  }

  Widget _buildStateIndicator() {
    return const SizedBox.shrink();
  }

  Widget _buildMonthSelector() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: Icon(
              Icons.chevron_left_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            DateFormat('MMMM', 'es').format(_focusedDate).toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabels() {
    final theme = Theme.of(context);
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: labels.map((l) {
          return Expanded(
            child: Center(
              child: Text(
                l,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    switch (_state) {
      case CalendarState.weekly:
        return _buildWeekView();
      case CalendarState.monthlyCompact:
      case CalendarState.monthlyFull:
        return _buildMonthView();
    }
  }

  Widget _buildWeekView() {
    // Get the current week of the focused date
    final weekStart = _focusedDate.subtract(
      Duration(days: _focusedDate.weekday - 1),
    );
    final selected = widget.selectedDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(7, (i) {
          final day = weekStart.add(Duration(days: i));
          final dayKey = DateTime(day.year, day.month, day.day);
          final events = widget.eventsByDay[dayKey] ?? [];
          final isSelected =
              day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          final isToday = _isToday(day);
          return Expanded(
            child: DayCell(
              day: day.day,
              isSelected: isSelected,
              isToday: isToday,
              isCurrentMonth: day.month == _focusedDate.month,
              events: events,
              viewState: _state,
              onTap: () {
                setState(() => _focusedDate = day);
                widget.onDateSelected(day);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthView() {
    final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDay = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final startOffset = firstDay.weekday - 1; // Monday = 0

    final totalDays = lastDay.day;
    final totalCells = startOffset + totalDays;
    final rows = (totalCells / 7).ceil();

    Widget grid = Column(
      key: ValueKey('month_${_state.name}'),
      children: List.generate(rows, (row) {
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(7, (col) {
              final index = row * 7 + col;
              if (index < startOffset || index >= startOffset + totalDays) {
                return const Expanded(child: SizedBox());
              }
              final dayNum = index - startOffset + 1;
              final day = DateTime(
                _focusedDate.year,
                _focusedDate.month,
                dayNum,
              );
              final dayKey = DateTime(day.year, day.month, day.day);
              final events = widget.eventsByDay[dayKey] ?? [];
              final isSelected =
                  day.year == widget.selectedDate.year &&
                  day.month == widget.selectedDate.month &&
                  day.day == widget.selectedDate.day;
              final isToday = _isToday(day);

              return Expanded(
                child: DayCell(
                  day: dayNum,
                  isSelected: isSelected,
                  isToday: isToday,
                  isCurrentMonth: true,
                  events: events,
                  viewState: _state,
                  onTap: () {
                    setState(() => _focusedDate = day);
                    widget.onDateSelected(day);
                  },
                ),
              );
            }),
          ),
        );
      }),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: grid,
    );
  }

  Widget _buildDragHandle() {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        // Toggle behavior if explicitly tapped (desktop fallback)
        if (_state == CalendarState.weekly) {
          _expandCalendar();
        } else if (_state == CalendarState.monthlyCompact) {
          _expandCalendar();
        } else {
          _collapseCalendar();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }
}
