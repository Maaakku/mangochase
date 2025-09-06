import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../utils/task_utils.dart';
import '../utils/calendar_delegate.dart' as cal;
import '../widgets/calendar_widgets.dart';
import '../widgets/task_dialogs.dart';
import 'main_screen.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  
  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream for real-time task updates
  late Stream<List<Task>> _tasksStream;
  
  // Cache for tasks to improve performance
  Map<String, List<Task>> _monthlyTasks = {};
  
  @override
  void initState() {
    super.initState();
    _setupTasksStream();
  }

  void _setupTasksStream() {
    _tasksStream = _firestore
        .collection('users')
        .doc('user_id')  // ← Replace with actual user ID
        .collection('tasks')
        .orderBy('scheduled_date')
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        return Task(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: (data['scheduled_date'] as Timestamp).toDate(),
          status: _parseTaskStatus(data['status']),
          isCompleted: data['is_completed'] ?? false, // Add completion status
        );
      }).toList();
      
      // Update monthly tasks cache
      _updateMonthlyTasksCache(tasks);
      
      return tasks;
    });
  }

  void _updateMonthlyTasksCache(List<Task> tasks) {
    _monthlyTasks.clear();
    for (final task in tasks) {
      final monthKey = '${task.date.year}-${task.date.month}';
      _monthlyTasks[monthKey] = _monthlyTasks[monthKey] ?? [];
      _monthlyTasks[monthKey]!.add(task);
    }
  }

  TaskStatus _parseTaskStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'watering':
        return TaskStatus.watering;
      case 'pest_control':
        return TaskStatus.pestControl;
      case 'harvest':
        return TaskStatus.harvest;
      case 'fertilizing':
        return TaskStatus.fertilizing;
      case 'pruning':
        return TaskStatus.pruning;
      default:
        return TaskStatus.watering; // Default status
    }
  }

  String _taskStatusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.watering:
        return 'watering';
      case TaskStatus.pestControl:
        return 'pest_control';
      case TaskStatus.harvest:
        return 'harvest';
      case TaskStatus.fertilizing:
        return 'fertilizing';
      case TaskStatus.pruning:
        return 'pruning';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Task>>(
        stream: _tasksStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading tasks: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Top Bar with Back + Title + Info
              SliverAppBar(
                pinned: true,
                floating: false,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.orange,
                elevation: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        final mainScreenState = MainScreen.globalKey.currentState;
                        if (mainScreenState != null) {
                          mainScreenState.navigateToHome(addToHistory: false);
                        }
                      },
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
                floating: false,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                elevation: 0,
                toolbarHeight: 50,
                title: MonthNavigationHeader(
                  currentMonth: _currentMonth,
                  onPreviousMonth: _previousMonth,
                  onNextMonth: _nextMonth,
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
              // Divider line after calendar
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 1,
                  color: Colors.grey[300],
                ),
              ),
              // Spacing and "Upcoming Tasks" header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upcoming Tasks",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),
              // Upcoming Task List
              snapshot.hasData
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tasks = TaskUtils.getCurrentMonthTasks(_currentMonth, _monthlyTasks);
                          if (index >= tasks.length) return null;
                          final task = tasks[index];
                          return TaskTileWithDoneButton(
                            task: task,
                            onMarkDone: () => _markTaskDone(task),
                          );
                        },
                        childCount: TaskUtils.getCurrentMonthTasks(_currentMonth, _monthlyTasks).length,
                      ),
                    )
                  : const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      color: const Color.fromRGBO(245, 245, 245, 1),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const CalendarHeader(),
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

  // Firebase methods
  Future<void> _addTask(Task task) async {
    try {
      await _firestore.collection('tasks').add({
        'title': task.title,
        'description': task.description,
        'scheduled_date': Timestamp.fromDate(task.date),
        'status': _taskStatusToString(task.status),
        'is_completed': false, // Default to not completed
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $e')),
        );
      }
    }
  }

  Future<void> _markTaskDone(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update({
        'is_completed': true,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" marked as done!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking task as done: $e')),
        );
      }
    }
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

// New custom widget for task tile with done button
class TaskTileWithDoneButton extends StatelessWidget {
  final Task task;
  final VoidCallback onMarkDone;

  const TaskTileWithDoneButton({
    super.key,
    required this.task,
    required this.onMarkDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: task.isCompleted ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.isCompleted ? Colors.grey[300]! : Colors.grey[200]!,
        ),
        boxShadow: task.isCompleted ? null : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Task status icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTaskStatusColor(task.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTaskStatusIcon(task.status),
              color: _getTaskStatusColor(task.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted ? Colors.grey[600] : Colors.black87,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: task.isCompleted ? Colors.grey[500] : Colors.grey[600],
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatDate(task.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: task.isCompleted ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Done button or completed status
          if (task.isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          ElevatedButton(
            onPressed: _isTaskDateToday(task.date) ? onMarkDone : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isTaskDateToday(task.date) ? Colors.orange : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _isTaskDateToday(task.date) ? 'Done' : 'Not Due',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  bool _isTaskDateToday(DateTime taskDate) {
  final now = DateTime.now();
  return taskDate.year == now.year && 
         taskDate.month == now.month && 
         taskDate.day == now.day;
}

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.watering:
        return Colors.blue;
      case TaskStatus.pestControl:
        return Colors.red;
      case TaskStatus.harvest:
        return Colors.green;
      case TaskStatus.fertilizing:
        return Colors.brown;
      case TaskStatus.pruning:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.watering:
        return Icons.water_drop;
      case TaskStatus.pestControl:
        return Icons.bug_report;
      case TaskStatus.harvest:
        return Icons.grass;
      case TaskStatus.fertilizing:
        return Icons.scatter_plot;
      case TaskStatus.pruning:
        return Icons.content_cut;
      default:
        return Icons.task;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    
    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}