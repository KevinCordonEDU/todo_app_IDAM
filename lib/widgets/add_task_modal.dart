import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../models/task_model.dart';
import '../services/mongo_service.dart';

class AddTaskModal extends StatefulWidget {
  final Task? taskToEdit;
  const AddTaskModal({super.key, this.taskToEdit});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController(); // Nuevo controlador

  String _selectedPriority = 'medium';
  String _selectedTag = 'Casa'; // Default en Español
  DateTime _selectedDate = DateTime.now();

  // Categorías traducidas
  final List<String> _tags = ['Casa', 'Trabajo', 'Negocios'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description;
      _selectedPriority = widget.taskToEdit!.priority;
      _selectedTag = widget.taskToEdit!.tag;
      _selectedDate = widget.taskToEdit!.date;
    }
  }

  void _presentDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveOrUpdateTask() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isLoading = true);

    if (widget.taskToEdit == null) {
      final newTask = Task(
        id: mongo.ObjectId(),
        title: _titleController.text,
        description: _descController.text,
        priority: _selectedPriority,
        tag: _selectedTag,
        date: _selectedDate,
      );
      await MongoService.insertTask(newTask);
    } else {
      final updatedTask = Task(
        id: widget.taskToEdit!.id,
        title: _titleController.text,
        description: _descController.text,
        priority: _selectedPriority,
        tag: _selectedTag,
        date: _selectedDate,
        isCompleted: widget.taskToEdit!.isCompleted,
      );
      await MongoService.updateTask(updatedTask);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String dateText = "${_selectedDate.day}/${_selectedDate.month}";
    if (_selectedDate.day == DateTime.now().day && _selectedDate.month == DateTime.now().month) dateText = "Hoy";

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(top: 20, left: 25, right: 25, bottom: MediaQuery.of(context).viewInsets.bottom + 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),

          Text(widget.taskToEdit == null ? "Nueva Tarea" : "Editar Tarea", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 20),

          // INPUT TÍTULO
          TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: "Título de la tarea",
                  hintText: '¿Qué necesitas hacer?',
                  contentPadding: EdgeInsets.all(20)
              )
          ),
          const SizedBox(height: 15),

          // INPUT DESCRIPCIÓN (NUEVO)
          TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Descripción (Detalles)",
                hintText: 'Agregar notas adicionales...',
                contentPadding: EdgeInsets.all(20),
                alignLabelWithHint: true,
              )
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(onTap: _presentDatePicker, child: _buildOptionBox(context, Icons.calendar_today_outlined, dateText, 'Fecha')),

              PopupMenuButton<String>(
                onSelected: (val) => setState(() => _selectedTag = val),
                itemBuilder: (context) => _tags.map((t) => PopupMenuItem(value: t, child: Text(t))).toList(),
                child: _buildOptionBox(context, Icons.local_offer_outlined, _selectedTag, 'Categoría'),
              ),

              _buildPrioritySelector(),
            ],
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveOrUpdateTask,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.taskToEdit == null ? 'Guardar Tarea' : 'Actualizar Tarea', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionBox(BuildContext context, IconData icon, String text, String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Row(children: [Icon(icon, size: 18, color: Theme.of(context).primaryColor), const SizedBox(width: 8), Text(text, style: const TextStyle(fontWeight: FontWeight.w500))]),
      ),
    ]);
  }

  Widget _buildPrioritySelector() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Prioridad', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [_priorityDot('high', Colors.redAccent), const SizedBox(width: 8), _priorityDot('medium', Colors.orangeAccent), const SizedBox(width: 8), _priorityDot('low', Colors.greenAccent)]),
    ]);
  }

  Widget _priorityDot(String level, Color color) {
    bool isSelected = _selectedPriority == level;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = level),
      child: Container(width: 24, height: 24, decoration: BoxDecoration(color: isSelected ? color : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2)), child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null),
    );
  }
}