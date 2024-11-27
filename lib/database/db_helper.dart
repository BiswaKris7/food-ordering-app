import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';


import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final _databaseName = "FoodOrdering.db";
  static final _databaseVersion = 2;

  static final foodTable = 'food_items';
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnCost = 'cost';

  static final orderTable = 'order_plans';
  static final columnDate = 'date';
  static final columnSelectedItems = 'selected_items';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    //////Create food items table
    await db.execute('''
      CREATE TABLE $foodTable (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnCost REAL NOT NULL
      )
    ''');

    ////////plans table
    await db.execute('''
      CREATE TABLE $orderTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDate TEXT NOT NULL,
        $columnSelectedItems TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $orderTable (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnDate TEXT NOT NULL,
          $columnSelectedItems TEXT NOT NULL
        )
      ''');
    }
  }

  // Food Items CRUD Operations
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(foodTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(foodTable);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['_id'];
    return await db.update(foodTable, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(foodTable, where: '$columnId = ?', whereArgs: [id]);
  }

  // Order Plans CRUD Operations
  Future<int> insertOrderPlan(String date, String selectedItemsJson) async {
    Database db = await instance.database;
    return await db.insert(orderTable, {
      columnDate: date,
      columnSelectedItems: selectedItemsJson,
    });
  }

  Future<List<Map<String, dynamic>>> queryOrderPlans(String date) async {
    Database db = await instance.database;
    return await db.query(orderTable, where: '$columnDate = ?', whereArgs: [date]);
  }

  Future<int> updateOrderPlan(int id, String date, String selectedItemsJson) async {
    Database db = await instance.database;
    return await db.update(
      orderTable,
      {
        columnDate: date,
        columnSelectedItems: selectedItemsJson,
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteOrderPlan(int id) async {
    Database db = await instance.database;
    return await db.delete(orderTable, where: '$columnId = ?', whereArgs: [id]);
  }
}
