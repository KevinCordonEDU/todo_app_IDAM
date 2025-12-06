import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final dateString = "${task.date.day} ${months[task.date.month - 1]}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade400, width: 2))),
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.darkText)),
            subtitle: Row(
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)), child: Text(task.tag.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                const SizedBox(width: 8),
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(dateString, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
            trailing: Container(width: 10, height: 10, decoration: BoxDecoration(color: task.priorityColor, shape: BoxShape.circle)),
          ),
        ),
      ),
    );
  }
}