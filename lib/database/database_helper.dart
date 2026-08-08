import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "gpi_fleet.db");

    return await openDatabase(
      path,
      version: 11,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE drivers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        driver_name TEXT NOT NULL,
        mobile_number TEXT,
        license_number TEXT,
        license_expiry TEXT,
        joining_date TEXT,
        address TEXT,
        emergency_contact TEXT,
        aadhaar_number TEXT,
        status TEXT DEFAULT 'Active',
        remarks TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE trucks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        truck_number TEXT UNIQUE NOT NULL,
        vehicle_type TEXT,
        make TEXT,
        model TEXT,
        owner_name TEXT,
        registration_number TEXT,
        status TEXT NOT NULL DEFAULT 'Active',
        remarks TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        driver_id INTEGER NOT NULL,
        truck_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        paid_by TEXT NOT NULL,
        payment_mode TEXT NOT NULL,
        expense_name TEXT NOT NULL,
        remarks TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE company_profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT NOT NULL,
        address TEXT,
        city TEXT,
        state TEXT,
        pincode TEXT,
        phone TEXT,
        email TEXT,
        website TEXT,
        gst_number TEXT,
        pan_number TEXT,
        logo_path TEXT,
        signature_path TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE fuel_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        truck_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        odometer REAL,
        liters REAL NOT NULL,
        rate_per_liter REAL,
        total_amount REAL NOT NULL,
        fuel_station TEXT,
        payment_mode TEXT,
        remarks TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (truck_id) REFERENCES trucks (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        truck_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        maintenance_type TEXT NOT NULL,
        description TEXT,
        odometer REAL,
        amount REAL NOT NULL,
        service_provider TEXT,
        next_service_date TEXT,
        next_service_odometer REAL,
        payment_mode TEXT,
        remarks TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (truck_id) REFERENCES trucks (id)
      )
    ''');
  }

  Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute("DROP TABLE IF EXISTS expenses");
      await db.execute('''
        CREATE TABLE expenses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          driver_id INTEGER NOT NULL,
          truck_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          paid_by TEXT NOT NULL,
          payment_mode TEXT NOT NULL,
          expense_name TEXT NOT NULL,
          remarks TEXT
        )
      ''');
    }

    if (oldVersion < 3) {
      final expenses = await db.query('expenses', columns: ['id', 'date']);
      for (final expense in expenses) {
        final value = expense['date'] as String;
        final parts = value.split('/');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          await db.update(
            'expenses',
            {'date': '${parts[2]}-$month-$day'},
            where: 'id=?',
            whereArgs: [expense['id']],
          );
        }
      }
    }

    if (oldVersion < 4) {
      final tableCheck = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='trucks'");
      if (tableCheck.isNotEmpty) {
        await db.execute("ALTER TABLE trucks RENAME TO trucks_old");
        await db.execute('''
          CREATE TABLE trucks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            truck_number TEXT UNIQUE NOT NULL,
            vehicle_type TEXT,
            make TEXT,
            model TEXT,
            owner_name TEXT,
            registration_number TEXT,
            status TEXT NOT NULL DEFAULT 'Active',
            remarks TEXT,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        final oldTrucks = await db.rawQuery("SELECT * FROM trucks_old");
        for (final oldTruck in oldTrucks) {
          await db.insert('trucks', {
            'id': oldTruck['id'],
            'truck_number': oldTruck['truck_no'] ?? oldTruck['truck_number'],
            'status': 'Active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
        await db.execute("DROP TABLE trucks_old");
      }
    }

    if (oldVersion < 5) {
      final tableInfo = await db.rawQuery("PRAGMA table_info(trucks)");
      final hasRegNo = tableInfo.any((col) => col['name'] == 'registration_number');
      if (!hasRegNo) {
         await db.execute("ALTER TABLE trucks ADD COLUMN registration_number TEXT");
      }
    }

    if (oldVersion < 6) {
      final profileCheck = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='company_profile'");
      if (profileCheck.isEmpty) {
        await db.execute('''
          CREATE TABLE company_profile(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            company_name TEXT NOT NULL,
            address TEXT,
            gst_number TEXT,
            pan_number TEXT,
            phone_number TEXT,
            email TEXT,
            website TEXT,
            logo_path TEXT,
            signature_path TEXT,
            notes TEXT
          )
        ''');
      }
    }

    if (oldVersion < 7) {
      final tableInfo = await db.rawQuery("PRAGMA table_info(drivers)");
      final hasDriverName = tableInfo.any((col) => col['name'] == 'driver_name');

      if (!hasDriverName) {
        await db.execute("ALTER TABLE drivers RENAME TO drivers_old");
        await db.execute('''
          CREATE TABLE drivers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            driver_name TEXT NOT NULL,
            mobile_number TEXT,
            license_number TEXT,
            license_expiry TEXT,
            joining_date TEXT,
            address TEXT,
            emergency_contact TEXT,
            aadhaar_number TEXT,
            status TEXT DEFAULT 'Active',
            remarks TEXT,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        final oldDrivers = await db.rawQuery("SELECT * FROM drivers_old");
        for (final oldDriver in oldDrivers) {
          await db.insert('drivers', {
            'id': oldDriver['id'],
            'driver_name': oldDriver['name'],
            'status': 'Active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
        await db.execute("DROP TABLE drivers_old");
      }
    }

    if (oldVersion < 8) {
      final tableCheck = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='company_profile'");
      if (tableCheck.isNotEmpty) {
        final tableInfo = await db.rawQuery("PRAGMA table_info(company_profile)");
        final hasCompanyName = tableInfo.any((col) => col['name'] == 'company_name');
        
        if (!hasCompanyName) {
          await db.execute("ALTER TABLE company_profile RENAME TO company_profile_old");
          await db.execute('''
            CREATE TABLE company_profile(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              company_name TEXT NOT NULL,
              address TEXT,
              city TEXT,
              state TEXT,
              pincode TEXT,
              phone TEXT,
              email TEXT,
              website TEXT,
              gst_number TEXT,
              pan_number TEXT,
              logo_path TEXT,
              signature_path TEXT,
              created_at TEXT,
              updated_at TEXT
            )
          ''');

          final oldProfiles = await db.rawQuery("SELECT * FROM company_profile_old");
          for (final oldProfile in oldProfiles) {
            await db.insert('company_profile', {
              'id': oldProfile['id'],
              'company_name': oldProfile['name'] ?? '',
              'address': oldProfile['address'],
              'phone': oldProfile['phone_number'] ?? oldProfile['phone'],
              'email': oldProfile['email'],
              'website': oldProfile['website'],
              'gst_number': oldProfile['gst_number'],
              'pan_number': oldProfile['pan_number'],
              'logo_path': oldProfile['logo_path'],
              'signature_path': oldProfile['signature_path'],
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
          await db.execute("DROP TABLE company_profile_old");
        }
      }
    }

    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE fuel_entries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          truck_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          odometer REAL,
          liters REAL NOT NULL,
          rate_per_liter REAL,
          total_amount REAL NOT NULL,
          fuel_station TEXT,
          payment_mode TEXT,
          remarks TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          FOREIGN KEY (truck_id) REFERENCES trucks (id)
        )
      ''');
    }

    if (oldVersion < 10) {
      await db.execute("DROP TABLE IF EXISTS fuel_entries");
      await db.execute('''
        CREATE TABLE fuel_entries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          truck_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          odometer REAL,
          liters REAL NOT NULL,
          rate_per_liter REAL,
          total_amount REAL NOT NULL,
          fuel_station TEXT,
          payment_mode TEXT,
          remarks TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          FOREIGN KEY (truck_id) REFERENCES trucks (id)
        )
      ''');
    }

    if (oldVersion < 11) {
      await db.execute('''
        CREATE TABLE maintenance_entries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          truck_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          maintenance_type TEXT NOT NULL,
          description TEXT,
          odometer REAL,
          amount REAL NOT NULL,
          service_provider TEXT,
          next_service_date TEXT,
          next_service_odometer REAL,
          payment_mode TEXT,
          remarks TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (truck_id) REFERENCES trucks (id)
        )
      ''');

    }
  }

  //---------------- DRIVER (Internal Methods) ----------------//

  Future<int> insertDriver(Map<String, dynamic> driver) async {
    final db = await database;
    return db.insert("drivers", driver);
  }

  Future<int> updateDriverRecord(int id, Map<String, dynamic> driver) async {
    final db = await database;
    return db.update("drivers", driver, where: "id=?", whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> queryDriver(int id) async {
    final db = await database;
    final result = await db.query("drivers", where: "id=?", whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> queryAllDrivers() async {
    final db = await database;
    return db.query("drivers", orderBy: "driver_name");
  }

  Future<List<Map<String, dynamic>>> queryActiveDrivers() async {
    final db = await database;
    return db.query("drivers", where: "status=?", whereArgs: ["Active"], orderBy: "driver_name");
  }

  Future<List<Map<String, dynamic>>> querySearchDrivers(String query) async {
    final db = await database;
    return db.query("drivers", where: "driver_name LIKE ? OR mobile_number LIKE ?", whereArgs: ["%$query%", "%$query%"], orderBy: "driver_name");
  }

  Future<bool> isDriverReferenced(int id) async {
    final db = await database;
    final result = await db.query(
      "expenses",
      columns: ["id"],
      where: "driver_id=?",
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> deleteDriverRecord(int id) async {
    if (await isDriverReferenced(id)) return 0;
    final db = await database;
    return db.delete("drivers", where: "id=?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getDrivers() async {
    final db = await database;
    return db.rawQuery('SELECT id, driver_name AS name FROM drivers ORDER BY driver_name');
  }

  //---------------- TRUCK (Internal Methods) ----------------//

  Future<int> insertTruck(Map<String, dynamic> truck) async {
    final db = await database;
    return db.insert("trucks", truck);
  }

  Future<int> updateTruckRecord(int id, Map<String, dynamic> truck) async {
    final db = await database;
    return db.update("trucks", truck, where: "id=?", whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> queryTruck(int id) async {
    final db = await database;
    final result = await db.query("trucks", where: "id=?", whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> queryAllTrucks() async {
    final db = await database;
    return db.query("trucks", orderBy: "truck_number");
  }

  Future<List<Map<String, dynamic>>> queryActiveTrucks() async {
    final db = await database;
    return db.query("trucks", where: "status=?", whereArgs: ["Active"], orderBy: "truck_number");
  }

  Future<List<Map<String, dynamic>>> querySearchTrucks(String query) async {
    final db = await database;
    return db.query("trucks", where: "truck_number LIKE ?", whereArgs: ["%$query%"], orderBy: "truck_number");
  }

  Future<bool> isTruckReferenced(int id) async {
    final db = await database;
    final result = await db.query(
      "expenses",
      columns: ["id"],
      where: "truck_id=?",
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> deleteTruckRecord(int id) async {
    if (await isTruckReferenced(id)) return 0;
    final db = await database;
    return db.delete("trucks", where: "id=?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getTrucks() async {
    final db = await database;
    return db.rawQuery('SELECT id, truck_number AS truck_no FROM trucks ORDER BY truck_number');
  }

  //---------------- COMPANY PROFILE ----------------//

  Future<int> insertCompanyProfile(Map<String, dynamic> profile) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    profile['created_at'] = now;
    profile['updated_at'] = now;
    return db.insert("company_profile", profile);
  }

  Future<int> updateCompanyProfileRecord(int id, Map<String, dynamic> profile) async {
    final db = await database;
    profile['updated_at'] = DateTime.now().toIso8601String();
    return db.update(
      "company_profile",
      profile,
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> queryCompanyProfile() async {
    final db = await database;
    final result = await db.query("company_profile", limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  //---------------- FUEL ENTRIES ----------------//

  Future<int> insertFuelEntry(Map<String, dynamic> fuel) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    fuel['created_at'] = now;
    fuel['updated_at'] = now;
    return db.insert("fuel_entries", fuel);
  }

  Future<int> updateFuelEntryRecord(int id, Map<String, dynamic> fuel) async {
    final db = await database;
    fuel['updated_at'] = DateTime.now().toIso8601String();
    return db.update("fuel_entries", fuel, where: "id=?", whereArgs: [id]);
  }

  Future<int> deleteFuelEntryRecord(int id) async {
    final db = await database;
    return db.delete("fuel_entries", where: "id=?", whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> queryFuelEntry(int id) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT f.*, t.truck_number
      FROM fuel_entries f
      LEFT JOIN trucks t ON f.truck_id = t.id
      WHERE f.id = ?
    ''', [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> queryFuelEntries({int? truckId, String? startDate, String? endDate, String? searchTerm}) async {
    final db = await database;
    String where = "";
    List<dynamic> whereArgs = [];

    if (truckId != null) {
      where = "f.truck_id = ?";
      whereArgs.add(truckId);
    }

    if (startDate != null && endDate != null) {
      if (where.isNotEmpty) where += " AND ";
      where += "f.date BETWEEN ? AND ?";
      whereArgs.addAll([startDate, endDate]);
    }

    if (searchTerm != null && searchTerm.isNotEmpty) {
      if (where.isNotEmpty) where += " AND ";
      where += "(t.truck_number LIKE ? OR f.fuel_station LIKE ? OR f.remarks LIKE ?)";
      whereArgs.addAll(["%$searchTerm%", "%$searchTerm%", "%$searchTerm%"]);
    }

    final query = '''
      SELECT f.*, t.truck_number
      FROM fuel_entries f
      LEFT JOIN trucks t ON f.truck_id = t.id
      ${where.isNotEmpty ? "WHERE $where" : ""}
      ORDER BY f.date DESC, f.id DESC
    ''';

    return db.rawQuery(query, whereArgs);
  }

  Future<List<Map<String, dynamic>>> queryMonthlyFuelSummary() async {
    final db = await database;
    return db.rawQuery('''
      SELECT strftime('%Y-%m', date) as month, SUM(total_amount) as total
      FROM fuel_entries
      GROUP BY month
      ORDER BY month DESC
    ''');
  }

  //---------------- MAINTENANCE ENTRIES ----------------//

  Future<int> insertMaintenanceEntry(Map<String, dynamic> entry) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    entry['created_at'] = now;
    entry['updated_at'] = now;
    return db.insert("maintenance_entries", entry);
  }

  Future<int> updateMaintenanceEntryRecord(int id, Map<String, dynamic> entry) async {
    final db = await database;
    entry['updated_at'] = DateTime.now().toIso8601String();
    return db.update("maintenance_entries", entry, where: "id=?", whereArgs: [id]);
  }

  Future<int> deleteMaintenanceEntryRecord(int id) async {
    final db = await database;
    return db.delete("maintenance_entries", where: "id=?", whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> queryMaintenanceEntry(int id) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT m.*, t.truck_number
      FROM maintenance_entries m
      LEFT JOIN trucks t ON m.truck_id = t.id
      WHERE m.id = ?
    ''', [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> queryMaintenanceEntries({
    int? truckId,
    String? startDate,
    String? endDate,
    String? type,
    String? searchTerm,
  }) async {
    final db = await database;
    String where = "";
    List<dynamic> whereArgs = [];

    if (truckId != null) {
      where = "m.truck_id = ?";
      whereArgs.add(truckId);
    }

    if (startDate != null && endDate != null) {
      if (where.isNotEmpty) where += " AND ";
      where += "m.date BETWEEN ? AND ?";
      whereArgs.addAll([startDate, endDate]);
    }

    if (type != null && type != 'All') {
      if (where.isNotEmpty) where += " AND ";
      where += "m.maintenance_type = ?";
      whereArgs.add(type);
    }

    if (searchTerm != null && searchTerm.isNotEmpty) {
      if (where.isNotEmpty) where += " AND ";
      where += "(t.truck_number LIKE ? OR m.description LIKE ? OR m.service_provider LIKE ? OR m.remarks LIKE ?)";
      whereArgs.addAll(["%$searchTerm%", "%$searchTerm%", "%$searchTerm%", "%$searchTerm%"]);
    }

    final query = '''
      SELECT m.*, t.truck_number
      FROM maintenance_entries m
      LEFT JOIN trucks t ON m.truck_id = t.id
      ${where.isNotEmpty ? "WHERE $where" : ""}
      ORDER BY m.date DESC, m.id DESC
    ''';

    return db.rawQuery(query, whereArgs);
  }

  Future<List<Map<String, dynamic>>> queryMaintenanceSummary() async {
    final db = await database;
    return db.rawQuery('''
      SELECT strftime('%Y-%m', date) as month, SUM(amount) as total
      FROM maintenance_entries
      GROUP BY month
      ORDER BY month DESC
    ''');
  }

  //---------------- EXPENSE ----------------//

  Future<int> addExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return db.insert("expenses", expense);
  }

  Future<int> updateExpense(int id, Map<String, dynamic> expense) async {
    final db = await database;
    return db.update("expenses", expense, where: "id=?", whereArgs: [id]);
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return db.delete("expenses", where: "id=?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return db.rawQuery('''
      SELECT e.*, d.driver_name AS driver_name, t.truck_number AS truck_no
      FROM expenses e
      LEFT JOIN drivers d ON e.driver_id = d.id
      LEFT JOIN trucks t ON e.truck_id = t.id
      ORDER BY e.id DESC
    ''');
  }

  Future<Map<String, double>> getDashboardTotals() async {
    final db = await database;
    final now = DateTime.now();
    final today = _dateString(now);
    final monthStart = _dateString(DateTime(now.year, now.month));
    final nextMonth = _dateString(DateTime(now.year, now.month + 1));

    final todayResult = await db.rawQuery(
      'SELECT COALESCE(SUM(amount),0) total FROM expenses WHERE date=?',
      [today],
    );

    final monthResult = await db.rawQuery(
      'SELECT COALESCE(SUM(amount),0) total FROM expenses WHERE date>=? AND date<?',
      [monthStart, nextMonth],
    );

    return {
      "today": (todayResult.first["total"] as num).toDouble(),
      "month": (monthResult.first["total"] as num).toDouble(),
    };
  }

  String _dateString(DateTime date) {
    final month = date.month.toString().padLeft(2, "0");
    final day = date.day.toString().padLeft(2, "0");
    return "${date.year}-$month-$day";
  }
}
