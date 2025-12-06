import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import 'add_task_modal.dart'; // Para poder ir a editar desde aquí

class TaskDetailModal extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit; // Callback para cerrar y abrir el editor
  final VoidCallback onDelete; // Callback para borrar

  const TaskDetailModal({super.key, required this.task, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Formato de fecha simple
    final dateText = "${task.date.day}/${task.date.month}/${task.date.year}";

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra superior (Drag handle)
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),

          // TÍTULO y ESTADO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                ),
              ),
              // Badge de Estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: task.isCompleted ? AppTheme.accentGreen : Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.isCompleted ? "Completada" : "Pendiente",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          // SECCIÓN DE DETALLES
          _buildDetailRow(Icons.calendar_today, "Fecha límite:", dateText),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.local_offer, "Categoría:", task.tag),
          const SizedBox(height: 20),

          const Text("Descripción:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.description.isEmpty ? "Sin descripción agregada." : task.description,
              style: const TextStyle(fontSize: 16, color: AppTheme.darkText),
            ),
          ),

          const SizedBox(height: 30),

          // BOTONES DE ACCIÓN
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar detalles
                    onEdit(); // Abrir editor
                  },
                  icon: const Icon(Icons.edit, color: AppTheme.darkText),
                  label: const Text("Editar", style: TextStyle(color: AppTheme.darkText)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppTheme.darkText),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Eliminar", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkText)),
      ],
    );
  }
}