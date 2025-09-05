import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskUtils {
  static Color getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.watering:
        return Colors.blue;
      case TaskStatus.pestControl:
        return Colors.red;
      case TaskStatus.fertilizing:
        return Colors.green;
      case TaskStatus.pruning:
        return Colors.orange;
      case TaskStatus.harvest:
        return Colors.amber;
      case TaskStatus.planting:
        return Colors.brown;
    }
  }

  static String getTaskStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.watering:
        return 'Watering';
      case TaskStatus.pestControl:
        return 'Pest Control';
      case TaskStatus.fertilizing:
        return 'Fertilizing';
      case TaskStatus.pruning:
        return 'Pruning';
      case TaskStatus.harvest:
        return 'Harvest Time';
      case TaskStatus.planting:
        return 'Planting';
    }
  }

  static String getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static List<Task> getTasksForDate(DateTime date, Map<String, List<Task>> monthlyTasks) {
    final monthKey = '${date.year}-${date.month}';
    final monthTasks = monthlyTasks[monthKey] ?? [];
    return monthTasks.where((task) =>
        task.date.day == date.day &&
        task.date.month == date.month &&
        task.date.year == date.year
    ).toList();
  }

  static List<Task> getCurrentMonthTasks(DateTime currentMonth, Map<String, List<Task>> monthlyTasks) {
    final monthKey = '${currentMonth.year}-${currentMonth.month}';
    return monthlyTasks[monthKey] ?? [];
  }
}