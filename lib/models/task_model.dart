import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Task {
  final ObjectId id;
  final String title;
  final String description; // Antes subtitle, ahora description para ser claros
  final String priority;
  final String tag;
  final DateTime date;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.tag,
    required this.date,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      // Mapeamos 'subtitle' o 'description' de la BD a nuestra variable description
      description: json['description'] ?? json['subtitle'] ?? '',
      priority: json['priority'] ?? 'medium',
      tag: json['tag'] ?? 'Casa', // Default en Español
      date: json['date'] != null ? json['date'].toLocal() : DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description, // Guardamos como description
      'priority': priority,
      'tag': tag,
      'date': date,
      'isCompleted': isCompleted,
    };
  }

  Color get priorityColor {
    switch (priority) {
      case 'high': return const Color(0xFFE57373);
      case 'medium': return const Color(0xFFFFD54F);
      case 'low': return const Color(0xFF81C784);
      default: return Colors.grey;
    }
  }
}