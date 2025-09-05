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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
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

        return GestureDetector(
          onTap: () => onDateTapped(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[100] : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue[800] : Colors.black,
                  ),
                ),
                if (tasksForDay.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Wrap(
                    children: tasksForDay.take(3).map((task) {
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
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
          .map((day) => SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ))
          .toList(),
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
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: TaskUtils.getTaskStatusColor(task.status),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(task.title),
        subtitle: Text('${task.description} • ${TaskUtils.getTaskStatusText(task.status)}'),
        trailing: Text(
          '${task.date.month}/${task.date.day}',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: onPreviousMonth,
        ),
        Text(
          TaskUtils.getMonthYearString(currentMonth),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.black),
          onPressed: onNextMonth,
        ),
      ],
    );
  }
}