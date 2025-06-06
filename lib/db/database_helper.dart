import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Thêm cột role nếu đang nâng cấp từ phiên bản 1
      await db.execute('ALTER TABLE users ADD COLUMN role TEXT DEFAULT "user"');
    }

    if (oldVersion < 3) {
      // Tạo bảng work_items nếu đang nâng cấp lên phiên bản 3
      await db.execute('''
        CREATE TABLE work_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          userId TEXT NOT NULL,
          userName TEXT NOT NULL,
          type TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT "pending",
          requestedDate TEXT NOT NULL,
          approvedDate TEXT,
          approvedBy TEXT
        )
      ''');
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT DEFAULT "user"
      )
    ''');

    await db.execute('''
      CREATE TABLE work_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT "pending",
        requestedDate TEXT NOT NULL,
        approvedDate TEXT,
        approvedBy TEXT
      )
    ''');
  }

  // Đăng ký người dùng mới
  Future<void> registerUser(
    String username,
    String password, {
    String role = 'user',
  }) async {
    final db = await database;

    // Kiểm tra xem username đã tồn tại chưa
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (existing.isNotEmpty) {
      throw Exception('User already exists');
    }

    await db.insert('users', {
      'username': username,
      'password': password,
      'role': role,
    });
  }

  // Xác thực đăng nhập và trả về thông tin người dùng
  Future<Map<String, dynamic>?> loginUser(
    String username,
    String password,
  ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return result.isNotEmpty ? result.first : null;
  }

  // Tạo yêu cầu phê duyệt mới
  Future<int> createWorkItem({
    required String title,
    required String description,
    required String userId,
    required String userName,
    required String type,
  }) async {
    final db = await database;

    final workItem = {
      'title': title,
      'description': description,
      'userId': userId,
      'userName': userName,
      'type': type,
      'status': 'pending',
      'requestedDate': DateTime.now().toIso8601String(),
    };

    return await db.insert('work_items', workItem);
  }

  // Lấy tất cả công việc cần phê duyệt
  Future<List<Map<String, dynamic>>> getPendingWorkItems() async {
    final db = await database;

    return await db.query(
      'work_items',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'requestedDate DESC',
    );
  }

  // Lấy tất cả công việc của một người dùng
  Future<List<Map<String, dynamic>>> getUserWorkItems(String userId) async {
    final db = await database;

    return await db.query(
      'work_items',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'requestedDate DESC',
    );
  }

  // Phê duyệt một công việc
  Future<int> approveWorkItem(int workItemId, String approverName) async {
    final db = await database;

    return await db.update(
      'work_items',
      {
        'status': 'approved',
        'approvedDate': DateTime.now().toIso8601String(),
        'approvedBy': approverName,
      },
      where: 'id = ?',
      whereArgs: [workItemId],
    );
  }

  // Từ chối một công việc
  Future<int> rejectWorkItem(int workItemId, String approverName) async {
    final db = await database;

    return await db.update(
      'work_items',
      {
        'status': 'rejected',
        'approvedDate': DateTime.now().toIso8601String(),
        'approvedBy': approverName,
      },
      where: 'id = ?',
      whereArgs: [workItemId],
    );
  }

  // Đếm số công việc chờ phê duyệt
  Future<int> countPendingWorkItems() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM work_items WHERE status = "pending"',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Lấy thông tin người dùng theo tên đăng nhập
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty ? result.first : null;
  }
}
