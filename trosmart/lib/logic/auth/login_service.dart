import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Pattern Singleton
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('trosmart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Mở database, nếu chưa có sẽ gọi hàm _createDB
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Tạo bảng Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // 2. Thêm dữ liệu mẫu (Mock data) để test phân quyền
    await db.insert('users', {
      'email': 'admin@gmail.com', 
      'password': '123', 
      'role': 'admin'
    });
    
    await db.insert('users', {
      'email': 'user@gmail.com', 
      'password': '123', 
      'role': 'user'
    });
  }

  // Hàm xử lý Đăng nhập
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      // SỬA DÒNG NÀY: Ép kiểu rõ ràng sang Map<String, dynamic>
      return Map<String, dynamic>.from(result.first); 
    }
    return null; // Sai email hoặc password
  }
}