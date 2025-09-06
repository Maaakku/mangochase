import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/task_utils.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final Map<String, List<Task>> monthlyTasks;
  final Function(DateTime) onDateTapped;

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.monthlyTasks,
    required this.onDateTapped,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInMonth = lastDayOfMonth.day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Prevent internal scrolling
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 42, // 6 weeks * 7 days
      
      itemBuilder: (context, index) {
        final dayNumber = index - firstWeekday + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(currentMonth.year, currentMonth.month, dayNumber);
        final tasksForDay = TaskUtils.getTasksForDate(date, monthlyTasks);
        final isSelected = selectedDate != null &&
            date.day == selectedDate!.day &&
            date.month == selectedDate!.month &&
            date.year == selectedDate!.year;

        // Check if it's today
        final now = DateTime.now();
        final isToday = date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;

        return GestureDetector(
          onTap: () => onDateTapped(date),
          child: Container(
            decoration: BoxDecoration(
              color: _getDateBackgroundColor(isSelected, isToday),
              borderRadius: BorderRadius.circular(8),
              border: _getDateBorder(isSelected, isToday),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    color: _getDateTextColor(isSelected, isToday),
                    fontSize: 14,
                  ),
                ),
                if (tasksForDay.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildTaskIndicators(tasksForDay),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getDateBackgroundColor(bool isSelected, bool isToday) {
    if (isSelected) return Colors.blue[100]!;
    if (isToday) return Colors.orange[50]!;
    return Colors.transparent;
  }

  Border? _getDateBorder(bool isSelected, bool isToday) {
    if (isSelected) return Border.all(color: Colors.blue, width: 2);
    if (isToday) return Border.all(color: Colors.orange, width: 1);
    return null;
  }

  Color _getDateTextColor(bool isSelected, bool isToday) {
    if (isSelected) return Colors.blue[800]!;
    if (isToday) return Colors.orange[800]!;
    return Colors.black;
  }

  Widget _buildTaskIndicators(List<Task> tasks) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: tasks.take(3).map((task) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: TaskUtils.getTaskStatusColor(task.status),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }
}

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: TaskUtils.getTaskStatusColor(task.status),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${task.description} • ${TaskUtils.getTaskStatusText(task.status)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${task.date.month}/${task.date.day}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class MonthNavigationHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MonthNavigationHeader({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
            onPressed: onPreviousMonth,
            splashRadius: 20,
          ),
          Expanded(
            child: Center(
              child: Text(
                TaskUtils.getMonthYearString(currentMonth),
                style: const TextStyle(
                  color: Colors.black, 
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.black, size: 28),
            onPressed: onNextMonth,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}