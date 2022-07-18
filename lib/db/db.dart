import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

class SQLHelper {

  /// id: the id of a item auto generated
  /// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<void> createTables(sql.Database database) async {

    await database.execute("CREATE TABLE messagelist (key_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "chat_id INTEGER,chat_db_id INTEGER,message_id INTEGER,message TEXT,name TEXT,sender_id INTEGER,receiver_id INTEGER,message_type TEXT,imagepath TEXT,"
        "videopath TEXT,filepath TEXT,audiopath TEXT,filename TEXT,uint8list TEXT,profilepic TEXT,gifpath TEXT,"
        "createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)");

    await database.execute("CREATE TABLE chatwindow (key_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "chat_id INTEGER,chat_db_id INTEGER,message_id INTEGER,message TEXT,name TEXT,sender_id INTEGER,receiver_id INTEGER,message_type TEXT,profilepic TEXT,"
        "createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)");

  }

/// Database
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'chatapp.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  /// Create new item
  static Future<int> createItem(String message,int messageid,int chat_db_id,int chatid,String name,int senderid,int receiverid,
      String messagetype,String imagepath,String videopath,String filepath,String audiopath,String filaname,
      String uint8list,String profilepic,String gifpath) async {
    final db = await SQLHelper.db();

    final data = {
      'chat_id':chatid,
      'chat_db_id':chat_db_id,
      'message_id':messageid,
      'message': message,
      'name':name,
      'sender_id':senderid,
      'receiver_id':receiverid,
      'message_type':messagetype,
      'imagepath':imagepath,
      'videopath':videopath,
      'filepath':filepath,
      'audiopath':audiopath,
      'filename':filaname,
      'uint8list':uint8list,
      'profilepic':profilepic,
      'gifpath':gifpath
                    };
    final id = await db.insert('messagelist', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  /// Read all items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('messagelist', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('messagelist', where: "id = ?", whereArgs: [id], limit: 1);
  }

  /// Update an item by id
  static Future<int> updateItem(
      int id, String message,int messageid,int chat_db_id,int chatid,String name,int senderid,int receiverid,
      String messagetype,String imagepath,String videopath,String filepath,String audiopath,String filaname,
      String uint8list,String profilepic,String gifpath) async {
    final db = await SQLHelper.db();

    final data = {
      'chat_id':chatid,
      'chat_db_id':chat_db_id,
      'message_id':messageid,
      'message': message,
      'name':name,
      'sender_id':senderid,
      'receiver_id':receiverid,
      'message_type':messagetype,
      'imagepath':imagepath,
      'videopath':videopath,
      'filepath':filepath,
      'audiopath':audiopath,
      'filename':filaname,
      'uint8list':uint8list,
      'profilepic':profilepic,
      'gifpath':gifpath,
      'createdAt': DateTime.now()
    };

    final result =
    await db.update('messagelist', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  /// Delete an item from list
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("messagelist", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  ///Delete all item
  static Future<void> deleteAll() async {
    final db = await SQLHelper.db();
    try {
      await db.execute("delete from  messagelist");
    } catch (err) {
      debugPrint("Something went wrong when deleting all item: $err");
    }
  }

  ///Delete table if exists
  static Future<void> DropTableIfExistsThenReCreate() async {
    final db = await SQLHelper.db();

    //here we execute a query to drop the table if exists which is called "tableName"
    //and could be given as method's input parameter too
    await db.execute("DROP TABLE IF EXISTS messagelist");

    //and finally here we recreate our beloved "tableName" again which needs
    //some columns initialization
    await db.execute("CREATE TABLE messagelist (key_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "chat_id INTEGER,chat_db_id INTEGER,message_id TEXT,message TEXT,name TEXT,sender_id INTEGER,receiver_id INTEGER,message_type TEXT,imagepath TEXT,"
        "videopath TEXT,filepath TEXT,audiopath TEXT,filename TEXT,uint8list TEXT,profilepic TEXT,gifpath TEXT,"
        "createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)");

  }

///  UPGRADE DATABASE TABLES
  static void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      db.execute("ALTER TABLE messagelist ADD COLUMN newCol TEXT;");
    }
  }

}