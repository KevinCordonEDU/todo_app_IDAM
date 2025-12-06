import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/task_model.dart';

class MongoService {
  static String _connectionString = dotenv.env['MONGO_CONN_URL'] ?? "";
  static String _collectionName = dotenv.env['collection_name'] ?? "tasks";

  static Db? db;
  static DbCollection? collection;

  static Future<bool> connect() async {
    try {
      if (_connectionString.isEmpty) {
        log('ERROR: MONGO_CONN_URL está vacío');
        return false;
      }
      db = await Db.create(_connectionString);
      await db!.open();
      collection = db!.collection(_collectionName);
      log('✅ Conectado a MongoDB Atlas');
      return true;
    } catch (e) {
      log('❌ Error conectando a MongoDB: $e');
      return false;
    }
  }

  static Future<void> _ensureConnected() async {
    if (collection == null || db == null || !db!.isConnected) {
      await connect();
    }
  }

  static Future<List<Task>> getTasks() async {
    await _ensureConnected();
    if (collection == null) return [];
    try {
      final tasksData = await collection!.find().toList();
      return tasksData.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> insertTask(Task task) async {
    await _ensureConnected();
    if (collection == null) return;
    await collection!.insert(task.toJson());
  }

  static Future<void> updateTask(Task task) async {
    await _ensureConnected();
    if (collection == null) return;
    try {
      await collection!.update(
        where.id(task.id),
        modify
            .set('title', task.title)
            .set('description', task.description) // Nuevo campo
            .set('priority', task.priority)
            .set('tag', task.tag)
            .set('date', task.date)
            .set('isCompleted', task.isCompleted),
      );
    } catch (e) {
      log('Error actualizando: $e');
    }
  }

  static Future<void> deleteTask(ObjectId id) async {
    await _ensureConnected();
    if (collection == null) return;
    await collection!.remove(where.id(id));
  }
}