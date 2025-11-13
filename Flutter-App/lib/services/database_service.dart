import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/download_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_auth.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
    if (oldVersion < 2) {
      // Create downloads table if upgrading from version 1
      await db.execute('''
        CREATE TABLE downloads (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          filename TEXT NOT NULL,
          filepath TEXT NOT NULL,
          type TEXT NOT NULL,
          downloadedAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Create downloads table to track user-specific downloads
    await db.execute('''
      CREATE TABLE downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        filename TEXT NOT NULL,
        filepath TEXT NOT NULL,
        type TEXT NOT NULL,
        downloadedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // Register a new user
  Future<bool> registerUser(User user) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  // Login user
  Future<User?> loginUser(String email, String password) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (maps.isEmpty) {
        return null;
      }

      return User.fromMap(maps.first);
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  // Get user by email (check if email exists)
  Future<bool> emailExists(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // Get user by ID
  Future<User?> getUserById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }

      return User.fromMap(maps.first);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUser(User user) async {
    try {
      final db = await database;
      final result = await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return result > 0;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete user (also deletes all their downloads automatically via FOREIGN KEY)
  Future<bool> deleteUser(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // ==================== DOWNLOADS TABLE METHODS ====================

  // Add a download record for a user
  Future<bool> addDownload(Download download) async {
    try {
      final db = await database;
      await db.insert(
        'downloads',
        download.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error adding download: $e');
      return false;
    }
  }

  // Get all downloads for a specific user
  Future<List<Download>> getUserDownloads(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'downloads',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'downloadedAt DESC',
      );

      return List.generate(
        maps.length,
        (i) => Download.fromMap(maps[i]),
      );
    } catch (e) {
      print('Error getting user downloads: $e');
      return [];
    }
  }

  // Delete a specific download record
  Future<bool> deleteDownload(int downloadId) async {
    try {
      final db = await database;
      final result = await db.delete(
        'downloads',
        where: 'id = ?',
        whereArgs: [downloadId],
      );
      return result > 0;
    } catch (e) {
      print('Error deleting download: $e');
      return false;
    }
  }

  // Delete all downloads for a user (called when user account is deleted)
  Future<bool> deleteUserDownloads(int userId) async {
    try {
      final db = await database;
      final result = await db.delete(
        'downloads',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return result >= 0;
    } catch (e) {
      print('Error deleting user downloads: $e');
      return false;
    }
  }

  // Get download by ID
  Future<Download?> getDownloadById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'downloads',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }

      return Download.fromMap(maps.first);
    } catch (e) {
      print('Error getting download: $e');
      return null;
    }
  }

  // Close database
  Future<void> closeDb() async {
    final db = await database;
    await db.close();
  }
}
