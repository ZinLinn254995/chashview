import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  // Singleton instance of FirebaseDatabase
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Get Database reference for any given path
  DatabaseReference ref(String path) => _database.ref(path);

  /// Create or overwrite data at a given path
  Future<void> setData(String path, Map<String, dynamic> data) async {
    await _database.ref(path).set(data);
  }

  /// Update existing data partially
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _database.ref(path).update(data);
  }

  /// Read data once
  Future<DataSnapshot> getData(String path) async {
    return await _database.ref(path).get();
  }

  /// Delete data
  Future<void> deleteData(String path) async {
    await _database.ref(path).remove();
  }

  /// Listen to realtime changes
  Stream<DatabaseEvent> listenToPath(String path) {
    return _database.ref(path).onValue;
  }
}
