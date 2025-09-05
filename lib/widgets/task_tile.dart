// import 'package:flutter/material.dart';
// import '../pages/schedule_page.dart';

// class TaskTileWidget extends StatelessWidget {
//   final Task task;
//   final Color Function(TaskStatus) getTaskStatusColor;
//   final String Function(TaskStatus) getTaskStatusText;
//   final VoidCallback onTap;

//   const TaskTileWidget({
//     super.key,
//     required this.task,
//     required this.getTaskStatusColor,
//     required this.getTaskStatusText,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       child: ListTile(
//         leading: Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: getTaskStatusColor(task.status),
//             shape: BoxShape.circle,
//           ),
//         ),
//         title: Text(task.title),
//         subtitle: Text('${task.description} • ${getTaskStatusText(task.status)}'),
//         trailing: Text(
//           '${task.date.month}/${task.date.day}',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
// }
