import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class TaskService {
  final _firestore = FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> getTasks() {
    return _firestore.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Future<void> addTask(Task task) async {
    await _firestore.add(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _firestore.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _firestore.doc(id).delete();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    await _firestore.doc(task.id).update({'isCompleted': !task.isCompleted});
  }
}