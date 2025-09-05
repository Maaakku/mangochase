class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TaskStatus status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
  });
}

enum TaskStatus {
  watering,
  pestControl,
  fertilizing,
  pruning,
  harvest,
  planting,
}