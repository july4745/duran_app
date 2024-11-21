import 'dart:async';
import '/home/result.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '/date/fragrance_result.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._privateConstructor();

  // Database instance
  static Database? _db;

  // Getter for the database instance
  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'prediction.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // สร้างตาราง ripeness_results
    await db.execute('''CREATE TABLE ripeness_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ripeness_level TEXT,
      image_path TEXT,
      timestamp TEXT
    )''');

    // สร้างตาราง fragrance_results
    await db.execute('''CREATE TABLE fragrance_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fragrance_date TEXT,
      scent_range TEXT,
      weight REAL,
      diameter REAL,
      length REAL,
      harvestDate TEXT,
      timestamp TEXT
    )''');
  }

  // Update database schema if necessary
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // Insert data into ripeness_results table
  Future<int> insert(Map<String, dynamic> row) async {
    Database dbClient = await db;
    return await dbClient.insert('ripeness_results', row);
  }

  // Save prediction results
  Future<int> savePrediction(String image, String result) async {
    Database dbClient = await db;
    Map<String, dynamic> values = {
      'image_path': image,
      'ripeness_level': result,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return await dbClient.insert('ripeness_results', values);
  }

  // Save fragrance calculation results
  Future<int> saveFragranceResult({
    required String fragranceDate,
    required String scentRange,
    required double weight,
    required double diameter,
    required double length,
    required String harvestDate,
    required dynamic fragranceResult,
  }) async {
    Database dbClient = await db;
    Map<String, dynamic> values = {
      'fragrance_date': fragranceResult.fragranceDate,
      'scent_range': fragranceResult.scentRange,
      'timestamp': DateTime.now().toIso8601String(),
      'weight': fragranceResult.weight,
      'diameter': fragranceResult.diameter,
      'length': fragranceResult.length,
      'harvestDate': fragranceResult.harvestDate,
    };

    return await dbClient.insert('fragrance_results', values);
  }

  Future<void> insertDurian(Durian durian) async {
    final db = await DatabaseHelper().db;
    await db.insert(
      'ripeness_results',
      {
        'image_path': durian.imagePath,
        'ripeness_level': durian.ripenessLevel,
        'timestamp': durian.timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ฟังก์ชันในการบันทึกข้อมูล fragrance result
  Future<void> insertFragranceData(FragranceResult fragranceResult) async {
    final db = await DatabaseHelper().db;
    await db.insert(
      'fragrance_results',
      {
        'fragrance_date': fragranceResult.fragranceDate,
        'scent_range': fragranceResult.scentRange,
        'timestamp': DateTime.now().toIso8601String(),
        'weight': fragranceResult.weight,
        'diameter': fragranceResult.diameter,
        'length': fragranceResult.length,
        'harvestDate': fragranceResult.harvestDate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve fragrance results
  Future<List<Map<String, dynamic>>> getFragranceResults() async {
    Database dbClient = await DatabaseHelper().db;
    List<Map<String, dynamic>> results =
        await dbClient.query('fragrance_results');

    // แปลง timestamp ที่เก็บในฐานข้อมูลกลับเป็น DateTime
    results.forEach((row) {
      String timestampStr = row['timestamp'];
      DateTime timestamp =
          DateTime.parse(timestampStr); // แปลงจาก ISO 8601 เป็น DateTime
      print("Timestamp: $timestamp");
    });

    return results;
  }

  // Retrieve ripeness results
  Future<List<Map<String, dynamic>>> getRipenessResults() async {
    Database dbClient = await DatabaseHelper().db;
    return await dbClient.query('ripeness_results');
  }
}
