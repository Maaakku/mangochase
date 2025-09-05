import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/task_utils.dart';
import '../utils/calendar_delegate.dart'as cal;
import '../widgets/calendar_widgets.dart';
import '../widgets/task_dialogs.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _currentMonth = DateTime(2021, 9, 1);
  DateTime? _selectedDate;

  final Map<String, List<Task>> _monthlyTasks = {
    '2021-9': [
      Task(
        id: '1',
        title: 'Tree No. 1',
        description: 'Pest Control',
        date: DateTime(2021, 9, 15),
        status: TaskStatus.pestControl,
      ),
      Task(
        id: '2',
        title: 'Tree No. 5',
        description: 'Watering',
        date: DateTime(2021, 9, 20),
        status: TaskStatus.watering,
      ),
      Task(
        id: '3',
        title: 'Apple Harvest',
        description: 'Ready for harvest',
        date: DateTime(2021, 9, 25),
        status: TaskStatus.harvest,
      ),
      Task(
        id: '4',
        title: 'Apple Harvest',
        description: 'Ready for harvest',
        date: DateTime(2021, 9, 25),
        status: TaskStatus.harvest,
      ),
      Task(
        id: '5',
        title: 'Apple Harvest',
        description: 'Ready for harvest',
        date: DateTime(2021, 9, 25),
        status: TaskStatus.harvest,
      ),
      Task(
        id: '6',
        title: 'Apple Harvest',
        description: 'Ready for harvest',
        date: DateTime(2021, 9, 25),
        status: TaskStatus.harvest,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Top Bar with Back + Title + Info
          SliverAppBar(
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Schedule",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.black),
                  onPressed: () => TaskDialogs.showTaskLegend(context),
                ),
              ],
            ),
          ),
          // Sticky Month Header
          SliverAppBar(
            pinned: true,
            expandedHeight: 50,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: MonthNavigationHeader(
                currentMonth: _currentMonth,
                onPreviousMonth: _previousMonth,
                onNextMonth: _nextMonth,
              ),
            ),
          ),
          // Collapsible Calendar
          SliverPersistentHeader(
            pinned: false,
            floating: false,
            delegate: cal.CalendarDelegate(
              minHeight: 0,
              maxHeight: 350,
              child: _buildCalendar(),
            ),
          ),
          // Upcoming Task List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tasks = TaskUtils.getCurrentMonthTasks(_currentMonth, _monthlyTasks);
                if (index >= tasks.length) return null;
                final task = tasks[index];
                return TaskTile(
                  task: task,
                  onTap: () => _editTask(task),
                );
              },
              childCount: TaskUtils.getCurrentMonthTasks(_currentMonth, _monthlyTasks).length,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCalendar() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CalendarHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: CalendarGrid(
              currentMonth: _currentMonth,
              selectedDate: _selectedDate,
              monthlyTasks: _monthlyTasks,
              onDateTapped: _onDateTapped,
            ),
          ),
        ],
      ),
    );
  }

  void _onDateTapped(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    TaskDialogs.showAddTaskDialog(
      context: context,
      date: date,
      onAddTask: _addTask,
    );
  }

  void _editTask(Task task) {
    TaskDialogs.showEditTaskDialog(
      context: context,
      task: task,
      onUpdateTask: _updateTask,
      onDeleteTask: _deleteTask,
    );
  }

  void _addTask(Task task) {
    final monthKey = '${task.date.year}-${task.date.month}';
    setState(() {
      _monthlyTasks[monthKey] = _monthlyTasks[monthKey] ?? [];
      _monthlyTasks[monthKey]!.add(task);
    });
  }

  void _updateTask(Task updatedTask) {
    final monthKey = '${updatedTask.date.year}-${updatedTask.date.month}';
    setState(() {
      final tasks = _monthlyTasks[monthKey] ?? [];
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    });
  }

  void _deleteTask(String taskId) {
    setState(() {
      _monthlyTasks.forEach((key, tasks) {
        tasks.removeWhere((task) => task.id == taskId);
      });
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.month == 1 ? _currentMonth.year - 1 : _currentMonth.year,
        _currentMonth.month == 1 ? 12 : _currentMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.month == 12 ? _currentMonth.year + 1 : _currentMonth.year,
        _currentMonth.month == 12 ? 1 : _currentMonth.month + 1,
        1,
      );
    });
  }
}