library;

import 'dart:html';
import 'dart:indexed_db';

/*
 * Permanent Worker Database
 * 
 * 17/02/2025 @ Luca Raffo
 */
class WorkerDatabase<T, K> {
  
  String dbName;
  String storeName;
  Database? _db;

  // Create the database
  WorkerDatabase(this.dbName, this.storeName);

  // Try to fetch a already loaded data in the db
  Future<T?> tryFetch(K key) async {
    
    await _loadDatabase();
    if(_db == null){ 
      print("WorkerDatabase Error: Database not loaded");
      return null; 
    }

    var tx = _db!.transaction(storeName, "readonly");
    var os = tx.objectStore(storeName);

    try
    {
      var objectRequest = await os.getObject(key);
      await tx.completed;
      if (objectRequest == null) return null;
      return objectRequest as T;
    }catch(e) {
      print("Fetch Error: $e");
    } 
    
    return null;
  }

  // Try to put the data inside the databse
  Future tryPut(K key, T data) async {
    
    await _loadDatabase();
    if(_db == null) { 
      print("WorkerDatabase Error: Database not loaded");
      return null;
    }

    var tx = _db!.transaction(storeName, "readwrite");
    var os = tx.objectStore(storeName);

    try {
      await os.put(data, key);
      await tx.completed;
      print("Cached $key");
    } catch (e) {
      print("Put Error: $e");
    }
  }

  // Make sure the database is loaded and ready
  Future _loadDatabase() async {

    if(_db != null) return;

    // Get the indexed db
    var context = DedicatedWorkerGlobalScope.instance;
    var indexedDB = context.indexedDB;
    if (indexedDB == null) {
      print("Fetch Error: IndexedDB not available");
      return null;
    }

    // Fetch the database instance and create the object store
    _db = await indexedDB.open(dbName, version: 1, onUpgradeNeeded: (e)
    {
      Database db = e.target.result;
      var os = db.createObjectStore(storeName);
      print("Store name created! $os");
    });
  }
}
