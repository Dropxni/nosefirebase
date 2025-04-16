import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getTareitas() async {
  List<Map<String, dynamic>> tasks = [];
  CollectionReference collectionTasks = db.collection('tasks');
  QuerySnapshot snapshot = await collectionTasks.get();

  for (var document in snapshot.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final taskData = {
      'id': document.id,
      'title': data['title'] ?? 'Sin título',
      'description': data['description'] ?? 'Sin descripción',
      'status': data['status'] ?? 0,
    };
    tasks.add(taskData);
  }
  return tasks;
}

Future<void> deleteTask(String taskId) async {
  await db.collection('tasks').doc(taskId).delete();
}
