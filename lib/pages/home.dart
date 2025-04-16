import 'package:flutter/material.dart';
import 'package:nosefirebase/services/task.firebase.dart';
import 'package:nosefirebase/pages/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _futureTareitas;

  @override
  void initState() {
    super.initState();
    _futureTareitas = getTareitas();
  }

  Future<void> _navigateToAddTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskPage()),
    );

    if (newTask != null) {
      setState(() {
        _futureTareitas = getTareitas();
      });
    }
  }

  // 🔴 Función para mostrar alerta antes de eliminar la tarea
  void _confirmDeleteTask(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Tarea completada?"),
        content: const Text("Si ya completaste la tarea, se eliminará de la lista."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cerrar la alerta sin eliminar
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              await deleteTask(taskId);
              setState(() {
                _futureTareitas = getTareitas();
              });
              // ignore: use_build_context_synchronously
              Navigator.pop(context); // Cerrar la alerta
            },
            child: const Text("Sí, eliminar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text("Lista de Tareas"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureTareitas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Ocurrió un error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var task = snapshot.data![index];
                return TaskTile(
                  taskId: task['id'],
                  title: task['title'],
                  description: task['description'],
                  status: task['status'],
                  onTaskCompleted: _confirmDeleteTask,
                );
              },
            );
          } else {
            return const Center(child: Text("No hay datos disponibles"));
          }
        },
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String taskId;
  final String title;
  final String description;
  final int status;
  final Function(String) onTaskCompleted;

  const TaskTile({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.status,
    required this.onTaskCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: IconButton(
          icon: Icon(
            status == 1 ? Icons.check_circle : Icons.circle_outlined,
            color: status == 1 ? Colors.green : Colors.grey,
          ),
          onPressed: () => onTaskCompleted(taskId),
        ),
      ),
    );
  }
}
