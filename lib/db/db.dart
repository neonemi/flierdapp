import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("CREATE TABLE chattable(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "user_id1 TEXT,user_id2 TEXT,message_id TEXT,message TEXT,"
        "createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)");
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'chatapp.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createItem(String message) async {
    final db = await SQLHelper.db();

    final data = {'message': message};
    final id = await db.insert('chattable', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('chattable', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('chattable', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(
      int id, String message) async {
    final db = await SQLHelper.db();

    final data = {
      'message': message,
      'createdAt': DateTime.now().toString()
    };

    final result =
    await db.update('chattable', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("chattable", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
  static Future<void> DropTableIfExistsThenReCreate() async {

    //here we get the Database object by calling the openDatabase method
    //which receives the path and onCreate function and all the good stuff
    final db = await SQLHelper.db();

    //here we execute a query to drop the table if exists which is called "tableName"
    //and could be given as method's input parameter too
    await db.execute("DROP TABLE IF EXISTS items");

    //and finally here we recreate our beloved "tableName" again which needs
    //some columns initialization
   // await db.execute("CREATE TABLE chatmessage (id INTEGER, name TEXT,image TEXT,count INTEGER)");

  }
//  UPGRADE DATABASE TABLES
  static void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      db.execute("ALTER TABLE chattable ADD COLUMN newCol TEXT;");
    }
  }
}