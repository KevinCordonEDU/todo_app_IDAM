import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../models/task_model.dart';
import '../services/mongo_service.dart';
import '../theme/app_theme.dart';
import '../widgets/add_task_modal.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_modal.dart'; // Importamos el nuevo modal

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String _selectedCategory = 'Casa'; // Default en español
  final List<String> _categories = ['Casa', 'Trabajo', 'Negocios']; // Nuevas categorías

  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasksFuture = MongoService.getTasks();
    });
  }

  void _handleDeleteTask(mongo.ObjectId id) async {
    await MongoService.deleteTask(id);
    _loadTasks();
  }

  void _toggleTaskStatus(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      tag: task.tag,
      date: task.date,
      isCompleted: !task.isCompleted,
    );
    await MongoService.updateTask(updatedTask);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_selectedIndex == 0) ...[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildCategories(),
                  ],
                ),
              ),
            ] else ...[
              const Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Historial", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText))
                ),
              )
            ],

            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No hay tareas encontradas."));
                  }

                  List<Task> filteredTasks = [];
                  if (_selectedIndex == 0) {
                    // Pestaña Pendientes
                    filteredTasks = snapshot.data!
                        .where((t) => !t.isCompleted && t.tag == _selectedCategory)
                        .toList();
                  } else {
                    // Pestaña Historial
                    filteredTasks = snapshot.data!
                        .where((t) => t.isCompleted)
                        .toList();
                  }

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              _selectedIndex == 0 ? Icons.task_alt : Icons.done_all,
                              size: 50, color: Colors.grey[300]
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _selectedIndex == 0
                                ? "No hay tareas de '$_selectedCategory'"
                                : "No hay tareas completadas aún",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return Dismissible(
                        key: Key(task.id.toString()),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          color: AppTheme.accentGreen,
                          child: Row(
                            children: [
                              Icon(task.isCompleted ? Icons.undo : Icons.check_circle_outline, color: Colors.white, size: 30),
                              const SizedBox(width: 10),
                              Text(task.isCompleted ? "Restaurar" : "Completar", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppTheme.accentRed,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Eliminar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 10),
                              Icon(Icons.delete_outline, color: Colors.white, size: 30),
                            ],
                          ),
                        ),

                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            _toggleTaskStatus(task);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(task.isCompleted ? "Tarea restaurada a Pendientes" : "Tarea marcada como Completada"),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          } else {
                            _handleDeleteTask(task.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Tarea eliminada"), duration: Duration(seconds: 1)),
                            );
                          }
                        },

                        // --- CAMBIO PRINCIPAL: Al tocar, mostramos DETALLES, no editar ---
                        child: GestureDetector(
                          onTap: () async {
                            // Mostrar Modal de Detalles
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => TaskDetailModal(
                                task: task,
                                // Si en el modal de detalles le dan a "Eliminar"
                                onDelete: () {
                                  _handleDeleteTask(task.id);
                                },
                                // Si en el modal de detalles le dan a "Editar"
                                onEdit: () async {
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => AddTaskModal(taskToEdit: task),
                                  );
                                  _loadTasks();
                                },
                              ),
                            );
                          },
                          child: TaskCard(task: task),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: _selectedIndex == 0 ? SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddTaskModal(),
            );
            _loadTasks();
          },
          backgroundColor: AppTheme.darkText,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buenos días,', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppTheme.darkText)),
            Text('Alex', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppTheme.darkText)),
          ],
        ),
        const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
        )
      ],
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() => _selectedCategory = category);
              },
              selectedColor: AppTheme.darkText,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Colors.transparent,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black12,
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.list_alt_rounded, 'Pendientes', 0),
            const SizedBox(width: 40),
            _buildNavItem(Icons.check_circle_outline_rounded, 'Historial', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? AppTheme.darkText : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isSelected ? AppTheme.darkText : Colors.grey)),
        ],
      ),
    );
  }
}